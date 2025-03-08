import { defineConfig } from "cypress"
import fs from "fs"
import { readFile, rm } from "fs/promises"
import path from "path"
import { fileURLToPath } from "url"

const __dirname = fileURLToPath(new URL(".", import.meta.resolve(".")))

const yaziLogFile = path.join(
  __dirname,
  "test-environment",
  ".repro",
  "yazi.log",
)

console.log(`yaziLogFile: ${yaziLogFile}`)

export default defineConfig({
  e2e: {
    baseUrl: "http://localhost:3000",
    video: true,
    setupNodeEvents(on, _config) {
      on("after:spec", (_spec, results): void => {
        // https://docs.cypress.io/app/guides/screenshots-and-videos#Delete-videos-for-specs-without-failing-or-retried-tests
        if (results && results.video) {
          // Do we have failures for any retry attempts?
          const failures = results.tests.some((test) => {
            return test.attempts.some((attempt) => attempt.state === "failed")
          })
          if (!failures && fs.existsSync(results.video)) {
            // delete the video if the spec passed and no tests retried
            return fs.unlinkSync(results.video)
          }
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
    experimentalRunAllSpecs: true,
    retries: {
      runMode: 2,
      openMode: 0,
    },
  },
})
