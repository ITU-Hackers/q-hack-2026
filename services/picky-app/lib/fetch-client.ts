/**
 * Custom Orval fetch mutator for picky-api.
 *
 * Orval's generated `fetch` client calls this function for every operation.
 * The generated code already:
 *   - builds the path + query string (e.g. `/predict?foo=bar`)
 *   - sets `method`, `Content-Type`, and JSON-stringifies the body
 *
 * All we need to do here is:
 *   1. Prepend the runtime base URL
 *   2. Execute the request
 *   3. Handle errors and empty responses uniformly
 *
 * Callers can pass any extra `RequestInit` fields (including Next.js-specific
 * `{ next: { revalidate: 60 } }` or `{ cache: 'no-store' }`) as the second
 * argument; they are spread over the options object before the fetch call.
 */

import { env } from "@/lib/env";

const BASE_URL = env.NEXT_PUBLIC_API_URL;

/** Shape of an API error thrown by this mutator. */
export interface ApiError {
  status: number;
  body: unknown;
}

export const fetchClient = async <T>(
  url: string,
  options?: RequestInit,
): Promise<T> => {
  const response = await fetch(`${BASE_URL}${url}`, options);

  if (!response.ok) {
    let body: unknown;
    try {
      body = await response.json();
    } catch {
      body = await response.text();
    }
    const error: ApiError = { status: response.status, body };
    throw error;
  }

  if (
    response.status === 204 ||
    response.headers.get("content-length") === "0"
  ) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
};
