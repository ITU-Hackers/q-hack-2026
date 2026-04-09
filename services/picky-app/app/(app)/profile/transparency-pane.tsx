"use client";

import { useState, useEffect } from "react";
import {
  IconFlag,
  IconCheck,
  IconArrowUp,
  IconArrowDown,
  IconSparkles,
  IconHistory,
  IconBrain,
} from "@tabler/icons-react";
import { Button } from "@workspace/ui/components/button";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@workspace/ui/components/card";
import { Badge } from "@workspace/ui/components/badge";
import { Separator } from "@workspace/ui/components/separator";
import { Textarea } from "@workspace/ui/components/textarea";
import {
  Progress,
  ProgressTrack,
  ProgressIndicator,
  ProgressLabel,
  ProgressValue,
} from "@workspace/ui/components/progress";
import type { Profile } from "@/lib/api";

// ─── Types ────────────────────────────────────────────────────────────────────

interface CorrectionEntry {
  id: string;
  dimension: string;
  label: string;
  currentValue: string;
  note: string;
  timestamp: number;
}

interface AffinityDelta {
  key: keyof AffinityState;
  label: string;
  emoji: string;
  oldVal: number;
  newVal: number;
}

interface ProfileDelta {
  key: string;
  label: string;
  oldVal: string;
  newVal: string;
}

interface SimulationResult {
  affinityDeltas: AffinityDelta[];
  profileDeltas: ProfileDelta[];
  newRestrictions: string[];
}

interface AffinityState {
  fish: number;
  pork: number;
  beef: number;
  dairy: number;
  spicy: number;
}

// ─── Habit Simulation Rules ───────────────────────────────────────────────────

type HabitRule = {
  keywords: string[];
  delta?: Partial<AffinityState>;
  restrictions?: string[];
  profile?: Partial<{ budget: string; cooking_time: string; health_goal: string }>;
};

const HABIT_RULES: HabitRule[] = [
  {
    keywords: ["bulk", "protein", "muscle", "gym", "gains", "lift", "lifting"],
    delta: { beef: 25, fish: 20 },
    profile: { health_goal: "high-protein" },
  },
  {
    keywords: ["healthy", "clean eating", "whole foods", "balanced", "diet", "nutrition"],
    delta: { spicy: -15, dairy: -10 },
  },
  {
    keywords: ["peanut", "no peanuts", "peanut allergy"],
    restrictions: ["nut-allergy"],
  },
  {
    keywords: ["vegetarian", "vegan", "no meat", "plant based", "plant-based"],
    delta: { beef: -80, pork: -80, fish: -80 },
  },
  {
    keywords: ["dairy free", "dairy-free", "lactose", "no dairy", "no milk"],
    delta: { dairy: -80 },
  },
  {
    keywords: ["spicy", "hot food", "chili", "hot sauce", "spice"],
    delta: { spicy: 30 },
  },
  {
    keywords: ["budget", "cheap", "saving", "economical", "frugal"],
    profile: { budget: "budget" },
  },
  {
    keywords: ["quick", "fast", "no time", "easy meals", "simple"],
    profile: { cooking_time: "quick" },
  },
  {
    keywords: ["mediterranean"],
    profile: { health_goal: "mediterranean" },
  },
  {
    keywords: ["high protein", "high-protein"],
    profile: { health_goal: "high-protein" },
  },
  {
    keywords: ["fish", "seafood", "salmon", "tuna"],
    delta: { fish: 25 },
  },
  {
    keywords: ["no fish", "no seafood", "hate fish"],
    delta: { fish: -40 },
  },
];

function clamp(value: number): number {
  return Math.max(0, Math.min(100, Math.round(value)));
}

function simulate(
  text: string,
  currentAffinity: AffinityState,
  currentProfile: { budget: string; cooking_time: string; health_goal: string },
  currentRestrictions: string[],
): SimulationResult {
  const lower = text.toLowerCase();
  const affinityAccum: Partial<AffinityState> = {};
  const profileAccum: Partial<{ budget: string; cooking_time: string; health_goal: string }> = {};
  const newRestrictions: string[] = [];

  for (const rule of HABIT_RULES) {
    const matched = rule.keywords.some((kw) => lower.includes(kw));
    if (!matched) continue;

    if (rule.delta) {
      for (const [k, v] of Object.entries(rule.delta)) {
        const key = k as keyof AffinityState;
        affinityAccum[key] = (affinityAccum[key] ?? 0) + v;
      }
    }
    if (rule.profile) {
      Object.assign(profileAccum, rule.profile);
    }
    if (rule.restrictions) {
      for (const r of rule.restrictions) {
        if (!currentRestrictions.includes(r) && !newRestrictions.includes(r)) {
          newRestrictions.push(r);
        }
      }
    }
  }

  const AFFINITY_META: { key: keyof AffinityState; label: string; emoji: string }[] = [
    { key: "fish", label: "Fish", emoji: "🐟" },
    { key: "pork", label: "Pork", emoji: "🐷" },
    { key: "beef", label: "Beef", emoji: "🥩" },
    { key: "dairy", label: "Dairy", emoji: "🥛" },
    { key: "spicy", label: "Spicy", emoji: "🌶️" },
  ];

  const affinityDeltas: AffinityDelta[] = [];
  for (const meta of AFFINITY_META) {
    const change = affinityAccum[meta.key];
    if (change !== undefined && change !== 0) {
      const oldVal = currentAffinity[meta.key];
      const newVal = clamp(oldVal + change);
      if (newVal !== oldVal) {
        affinityDeltas.push({ ...meta, oldVal, newVal });
      }
    }
  }

  const PROFILE_LABELS: Record<string, Record<string, string>> = {
    budget: { budget: "Budget", moderate: "Moderate", flexible: "Flexible" },
    cooking_time: { quick: "Quick", moderate: "Moderate", enthusiast: "Enthusiast" },
    health_goal: { balanced: "Balanced", mediterranean: "Mediterranean", "high-protein": "High Protein" },
  };

  const profileDeltas: ProfileDelta[] = [];
  for (const [k, newVal] of Object.entries(profileAccum)) {
    const oldVal = currentProfile[k as keyof typeof currentProfile];
    if (newVal !== oldVal) {
      const labelMap = PROFILE_LABELS[k] ?? {};
      profileDeltas.push({
        key: k,
        label: k === "budget" ? "Budget" : k === "cooking_time" ? "Cooking time" : "Health goal",
        oldVal: labelMap[oldVal] ?? oldVal,
        newVal: labelMap[newVal] ?? newVal,
      });
    }
  }

  return { affinityDeltas, profileDeltas, newRestrictions };
}

// ─── Affinity Bar ─────────────────────────────────────────────────────────────

const AFFINITY_META = [
  { key: "fish" as const, label: "Fish", emoji: "🐟" },
  { key: "pork" as const, label: "Pork", emoji: "🐷" },
  { key: "beef" as const, label: "Beef", emoji: "🥩" },
  { key: "dairy" as const, label: "Dairy", emoji: "🥛" },
  { key: "spicy" as const, label: "Spicy", emoji: "🌶️" },
];

function AffinityBar({ value, highlight }: { value: number; highlight?: "up" | "down" }) {
  return (
    <Progress value={value} className="gap-0">
      <ProgressTrack className="h-2">
        <ProgressIndicator
          className={
            highlight === "up"
              ? "bg-green-500 transition-all duration-700"
              : highlight === "down"
                ? "bg-red-400 transition-all duration-700"
                : "transition-all duration-700"
          }
        />
      </ProgressTrack>
    </Progress>
  );
}

// ─── Inline Flag Form ─────────────────────────────────────────────────────────

function InlineFlagForm({
  dimension,
  label,
  currentValue,
  onSubmit,
  onCancel,
}: {
  dimension: string;
  label: string;
  currentValue: string;
  onSubmit: (note: string) => void;
  onCancel: () => void;
}) {
  const [note, setNote] = useState("");
  return (
    <div className="mt-2 rounded-lg border border-destructive/30 bg-destructive/5 p-3 flex flex-col gap-2">
      <p className="text-xs text-muted-foreground">
        Flagging: <span className="font-medium text-foreground">{label}</span>{" "}
        <span className="text-muted-foreground">({currentValue})</span>
      </p>
      <Textarea
        placeholder="Why is this wrong? (optional)"
        value={note}
        onChange={(e) => setNote(e.target.value)}
        className="text-sm min-h-12"
      />
      <div className="flex gap-2 justify-end">
        <Button variant="ghost" size="sm" onClick={onCancel}>
          Cancel
        </Button>
        <Button
          variant="destructive"
          size="sm"
          onClick={() => onSubmit(note)}
        >
          Submit correction
        </Button>
      </div>
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

const CORRECTIONS_KEY = "picky_corrections";

// Hardcoded demo values so the pane always looks populated and realistic.
// These overlay the real profile only for display inside this component.
const DEMO_PREFERENCES = { fish: 72, pork: 41, beef: 88, dairy: 63, spicy: 34 };
const DEMO_BUDGET = "moderate";
const DEMO_HEALTH_GOAL = "high-protein";
const DEMO_COOKING_TIME = "quick";
const DEMO_RESTRICTIONS = ["gluten-free"];

export function TransparencyPane({ user }: { user: Profile }) {
  const [activeFlag, setActiveFlag] = useState<string | null>(null);
  const [submitted, setSubmitted] = useState<string | null>(null);
  const [habitText, setHabitText] = useState("");
  const [simulationResult, setSimulationResult] = useState<SimulationResult | null>(null);
  const [corrections, setCorrections] = useState<CorrectionEntry[]>([]);

  // Hydrate corrections from localStorage
  useEffect(() => {
    try {
      const raw = localStorage.getItem(CORRECTIONS_KEY);
      if (raw) setCorrections(JSON.parse(raw) as CorrectionEntry[]);
    } catch {
      // ignore
    }
  }, []);

  function persistCorrections(list: CorrectionEntry[]) {
    setCorrections(list);
    try {
      localStorage.setItem(CORRECTIONS_KEY, JSON.stringify(list));
    } catch {
      // ignore
    }
  }

  function handleFlagSubmit(dimension: string, label: string, currentValue: string, note: string) {
    const entry: CorrectionEntry = {
      id: `${Date.now()}-${Math.random()}`,
      dimension,
      label,
      currentValue,
      note,
      timestamp: Date.now(),
    };
    persistCorrections([entry, ...corrections]);
    setActiveFlag(null);
    setSubmitted(dimension);
    setTimeout(() => setSubmitted(null), 2000);
  }

  function handleSimulate() {
    const result = simulate(
      habitText,
      DEMO_PREFERENCES,
      { budget: DEMO_BUDGET, cooking_time: DEMO_COOKING_TIME, health_goal: DEMO_HEALTH_GOAL },
      DEMO_RESTRICTIONS,
    );
    setSimulationResult(result);
  }

  const hasSimulationOutput =
    simulationResult &&
    (simulationResult.affinityDeltas.length > 0 ||
      simulationResult.profileDeltas.length > 0 ||
      simulationResult.newRestrictions.length > 0);

  function formatTimestamp(ts: number): string {
    const d = new Date(ts);
    const now = new Date();
    const diffMs = now.getTime() - ts;
    const diffMin = Math.floor(diffMs / 60000);
    if (diffMin < 1) return "Just now";
    if (diffMin < 60) return `${diffMin}m ago`;
    if (d.toDateString() === now.toDateString()) return "Today";
    return d.toLocaleDateString();
  }

  function capitalize(s: string) {
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  // Build simulated affinity values for display
  const simulatedAffinity: AffinityState | null = simulationResult && hasSimulationOutput
    ? (() => {
        const next = { ...DEMO_PREFERENCES };
        for (const d of simulationResult.affinityDeltas) {
          next[d.key] = d.newVal;
        }
        return next;
      })()
    : null;

  return (
    <div className="flex flex-col gap-4">
      {/* ── Card 1: How Picky Knows You ─────────────────────────────────── */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <IconBrain className="size-4 text-primary" />
            How Picky Knows You
          </CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-4 text-sm">
          {/* Food Affinities */}
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Food Affinities
          </p>
          <div className="flex flex-col gap-3">
            {AFFINITY_META.map(({ key, label, emoji }) => {
              const raw = DEMO_PREFERENCES[key];
              const simVal = simulatedAffinity?.[key];
              const displayVal = simVal ?? raw;
              const highlight =
                simVal !== undefined
                  ? simVal > raw
                    ? "up"
                    : simVal < raw
                      ? "down"
                      : undefined
                  : undefined;

              const flagId = `affinity-${key}`;
              const isActive = activeFlag === flagId;
              const isSubmitted = submitted === flagId;

              return (
                <div key={key} className="flex flex-col gap-1">
                  <div className="flex items-center justify-between">
                    <span className="flex items-center gap-1.5">
                      <span>{emoji}</span>
                      <span>{label}</span>
                    </span>
                    <div className="flex items-center gap-2">
                      <span className="tabular-nums text-muted-foreground text-xs">
                        {displayVal}%
                        {simVal !== undefined && simVal !== raw && (
                          <span
                            className={
                              simVal > raw ? "text-green-500 ml-1" : "text-red-400 ml-1"
                            }
                          >
                            {simVal > raw ? (
                              <IconArrowUp className="inline size-3" />
                            ) : (
                              <IconArrowDown className="inline size-3" />
                            )}
                            {Math.abs(simVal - raw)}
                          </span>
                        )}
                      </span>
                      {isSubmitted ? (
                        <span className="text-green-500">
                          <IconCheck className="size-4" />
                        </span>
                      ) : (
                        <Button
                          variant="ghost"
                          size="icon-sm"
                          className="text-muted-foreground hover:text-destructive"
                          onClick={() => setActiveFlag(isActive ? null : flagId)}
                          title="Flag inaccuracy"
                        >
                          <IconFlag className="size-3.5" />
                        </Button>
                      )}
                    </div>
                  </div>
                  <AffinityBar value={displayVal} highlight={highlight} />
                  {isActive && (
                    <InlineFlagForm
                      dimension={flagId}
                      label={label}
                      currentValue={`${raw}%`}
                      onSubmit={(note) =>
                        handleFlagSubmit(flagId, label, `${raw}%`, note)
                      }
                      onCancel={() => setActiveFlag(null)}
                    />
                  )}
                </div>
              );
            })}
          </div>

          <Separator />

          {/* Profile Signals */}
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Profile Signals
          </p>
          <div className="flex flex-col gap-3">
            {[
              {
                id: "signal-budget",
                label: "Budget",
                value: capitalize(DEMO_BUDGET),
              },
              {
                id: "signal-goal",
                label: "Health goal",
                value: capitalize(DEMO_HEALTH_GOAL.replace("-", " ")),
              },
              {
                id: "signal-cooking",
                label: "Cooking time",
                value: capitalize(DEMO_COOKING_TIME),
              },
            ].map(({ id, label, value }) => {
              const isActive = activeFlag === id;
              const isSubmitted = submitted === id;
              return (
                <div key={id} className="flex flex-col gap-1">
                  <div className="flex items-center justify-between">
                    <span className="text-muted-foreground">{label}</span>
                    <div className="flex items-center gap-2">
                      <Badge variant="secondary">{value}</Badge>
                      {isSubmitted ? (
                        <span className="text-green-500">
                          <IconCheck className="size-4" />
                        </span>
                      ) : (
                        <Button
                          variant="ghost"
                          size="icon-sm"
                          className="text-muted-foreground hover:text-destructive"
                          onClick={() => setActiveFlag(isActive ? null : id)}
                          title="Flag inaccuracy"
                        >
                          <IconFlag className="size-3.5" />
                        </Button>
                      )}
                    </div>
                  </div>
                  {isActive && (
                    <InlineFlagForm
                      dimension={id}
                      label={label}
                      currentValue={value}
                      onSubmit={(note) => handleFlagSubmit(id, label, value, note)}
                      onCancel={() => setActiveFlag(null)}
                    />
                  )}
                </div>
              );
            })}

            {/* Restrictions */}
            {(() => {
              const id = "signal-restrictions";
              const isActive = activeFlag === id;
              const isSubmitted = submitted === id;
              const value =
                DEMO_RESTRICTIONS.length > 0 ? DEMO_RESTRICTIONS.join(", ") : "None";
              return (
                <div className="flex flex-col gap-1">
                  <div className="flex items-center justify-between">
                    <span className="text-muted-foreground">Restrictions</span>
                    <div className="flex items-center gap-2 flex-wrap justify-end max-w-[60%]">
                      {DEMO_RESTRICTIONS.length > 0 ? (
                        DEMO_RESTRICTIONS.map((r) => (
                          <Badge key={r} variant="outline" className="text-xs">
                            {r}
                          </Badge>
                        ))
                      ) : (
                        <span className="text-xs text-muted-foreground">None</span>
                      )}
                      {isSubmitted ? (
                        <span className="text-green-500">
                          <IconCheck className="size-4" />
                        </span>
                      ) : (
                        <Button
                          variant="ghost"
                          size="icon-sm"
                          className="text-muted-foreground hover:text-destructive"
                          onClick={() => setActiveFlag(isActive ? null : id)}
                          title="Flag inaccuracy"
                        >
                          <IconFlag className="size-3.5" />
                        </Button>
                      )}
                    </div>
                  </div>
                  {isActive && (
                    <InlineFlagForm
                      dimension={id}
                      label="Restrictions"
                      currentValue={value}
                      onSubmit={(note) => handleFlagSubmit(id, "Restrictions", value, note)}
                      onCancel={() => setActiveFlag(null)}
                    />
                  )}
                </div>
              );
            })()}
          </div>
        </CardContent>
      </Card>

      {/* ── Card 2: Teach Picky a New Habit ─────────────────────────────── */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <IconSparkles className="size-4 text-primary" />
            New Habit? Something Wrong?
          </CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-3 text-sm">
          <p className="text-muted-foreground text-xs">
            What&apos;s changing in your life? Picky will reflect that in your profile.
          </p>
          <Textarea
            placeholder="e.g. I'm going on a bulk, no peanuts, want to eat healthy"
            value={habitText}
            onChange={(e) => {
              setHabitText(e.target.value);
              setSimulationResult(null);
            }}
            className="min-h-16"
          />
          <Button
            onClick={handleSimulate}
            disabled={!habitText.trim()}
            className="self-end"
            size="sm"
          >
            Teach Picky
          </Button>

          {simulationResult && !hasSimulationOutput && (
            <p className="text-xs text-muted-foreground italic">
              No changes detected — try describing a dietary shift or lifestyle change.
            </p>
          )}

          {hasSimulationOutput && (
            <div className="flex flex-col gap-3 rounded-lg bg-muted/50 p-3 mt-1">
              <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                Vector Impact (simulated)
              </p>

              {simulationResult!.affinityDeltas.map((d) => (
                <div key={d.key} className="flex flex-col gap-1">
                  <div className="flex items-center justify-between">
                    <span className="flex items-center gap-1.5">
                      <span>{d.emoji}</span>
                      <span>{d.label}</span>
                    </span>
                    <span className="text-xs tabular-nums flex items-center gap-1">
                      <span className="text-muted-foreground">{d.oldVal}%</span>
                      <span className="text-muted-foreground">→</span>
                      <span
                        className={
                          d.newVal > d.oldVal ? "text-green-600 font-medium" : "text-red-500 font-medium"
                        }
                      >
                        {d.newVal}%
                      </span>
                      {d.newVal > d.oldVal ? (
                        <IconArrowUp className="size-3 text-green-600" />
                      ) : (
                        <IconArrowDown className="size-3 text-red-400" />
                      )}
                    </span>
                  </div>
                  <AffinityBar
                    value={d.newVal}
                    highlight={d.newVal > d.oldVal ? "up" : "down"}
                  />
                </div>
              ))}

              {simulationResult!.profileDeltas.map((d) => (
                <div key={d.key} className="flex items-center justify-between">
                  <span className="text-muted-foreground">{d.label}</span>
                  <span className="flex items-center gap-1.5 text-xs">
                    <Badge variant="outline" className="line-through opacity-50">
                      {d.oldVal}
                    </Badge>
                    <span>→</span>
                    <Badge variant="default">{d.newVal}</Badge>
                  </span>
                </div>
              ))}

              {simulationResult!.newRestrictions.map((r) => (
                <div key={r} className="flex items-center justify-between">
                  <span className="text-muted-foreground">New restriction</span>
                  <Badge variant="destructive" className="text-xs">
                    + {r}
                  </Badge>
                </div>
              ))}

              <p className="text-xs text-muted-foreground italic mt-1">
                Picky has noted this — use flags above to correct specific signals.
              </p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* ── Card 3: Correction History ────────────────────────────────────── */}
      {corrections.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base flex items-center gap-2">
              <IconHistory className="size-4 text-primary" />
              Correction History
            </CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col gap-3 text-sm">
            <p className="text-xs text-muted-foreground italic">
              The system is learning from you.
            </p>
            <div className="flex flex-col gap-2">
              {corrections.map((c, i) => (
                <div key={c.id}>
                  {i > 0 && <Separator className="mb-2" />}
                  <div className="flex flex-col gap-0.5">
                    <div className="flex items-center justify-between">
                      <span className="font-medium">{c.label}</span>
                      <span className="text-xs text-muted-foreground">
                        {formatTimestamp(c.timestamp)}
                      </span>
                    </div>
                    <span className="text-xs text-muted-foreground">
                      Was: {c.currentValue}
                    </span>
                    {c.note && (
                      <span className="text-xs italic text-foreground/70">
                        &quot;{c.note}&quot;
                      </span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
