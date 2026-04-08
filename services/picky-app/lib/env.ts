import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

const penv = process.env;

export const env = createEnv({
  // Used for docker builds, since docker does not load
  // environment variables during build (only at runtime).
  skipValidation: !!penv.SKIP_ENV_VALIDATION,
  runtimeEnv: {
    NODE_ENV: penv.NODE_ENV,
    NEXT_PUBLIC_API_URL: penv.NEXT_PUBLIC_API_URL,
  },
  server: {
    NODE_ENV: z.enum(["production", "development", "test"]),
  },
  client: {
    NEXT_PUBLIC_API_URL: z.url(),
  },
});
