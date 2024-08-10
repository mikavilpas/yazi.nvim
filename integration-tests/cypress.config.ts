import { defineConfig } from "cypress"
import { mkdir, readdir, readFile, rm } from "fs/promises"
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

const testEnvironmentDir = path.join(__dirname, "test-environment")
const testdirs = path.join(testEnvironmentDir, "testdirs")

export default defineConfig({
  e2e: {
    setupNodeEvents(on, _config) {
      on("after:browser:launch", async (): Promise<void> => {
        // delete everything under the ./test-environment/testdirs/ directory
        await mkdir(testdirs, { recursive: true })
        const files = await readdir(testdirs)

        console.log("Cleaning up testdirs directory...")

        for (const file of files) {
          const testdir = path.join(testdirs, file)
          console.log(`Removing ${testdir}`)
          await rm(testdir, { recursive: true })
        }
      })

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
    retries: {
      runMode: 2,
      openMode: 0,
    },
  },
})
