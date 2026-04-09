"use client";

import { createContext, useCallback, useContext, useState } from "react";
import { fetchRecommendations, type Recipe } from "@/lib/api";

export type Ingredient = {
  id: string;
  name: string;
  quantity: number;
  unit: string;
  price: number;
  emoji: string;
  recipeSource: string;
};

type CartState = {
  items: Ingredient[];
  selectedRecipes: string[];
  notification: string | null;
  hasPendingPrediction: boolean;
  toastDismissed: boolean;
  pendingMessage: string | null;
  predictBasket: (profileId: string, allRecipes: Recipe[]) => void;
  confirmBasket: () => void;
  removeItem: (id: string) => void;
  purchase: () => void;
  dismissNotification: () => void;
  setToastDismissed: (v: boolean) => void;
  addRecipe: (
    recipeName: string,
    ingredients: {
      name: string;
      emoji: string;
      default_unit: string;
      default_price: number;
    }[],
  ) => void;
};

const CartContext = createContext<CartState | null>(null);

export function useCart() {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error("useCart must be used within CartProvider");
  return ctx;
}

function pickRandom<T>(arr: T[], count: number): T[] {
  const shuffled = [...arr].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, count);
}

/** Normalise a dish name for fuzzy matching: lowercase, no underscores/hyphens/extra spaces. */
function normaliseName(name: string): string {
  return name.toLowerCase().replace(/[_-]+/g, " ").replace(/\s+/g, " ").trim();
}

let nextId = 0;

function buildItems(picked: Recipe[]): {
  items: Ingredient[];
  recipeNames: string[];
} {
  const recipeNames = picked.map((r) => r.dish.replace(/_/g, " "));
  const newItems: Ingredient[] = [];

  for (const recipe of picked) {
    const recipeName = recipe.dish.replace(/_/g, " ");
    for (const ing of recipe.ingredients) {
      const existing = newItems.find((i) => i.name === ing.name);
      if (existing) {
        existing.quantity += 1;
      } else {
        newItems.push({
          id: `item-${nextId++}`,
          name: ing.name,
          quantity: 1,
          unit: ing.default_unit,
          price: ing.default_price,
          emoji: ing.emoji,
          recipeSource: recipeName,
        });
      }
    }
  }

  return { items: newItems, recipeNames };
}

export function CartProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<Ingredient[]>([]);
  const [selectedRecipes, setSelectedRecipes] = useState<string[]>([]);
  const [pendingItems, setPendingItems] = useState<Ingredient[]>([]);
  const [notification, setNotification] = useState<string | null>(null);
  const [toastDismissed, setToastDismissed] = useState(false);
  const [pendingMessage, setPendingMessage] = useState<string | null>(null);

  const addRecipe = useCallback(
    (
      recipeName: string,
      ingredients: {
        name: string;
        emoji: string;
        default_unit: string;
        default_price: number;
      }[],
    ) => {
      setSelectedRecipes((prev) =>
        prev.includes(recipeName) ? prev : [...prev, recipeName],
      );
      setItems((prev) => {
        const newItems = [...prev];
        for (const ing of ingredients) {
          const existing = newItems.find(
            (i) => i.name === ing.name && i.recipeSource === recipeName,
          );
          if (existing) {
            existing.quantity += 1;
          } else {
            newItems.push({
              id: `item-${nextId++}`,
              name: ing.name,
              quantity: 1,
              unit: ing.default_unit,
              price: ing.default_price,
              emoji: ing.emoji,
              recipeSource: recipeName,
            });
          }
        }
        return newItems;
      });
    },
    [],
  );

  const predictBasket = useCallback(
    (profileId: string, allRecipes: Recipe[]) => {
      if (allRecipes.length === 0) return;

      const applyPrediction = (picked: Recipe[]) => {
        const { items: newItems, recipeNames } = buildItems(picked);
        const msg = `Hey it's Picky! I predicted your weekly basket \u2014 ${picked.length} meals, ${newItems.length} items ready to go.`;
        setSelectedRecipes(recipeNames);
        setPendingItems(newItems);
        setPendingMessage(msg);
        setNotification(msg);
        setToastDismissed(false);
      };

      // Attempt to use the recommendation API, fall back to random picks on any failure.
      fetchRecommendations(profileId, 5)
        .then((response) => {
          const meals = response.meals;

          if (meals.length === 0) {
            applyPrediction(
              pickRandom(allRecipes, 2 + Math.floor(Math.random() * 2)),
            );
            return;
          }

          // Cross-reference recommended meal names against the full recipe list
          // to resolve real ingredient data (recommendations only carry string names).
          const matched: Recipe[] = [];
          for (const meal of meals) {
            const normMeal = normaliseName(meal.dish);
            const found = allRecipes.find(
              (r) => normaliseName(r.dish) === normMeal,
            );
            if (found) {
              matched.push(found);
            }
          }

          if (matched.length === 0) {
            // None of the recommended meals matched — fall back to random.
            applyPrediction(
              pickRandom(allRecipes, 2 + Math.floor(Math.random() * 2)),
            );
            return;
          }

          applyPrediction(matched);
        })
        .catch(() => {
          // Backend unreachable or model not ready — degrade gracefully.
          applyPrediction(
            pickRandom(allRecipes, 2 + Math.floor(Math.random() * 2)),
          );
        });
    },
    [],
  );

  const confirmBasket = useCallback(() => {
    setItems((prev) => {
      const merged = [...prev];
      for (const item of pendingItems) {
        const existing = merged.find((i) => i.name === item.name && i.recipeSource === item.recipeSource);
        if (existing) {
          existing.quantity += item.quantity;
        } else {
          merged.push(item);
        }
      }
      return merged;
    });
    setSelectedRecipes((prev) => {
      const newNames = pendingItems.map((i) => i.recipeSource);
      return [...new Set([...prev, ...newNames])];
    });
    setPendingItems([]);
    setPendingMessage(null);
    setNotification(null);
    setToastDismissed(false);
  }, [pendingItems]);

  const removeItem = useCallback((id: string) => {
    setItems((prev) => prev.filter((i) => i.id !== id));
  }, []);

  const purchase = useCallback(() => {
    setItems([]);
    setPendingItems([]);
    setPendingMessage(null);
    setSelectedRecipes([]);
    setNotification(null);
    setToastDismissed(false);
  }, []);

  const dismissNotification = useCallback(() => {
    setNotification(null);
  }, []);

  return (
    <CartContext
      value={{
        items,
        selectedRecipes,
        notification,
        hasPendingPrediction: pendingItems.length > 0,
        toastDismissed,
        pendingMessage,
        predictBasket,
        confirmBasket,
        removeItem,
        purchase,
        dismissNotification,
        setToastDismissed,
        addRecipe,
      }}
    >
      {children}
    </CartContext>
  );
}
