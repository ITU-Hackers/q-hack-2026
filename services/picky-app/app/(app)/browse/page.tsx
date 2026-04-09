"use client";

import { IconSparkles, IconX } from "@tabler/icons-react";
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
import { useEffect } from "react";
import { toast } from "sonner";
import { useCart } from "../cart-context";

type Dish = {
  id: number;
  name: string;
  description: string;
  emoji: string;
  accent: string;
};

const recommended: Dish[] = [
  {
    id: 1,
    name: "Creamy Pasta Carbonara",
    description: "Classic Italian comfort",
    emoji: "🍝",
    accent: "bg-[var(--color-default-secondary)]",
  },
  {
    id: 2,
    name: "Grilled Salmon",
    description: "With lemon butter sauce",
    emoji: "🐟",
    accent: "bg-[var(--color-diary-secondary)]",
  },
  {
    id: 3,
    name: "Avocado Toast",
    description: "Poached egg & chili flakes",
    emoji: "🥑",
    accent: "bg-[var(--color-vegtables-secondary)]",
  },
  {
    id: 4,
    name: "Beef Tacos",
    description: "With fresh salsa & guac",
    emoji: "🌮",
    accent: "bg-[var(--color-meat-secondary)]",
  },
  {
    id: 5,
    name: "Caesar Salad",
    description: "Crispy romaine & croutons",
    emoji: "🥗",
    accent: "bg-[var(--color-vegtables-secondary)]",
  },
  {
    id: 6,
    name: "Margherita Pizza",
    description: "San Marzano tomatoes",
    emoji: "🍕",
    accent: "bg-[var(--color-meat-secondary)]",
  },
  {
    id: 7,
    name: "Sushi Platter",
    description: "Chef's selection",
    emoji: "🍣",
    accent: "bg-[var(--color-diary-secondary)]",
  },
];

const popularNow: Dish[] = [
  {
    id: 8,
    name: "Smash Burger",
    description: "Double patty & secret sauce",
    emoji: "🍔",
    accent: "bg-[var(--color-default-secondary)]",
  },
  {
    id: 9,
    name: "Ramen Bowl",
    description: "Tonkotsu broth, soft egg",
    emoji: "🍜",
    accent: "bg-[var(--color-meat-secondary)]",
  },
  {
    id: 10,
    name: "Poke Bowl",
    description: "Ahi tuna & sesame",
    emoji: "🥣",
    accent: "bg-[var(--color-diary-secondary)]",
  },
  {
    id: 11,
    name: "BBQ Ribs",
    description: "Slow-smoked for 12 hours",
    emoji: "🍖",
    accent: "bg-[var(--color-meat-secondary)]",
  },
  {
    id: 12,
    name: "Pad Thai",
    description: "Wok-fried rice noodles",
    emoji: "🍜",
    accent: "bg-[var(--color-default-secondary)]",
  },
  {
    id: 13,
    name: "Shakshuka",
    description: "Eggs in spiced tomato",
    emoji: "🍳",
    accent: "bg-[var(--color-meat-secondary)]",
  },
  {
    id: 14,
    name: "Greek Bowl",
    description: "Falafel, tzatziki & pita",
    emoji: "🧆",
    accent: "bg-[var(--color-vegtables-secondary)]",
  },
];

const indianCuisine: Dish[] = [
  {
    id: 15,
    name: "Butter Chicken",
    description: "Creamy tomato masala",
    emoji: "🍛",
    accent: "bg-[var(--color-meat-secondary)]",
  },
  {
    id: 16,
    name: "Palak Paneer",
    description: "Spinach & cottage cheese",
    emoji: "🌿",
    accent: "bg-[var(--color-vegtables-secondary)]",
  },
  {
    id: 17,
    name: "Biryani",
    description: "Fragrant basmati & saffron",
    emoji: "🍚",
    accent: "bg-[var(--color-default-secondary)]",
  },
  {
    id: 18,
    name: "Samosa",
    description: "Crispy potato & pea filling",
    emoji: "🔺",
    accent: "bg-[var(--color-default-secondary)]",
  },
  {
    id: 19,
    name: "Dal Makhani",
    description: "Slow-cooked black lentils",
    emoji: "🫘",
    accent: "bg-[var(--color-meat-secondary)]",
  },
  {
    id: 20,
    name: "Naan Bread",
    description: "Tandoor-baked, garlic butter",
    emoji: "🫓",
    accent: "bg-[var(--color-non-food-secondary)]",
  },
  {
    id: 21,
    name: "Mango Lassi",
    description: "Chilled yogurt & mango",
    emoji: "🥭",
    accent: "bg-[var(--color-diary-secondary)]",
  },
];

function DishCard({ dish }: { dish: Dish }) {
  return (
    <div className="group cursor-pointer">
      <div
        className={`${dish.accent} relative flex aspect-square w-full items-center justify-center rounded-xl text-8xl ring-1 ring-border transition-transform duration-200 group-hover:scale-105`}
      >
        <span>{dish.emoji}</span>
      </div>
      <div className="mt-3 px-0.5">
        <p className="truncate text-base font-medium text-foreground">
          {dish.name}
        </p>
        <p className="truncate text-sm text-muted-foreground">
          {dish.description}
        </p>
      </div>
    </div>
  );
}

function DishRow({ title, dishes }: { title: string; dishes: Dish[] }) {
  return (
    <section className="px-8 sm:px-16">
      <h2 className="mb-4 text-xl font-semibold text-foreground">{title}</h2>
      <Carousel opts={{ align: "center", dragFree: true, loop: true }}>
        <CarouselContent
          className="py-2"
          viewportClassName="[mask-image:linear-gradient(to_right,transparent,black_10%,black_90%,transparent)]"
        >
          {dishes.map((dish) => (
            <CarouselItem
              key={dish.id}
              className="basis-3/5 sm:basis-2/5 md:basis-1/3 lg:basis-1/4"
            >
              <DishCard dish={dish} />
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
  } = useCart();
  const router = useRouter();

  useEffect(() => {
    if (items.length === 0 && !notification && !hasPendingPrediction) {
      const timer = setTimeout(() => predictBasket(), 600);
      return () => clearTimeout(timer);
    }
  }, [items.length, notification, hasPendingPrediction, predictBasket]);

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
    } else {
      predictBasket();
    }
  };

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

      <div className="flex flex-col gap-16">
        <DishRow title="Recommended for You" dishes={recommended} />
        <DishRow title="Popular Right Now" dishes={popularNow} />
        <DishRow title="Indian Cuisine" dishes={indianCuisine} />
      </div>

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
