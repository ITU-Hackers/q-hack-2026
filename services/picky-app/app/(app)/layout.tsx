"use client";

import {
  IconShoppingCart,
  IconToolsKitchen2,
  IconUser,
} from "@tabler/icons-react";
import { Badge } from "@workspace/ui/components/badge";
import { Toaster } from "@workspace/ui/components/sonner";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect } from "react";
import { useUser } from "@/components/user-context";
import { CartProvider, useCart } from "./cart-context";

const tabs = [
  { href: "/profile", label: "Profile", icon: IconUser },
  { href: "/browse", label: "Meals", icon: IconToolsKitchen2 },
  { href: "/cart", label: "Cart", icon: IconShoppingCart },
];

function BottomNav() {
  const pathname = usePathname();
  const { items } = useCart();
  const router = useRouter();
  const { user, mounted } = useUser();

  useEffect(() => {
    if (mounted && !user) {
      router.replace("/");
    }
  }, [mounted, user, router]);

  // Avoid flashing protected content before the localStorage check finishes.
  if (!mounted || !user) {
    return (
      <div className="flex min-h-svh items-center justify-center bg-background">
        <span className="text-sm text-muted-foreground">Loading…</span>
      </div>
    );
  }

  return (
    <nav className="fixed inset-x-0 bottom-0 z-50 border-t border-border bg-background/95 backdrop-blur-sm">
      <div className="mx-auto flex h-20 max-w-lg items-stretch justify-around">
        {tabs.map((tab) => {
          const active = pathname === tab.href;
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex flex-1 flex-col items-center justify-center gap-1 text-sm transition-colors ${
                active
                  ? "font-medium text-primary"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <span className="relative">
                <tab.icon
                  className={`size-7 transition-transform ${active ? "scale-110" : ""}`}
                />
                {tab.href === "/cart" && items.length > 0 && (
                  <Badge className="absolute -top-2 -right-3 size-4 justify-center p-0 text-[10px]">
                    {items.length}
                  </Badge>
                )}
              </span>
              {tab.label}
            </Link>
          );
        })}
      </div>
      <div className="h-[env(safe-area-inset-bottom)]" />
    </nav>
  );
}

export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <CartProvider>
      <div className="flex min-h-svh flex-col bg-background">
        <div className="flex-1 pb-24">{children}</div>
        <BottomNav />
        <Toaster
          position="bottom-center"
          containerAriaLabel="Notifications"
          style={{ bottom: "5rem", "--width": "100vw" } as React.CSSProperties}
        />
      </div>
    </CartProvider>
  );
}
