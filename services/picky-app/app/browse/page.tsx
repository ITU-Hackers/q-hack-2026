"use client"

import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@workspace/ui/components/carousel"

type Dish = {
  id: number
  name: string
  description: string
  emoji: string
  accent: string
}

const recommended: Dish[] = [
  { id: 1, name: "Creamy Pasta Carbonara", description: "Classic Italian comfort", emoji: "🍝", accent: "bg-[var(--color-default-secondary)]" },
  { id: 2, name: "Grilled Salmon", description: "With lemon butter sauce", emoji: "🐟", accent: "bg-[var(--color-diary-secondary)]" },
  { id: 3, name: "Avocado Toast", description: "Poached egg & chili flakes", emoji: "🥑", accent: "bg-[var(--color-vegtables-secondary)]" },
  { id: 4, name: "Beef Tacos", description: "With fresh salsa & guac", emoji: "🌮", accent: "bg-[var(--color-meat-secondary)]" },
  { id: 5, name: "Caesar Salad", description: "Crispy romaine & croutons", emoji: "🥗", accent: "bg-[var(--color-vegtables-secondary)]" },
  { id: 6, name: "Margherita Pizza", description: "San Marzano tomatoes", emoji: "🍕", accent: "bg-[var(--color-meat-secondary)]" },
  { id: 7, name: "Sushi Platter", description: "Chef's selection", emoji: "🍣", accent: "bg-[var(--color-diary-secondary)]" },
]

const popularNow: Dish[] = [
  { id: 8, name: "Smash Burger", description: "Double patty & secret sauce", emoji: "🍔", accent: "bg-[var(--color-default-secondary)]" },
  { id: 9, name: "Ramen Bowl", description: "Tonkotsu broth, soft egg", emoji: "🍜", accent: "bg-[var(--color-meat-secondary)]" },
  { id: 10, name: "Poke Bowl", description: "Ahi tuna & sesame", emoji: "🥣", accent: "bg-[var(--color-diary-secondary)]" },
  { id: 11, name: "BBQ Ribs", description: "Slow-smoked for 12 hours", emoji: "🍖", accent: "bg-[var(--color-meat-secondary)]" },
  { id: 12, name: "Pad Thai", description: "Wok-fried rice noodles", emoji: "🍜", accent: "bg-[var(--color-default-secondary)]" },
  { id: 13, name: "Shakshuka", description: "Eggs in spiced tomato", emoji: "🍳", accent: "bg-[var(--color-meat-secondary)]" },
  { id: 14, name: "Greek Bowl", description: "Falafel, tzatziki & pita", emoji: "🧆", accent: "bg-[var(--color-vegtables-secondary)]" },
]

const indianCuisine: Dish[] = [
  { id: 15, name: "Butter Chicken", description: "Creamy tomato masala", emoji: "🍛", accent: "bg-[var(--color-meat-secondary)]" },
  { id: 16, name: "Palak Paneer", description: "Spinach & cottage cheese", emoji: "🌿", accent: "bg-[var(--color-vegtables-secondary)]" },
  { id: 17, name: "Biryani", description: "Fragrant basmati & saffron", emoji: "🍚", accent: "bg-[var(--color-default-secondary)]" },
  { id: 18, name: "Samosa", description: "Crispy potato & pea filling", emoji: "🔺", accent: "bg-[var(--color-default-secondary)]" },
  { id: 19, name: "Dal Makhani", description: "Slow-cooked black lentils", emoji: "🫘", accent: "bg-[var(--color-meat-secondary)]" },
  { id: 20, name: "Naan Bread", description: "Tandoor-baked, garlic butter", emoji: "🫓", accent: "bg-[var(--color-non-food-secondary)]" },
  { id: 21, name: "Mango Lassi", description: "Chilled yogurt & mango", emoji: "🥭", accent: "bg-[var(--color-diary-secondary)]" },
]

function DishCard({ dish }: { dish: Dish }) {
  return (
    <div className="group cursor-pointer">
      <div
        className={`${dish.accent} relative flex aspect-[3/2] w-full items-center justify-center rounded-xl text-7xl ring-1 ring-border transition-transform duration-200 group-hover:scale-105`}
      >
        <span>{dish.emoji}</span>
      </div>
      <div className="mt-3 px-0.5">
        <p className="truncate text-base font-medium text-foreground">{dish.name}</p>
        <p className="truncate text-sm text-muted-foreground">{dish.description}</p>
      </div>
    </div>
  )
}

function DishRow({ title, dishes }: { title: string; dishes: Dish[] }) {
  return (
    <section className="px-16">
      <h2 className="mb-4 text-xl font-semibold text-foreground">{title}</h2>
      <Carousel opts={{ align: "start", dragFree: true }}>
        <CarouselContent>
          {dishes.map((dish) => (
            <CarouselItem key={dish.id} className="basis-1/2 sm:basis-1/3 md:basis-1/4 lg:basis-1/5">
              <DishCard dish={dish} />
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious className="left-2" />
        <CarouselNext className="right-2" />
      </Carousel>
    </section>
  )
}

export default function BrowsePage() {
  return (
    <div className="min-h-screen bg-background py-10">
      <header className="mb-10 px-16">
        <h1 className="text-3xl font-bold text-primary">Browse Dishes</h1>
      </header>

      <div className="flex flex-col gap-16">
        <DishRow title="Recommended for You" dishes={recommended} />
        <DishRow title="Popular Right Now" dishes={popularNow} />
        <DishRow title="Indian Cuisine" dishes={indianCuisine} />
      </div>
    </div>
  )
}
