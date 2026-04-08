"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { IconUser, IconToolsKitchen2, IconShoppingCart } from "@tabler/icons-react"
import { Badge } from "@workspace/ui/components/badge"
import { Toaster } from "@workspace/ui/components/sonner"
import { CartProvider, useCart } from "./cart-context"

const tabs = [
    { href: "/profile", label: "Profile", icon: IconUser },
    { href: "/browse", label: "Meals", icon: IconToolsKitchen2 },
    { href: "/cart", label: "Cart", icon: IconShoppingCart },
]

function BottomNav() {
    const pathname = usePathname()
    const { items } = useCart()

    return (
        <nav className="fixed inset-x-0 bottom-0 z-50 border-t border-border bg-background/95 backdrop-blur-sm">
            <div className="mx-auto flex h-16 max-w-lg items-stretch justify-around">
                {tabs.map((tab) => {
                    const active = pathname === tab.href
                    return (
                        <Link
                            key={tab.href}
                            href={tab.href}
                            className={`flex flex-1 flex-col items-center justify-center gap-1 text-xs transition-colors ${
                                active
                                    ? "font-medium text-primary"
                                    : "text-muted-foreground hover:text-foreground"
                            }`}
                        >
                            <span className="relative">
                                <tab.icon
                                    className={`size-5 transition-transform ${active ? "scale-110" : ""}`}
                                />
                                {tab.href === "/cart" && items.length > 0 && (
                                    <Badge className="absolute -top-2 -right-3 size-4 justify-center p-0 text-[10px]">
                                        {items.length}
                                    </Badge>
                                )}
                            </span>
                            {tab.label}
                        </Link>
                    )
                })}
            </div>
            <div className="h-[env(safe-area-inset-bottom)]" />
        </nav>
    )
}

export default function AppLayout({ children }: { children: React.ReactNode }) {
    return (
        <CartProvider>
            <div className="flex min-h-svh flex-col bg-background">
                <div className="flex-1 pb-20">{children}</div>
                <BottomNav />
                <Toaster
                    position="bottom-center"
                    containerAriaLabel="Notifications"
                    style={{ bottom: "5rem" }}
                />
            </div>
        </CartProvider>
    )
}
