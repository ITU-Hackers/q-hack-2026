"use client";

import { createContext, useCallback, useContext, useState } from "react";
import type { Recipe } from "@/lib/api";

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
  predictBasket: (allRecipes: Recipe[]) => void;
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

let nextId = 0;

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

  const predictBasket = useCallback((allRecipes: Recipe[]) => {
    if (allRecipes.length === 0) return;

    const count = 2 + Math.floor(Math.random() * 2);
    const picked = pickRandom(allRecipes, count);
    const recipeNames = picked.map((r) => r.dish.replace(/_/g, " "));
    setSelectedRecipes(recipeNames);

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

    const msg = `Hey it's Picky! I predicted your weekly basket \u2014 ${picked.length} meals, ${newItems.length} items ready to go.`;
    setPendingItems(newItems);
    setPendingMessage(msg);
    setNotification(msg);
    setToastDismissed(false);
  }, []);

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
