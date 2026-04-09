"use client";

import { IconShoppingCart, IconTrash } from "@tabler/icons-react";
import { Button } from "@workspace/ui/components/button";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@workspace/ui/components/card";
import { Separator } from "@workspace/ui/components/separator";
import { useRouter } from "next/navigation";
import { useCart } from "../../../components/cart-context";

export default function CartPage() {
  const { items, selectedRecipes, removeItem, purchase } = useCart();
  const router = useRouter();

  const total = items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0,
  );

  const grouped = selectedRecipes
    .map((recipe) => ({
      recipe,
      ingredients: items.filter((i) => i.recipeSource === recipe),
    }))
    .filter((g) => g.ingredients.length > 0);

  if (items.length === 0) {
    return (
      <div className="flex min-h-[60vh] flex-col items-center justify-center gap-4 px-4">
        <IconShoppingCart className="size-12 text-muted-foreground" />
        <h2 className="text-lg font-semibold text-foreground">
          Your cart is empty
        </h2>
        <p className="text-sm text-muted-foreground">
          Head to Meals and we'll predict your weekly basket!
        </p>
        <Button onClick={() => router.push("/browse")}>Browse Meals</Button>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-lg px-4 py-8">
      <div className="mb-6 flex items-center gap-3">
        <IconShoppingCart className="size-6 text-primary" />
        <h1 className="text-2xl font-bold text-foreground">Your Cart</h1>
      </div>

      <div className="flex flex-col gap-4">
        {grouped.map(({ recipe, ingredients }) => (
          <Card key={recipe}>
            <CardHeader>
              <CardTitle className="text-base">{recipe}</CardTitle>
            </CardHeader>
            <CardContent className="flex flex-col gap-0 p-0">
              {ingredients.map((item, i) => (
                <div key={item.id}>
                  <div className="flex items-center gap-4 px-6 py-3">
                    <span className="text-2xl">{item.emoji}</span>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-foreground">
                        {item.name}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {item.quantity} {item.unit}
                      </p>
                    </div>
                    <span className="text-sm font-medium tabular-nums text-foreground">
                      &euro;{(item.price * item.quantity).toFixed(2)}
                    </span>
                    <Button
                      variant="ghost"
                      size="icon-xs"
                      onClick={() => removeItem(item.id)}
                    >
                      <IconTrash className="size-3.5 text-muted-foreground" />
                    </Button>
                  </div>
                  {i < ingredients.length - 1 && <Separator />}
                </div>
              ))}
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="mt-6 flex items-center justify-between px-1">
        <span className="text-sm text-muted-foreground">
          {items.length} items
        </span>
        <span className="text-lg font-semibold text-foreground">
          &euro;{total.toFixed(2)}
        </span>
      </div>

      <Button
        className="mt-4 w-full"
        onClick={() => {
          purchase();
          router.push("/browse");
        }}
      >
        Order with Picnic
      </Button>
    </div>
  );
}
