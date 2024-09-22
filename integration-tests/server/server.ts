import { startTestServer } from "@tui-sandbox/library/src/server/server"
import type { TestServerConfig } from "@tui-sandbox/library/src/server/updateTestdirectorySchemaFile"
import { updateTestdirectorySchemaFile } from "@tui-sandbox/library/src/server/updateTestdirectorySchemaFile"
import path from "node:path"
import { fileURLToPath } from "node:url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const config: TestServerConfig = {
  testEnvironmentPath: path.join(__dirname, "..", "test-environment/"),
  outputFilePath: path.join(__dirname, "..", "MyTestDirectory.ts"),
}

console.log(
  `Starting test server with config ${JSON.stringify(config, null, 2)}`,
)

await updateTestdirectorySchemaFile(config)
await startTestServer(config)
