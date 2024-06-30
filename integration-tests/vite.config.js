import { defineConfig } from "vite"

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    host: "127.0.0.1",
    https: false,
    strictPort: true,
  }, // Not needed for Vite 5+ (simply omit this option)
  plugins: [],
})
