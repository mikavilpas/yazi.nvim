import { Server } from "socket.io"
import { TerminalApplication } from "./TerminalApplication.ts"

import express from "express"
import assert from "node:assert"
import { createServer } from "node:http"
import path from "node:path"
import { fileURLToPath } from "url"
import type { StartNeovimServerArguments } from "../client/testEnvironmentTypes"

const __dirname = fileURLToPath(new URL(".", import.meta.url))
const testDirectory = path.join(__dirname, "..", "test-environment/")

export type StdinMessage = "stdin"
export type StdoutMessage = "stdout"
export type StartNeovimMessage = "startNeovim"

const expressApp = express()
const server = createServer(expressApp)
const connections: Map<string, TerminalApplication> = new Map()

const io = new Server(server, {
  cors: {
    origin: (requestOrigin, callback): void => {
      if (
        requestOrigin == "http://localhost:5173" ||
        requestOrigin == "http://localhost:5174"
      ) {
        callback(null, requestOrigin)
      } else {
        callback(new Error("Not allowed by CORS"))
      }
    },
  },
})

io.on("connection", function connection(socket) {
  const peerId = socket.id

  socket.on(
    "startNeovim" satisfies StartNeovimMessage,
    function (startArgs: StartNeovimServerArguments) {
      const args = ["-u", "test-setup.lua"]
      if (startArgs.startupScriptModifications) {
        for (const modification of startArgs.startupScriptModifications) {
          switch (modification) {
            // execute a lua script after startup, allowing the tests to modify
            // the base config without overriding all of it
            case "modify_yazi_config_to_use_ya_as_event_reader.lua":
              const file = path.join(
                testDirectory,
                "config-modifications",
                "modify_yazi_config_to_use_ya_as_event_reader.lua",
              )
              args.push("-c", `lua dofile('${file}')`)
              break
            default:
              modification satisfies never
              throw new Error(
                `unexpected startup script modification: ${String(modification)}`,
              )
          }
        }
      }
      if (startArgs.filename) {
        const file = path.join(startArgs.directory, startArgs.filename)
        args.push(file)
      }

      const app = TerminalApplication.start({
        command: "nvim",
        args: args,

        cwd: testDirectory,
        env: process.env,

        onStdoutOrStderr(data: string) {
          void socket
            .timeout(500)
            .emitWithAck("stdout" satisfies StdoutMessage, data)
            .catch((e: unknown) => {
              app.logger.debug(
                `I sent stdout to the client, but did not get an acknowledgement back in 500ms 🤔: `,
                e,
              )
            })
        },
      })
      connections.set(peerId, app)

      socket.on("disconnect", async (_reason) => {
        await app.waitUntilCleanedUp()
      })

      void app.finishedPromise.promise.then(() => {
        app.logger.info(`TerminalApplication ${peerId} finished`)
        connections.delete(peerId)
      })

      socket.on("stdin" satisfies StdinMessage, function (data) {
        assert(typeof data === "string", "stdin message must be a string")
        app.write(data)
      })
    },
  )
})

process.on("SIGINT", () => {
  console.log("Received SIGINT. Cleaning up...")
  async function cleanup() {
    for (const app of connections.values()) {
      await app.waitUntilCleanedUp()
    }
    process.exit(0)
  }

  void cleanup()
})

server.listen(3000, () => {
  console.log("server running at http://localhost:3000")
})
