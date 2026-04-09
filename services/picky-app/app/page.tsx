"use client";

import {
  IconArrowLeft,
  IconArrowRight,
  IconBabyCarriage,
  IconCat,
  IconCheck,
  IconClock,
  IconDog,
  IconHeartbeat,
  IconMinus,
  IconPlus,
  IconSalad,
  IconSparkles,
  IconToolsKitchen2,
  IconUser,
  IconUsers,
  IconWallet,
} from "@tabler/icons-react";
import { Button } from "@workspace/ui/components/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@workspace/ui/components/card";
import { Input } from "@workspace/ui/components/input";
import { Label } from "@workspace/ui/components/label";
import { Progress } from "@workspace/ui/components/progress";
import {
  RadioGroup,
  RadioGroupItem,
} from "@workspace/ui/components/radio-group";
import { Separator } from "@workspace/ui/components/separator";
import { Slider } from "@workspace/ui/components/slider";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { useUser } from "@/components/user-context";
import { ApiError, createProfile, loginProfile } from "@/lib/api";

const TOTAL_STEPS = 5;

const CUISINES = [
  "Asian",
  "Indian",
  "Italian",
  "Mexican",
  "French",
  "German",
  "Thai",
  "Mediterranean",
];

const PREFERENCE_ITEMS = [
  { id: "fish", label: "Fish", restrictedBy: ["vegan", "vegetarian"] },
  { id: "pork", label: "Pork", restrictedBy: ["vegan", "vegetarian"] },
  { id: "beef", label: "Beef", restrictedBy: ["vegan", "vegetarian"] },
  { id: "dairy", label: "Dairy", restrictedBy: ["vegan"] },
  { id: "spicy", label: "Spicy food", restrictedBy: [] },
];

const HARD_RESTRICTIONS = [
  { id: "nut-allergy", label: "Nut Allergy" },
  { id: "gluten-free", label: "Gluten Free" },
  { id: "vegan", label: "Vegan" },
  { id: "vegetarian", label: "Vegetarian" },
];

const HEALTH_GOALS = [
  {
    id: "high-protein",
    label: "High Protein",
  },
  {
    id: "keto",
    label: "Keto",
  },
  {
    id: "low-carb",
    label: "Low Carb",
  },
  {
    id: "balanced",
    label: "Balanced",
  },
  {
    id: "mediterranean",
    label: "Mediterranean",
  },
];

const COOKING_TIMES = [
  {
    id: "quick",
    label: "Quick",
    icon: "🚀",
  },
  {
    id: "moderate",
    label: "Moderate",
    icon: "🍳",
  },
  {
    id: "enthusiast",
    label: "Enthusiast",
    icon: "👨‍🍳",
  },
];

function budgetTiers() {
  return [
    {
      id: "tight",
      label: "Tight",
      icon: "🪙",
    },
    {
      id: "moderate",
      label: "Moderate",
      icon: "💶",
    },
    {
      id: "flexible",
      label: "Flexible",
      icon: "✨",
    },
  ];
}

function preferenceLabel(value: number) {
  if (value <= -75) return "Hate it";
  if (value <= -25) return "Dislike";
  if (value < 25) return "No opinion";
  if (value < 75) return "Like it";
  return "Love it";
}

function preferenceColor(value: number) {
  if (value <= -25) return "text-destructive";
  if (value >= 25) return "text-secondary";
  return "text-muted-foreground";
}

interface OnboardingData {
  email: string;
  password: string;
  adults: number;
  kids: number;
  dogs: number;
  cats: number;
  cuisines: string[];
  preferences: Record<string, number>;
  restrictions: string[];
  healthGoal: string;
  cookingTime: string;
  budget: string;
}

function StepHint({ children }: { children: React.ReactNode }) {
  return (
    <p className="flex items-start gap-2 rounded-lg bg-secondary/10 p-3 text-xs leading-relaxed text-secondary">
      <IconSparkles className="mt-0.5 size-3.5 shrink-0" />
      {children}
    </p>
  );
}

function CounterRow({
  label,
  icon,
  value,
  onChange,
  min = 0,
  max = 8,
}: {
  label: string;
  icon: React.ReactNode;
  value: number;
  onChange: (v: number) => void;
  min?: number;
  max?: number;
}) {
  return (
    <div className="flex items-center justify-between">
      <div className="flex items-center gap-2.5">
        <span className="text-muted-foreground">{icon}</span>
        <span className="text-sm font-medium">{label}</span>
      </div>
      <div className="flex items-center gap-2">
        <Button
          variant="outline"
          size="icon-sm"
          onClick={() => onChange(Math.max(min, value - 1))}
          disabled={value <= min}
        >
          <IconMinus className="size-3.5" />
        </Button>
        <span className="w-8 text-center text-sm font-medium tabular-nums">
          {value}
        </span>
        <Button
          variant="outline"
          size="icon-sm"
          onClick={() => onChange(Math.min(max, value + 1))}
          disabled={value >= max}
        >
          <IconPlus className="size-3.5" />
        </Button>
      </div>
    </div>
  );
}

function HouseholdPortrait({
  adults,
  kids,
  dogs,
  cats,
}: {
  adults: number;
  kids: number;
  dogs: number;
  cats: number;
}) {
  if (adults === 0 && kids === 0 && dogs === 0 && cats === 0) {
    return (
      <div className="flex h-28 items-center justify-center rounded-lg border border-dashed border-border text-sm text-muted-foreground">
        Add your household members
      </div>
    );
  }

  return (
    <div className="flex min-h-28 flex-wrap items-end justify-center gap-1 overflow-x-auto rounded-lg border border-border bg-muted/30 p-4 transition-all">
      {/* Dogs on the left */}
      {[...Array(dogs).keys()].map((n) => (
        <div
          key={`dog-${n}`}
          className="flex flex-col items-center gap-0.5 transition-all animate-in fade-in slide-in-from-left-2"
        >
          <IconDog className="size-7 text-amber-700" />
        </div>
      ))}

      {dogs > 0 && (adults > 0 || kids > 0) && <div className="w-2" />}

      {/* Adults (split) with kids grouped in the middle */}
      {(() => {
        const people: { type: "adult" | "kid"; index: number }[] = [];
        const leftAdults = Math.ceil(adults / 2);
        const rightAdults = adults - leftAdults;

        for (let i = 0; i < leftAdults; i++)
          people.push({ type: "adult", index: i });
        for (let i = 0; i < kids; i++) people.push({ type: "kid", index: i });
        for (let i = 0; i < rightAdults; i++)
          people.push({ type: "adult", index: leftAdults + i });

        return people.map((p) =>
          p.type === "adult" ? (
            <div
              key={`adult-${p.index}`}
              className="flex flex-col items-center gap-0.5 transition-all animate-in fade-in slide-in-from-bottom-2"
            >
              <IconUser className="size-9 text-primary" />
            </div>
          ) : (
            <div
              key={`kid-${p.index}`}
              className="flex flex-col items-center gap-0.5 self-end transition-all animate-in fade-in zoom-in"
            >
              <IconBabyCarriage className="size-6 text-secondary" />
            </div>
          ),
        );
      })()}

      {cats > 0 && (adults > 0 || kids > 0) && <div className="w-2" />}

      {/* Cats on the right */}
      {[...Array(cats).keys()].map((n) => (
        <div
          key={`cat-${n}`}
          className="flex flex-col items-center gap-0.5 transition-all animate-in fade-in slide-in-from-right-2"
        >
          <IconCat className="size-7 text-muted-foreground" />
        </div>
      ))}
    </div>
  );
}

export default function Page() {
  const [step, setStep] = useState(0);
  const [data, setData] = useState<OnboardingData>({
    email: "",
    password: "",
    adults: 2,
    kids: 0,
    dogs: 0,
    cats: 0,
    cuisines: [],
    preferences: { fish: 0, pork: 0, beef: 0, dairy: 0, spicy: 0 },
    restrictions: [],
    healthGoal: "balanced",
    cookingTime: "moderate",
    budget: "moderate",
  });

  const { user, mounted, setUser } = useUser();
  const router = useRouter();

  const [isLoginLoading, setIsLoginLoading] = useState(false);
  const [loginError, setLoginError] = useState<string | null>(null);
  const [isCreating, setIsCreating] = useState(false);
  const [createError, setCreateError] = useState<string | null>(null);

  useEffect(() => {
    if (mounted && user) {
      router.replace("/browse");
    }
  }, [mounted, user, router]);

  // Show nothing while determining auth state to avoid a flash.
  if (!mounted || user) return null;

  function next() {
    setStep((s) => s + 1);
  }

  function back() {
    setStep((s) => s - 1);
  }

  function toggleCuisine(cuisine: string) {
    setData((d) => ({
      ...d,
      cuisines: d.cuisines.includes(cuisine)
        ? d.cuisines.filter((c) => c !== cuisine)
        : [...d.cuisines, cuisine],
    }));
  }

  function toggleRestriction(id: string) {
    setData((d) => ({
      ...d,
      restrictions: d.restrictions.includes(id)
        ? d.restrictions.filter((r) => r !== id)
        : [...d.restrictions, id],
    }));
  }

  function isRestricted(item: (typeof PREFERENCE_ITEMS)[number]) {
    return item.restrictedBy.some((r) => data.restrictions.includes(r));
  }

  async function handleLogin() {
    if (!data.email || !data.password) return;
    setIsLoginLoading(true);
    setLoginError(null);
    try {
      const profile = await loginProfile(data.email, data.password);
      setUser(profile);
      router.replace("/browse");
    } catch (err) {
      if (err instanceof ApiError) {
        if (err.status === 404) {
          // No account yet — proceed to onboarding wizard to create one.
          next();
        } else if (err.status === 401) {
          setLoginError("Incorrect password. Please try again.");
        } else {
          setLoginError("Something went wrong. Please try again.");
        }
      } else {
        setLoginError("Could not reach the server. Please try again.");
      }
    } finally {
      setIsLoginLoading(false);
    }
  }

  async function handleFinish() {
    setIsCreating(true);
    setCreateError(null);
    try {
      const profile = await createProfile({
        email: data.email,
        password: data.password,
        adults: data.adults,
        kids: data.kids,
        dogs: data.dogs,
        cats: data.cats,
        cuisines: data.cuisines,
        preferences: {
          fish: data.preferences.fish ?? 0,
          pork: data.preferences.pork ?? 0,
          beef: data.preferences.beef ?? 0,
          dairy: data.preferences.dairy ?? 0,
          spicy: data.preferences.spicy ?? 0,
        },
        restrictions: data.restrictions,
        health_goal: data.healthGoal,
        cooking_time: data.cookingTime,
        budget: data.budget,
      });
      setUser(profile);
      next();
    } catch (err) {
      if (err instanceof ApiError && err.status === 409) {
        setCreateError("An account with this email already exists.");
      } else {
        setCreateError("Failed to create your account. Please try again.");
      }
    } finally {
      setIsCreating(false);
    }
  }

  if (step === 0) {
    return (
      <div className="flex min-h-svh items-center justify-center bg-background p-4">
        <Card className="w-full max-w-sm animate-in fade-in slide-in-from-bottom-4 duration-500">
          <CardHeader className="text-center">
            <CardTitle className="text-2xl">Welcome to Picky</CardTitle>
            <CardDescription>
              Your personal meal planner, powered by Picnic.
              <br />
              Fresh ideas, delivered to your door.
            </CardDescription>
          </CardHeader>
          <form
            className="contents"
            onSubmit={(e) => {
              e.preventDefault();
              handleLogin();
            }}
          >
            <CardContent className="flex flex-col gap-4">
              <div className="flex flex-col gap-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="you@example.com"
                  value={data.email}
                  onChange={(e) =>
                    setData((d) => ({ ...d, email: e.target.value }))
                  }
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="password">Password</Label>
                <Input
                  id="password"
                  type="password"
                  placeholder="Enter your password"
                  value={data.password}
                  onChange={(e) =>
                    setData((d) => ({ ...d, password: e.target.value }))
                  }
                />
              </div>
            </CardContent>
            <CardFooter className="flex flex-col gap-3">
              {loginError && (
                <p className="text-center text-sm text-destructive">
                  {loginError}
                </p>
              )}
              <Button
                type="submit"
                className="w-full"
                disabled={isLoginLoading || !data.email || !data.password}
              >
                {isLoginLoading ? "Signing in…" : "Sign In"}
              </Button>
              <p className="text-center text-xs text-muted-foreground">
                No account yet? Enter your email and a password and we&apos;ll
                set one up for you.
              </p>
            </CardFooter>
          </form>
        </Card>
      </div>
    );
  }

  if (step === TOTAL_STEPS + 1) {
    return (
      <div className="flex min-h-svh items-center justify-center bg-background p-4">
        <Card className="w-full max-w-md animate-in fade-in zoom-in-95 duration-500">
          <CardHeader className="text-center">
            <div className="mx-auto mb-3 flex size-14 items-center justify-center rounded-full bg-secondary/20 animate-in zoom-in duration-500">
              <IconCheck className="size-7 text-secondary" />
            </div>
            <CardTitle className="text-xl">
              Thanks for setting up Picky!
            </CardTitle>
            <CardDescription>
              We&apos;re using your answers to build a personalised meal plan
              and shopping list that fits your household, budget, and taste. You
              can always update these in settings.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="rounded-lg border border-border bg-muted/50 p-4 text-left text-sm">
              <p className="mb-2 font-medium text-foreground">
                Your profile at a glance:
              </p>
              <ul className="flex flex-col gap-1.5 text-muted-foreground">
                <li>
                  {data.adults} adult{data.adults !== 1 ? "s" : ""}
                  {data.kids > 0 &&
                    `, ${data.kids} kid${data.kids !== 1 ? "s" : ""}`}
                  {data.dogs > 0 &&
                    `, ${data.dogs} dog${data.dogs !== 1 ? "s" : ""}`}
                  {data.cats > 0 &&
                    `, ${data.cats} cat${data.cats !== 1 ? "s" : ""}`}
                </li>
                {data.cuisines.length > 0 && (
                  <li>Cuisines: {data.cuisines.join(", ")}</li>
                )}
                {data.restrictions.length > 0 && (
                  <li>
                    Restrictions:{" "}
                    {data.restrictions
                      .map(
                        (r) =>
                          HARD_RESTRICTIONS.find((hr) => hr.id === r)?.label,
                      )
                      .join(", ")}
                  </li>
                )}
                <li>
                  Cooking:{" "}
                  {COOKING_TIMES.find((c) => c.id === data.cookingTime)
                    ?.label ?? data.cookingTime}{" "}
                  &middot; Budget: {data.budget}
                </li>
                <li>
                  Goal:{" "}
                  {HEALTH_GOALS.find((g) => g.id === data.healthGoal)?.label}
                </li>
              </ul>
            </div>
          </CardContent>
          <CardFooter className="flex justify-center gap-3">
            <Button variant="outline" onClick={() => setStep(0)}>
              Start Over
            </Button>
            <Button nativeButton={false} render={<Link href="/browse" />}>
              Browse Recipes
              <IconArrowRight className="size-4" />
            </Button>
          </CardFooter>
        </Card>
      </div>
    );
  }

  const progressValue = (step / TOTAL_STEPS) * 100;

  const stepIcons = [
    <IconUsers key="users" className="size-4" />,
    <IconToolsKitchen2 key="kitchen" className="size-4" />,
    <IconSalad key="salad" className="size-4" />,
    <IconClock key="clock" className="size-4" />,
    <IconHeartbeat key="heart" className="size-4" />,
  ];

  const stepLabels = ["Household", "Cuisines", "Dietary", "Lifestyle", "Goals"];

  return (
    <div className="flex min-h-svh items-center justify-center bg-background p-4">
      <div className="flex w-full max-w-lg flex-col gap-6">
        <div className="flex flex-col gap-3 animate-in fade-in duration-300">
          <div className="flex items-center justify-between text-sm text-muted-foreground">
            <span>
              Step {step} of {TOTAL_STEPS}
            </span>
            <span>{stepLabels[step - 1]}</span>
          </div>
          <Progress value={progressValue} />
          <div className="flex justify-between">
            {stepLabels.map((label, i) => (
              <div
                key={label}
                className={`flex items-center gap-1.5 text-xs transition-colors duration-300 ${
                  i + 1 <= step
                    ? "font-medium text-primary"
                    : "text-muted-foreground"
                }`}
              >
                <div
                  className={`flex size-6 items-center justify-center rounded-full text-xs transition-all duration-300 ${
                    i + 1 < step
                      ? "bg-primary text-primary-foreground"
                      : i + 1 === step
                        ? "border-2 border-primary text-primary"
                        : "border border-border text-muted-foreground"
                  }`}
                >
                  {i + 1 < step ? (
                    <IconCheck className="size-3" />
                  ) : (
                    stepIcons[i]
                  )}
                </div>
                <span className="hidden sm:inline">{label}</span>
              </div>
            ))}
          </div>
        </div>

        <Card
          key={step}
          className="animate-in fade-in slide-in-from-right-4 duration-300"
        >
          {step === 1 && (
            <>
              <CardHeader>
                <CardTitle>Who&apos;s at home?</CardTitle>
              </CardHeader>
              <CardContent className="flex flex-col gap-5">
                <div className="flex flex-col gap-4">
                  <CounterRow
                    label="Adults"
                    icon={<IconUser className="size-5" />}
                    value={data.adults}
                    onChange={(v) => setData((d) => ({ ...d, adults: v }))}
                    min={1}
                  />
                  <CounterRow
                    label="Kids"
                    icon={<IconBabyCarriage className="size-5" />}
                    value={data.kids}
                    onChange={(v) => setData((d) => ({ ...d, kids: v }))}
                  />
                  <CounterRow
                    label="Dogs"
                    icon={<IconDog className="size-5" />}
                    value={data.dogs}
                    onChange={(v) => setData((d) => ({ ...d, dogs: v }))}
                  />
                  <CounterRow
                    label="Cats"
                    icon={<IconCat className="size-5" />}
                    value={data.cats}
                    onChange={(v) => setData((d) => ({ ...d, cats: v }))}
                  />
                </div>

                <Separator />

                <HouseholdPortrait
                  adults={data.adults}
                  kids={data.kids}
                  dogs={data.dogs}
                  cats={data.cats}
                />

                {(data.dogs > 0 || data.cats > 0) && (
                  <StepHint>
                    Good to know! We&apos;ll add pet-friendly snack ideas to
                    your weekly plan.
                  </StepHint>
                )}
              </CardContent>
            </>
          )}

          {step === 2 && (
            <>
              <CardHeader>
                <CardTitle>What flavours excite you?</CardTitle>
              </CardHeader>
              <CardContent className="flex flex-col gap-5">
                <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
                  {CUISINES.map((cuisine) => {
                    const selected = data.cuisines.includes(cuisine);
                    return (
                      <Button
                        key={cuisine}
                        variant="outline"
                        className={`h-auto justify-center px-3 py-3 transition-all duration-200 ${
                          selected
                            ? "border-primary bg-primary/10 text-primary hover:border-primary hover:bg-primary/10 hover:text-primary scale-[1.03]"
                            : "hover:border-primary hover:bg-primary/10 hover:text-primary hover:scale-[1.02]"
                        }`}
                        onClick={() => toggleCuisine(cuisine)}
                      >
                        {selected && <IconCheck className="mr-1.5 size-4" />}
                        {cuisine}
                      </Button>
                    );
                  })}
                </div>
                {data.cuisines.length > 0 && (
                  <p className="text-sm text-muted-foreground animate-in fade-in">
                    {data.cuisines.length} cuisine
                    {data.cuisines.length !== 1 ? "s" : ""} selected
                  </p>
                )}
                <StepHint>
                  We use this to match recipes and highlight relevant
                  ingredients in your Picnic basket.
                </StepHint>
              </CardContent>
            </>
          )}

          {step === 3 && (
            <>
              <CardHeader>
                <CardTitle>Any dietary needs?</CardTitle>
              </CardHeader>
              <CardContent className="flex flex-col gap-5">
                <div className="flex flex-wrap gap-2">
                  {HARD_RESTRICTIONS.map((restriction) => {
                    const active = data.restrictions.includes(restriction.id);
                    return (
                      <Button
                        key={restriction.id}
                        variant="outline"
                        size="sm"
                        className={`transition-all duration-200 ${
                          active
                            ? "border-primary bg-primary/10 text-primary hover:border-primary hover:bg-primary/10 hover:text-primary scale-[1.03]"
                            : "hover:border-primary hover:bg-primary/10 hover:text-primary hover:scale-[1.02]"
                        }`}
                        onClick={() => toggleRestriction(restriction.id)}
                      >
                        {active && <IconCheck className="mr-1 size-3.5" />}
                        {restriction.label}
                      </Button>
                    );
                  })}
                </div>

                <Separator />

                <div className="flex items-center justify-between text-xs text-muted-foreground">
                  <span className="text-destructive">Hate it</span>
                  <span>No opinion</span>
                  <span className="text-secondary">Love it</span>
                </div>

                {PREFERENCE_ITEMS.map((item) => {
                  const restricted = isRestricted(item);
                  const value = data.preferences[item.id] ?? 0;

                  return (
                    <div
                      key={item.id}
                      className={`flex flex-col gap-2 transition-opacity duration-300 ${
                        restricted ? "opacity-30" : ""
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-medium">
                          {item.label}
                          {restricted && (
                            <span className="ml-2 text-xs font-normal text-muted-foreground">
                              (restricted)
                            </span>
                          )}
                        </span>
                        <span
                          className={`text-xs transition-colors ${
                            restricted
                              ? "text-muted-foreground"
                              : preferenceColor(value)
                          }`}
                        >
                          {restricted ? "N/A" : preferenceLabel(value)}
                        </span>
                      </div>
                      <Slider
                        value={[restricted ? 0 : value]}
                        min={-100}
                        max={100}
                        step={25}
                        disabled={restricted}
                        onValueChange={(v) => {
                          if (!restricted) {
                            const newVal = Array.isArray(v) ? v[0] : v;
                            setData((d) => ({
                              ...d,
                              preferences: {
                                ...d.preferences,
                                [item.id]: newVal ?? 0,
                              },
                            }));
                          }
                        }}
                      />
                    </div>
                  );
                })}

                <StepHint>
                  This keeps your Picnic suggestions safe and tailored to your
                  taste buds.
                </StepHint>
              </CardContent>
            </>
          )}

          {step === 4 && (
            <>
              <CardHeader>
                <CardTitle>Your kitchen reality</CardTitle>
              </CardHeader>
              <CardContent className="flex flex-col gap-5">
                <div className="flex flex-col gap-3">
                  <Label className="flex items-center gap-2 text-sm">
                    <IconClock className="size-4 text-muted-foreground" />
                    How much time do you like spending on a meal?
                  </Label>
                  <div className="grid grid-cols-3 gap-3">
                    {COOKING_TIMES.map((t) => {
                      const selected = data.cookingTime === t.id;
                      return (
                        <Button
                          key={t.id}
                          variant="outline"
                          className={`flex h-auto flex-col items-center gap-1 px-3 py-4 transition-all duration-200 ${
                            selected
                              ? "border-primary bg-primary/10 text-primary hover:border-primary hover:bg-primary/10 hover:text-primary scale-[1.03]"
                              : "hover:border-primary hover:bg-primary/10 hover:text-primary hover:scale-[1.02]"
                          }`}
                          onClick={() =>
                            setData((d) => ({
                              ...d,
                              cookingTime: t.id,
                            }))
                          }
                        >
                          <span className="text-xl">{t.icon}</span>
                          <span className="text-sm font-medium">{t.label}</span>
                        </Button>
                      );
                    })}
                  </div>
                </div>

                <Separator />

                <div className="flex flex-col gap-3">
                  <Label className="flex items-center gap-2 text-sm">
                    <IconWallet className="size-4 text-muted-foreground" />
                    Weekly grocery budget
                  </Label>
                  <div className="grid grid-cols-3 gap-3">
                    {budgetTiers().map((b) => {
                      const selected = data.budget === b.id;
                      return (
                        <Button
                          key={b.id}
                          variant="outline"
                          className={`flex h-auto flex-col items-center gap-1 px-3 py-4 transition-all duration-200 ${
                            selected
                              ? "border-primary bg-primary/10 text-primary hover:border-primary hover:bg-primary/10 hover:text-primary scale-[1.03]"
                              : "hover:border-primary hover:bg-primary/10 hover:text-primary hover:scale-[1.02]"
                          }`}
                          onClick={() =>
                            setData((d) => ({
                              ...d,
                              budget: b.id,
                            }))
                          }
                        >
                          <span className="text-xl">{b.icon}</span>
                          <span className="text-sm font-medium">{b.label}</span>
                        </Button>
                      );
                    })}
                  </div>
                </div>

                <StepHint>
                  We use this to filter recipes by prep time and pick
                  ingredients that fit your weekly spend.
                </StepHint>
              </CardContent>
            </>
          )}

          {step === 5 && (
            <>
              <CardHeader>
                <CardTitle>Any health goals?</CardTitle>
              </CardHeader>
              <CardContent className="flex flex-col gap-5">
                <RadioGroup
                  value={data.healthGoal}
                  onValueChange={(value) =>
                    setData((d) => ({
                      ...d,
                      healthGoal: value as string,
                    }))
                  }
                  className="gap-3"
                >
                  {HEALTH_GOALS.map((goal) => (
                    <label
                      key={goal.id}
                      htmlFor={goal.id}
                      className={`flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-all duration-200 ${
                        data.healthGoal === goal.id
                          ? "border-primary bg-primary/5 hover:border-primary hover:bg-primary/5 scale-[1.01]"
                          : "border-border hover:border-primary hover:bg-primary/5 hover:scale-[1.01]"
                      }`}
                    >
                      <RadioGroupItem
                        id={goal.id}
                        value={goal.id}
                        className="mt-0.5"
                      />
                      <div className="flex flex-col gap-0.5">
                        <span className="text-sm font-medium">
                          {goal.label}
                        </span>
                      </div>
                    </label>
                  ))}
                </RadioGroup>

                <StepHint>
                  Almost there! This helps us balance macros across your weekly
                  plan.
                </StepHint>
              </CardContent>
            </>
          )}

          <CardFooter className="flex flex-col gap-3">
            {createError && (
              <p className="text-center text-sm text-destructive">
                {createError}
              </p>
            )}
            <div className="flex w-full justify-between">
              <Button variant="outline" onClick={back} disabled={isCreating}>
                <IconArrowLeft className="size-4" />
                Back
              </Button>
              <Button
                onClick={step === TOTAL_STEPS ? handleFinish : next}
                disabled={isCreating}
              >
                {step === TOTAL_STEPS ? (
                  <>
                    {isCreating ? "Creating…" : "Finish"}
                    <IconCheck className="size-4" />
                  </>
                ) : (
                  <>
                    Next
                    <IconArrowRight className="size-4" />
                  </>
                )}
              </Button>
            </div>
          </CardFooter>
        </Card>
      </div>
    </div>
  );
}
