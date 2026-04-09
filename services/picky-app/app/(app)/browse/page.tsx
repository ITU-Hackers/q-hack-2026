"use client";

import { IconLoader2, IconSparkles, IconX } from "@tabler/icons-react";
import { Button } from "@workspace/ui/components/button";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@workspace/ui/components/carousel";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { toast } from "sonner";
import { type Recipe, fetchRecipes } from "@/lib/api";
import { useCart } from "../cart-context";

const ACCENT_COLORS = [
  "bg-[var(--color-default-secondary)]",
  "bg-[var(--color-diary-secondary)]",
  "bg-[var(--color-vegtables-secondary)]",
  "bg-[var(--color-meat-secondary)]",
  "bg-[var(--color-non-food-secondary)]",
];

function accentForIndex(i: number): string {
  return ACCENT_COLORS[i % ACCENT_COLORS.length] ?? "bg-[var(--color-default-secondary)]";
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
  return (
    <button type="button" onClick={onAdd} className="group w-full text-left">
      <div
        className={`${accent} relative flex aspect-square w-full items-center justify-center rounded-xl text-8xl ring-1 ring-border transition-transform duration-200 group-hover:scale-105`}
      >
        <span>{recipe.emoji}</span>
      </div>
      <div className="mt-3 px-0.5">
        <p className="truncate text-base font-medium text-foreground">
          {recipe.dish.replace(/_/g, " ")}
        </p>
        <p className="truncate text-sm text-muted-foreground">
          {recipe.ingredients.length} ingredients &middot;{" "}
          &euro;
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
      <Carousel opts={{ align: "center", dragFree: true, loop: true }}>
        <CarouselContent
          className="py-2"
          viewportClassName="[mask-image:linear-gradient(to_right,transparent,black_10%,black_90%,transparent)]"
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

function showPickyToast(
  msg: string,
  onConfirm: () => void,
  onDismiss: () => void,
) {
  toast.dismiss();

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
          onClick={() => { toast.dismiss(id); onDismiss(); }}
        >
          <IconX className="size-3.5" />
        </button>
        <p className="px-4 text-base font-medium leading-snug">{msg}</p>
        <Button
          size="sm"
          className="w-full"
          onClick={() => { toast.dismiss(id); onConfirm(); }}
        >
          View Cart
        </Button>
      </div>
      </div>
    ),
    { duration: Infinity },
  );
}

export default function BrowsePage() {
  const {
    notification,
    items,
    hasPendingPrediction,
    toastDismissed,
    pendingMessage,
    predictBasket,
    confirmBasket,
    dismissNotification,
    setToastDismissed,
    addRecipe,
  } = useCart();
  const router = useRouter();
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchRecipes()
      .then(setRecipes)
      .catch((e) => {
        console.error("Failed to fetch recipes:", e);
      })
      .finally(() => setLoading(false));
  }, []);

  // Trigger prediction once recipes are loaded and cart is empty.
  useEffect(() => {
    if (
      recipes.length > 0 &&
      items.length === 0 &&
      !notification &&
      !hasPendingPrediction
    ) {
      const timer = setTimeout(() => predictBasket(recipes), 600);
      return () => clearTimeout(timer);
    }
  }, [recipes, items.length, notification, hasPendingPrediction, predictBasket]);

  // Show the Picky toast when a notification arrives.
  useEffect(() => {
    if (notification) {
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
  }, [notification, dismissNotification, confirmBasket, setToastDismissed, router]);

  const reopenToast = () => {
    if (pendingMessage) {
      setToastDismissed(false);
      showPickyToast(
        pendingMessage,
        () => {
          confirmBasket();
          router.push("/cart");
        },
        () => setToastDismissed(true),
      );
    } else if (recipes.length > 0) {
      predictBasket(recipes);
    }
  };

  const handleAdd = (recipe: Recipe) => {
    addRecipe(recipe.dish.replace(/_/g, " "), recipe.ingredients);
    toast.success(
      `${recipe.emoji} ${recipe.dish.replace(/_/g, " ")} added to cart!`,
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
        <h1 className="text-3xl font-bold text-primary">Browse Dishes</h1>
        {items.length > 0 && (
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

      {toastDismissed && (
        <button
          type="button"
          onClick={reopenToast}
          className="fixed bottom-20 right-4 z-50 flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform hover:scale-110"
        >
          <IconSparkles className="size-5" />
        </button>
      )}
    </div>
  );
}
