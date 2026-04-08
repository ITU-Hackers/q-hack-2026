const API_BASE =
  process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api/v1";

export interface ProfilePreferences {
  fish: number;
  pork: number;
  beef: number;
  dairy: number;
  spicy: number;
}

export interface Profile {
  id: string;
  email: string;
  adults: number;
  kids: number;
  dogs: number;
  cats: number;
  cuisines: string[];
  preferences: ProfilePreferences;
  restrictions: string[];
  health_goal: string;
  cooking_time: string;
  budget: string;
}

export interface CreateProfilePayload {
  email: string;
  password: string;
  adults: number;
  kids: number;
  dogs: number;
  cats: number;
  cuisines: string[];
  preferences: ProfilePreferences;
  restrictions: string[];
  health_goal: string;
  cooking_time: string;
  budget: string;
}

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
