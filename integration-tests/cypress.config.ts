import assert from "assert"
import { execSync, Serializable } from "child_process"
import { defineConfig } from "cypress"
import { constants } from "fs"
import { access, mkdir, mkdtemp, readdir, readFile, rm } from "fs/promises"
import path from "path"
import { fileURLToPath } from "url"
import type { TestDirectory } from "./client/testEnvironmentTypes"

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
        async removeYaziLog() {
          try {
            await rm(yaziLogFile)
          } catch (err) {
            if (err.code !== "ENOENT") {
              console.error(err)
            }
          }
          return null // something must be returned
        },
        async showYaziLog() {
          try {
            const log = await readFile(yaziLogFile, "utf-8")
            console.log(`${yaziLogFile}`, log.split("\n"))
            return null
          } catch (err) {
            console.error(err)
            return null // something must be returned
          }
        },
        async createTempDir(): Promise<TestDirectory> {
          try {
            const dir = await createUniqueDirectory()

            const directory: TestDirectory = {
              rootPathAbsolute: dir,
              rootPathRelativeToTestEnvironmentDir: path.relative(
                testEnvironmentDir,
                dir,
              ),
              contents: {
                "initial-file.txt": {
                  name: "initial-file.txt",
                  stem: "initial-file",
                  extension: ".txt",
                },
                "test.lua": {
                  name: "test.lua",
                  stem: "test",
                  extension: ".lua",
                },
                "file.txt": {
                  name: "file.txt",
                  stem: "file",
                  extension: ".txt",
                },
                "subdirectory/subdirectory-file.txt": {
                  name: "subdirectory-file.txt",
                  stem: "subdirectory-file",
                  extension: ".txt",
                },
                ["other-subdirectory/other-sub-file.txt"]: {
                  name: "other-sub-file.txt",
                  stem: "other-sub-file",
                  extension: ".txt",
                },
                "modify_yazi_config_to_use_ya_as_event_reader.lua": {
                  name: "modify_yazi_config_to_use_ya_as_event_reader.lua",
                  stem: "modify_yazi_config_to_use_ya_as_event_reader",
                  extension: ".lua",
                },
                "routes/posts.$postId/adjacent-file.txt": {
                  name: "adjacent-file.txt",
                  stem: "adjacent-file",
                  extension: ".txt",
                },
                "routes/posts.$postId/route.tsx": {
                  name: "route.tsx",
                  stem: "route",
                  extension: ".tsx",
                },
              },
            }
            directory satisfies Serializable // required by cypress

            execSync(`cp ./test-environment/initial-file.txt ${dir}/`)
            execSync(`cp ./test-environment/file.txt ${dir}/`)
            execSync(`cp ./test-environment/test-setup.lua ${dir}/test.lua`)
            execSync(`cp -r ./test-environment/subdirectory ${dir}/`)
            execSync(`cp -r ./test-environment/other-subdirectory ${dir}/`)
            execSync(`cp -r ./test-environment/config-modifications/ ${dir}/`)
            execSync(`cp -r ./test-environment/routes ${dir}/`)
            console.log(`Created test directory at ${dir}`)

            return directory
          } catch (err) {
            console.error(err)
            throw err
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

async function createUniqueDirectory(): Promise<string> {
  const __dirname = fileURLToPath(new URL(".", import.meta.resolve(".")))
  const testdirs = path.join(__dirname, "test-environment", "testdirs")
  try {
    await access(testdirs, constants.F_OK)
  } catch {
    await mkdir(testdirs)
  }
  const dir = await mkdtemp(path.join(testdirs, "dir-"))
  assert(typeof dir === "string")

  return dir
}
