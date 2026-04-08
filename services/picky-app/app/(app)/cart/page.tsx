import {
    Card,
    CardHeader,
    CardTitle,
    CardContent,
    CardFooter,
} from "@workspace/ui/components/card"
import { Button } from "@workspace/ui/components/button"
import { Separator } from "@workspace/ui/components/separator"
import { IconShoppingCart, IconPlus, IconMinus } from "@tabler/icons-react"

const cartItems = [
    { id: 1, name: "Chicken Breast", quantity: 2, unit: "500g", price: 4.99, emoji: "🍗" },
    { id: 2, name: "Basmati Rice", quantity: 1, unit: "1kg", price: 2.49, emoji: "🍚" },
    { id: 3, name: "Fresh Basil", quantity: 1, unit: "bunch", price: 1.29, emoji: "🌿" },
    { id: 4, name: "Cherry Tomatoes", quantity: 1, unit: "250g", price: 1.99, emoji: "🍅" },
    { id: 5, name: "Mozzarella", quantity: 2, unit: "125g", price: 1.79, emoji: "🧀" },
]

const total = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0)

export default function CartPage() {
    return (
        <div className="mx-auto max-w-lg px-4 py-8">
            <div className="mb-6 flex items-center gap-3">
                <IconShoppingCart className="size-6 text-primary" />
                <h1 className="text-2xl font-bold text-foreground">Your Cart</h1>
            </div>

            <Card>
                <CardContent className="flex flex-col gap-0 p-0">
                    {cartItems.map((item, i) => (
                        <div key={item.id}>
                            <div className="flex items-center gap-4 px-6 py-4">
                                <span className="text-2xl">{item.emoji}</span>
                                <div className="flex-1">
                                    <p className="text-sm font-medium text-foreground">
                                        {item.name}
                                    </p>
                                    <p className="text-xs text-muted-foreground">
                                        {item.unit}
                                    </p>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Button variant="outline" size="icon-xs">
                                        <IconMinus className="size-3" />
                                    </Button>
                                    <span className="w-5 text-center text-sm font-medium tabular-nums">
                                        {item.quantity}
                                    </span>
                                    <Button variant="outline" size="icon-xs">
                                        <IconPlus className="size-3" />
                                    </Button>
                                </div>
                                <span className="w-14 text-right text-sm font-medium tabular-nums">
                                    €{(item.price * item.quantity).toFixed(2)}
                                </span>
                            </div>
                            {i < cartItems.length - 1 && <Separator />}
                        </div>
                    ))}
                </CardContent>
                <CardFooter className="flex items-center justify-between border-t border-border pt-6">
                    <span className="text-sm text-muted-foreground">
                        {cartItems.length} items
                    </span>
                    <span className="text-lg font-semibold text-foreground">
                        €{total.toFixed(2)}
                    </span>
                </CardFooter>
            </Card>

            <Button className="mt-4 w-full">
                Order with Picnic
            </Button>
        </div>
    )
}
