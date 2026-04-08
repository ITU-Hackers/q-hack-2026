"use client";

import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import type { Profile } from "@/lib/api";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface UserContextValue {
  /** The currently authenticated user, or null if not logged in. */
  user: Profile | null;
  /** True once the initial localStorage read has completed. */
  mounted: boolean;
  /** Persist a user (call after successful login or registration). */
  setUser: (user: Profile) => void;
  /** Clear the user and remove it from localStorage (sign out). */
  logout: () => void;
}

// ---------------------------------------------------------------------------
// Context
// ---------------------------------------------------------------------------

const UserContext = createContext<UserContextValue>({
  user: null,
  mounted: false,
  setUser: () => {},
  logout: () => {},
});

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

const STORAGE_KEY = "picky_user";

export function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUserState] = useState<Profile | null>(null);
  const [mounted, setMounted] = useState(false);

  // Hydrate from localStorage once on mount (client-only).
  useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        setUserState(JSON.parse(raw) as Profile);
      }
    } catch {
      // Corrupted data — ignore and start fresh.
      localStorage.removeItem(STORAGE_KEY);
    } finally {
      setMounted(true);
    }
  }, []);

  function setUser(profile: Profile) {
    setUserState(profile);
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(profile));
    } catch {
      // Storage quota exceeded or private-browsing restriction — carry on.
    }
  }

  function logout() {
    setUserState(null);
    localStorage.removeItem(STORAGE_KEY);
  }

  return (
    <UserContext.Provider value={{ user, mounted, setUser, logout }}>
      {children}
    </UserContext.Provider>
  );
}

// ---------------------------------------------------------------------------
// Hook
// ---------------------------------------------------------------------------

export function useUser(): UserContextValue {
  return useContext(UserContext);
}