import assert from "assert"
import { execSync } from "child_process"
import { constants } from "fs"
import { access, mkdir, mkdtemp } from "fs/promises"
import path from "path"
import { NeovimTestDirectory } from "./NeovimTestEnvironment"
import type { TestDirectory } from "./testEnvironmentTypes"

export async function createTempDir(): Promise<TestDirectory> {
  try {
    const dir = await createUniqueDirectory()

    const directory: TestDirectory = {
      rootPathAbsolute: dir,
      rootPathRelativeToTestEnvironmentDir: path.relative(
        NeovimTestDirectory.testEnvironmentDir,
        dir,
      ),
      contents: {
        "initial-file.txt": {
          name: "initial-file.txt",
          stem: "initial-file",
          extension: ".txt",
        },
        "dir with spaces/file1.txt": {
          name: "file1.txt",
          stem: "file1",
          extension: ".txt",
        },
        "dir with spaces/file2.txt": {
          name: "file2.txt",
          stem: "file2",
          extension: ".txt",
        },
        "test-setup.lua": {
          name: "test-setup.lua",
          stem: "test-setup",
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
        "routes/posts.$postId/should-be-excluded-file.txt": {
          name: "should-be-excluded-file.txt",
          stem: "should-be-excluded-file",
          extension: ".txt",
        },
      },
    }

    execSync(`cp ./test-environment/initial-file.txt ${dir}/`)
    execSync(`cp ./test-environment/file.txt ${dir}/`)
    execSync(`cp ./test-environment/test-setup.lua ${dir}/test-setup.lua`)
    execSync(`cp -r "./test-environment/dir with spaces" ${dir}/`)
    execSync(`cp -r ./test-environment/subdirectory ${dir}/`)
    execSync(`cp -r ./test-environment/other-subdirectory ${dir}/`)
    execSync(`cp -r ./test-environment/config-modifications ${dir}/`)
    execSync(`cp -r ./test-environment/routes ${dir}/`)
    console.log(`Created test directory at ${dir}`)

    return directory
  } catch (err) {
    console.error(err)
    throw err
  }
}

async function createUniqueDirectory(): Promise<string> {
  const testdirs = path.join(NeovimTestDirectory.testEnvironmentDir, "testdirs")
  try {
    await access(testdirs, constants.F_OK)
  } catch {
    await mkdir(testdirs)
  }
  const dir = await mkdtemp(path.join(testdirs, "dir-"))
  assert(typeof dir === "string")

  return dir
}
