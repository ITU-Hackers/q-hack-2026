"use client"

import { createContext, useContext, useState, useCallback } from "react"

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type Ingredient = {
    id: string
    name: string
    quantity: number
    unit: string
    price: number
    emoji: string
    recipeSource: string
}

// ---------------------------------------------------------------------------
// Recipe → ingredient lookup (mock data)
// Replace this with a real API call when ready.
// ---------------------------------------------------------------------------

type Recipe = {
    name: string
    ingredients: Omit<Ingredient, "id" | "recipeSource">[]
}

const RECIPE_INGREDIENTS: Record<string, Recipe> = {
    "Creamy Pasta Carbonara": {
        name: "Creamy Pasta Carbonara",
        ingredients: [
            { name: "Spaghetti", quantity: 1, unit: "500g", price: 1.49, emoji: "🍝" },
            { name: "Pancetta", quantity: 1, unit: "150g", price: 2.99, emoji: "🥓" },
            { name: "Eggs", quantity: 4, unit: "pcs", price: 1.29, emoji: "🥚" },
            { name: "Parmesan", quantity: 1, unit: "100g", price: 2.49, emoji: "🧀" },
        ],
    },
    "Grilled Salmon": {
        name: "Grilled Salmon",
        ingredients: [
            { name: "Salmon Fillet", quantity: 2, unit: "200g", price: 5.99, emoji: "🐟" },
            { name: "Lemon", quantity: 2, unit: "pcs", price: 0.69, emoji: "🍋" },
            { name: "Butter", quantity: 1, unit: "100g", price: 1.49, emoji: "🧈" },
            { name: "Asparagus", quantity: 1, unit: "250g", price: 2.29, emoji: "🌿" },
        ],
    },
    "Beef Tacos": {
        name: "Beef Tacos",
        ingredients: [
            { name: "Ground Beef", quantity: 1, unit: "500g", price: 4.49, emoji: "🥩" },
            { name: "Taco Shells", quantity: 1, unit: "8 pcs", price: 1.99, emoji: "🌮" },
            { name: "Avocado", quantity: 2, unit: "pcs", price: 1.49, emoji: "🥑" },
            { name: "Tomatoes", quantity: 3, unit: "pcs", price: 0.99, emoji: "🍅" },
            { name: "Sour Cream", quantity: 1, unit: "200ml", price: 1.19, emoji: "🥛" },
        ],
    },
    "Margherita Pizza": {
        name: "Margherita Pizza",
        ingredients: [
            { name: "Pizza Dough", quantity: 1, unit: "400g", price: 1.79, emoji: "🍕" },
            { name: "San Marzano Tomatoes", quantity: 1, unit: "400g", price: 1.99, emoji: "🍅" },
            { name: "Fresh Mozzarella", quantity: 2, unit: "125g", price: 1.79, emoji: "🧀" },
            { name: "Fresh Basil", quantity: 1, unit: "bunch", price: 1.29, emoji: "🌿" },
        ],
    },
    "Ramen Bowl": {
        name: "Ramen Bowl",
        ingredients: [
            { name: "Ramen Noodles", quantity: 2, unit: "packs", price: 1.89, emoji: "🍜" },
            { name: "Pork Belly", quantity: 1, unit: "300g", price: 4.99, emoji: "🥩" },
            { name: "Eggs", quantity: 4, unit: "pcs", price: 1.29, emoji: "🥚" },
            { name: "Spring Onions", quantity: 1, unit: "bunch", price: 0.89, emoji: "🧅" },
            { name: "Miso Paste", quantity: 1, unit: "100g", price: 2.49, emoji: "🫙" },
        ],
    },
    "Butter Chicken": {
        name: "Butter Chicken",
        ingredients: [
            { name: "Chicken Thighs", quantity: 1, unit: "600g", price: 4.49, emoji: "🍗" },
            { name: "Tomato Passata", quantity: 1, unit: "500ml", price: 1.29, emoji: "🍅" },
            { name: "Cream", quantity: 1, unit: "200ml", price: 1.19, emoji: "🥛" },
            { name: "Basmati Rice", quantity: 1, unit: "500g", price: 1.99, emoji: "🍚" },
            { name: "Garam Masala", quantity: 1, unit: "50g", price: 1.79, emoji: "🌶️" },
        ],
    },
    "Pad Thai": {
        name: "Pad Thai",
        ingredients: [
            { name: "Rice Noodles", quantity: 1, unit: "400g", price: 1.69, emoji: "🍜" },
            { name: "Shrimp", quantity: 1, unit: "300g", price: 5.49, emoji: "🦐" },
            { name: "Bean Sprouts", quantity: 1, unit: "200g", price: 0.99, emoji: "🌱" },
            { name: "Peanuts", quantity: 1, unit: "100g", price: 1.49, emoji: "🥜" },
            { name: "Lime", quantity: 2, unit: "pcs", price: 0.59, emoji: "🍋" },
        ],
    },
    "Greek Bowl": {
        name: "Greek Bowl",
        ingredients: [
            { name: "Falafel Mix", quantity: 1, unit: "300g", price: 2.29, emoji: "🧆" },
            { name: "Pita Bread", quantity: 4, unit: "pcs", price: 1.49, emoji: "🫓" },
            { name: "Cucumber", quantity: 1, unit: "pc", price: 0.69, emoji: "🥒" },
            { name: "Greek Yogurt", quantity: 1, unit: "200g", price: 1.29, emoji: "🥛" },
            { name: "Feta Cheese", quantity: 1, unit: "150g", price: 1.99, emoji: "🧀" },
        ],
    },
}

const RECIPE_NAMES = Object.keys(RECIPE_INGREDIENTS)

// ---------------------------------------------------------------------------
// Context
// ---------------------------------------------------------------------------

type CartState = {
    items: Ingredient[]
    selectedRecipes: string[]
    notification: string | null
    hasPendingPrediction: boolean
    predictBasket: () => void
    confirmBasket: () => void
    removeItem: (id: string) => void
    purchase: () => void
    dismissNotification: () => void
}

const CartContext = createContext<CartState | null>(null)

export function useCart() {
    const ctx = useContext(CartContext)
    if (!ctx) throw new Error("useCart must be used within CartProvider")
    return ctx
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

function pickRandom<T>(arr: T[], count: number): T[] {
    const shuffled = [...arr].sort(() => Math.random() - 0.5)
    return shuffled.slice(0, count)
}

export function CartProvider({ children }: { children: React.ReactNode }) {
    const [items, setItems] = useState<Ingredient[]>([])
    const [selectedRecipes, setSelectedRecipes] = useState<string[]>([])
    const [pendingItems, setPendingItems] = useState<Ingredient[]>([])
    const [notification, setNotification] = useState<string | null>(null)

    const predictBasket = useCallback(() => {
        const count = 2 + Math.floor(Math.random() * 2) // 2–3 recipes
        const recipes = pickRandom(RECIPE_NAMES, count)
        setSelectedRecipes(recipes)

        const newItems: Ingredient[] = []
        let idCounter = 0

        for (const recipeName of recipes) {
            const recipe = RECIPE_INGREDIENTS[recipeName]
            if (!recipe) continue
            for (const ing of recipe.ingredients) {
                const existing = newItems.find((i) => i.name === ing.name)
                if (existing) {
                    existing.quantity += ing.quantity
                } else {
                    newItems.push({
                        ...ing,
                        id: `item-${idCounter++}`,
                        recipeSource: recipeName,
                    })
                }
            }
        }

        setPendingItems(newItems)
        setNotification(
            `Hey it's Picky! I predicted your weekly basket — ${recipes.length} meals, ${newItems.length} items ready to go.`,
        )
    }, [])

    const confirmBasket = useCallback(() => {
        setItems(pendingItems)
        setPendingItems([])
        setNotification(null)
    }, [pendingItems])

    const removeItem = useCallback((id: string) => {
        setItems((prev) => prev.filter((i) => i.id !== id))
    }, [])

    const purchase = useCallback(() => {
        setItems([])
        setPendingItems([])
        setSelectedRecipes([])
        setNotification(null)
    }, [])

    const dismissNotification = useCallback(() => {
        setNotification(null)
    }, [])

    return (
        <CartContext
            value={{
                items,
                selectedRecipes,
                notification,
                hasPendingPrediction: pendingItems.length > 0,
                predictBasket,
                confirmBasket,
                removeItem,
                purchase,
                dismissNotification,
            }}
        >
            {children}
        </CartContext>
    )
}
