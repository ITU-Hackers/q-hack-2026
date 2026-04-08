"use client"

import { useState } from "react"
import {
    Card,
    CardHeader,
    CardTitle,
    CardDescription,
    CardContent,
    CardFooter,
} from "@workspace/ui/components/card"
import { Button } from "@workspace/ui/components/button"
import { Input } from "@workspace/ui/components/input"
import { Label } from "@workspace/ui/components/label"
import { Progress } from "@workspace/ui/components/progress"
import {
    RadioGroup,
    RadioGroupItem,
} from "@workspace/ui/components/radio-group"
import { Separator } from "@workspace/ui/components/separator"
import { Slider } from "@workspace/ui/components/slider"
import {
    IconArrowLeft,
    IconArrowRight,
    IconCheck,
    IconToolsKitchen2,
    IconSalad,
    IconHeartbeat,
    IconUsers,
    IconUser,
    IconBabyCarriage,
    IconDog,
    IconCat,
    IconPlus,
    IconMinus,
} from "@tabler/icons-react"

const TOTAL_STEPS = 4

const CUISINES = [
    "Asian",
    "Indian",
    "Italian",
    "Mexican",
    "French",
    "German",
    "Thai",
    "Mediterranean",
]

const PREFERENCE_ITEMS = [
    { id: "fish", label: "Fish", restrictedBy: ["vegan", "vegetarian"] },
    { id: "pork", label: "Pork", restrictedBy: ["vegan", "vegetarian"] },
    { id: "beef", label: "Beef", restrictedBy: ["vegan", "vegetarian"] },
    { id: "dairy", label: "Dairy", restrictedBy: ["vegan", "lactose-intolerant"] },
    { id: "spicy", label: "Spicy food", restrictedBy: [] },
]

const HARD_RESTRICTIONS = [
    { id: "nut-allergy", label: "Nut Allergy" },
    { id: "gluten-free", label: "Gluten Free" },
    { id: "lactose-intolerant", label: "Lactose Intolerant" },
    { id: "vegan", label: "Vegan" },
    { id: "vegetarian", label: "Vegetarian" },
]

const HEALTH_GOALS = [
    {
        id: "high-protein",
        label: "High Protein",
        description: "Focus on protein-rich meals for muscle building and recovery",
    },
    {
        id: "keto",
        label: "Keto",
        description: "Very low carb, high fat diet for ketosis",
    },
    {
        id: "low-carb",
        label: "Low Carb",
        description: "Reduced carbohydrate intake while maintaining balance",
    },
    {
        id: "balanced",
        label: "Balanced",
        description: "Well-rounded meals with all macronutrient groups",
    },
    {
        id: "mediterranean",
        label: "Mediterranean",
        description: "Heart-healthy eating inspired by Mediterranean cuisine",
    },
]

function preferenceLabel(value: number) {
    if (value <= -75) return "Hate it"
    if (value <= -25) return "Dislike"
    if (value < 25) return "No opinion"
    if (value < 75) return "Like it"
    return "Love it"
}

function preferenceColor(value: number) {
    if (value <= -25) return "text-destructive"
    if (value >= 25) return "text-secondary"
    return "text-muted-foreground"
}

interface OnboardingData {
    email: string
    password: string
    adults: number
    kids: number
    dogs: number
    cats: number
    cuisines: string[]
    preferences: Record<string, number>
    restrictions: string[]
    healthGoal: string
}

function CounterRow({
    label,
    icon,
    value,
    onChange,
    min = 0,
    max = 8,
}: {
    label: string
    icon: React.ReactNode
    value: number
    onChange: (v: number) => void
    min?: number
    max?: number
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
    )
}

function HouseholdPortrait({
    adults,
    kids,
    dogs,
    cats,
}: {
    adults: number
    kids: number
    dogs: number
    cats: number
}) {
    if (adults === 0 && kids === 0 && dogs === 0 && cats === 0) {
        return (
            <div className="flex h-28 items-center justify-center rounded-lg border border-dashed border-border text-sm text-muted-foreground">
                Add your household members
            </div>
        )
    }

    return (
        <div className="flex min-h-28 flex-wrap items-end justify-center gap-1 overflow-x-auto rounded-lg border border-border bg-muted/30 p-4">
            {/* Dogs on the left */}
            {Array.from({ length: dogs }, (_, i) => (
                <div
                    key={`dog-${i}`}
                    className="flex flex-col items-center gap-0.5 transition-all animate-in fade-in slide-in-from-left-2"
                >
                    <IconDog className="size-7 text-amber-700" />
                </div>
            ))}

            {dogs > 0 && (adults > 0 || kids > 0) && <div className="w-2" />}

            {/* Adults (split) with kids grouped in the middle */}
            {(() => {
                const people: { type: "adult" | "kid"; index: number }[] = []
                const leftAdults = Math.ceil(adults / 2)
                const rightAdults = adults - leftAdults

                // Left half of adults
                for (let i = 0; i < leftAdults; i++) {
                    people.push({ type: "adult", index: i })
                }
                // All kids in the middle
                for (let i = 0; i < kids; i++) {
                    people.push({ type: "kid", index: i })
                }
                // Right half of adults
                for (let i = 0; i < rightAdults; i++) {
                    people.push({ type: "adult", index: leftAdults + i })
                }

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
                    )
                )
            })()}

            {cats > 0 && (adults > 0 || kids > 0) && <div className="w-2" />}

            {/* Cats on the right */}
            {Array.from({ length: cats }, (_, i) => (
                <div
                    key={`cat-${i}`}
                    className="flex flex-col items-center gap-0.5 transition-all animate-in fade-in slide-in-from-right-2"
                >
                    <IconCat className="size-7 text-muted-foreground" />
                </div>
            ))}
        </div>
    )
}

export default function Page() {
    const [step, setStep] = useState(0)
    const [data, setData] = useState<OnboardingData>({
        email: "",
        password: "",
        adults: 2,
        kids: 0,
        dogs: 0,
        cats: 0,
        cuisines: [],
        preferences: {
            fish: 0,
            pork: 0,
            beef: 0,
            dairy: 0,
            spicy: 0,
        },
        restrictions: [],
        healthGoal: "balanced",
    })

    function next() {
        setStep((s) => s + 1)
    }

    function back() {
        setStep((s) => s - 1)
    }

    function toggleCuisine(cuisine: string) {
        setData((d) => ({
            ...d,
            cuisines: d.cuisines.includes(cuisine)
                ? d.cuisines.filter((c) => c !== cuisine)
                : [...d.cuisines, cuisine],
        }))
    }

    function toggleRestriction(id: string) {
        setData((d) => ({
            ...d,
            restrictions: d.restrictions.includes(id)
                ? d.restrictions.filter((r) => r !== id)
                : [...d.restrictions, id],
        }))
    }

    function isRestricted(item: (typeof PREFERENCE_ITEMS)[number]) {
        return item.restrictedBy.some((r) => data.restrictions.includes(r))
    }

    // Step 0: Login
    if (step === 0) {
        return (
            <div className="flex min-h-svh items-center justify-center bg-background p-4">
                <Card className="w-full max-w-sm">
                    <CardHeader>
                        <CardTitle className="text-xl">Welcome to Picky</CardTitle>
                        <CardDescription>
                            Sign in to start planning your meals
                        </CardDescription>
                    </CardHeader>
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
                    <CardFooter>
                        <Button className="w-full" onClick={next}>
                            Sign In
                        </Button>
                    </CardFooter>
                </Card>
            </div>
        )
    }

    // Done step
    if (step === TOTAL_STEPS + 1) {
        return (
            <div className="flex min-h-svh items-center justify-center bg-background p-4">
                <Card className="w-full max-w-md text-center">
                    <CardHeader>
                        <div className="mx-auto mb-2 flex size-12 items-center justify-center rounded-full bg-secondary/20">
                            <IconCheck className="size-6 text-secondary" />
                        </div>
                        <CardTitle className="text-xl">You&apos;re all set!</CardTitle>
                        <CardDescription>
                            We&apos;ve saved your preferences. Your personalized meal plans
                            are being prepared.
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="rounded-lg border border-border bg-muted/50 p-4 text-left text-sm">
                            <p className="mb-2 font-medium text-foreground">Your profile:</p>
                            <ul className="flex flex-col gap-1 text-muted-foreground">
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
                                                    HARD_RESTRICTIONS.find((hr) => hr.id === r)?.label
                                            )
                                            .join(", ")}
                                    </li>
                                )}
                                <li>
                                    Goal:{" "}
                                    {HEALTH_GOALS.find((g) => g.id === data.healthGoal)?.label}
                                </li>
                            </ul>
                        </div>
                    </CardContent>
                    <CardFooter className="justify-center">
                        <Button onClick={() => setStep(0)} variant="outline">
                            Start Over
                        </Button>
                    </CardFooter>
                </Card>
            </div>
        )
    }

    // Steps 1–5: Wizard
    const progressValue = (step / TOTAL_STEPS) * 100

    const stepIcons = [
        <IconUsers key="users" className="size-4" />,
        <IconToolsKitchen2 key="kitchen" className="size-4" />,
        <IconSalad key="salad" className="size-4" />,
        <IconHeartbeat key="heart" className="size-4" />,
    ]

    const stepLabels = [
        "Household",
        "Cuisines",
        "Dietary",
        "Health Goals",
    ]

    return (
        <div className="flex min-h-svh items-center justify-center bg-background p-4">
            <div className="flex w-full max-w-lg flex-col gap-6">
                {/* Progress */}
                <div className="flex flex-col gap-3">
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
                                className={`flex items-center gap-1.5 text-xs ${i + 1 <= step
                                    ? "font-medium text-primary"
                                    : "text-muted-foreground"
                                    }`}
                            >
                                <div
                                    className={`flex size-6 items-center justify-center rounded-full text-xs ${i + 1 < step
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

                {/* Step Content */}
                <Card>
                    {/* Step 1: Household */}
                    {step === 1 && (
                        <>
                            <CardHeader>
                                <CardTitle>Household Profile</CardTitle>
                                <CardDescription>
                                    Tell us about your household so we can tailor portion sizes and
                                    ingredient safety.
                                </CardDescription>
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
                                    <p className="text-xs text-muted-foreground">
                                        We&apos;ll flag recipes with ingredients that can be harmful
                                        to your pets.
                                    </p>
                                )}
                            </CardContent>
                        </>
                    )}

                    {/* Step 2: Cuisines */}
                    {step === 2 && (
                        <>
                            <CardHeader>
                                <CardTitle>Cuisine Preferences</CardTitle>
                                <CardDescription>
                                    Select the cuisines your household enjoys. Pick as many as you
                                    like.
                                </CardDescription>
                            </CardHeader>
                            <CardContent>
                                <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
                                    {CUISINES.map((cuisine) => {
                                        const selected = data.cuisines.includes(cuisine)
                                        return (
                                            <Button
                                                key={cuisine}
                                                variant="outline"
                                                className={`h-auto justify-start px-4 py-3 text-left ${selected
                                                    ? "border-primary bg-primary/10 text-primary"
                                                    : ""
                                                    }`}
                                                onClick={() => toggleCuisine(cuisine)}
                                            >
                                                {selected && <IconCheck className="mr-1.5 size-4" />}
                                                {cuisine}
                                            </Button>
                                        )
                                    })}
                                </div>
                                {data.cuisines.length > 0 && (
                                    <p className="mt-4 text-sm text-muted-foreground">
                                        {data.cuisines.length} cuisine
                                        {data.cuisines.length !== 1 ? "s" : ""} selected
                                    </p>
                                )}
                            </CardContent>
                        </>
                    )}

                    {/* Step 3: Dietary (restrictions + preferences combined) */}
                    {step === 3 && (
                        <>
                            <CardHeader>
                                <CardTitle>Dietary Preferences</CardTitle>
                                <CardDescription>
                                    Set any hard restrictions, then fine-tune how you feel about
                                    specific ingredients.
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="flex flex-col gap-5">
                                {/* Hard restrictions */}
                                <div className="flex flex-wrap gap-2">
                                    {HARD_RESTRICTIONS.map((restriction) => {
                                        const active = data.restrictions.includes(restriction.id)
                                        return (
                                            <Button
                                                key={restriction.id}
                                                variant="outline"
                                                size="sm"
                                                className={`${
                                                    active
                                                        ? "border-primary bg-primary/10 text-primary"
                                                        : ""
                                                }`}
                                                onClick={() => toggleRestriction(restriction.id)}
                                            >
                                                {active && <IconCheck className="mr-1 size-3.5" />}
                                                {restriction.label}
                                            </Button>
                                        )
                                    })}
                                </div>

                                <Separator />

                                {/* Scale legend */}
                                <div className="flex items-center justify-between text-xs text-muted-foreground">
                                    <span className="text-destructive">Hate it</span>
                                    <span>No opinion</span>
                                    <span className="text-secondary">Love it</span>
                                </div>

                                {PREFERENCE_ITEMS.map((item) => {
                                    const restricted = isRestricted(item)
                                    const value = data.preferences[item.id] ?? 0

                                    return (
                                        <div
                                            key={item.id}
                                            className={`flex flex-col gap-2 transition-opacity ${restricted ? "opacity-30" : ""}`}
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
                                                    className={`text-xs ${restricted ? "text-muted-foreground" : preferenceColor(value)}`}
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
                                                        const newVal = Array.isArray(v) ? v[0] : v
                                                        setData((d) => ({
                                                            ...d,
                                                            preferences: {
                                                                ...d.preferences,
                                                                [item.id]: newVal ?? 0,
                                                            },
                                                        }))
                                                    }
                                                }}
                                            />
                                        </div>
                                    )
                                })}
                            </CardContent>
                        </>
                    )}

                    {/* Step 4: Health Goals */}
                    {step === 4 && (
                        <>
                            <CardHeader>
                                <CardTitle>Health Goals</CardTitle>
                                <CardDescription>
                                    Choose an eating style that aligns with your health objectives.
                                </CardDescription>
                            </CardHeader>
                            <CardContent>
                                <RadioGroup
                                    value={data.healthGoal}
                                    onValueChange={(value) =>
                                        setData((d) => ({ ...d, healthGoal: value as string }))
                                    }
                                >
                                    {HEALTH_GOALS.map((goal) => (
                                        <label
                                            key={goal.id}
                                            className={`flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-colors ${data.healthGoal === goal.id
                                                ? "border-primary bg-primary/5"
                                                : "border-border hover:bg-muted/50"
                                                }`}
                                        >
                                            <RadioGroupItem value={goal.id} className="mt-0.5" />
                                            <div className="flex flex-col gap-1">
                                                <span className="text-sm font-medium">
                                                    {goal.label}
                                                </span>
                                                <span className="text-sm text-muted-foreground">
                                                    {goal.description}
                                                </span>
                                            </div>
                                        </label>
                                    ))}
                                </RadioGroup>
                            </CardContent>
                        </>
                    )}

                    <CardFooter className="flex justify-between">
                        <Button variant="outline" onClick={back}>
                            <IconArrowLeft className="size-4" />
                            Back
                        </Button>
                        <Button onClick={next}>
                            {step === TOTAL_STEPS ? (
                                <>
                                    Finish
                                    <IconCheck className="size-4" />
                                </>
                            ) : (
                                <>
                                    Next
                                    <IconArrowRight className="size-4" />
                                </>
                            )}
                        </Button>
                    </CardFooter>
                </Card>
            </div>
        </div>
    )
}
