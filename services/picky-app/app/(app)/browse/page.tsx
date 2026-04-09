"use client";

import { IconLoader2, IconPlayerStop, IconRobot, IconSparkles, IconX } from "@tabler/icons-react";
import { Button } from "@workspace/ui/components/button";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@workspace/ui/components/carousel";
import AutoScroll from "embla-carousel-auto-scroll";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { toast } from "sonner";
import { useUser } from "@/components/user-context";
import { fetchRecommendations, fetchRecipes, type Recipe } from "@/lib/api";
import { useCart } from "../../../components/cart-context";

function normaliseName(name: string): string {
  return name.toLowerCase().replace(/[_-]+/g, " ").replace(/\s+/g, " ").trim();
}

const ACCENT_COLORS = [
  "bg-[var(--color-default-secondary)]",
  "bg-[var(--color-diary-secondary)]",
  "bg-[var(--color-vegtables-secondary)]",
  "bg-[var(--color-meat-secondary)]",
  "bg-[var(--color-non-food-secondary)]",
];

function accentForIndex(i: number): string {
  return (
    ACCENT_COLORS[i % ACCENT_COLORS.length] ??
    "bg-[var(--color-default-secondary)]"
  );
}

function dishPhoto(dish: string): string {
  const slug = dish
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/_/g, "-")
    .replace(/[^a-z0-9-]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");
  return `/dishes/${slug}.jpg`;
}

function DishCard({
  recipe,
  accent,
  onAdd,
}: {
  recipe: Recipe;
  accent: string;
  onAdd: () => void;
}) {
  const [imgError, setImgError] = useState(false);

  return (
    <button type="button" onClick={onAdd} className="group w-full text-left">
      <div
        className={`${accent} relative flex aspect-square w-full items-center justify-center overflow-hidden rounded-xl text-8xl ring-1 ring-border transition-transform duration-200 group-hover:scale-105`}
      >
        {!imgError ? (
          <Image
            src={dishPhoto(recipe.dish)}
            alt={recipe.dish.replace(/_/g, " ")}
            fill
            className="object-cover"
            sizes="(max-width: 640px) 60vw, (max-width: 768px) 40vw, 33vw"
            onError={() => setImgError(true)}
          />
        ) : (
          <span>{recipe.emoji}</span>
        )}
      </div>
      <div className="mt-3 px-0.5">
        <p className="truncate text-base font-medium text-foreground">
          {recipe.dish.replace(/_/g, " ")}
        </p>
        <p className="truncate text-sm text-muted-foreground">
          {recipe.ingredients.length} ingredients &middot; &euro;
          {recipe.ingredients
            .reduce((s, i) => s + i.default_price, 0)
            .toFixed(2)}
        </p>
      </div>
    </button>
  );
}

function DishRow({
  title,
  recipes,
  onAdd,
}: {
  title: string;
  recipes: Recipe[];
  onAdd: (recipe: Recipe) => void;
}) {
  return (
    <section className="px-8 sm:px-16">
      <h2 className="mb-4 text-xl font-semibold text-foreground">{title}</h2>
      <Carousel
        opts={{ align: "center", dragFree: true, loop: true }}
        plugins={[
          AutoScroll({
            speed: 0.5,
            startDelay: 500,
            stopOnInteraction: false,
            stopOnMouseEnter: true,
            stopOnFocusIn: true,
          }),
        ]}
      >
        <CarouselContent
          className="py-2"
          viewportClassName="[mask-image:linear-gradient(to_right,transparent,black_6%,black_94%,transparent)]"
        >
          {recipes.map((recipe, i) => (
            <CarouselItem
              key={recipe.id}
              className="basis-3/5 sm:basis-2/5 md:basis-1/3 lg:basis-1/4"
            >
              <DishCard
                recipe={recipe}
                accent={accentForIndex(i)}
                onAdd={() => onAdd(recipe)}
              />
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious className="left-2 -mt-5" />
        <CarouselNext className="right-2 -mt-5" />
      </Carousel>
    </section>
  );
}

function createPickyToast(
  msg: string,
  onConfirm: () => void,
  onDismiss: () => void,
) {
  toast.custom(
    (id) => (
      <div className="flex w-screen justify-center">
        <div className="relative flex w-72 flex-col items-center gap-2 rounded-xl border border-border bg-background p-3 text-center shadow-lg">
          <Image
            src="/picky-mascot.png"
            alt="Picky"
            width={124}
            height={124}
            className="absolute -top-28 left-1/2 animate-bounce-subtle"
          />
          <button
            type="button"
            className="absolute top-2 right-2 rounded-full p-0.5"
            onClick={() => {
              toast.dismiss(id);
              onDismiss();
            }}
          >
            <IconX className="size-3.5" />
          </button>
          <p className="px-4 text-base font-medium leading-snug">{msg}</p>
          <Button
            size="sm"
            className="w-full"
            onClick={() => {
              toast.dismiss(id);
              onConfirm();
            }}
          >
            View Cart
          </Button>
        </div>
      </div>
    ),
    { duration: Infinity },
  );
}

function showPickyToast(
  msg: string,
  onConfirm: () => void,
  onDismiss: () => void,
) {
  toast.dismiss();
  setTimeout(() => createPickyToast(msg, onConfirm, onDismiss), 400);
}

export default function BrowsePage() {
  const {
    notification,
    items,
    hasPendingPrediction,
    toastDismissed,
    pendingMessage,
    isAutoRunning,
    predictBasket,
    confirmBasket,
    dismissNotification,
    setToastDismissed,
    addRecipe,
    startAuto,
    stopAuto,
    fillCartDirect,
  } = useCart();
  const { user } = useUser();
  const router = useRouter();
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [loading, setLoading] = useState(true);
  const [recommendedRecipes, setRecommendedRecipes] = useState<Recipe[]>([]);

  useEffect(() => {
    fetchRecipes()
      .then(setRecipes)
      .catch((e) => {
        console.error("Failed to fetch recipes:", e);
      })
      .finally(() => setLoading(false));
  }, []);

  // Fetch top-15 recommendations and cross-reference against full recipe list.
  useEffect(() => {
    if (!user || recipes.length === 0) return;
    fetchRecommendations(user.id, 15)
      .then((response) => {
        const matched: Recipe[] = [];
        for (const meal of response.meals) {
          const norm = normaliseName(meal.dish);
          const found = recipes.find((r) => normaliseName(r.dish) === norm);
          if (found) matched.push(found);
        }
        setRecommendedRecipes(matched);
      })
      .catch(() => {/* model not ready — carousel stays hidden */});
  }, [user, recipes]);

  // Trigger prediction once recipes are loaded and cart is empty (not in auto mode).
  useEffect(() => {
    if (
      !isAutoRunning &&
      recipes.length > 0 &&
      items.length === 0 &&
      !notification &&
      !hasPendingPrediction &&
      user
    ) {
      const timer = setTimeout(() => predictBasket(user.id, recipes), 600);
      return () => clearTimeout(timer);
    }
  }, [
    isAutoRunning,
    recipes,
    items.length,
    notification,
    hasPendingPrediction,
    predictBasket,
    user,
  ]);

  // Auto-loop: when running and cart is empty, fetch recommendations, fill cart, go to cart.
  useEffect(() => {
    if (!isAutoRunning || !user || recipes.length === 0) return;
    let cancelled = false;

    function pickRandom<T>(arr: T[], n: number): T[] {
      return [...arr].sort(() => Math.random() - 0.5).slice(0, n);
    }

    fetchRecommendations(user.id, 5)
      .then((response) => {
        if (cancelled) return;
        const matched: Recipe[] = [];
        for (const meal of response.meals) {
          const norm = normaliseName(meal.dish);
          const found = recipes.find((r) => normaliseName(r.dish) === norm);
          if (found) matched.push(found);
        }
        fillCartDirect(matched.length > 0 ? matched : pickRandom(recipes, 3));
      })
      .catch(() => {
        if (cancelled) return;
        const picks = [...recipes].sort(() => Math.random() - 0.5).slice(0, 3);
        fillCartDirect(picks);
      })
      .finally(() => {
        if (!cancelled) {
          setTimeout(() => { if (!cancelled) router.push("/cart"); }, 1500);
        }
      });

    return () => { cancelled = true; };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isAutoRunning, user, recipes]);

  // Dismiss any open toast as soon as auto mode starts.
  useEffect(() => {
    if (isAutoRunning) toast.dismiss();
  }, [isAutoRunning]);

  // Show the Picky toast when a notification arrives and the user has opted in
  // (clicked the sparkle button). On first load toastDismissed is true so the
  // toast stays hidden and only the sparkle button appears.
  useEffect(() => {
    if (notification && !toastDismissed && !isAutoRunning) {
      dismissNotification();
      showPickyToast(
        notification,
        () => {
          confirmBasket();
          router.push("/cart");
        },
        () => setToastDismissed(true),
      );
    }
  }, [
    notification,
    toastDismissed,
    isAutoRunning,
    dismissNotification,
    confirmBasket,
    setToastDismissed,
    router,
  ]);

  const reopenToast = () => {
    if (pendingMessage) {
      showPickyToast(
        pendingMessage,
        () => {
          confirmBasket();
          router.push("/cart");
        },
        () => setToastDismissed(true),
      );
    } else if (recipes.length > 0 && user) {
      setToastDismissed(false);
      predictBasket(user.id, recipes);
    }
  };

  const handleAdd = (recipe: Recipe) => {
    addRecipe(recipe.dish.replace(/_/g, " "), recipe.ingredients);
    toast.dismiss();
    setToastDismissed(true);
    toast.custom(
      (id) => (
        <div className="pointer-events-none flex w-screen justify-center">
          <button type="button" onClick={() => toast.dismiss()} className="pointer-events-auto flex w-72 items-center gap-3 rounded-xl border border-border bg-background p-3 shadow-lg">
            <span className="text-2xl">{recipe.emoji}</span>
            <p className="flex-1 text-left text-sm font-medium leading-snug">
              {recipe.dish.replace(/_/g, " ")} added to cart
            </p>
          </button>
        </div>
      ),
      { duration: 2000, className: "!pointer-events-none" },
    );
  };

  // Group recipes by region.
  const byRegion: Record<string, Recipe[]> = {};
  for (const r of recipes) {
    if (!byRegion[r.region]) {
      byRegion[r.region] = [];
    }
    byRegion[r.region]?.push(r);
  }

  const regions = Object.keys(byRegion);

  return (
    <div className="min-h-screen bg-background py-10">
      <header className="mb-10 px-8 sm:px-16">
        <div className="flex items-center justify-between gap-4">
          <h1 className="text-3xl font-bold text-primary">Browse Dishes</h1>
          <Button
            size="sm"
            variant={isAutoRunning ? "destructive" : "outline"}
            onClick={isAutoRunning ? stopAuto : startAuto}
            className="shrink-0 gap-1.5"
          >
            {isAutoRunning ? (
              <>
                <IconPlayerStop className="size-4" />
                Stop Auto
              </>
            ) : (
              <>
                <IconRobot className="size-4" />
                Auto Shop
              </>
            )}
          </Button>
        </div>
        {isAutoRunning && (
          <p className="mt-2 text-sm text-muted-foreground animate-pulse">
            Fetching your Picky suggestions…
          </p>
        )}
        {!isAutoRunning && items.length > 0 && (
          <p className="mt-1 text-sm text-muted-foreground">
            {items.length} items in your predicted basket
          </p>
        )}
      </header>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <IconLoader2 className="size-8 animate-spin text-muted-foreground" />
        </div>
      ) : recipes.length === 0 ? (
        <div className="px-8 text-center text-muted-foreground sm:px-16">
          No recipes available. Make sure the backend is running.
        </div>
      ) : (
        <div className="flex flex-col gap-16">
          {recommendedRecipes.length > 0 && (
            <DishRow
              title="Recommended for You"
              recipes={recommendedRecipes}
              onAdd={handleAdd}
            />
          )}
          {regions.map((region) => (
            <DishRow
              key={region}
              title={region}
              recipes={byRegion[region] ?? []}
              onAdd={handleAdd}
            />
          ))}
        </div>
      )}

      {!isAutoRunning && toastDismissed && (hasPendingPrediction || pendingMessage) && (
        <button
          type="button"
          onClick={reopenToast}
          className="fixed bottom-20 right-4 z-[10000] flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform hover:scale-110"
        >
          <IconSparkles className="size-5" />
        </button>
      )}
    </div>
  );
}
