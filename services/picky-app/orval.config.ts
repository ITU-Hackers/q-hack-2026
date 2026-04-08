import { defineConfig } from "orval";

export default defineConfig({
  "picky-api": {
    input: {
      target: "http://localhost:3001/api/openapi.json",
    },
    output: {
      mode: "tags-split",
      target: "./lib/api",
      client: "fetch",
      override: {
        mutator: {
          path: "./lib/fetch-client.ts",
          name: "fetchClient",
        },
      },
      clean: true,
    },
  },
});