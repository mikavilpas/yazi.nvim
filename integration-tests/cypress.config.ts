import { defineConfig } from "cypress"
import { readFile, rm } from "fs/promises"
import path from "path"
import { fileURLToPath } from "url"

const __dirname = fileURLToPath(new URL(".", import.meta.resolve(".")))

// const file = "./test-environment/.repro/state/nvim/yazi.log"
const yaziLogFile = path.join(
  __dirname,
  "test-environment",
  ".repro",
  "state",
  "nvim",
  "yazi.log",
)

console.log(`yaziLogFile: ${yaziLogFile}`)

export default defineConfig({
  e2e: {
    baseUrl: "http://localhost:3000",
    setupNodeEvents(on, _config) {
      on("task", {
        async removeYaziLog(): Promise<null> {
          try {
            await rm(yaziLogFile)
          } catch (err) {
            if (err.code !== "ENOENT") {
              console.error(err)
            }
          }
          return null // something must be returned
        },
        async showYaziLog(): Promise<null> {
          try {
            const log = await readFile(yaziLogFile, "utf-8")
            console.log(`${yaziLogFile}`, log.split("\n"))
            return null
          } catch (err) {
            console.error(err)
            return null // something must be returned
          }
        },
      })
    },
    experimentalRunAllSpecs: true,
    retries: {
      runMode: 2,
      openMode: 0,
    },
  },
})
