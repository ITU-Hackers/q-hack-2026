const API_BASE =
  process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api/v1";

// ── Error handling ────────────────────────────────────────────────────────────

export class ApiError extends Error {
  constructor(
    public readonly status: number,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

async function handleResponse<T>(res: Response): Promise<T> {
  if (res.ok) {
    return res.json() as Promise<T>;
  }
  const text = await res.text().catch(() => res.statusText);
  throw new ApiError(res.status, text);
}

// ── Shared types ──────────────────────────────────────────────────────────────

/** Ingredient preference scores (0–100). */
export interface Preferences {
  fish: number;
  pork: number;
  beef: number;
  dairy: number;
  spicy: number;
}

/** A user profile as returned by the API. */
export interface Profile {
  id: string;
  email: string;
  adults: number;
  kids: number;
  dogs: number;
  cats: number;
  cuisines: string[];
  preferences: Preferences;
  restrictions: string[];
  health_goal: string;
  cooking_time: string;
  budget: string;
}

// ── Profile types ─────────────────────────────────────────────────────────────

/** Request body for creating a new profile. */
export interface CreateProfilePayload {
  email: string;
  password: string;
  adults?: number;
  kids?: number;
  dogs?: number;
  cats?: number;
  cuisines?: string[];
  preferences?: Preferences;
  restrictions?: string[];
  health_goal?: string;
  cooking_time?: string;
  budget?: string;
}

/** Request body for updating an existing profile (all fields optional). */
export interface UpdateProfilePayload {
  email?: string;
  password?: string;
  adults?: number;
  kids?: number;
  dogs?: number;
  cats?: number;
  cuisines?: string[];
  preferences?: Preferences;
  restrictions?: string[];
  health_goal?: string;
  cooking_time?: string;
  budget?: string;
}

// ── Recipe types ──────────────────────────────────────────────────────────────

export interface RecipeIngredient {
  id: number;
  name: string;
  emoji: string;
  category: string;
  default_unit: string;
  default_price: number;
}

export interface Recipe {
  id: number;
  region: string;
  dish: string;
  emoji: string;
  ingredients: RecipeIngredient[];
}

// ── Recommendation types ──────────────────────────────────────────────────────

export interface RecommendedMeal {
  id: string;
  dish: string;
  region: string;
  ingredients: string[];
  score: number;
}

export interface RecommendResponse {
  meals: RecommendedMeal[];
}

// ── Chat types ────────────────────────────────────────────────────────────────

export type ChatEventType = "message" | "error" | "done";

export interface ChatEvent {
  type: ChatEventType;
  data: string;
}

// ── Profile endpoints ─────────────────────────────────────────────────────────

/**
 * Create a new profile (registration / onboarding completion).
 *
 * Throws ApiError with status 409 if the email is already taken.
 */
export async function createProfile(
  payload: CreateProfilePayload,
): Promise<Profile> {
  const res = await fetch(`${API_BASE}/profile/create`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  return handleResponse<Profile>(res);
}

/**
 * Get a profile by ID.
 *
 * Throws ApiError with status 404 if no profile exists for that ID.
 */
export async function getProfile(id: string): Promise<Profile> {
  const res = await fetch(`${API_BASE}/profile/${encodeURIComponent(id)}`);
  return handleResponse<Profile>(res);
}

/**
 * Update an existing profile. Only provided fields are changed.
 *
 * Throws ApiError with status 404 if no profile exists for that ID.
 */
export async function updateProfile(
  id: string,
  payload: UpdateProfilePayload,
): Promise<Profile> {
  const res = await fetch(`${API_BASE}/profile/${encodeURIComponent(id)}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  return handleResponse<Profile>(res);
}

/**
 * Login with email and password.
 *
 * Throws ApiError with status 401 if the password is wrong.
 * Throws ApiError with status 404 if no profile exists for that email.
 */
export async function loginProfile(
  email: string,
  password: string,
): Promise<Profile> {
  const res = await fetch(`${API_BASE}/profile/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  return handleResponse<Profile>(res);
}

// ── Recipe endpoints ──────────────────────────────────────────────────────────

/**
 * List all recipes with their resolved ingredients.
 * Optionally filter by region (e.g. "Italian", "Asian").
 *
 * Returns an empty array if the backend is unreachable.
 */
export async function fetchRecipes(region?: string): Promise<Recipe[]> {
  const params = region ? `?region=${encodeURIComponent(region)}` : "";
  try {
    const res = await fetch(`${API_BASE}/recipes${params}`);
    return await handleResponse<Recipe[]>(res);
  } catch {
    console.warn("Could not reach the recipe API — is the backend running?");
    return [];
  }
}

// ── Recommendation endpoints ──────────────────────────────────────────────────

/**
 * Get personalised meal recommendations for a profile.
 *
 * Uses the two-tower ONNX model + Qdrant ANN search on the backend.
 *
 * @param profileId - The profile's UUID.
 * @param topK      - Number of meals to return (default: 5).
 *
 * Throws ApiError with status 404 if no profile exists for that ID.
 * Throws ApiError with status 503 if the ONNX model is not yet loaded.
 */
export async function fetchRecommendations(
  profileId: string,
  topK = 5,
): Promise<RecommendResponse> {
  const params = `?top_k=${topK}`;
  const res = await fetch(
    `${API_BASE}/recommend/${encodeURIComponent(profileId)}${params}`,
  );
  return handleResponse<RecommendResponse>(res);
}

// ── Chat / SSE endpoint ───────────────────────────────────────────────────────

/**
 * Stream a chat message to the AI agent via Server-Sent Events.
 *
 * The returned `EventSource`-compatible stream emits three event types:
 *   - `message` — a text chunk from the agent's response
 *   - `error`   — an error occurred during generation
 *   - `done`    — the stream has completed (data will be `[DONE]`)
 *
 * @param message  - The message to send to the agent.
 * @param onEvent  - Callback invoked for each SSE event.
 * @param signal   - Optional AbortSignal to cancel the stream.
 */
export async function streamChat(
  message: string,
  onEvent: (event: ChatEvent) => void,
  signal?: AbortSignal,
): Promise<void> {
  const res = await fetch(`${API_BASE}/chat`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "text/event-stream",
    },
    body: JSON.stringify({ message }),
    signal,
  });

  if (!res.ok) {
    const text = await res.text().catch(() => res.statusText);
    throw new ApiError(res.status, text);
  }

  if (!res.body) {
    throw new ApiError(500, "Response body is null — SSE stream unavailable");
  }

  const reader = res.body.getReader();
  const decoder = new TextDecoder();
  let buffer = "";

  while (true) {
    const { value, done } = await reader.read();
    if (done) break;

    buffer += decoder.decode(value, { stream: true });
    const lines = buffer.split("\n");
    // Keep the last (potentially incomplete) line in the buffer.
    buffer = lines.pop() ?? "";

    let eventType: ChatEventType = "message";
    let dataLine = "";

    for (const line of lines) {
      if (line.startsWith("event:")) {
        const raw = line.slice("event:".length).trim();
        if (raw === "message" || raw === "error" || raw === "done") {
          eventType = raw;
        }
      } else if (line.startsWith("data:")) {
        dataLine = line.slice("data:".length).trim();
      } else if (line === "") {
        // Blank line → dispatch the accumulated event.
        if (dataLine !== "") {
          onEvent({ type: eventType, data: dataLine });
        }
        // Reset for the next event.
        eventType = "message";
        dataLine = "";
      }
    }
  }
}
