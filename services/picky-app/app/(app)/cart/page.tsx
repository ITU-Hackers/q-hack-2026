"use client";

import { IconCheck, IconPlayerStop, IconRobot, IconShoppingCart, IconTrash } from "@tabler/icons-react";
import { Button } from "@workspace/ui/components/button";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@workspace/ui/components/card";
import { Separator } from "@workspace/ui/components/separator";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useRef, useState } from "react";
import { useCart } from "../../../components/cart-context";

/* ------------------------------------------------------------------ */
/*  Canvas confetti                                                    */
/* ------------------------------------------------------------------ */

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  color: string;
  rotation: number;
  rotationSpeed: number;
  opacity: number;
}

const CONFETTI_COLORS = [
  "#e1171e", // Picnic red
  "#ff6b6b",
  "#ffd93d",
  "#6bcb77",
  "#4d96ff",
  "#ff922b",
  "#cc5de8",
  "#ffffff",
];

function spawnConfetti(
  canvas: HTMLCanvasElement,
  onDone: () => void,
) {
  const ctx = canvas.getContext("2d");
  if (!ctx) return;

  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  const particles: Particle[] = [];
  const count = 120;

  for (let i = 0; i < count; i++) {
    particles.push({
      x: canvas.width / 2 + (Math.random() - 0.5) * canvas.width * 0.4,
      y: canvas.height * 0.45,
      vx: (Math.random() - 0.5) * 14,
      vy: -Math.random() * 16 - 6,
      size: Math.random() * 8 + 4,
      color: CONFETTI_COLORS[Math.floor(Math.random() * CONFETTI_COLORS.length)]!,
      rotation: Math.random() * Math.PI * 2,
      rotationSpeed: (Math.random() - 0.5) * 0.3,
      opacity: 1,
    });
  }

  let frame = 0;
  const maxFrames = 300;

  function animate() {
    if (!ctx) return;
    frame++;
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    for (const p of particles) {
      p.x += p.vx;
      p.vy += 0.35; // gravity
      p.y += p.vy;
      p.rotation += p.rotationSpeed;
      if (frame > maxFrames - 60) {
        p.opacity = Math.max(0, p.opacity - 0.02);
      }

      ctx.save();
      ctx.translate(p.x, p.y);
      ctx.rotate(p.rotation);
      ctx.globalAlpha = p.opacity;
      ctx.fillStyle = p.color;
      ctx.fillRect(-p.size / 2, -p.size / 4, p.size, p.size / 2);
      ctx.restore();
    }

    if (frame < maxFrames) {
      requestAnimationFrame(animate);
    } else {
      onDone();
    }
  }

  requestAnimationFrame(animate);
}

/* ------------------------------------------------------------------ */
/*  Page                                                               */
/* ------------------------------------------------------------------ */

export default function CartPage() {
  const { items, selectedRecipes, removeItem, purchase, isAutoRunning, startAuto, stopAuto } = useCart();
  const router = useRouter();
  const [celebrating, setCelebrating] = useState(false);
  const canvasRef = useRef<HTMLCanvasElement>(null);

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

  const handlePurchase = useCallback(() => {
    setCelebrating(true);
  }, []);

  // Launch confetti when celebration starts
  useEffect(() => {
    if (!celebrating || !canvasRef.current) return;
    spawnConfetti(canvasRef.current, () => {
      setTimeout(() => {
        purchase();
        router.push("/browse");
      }, 1200);
    });
  }, [celebrating, purchase, router]);

  // Auto-loop: when running, either go to browse (cart empty) or auto-purchase.
  useEffect(() => {
    if (!isAutoRunning || celebrating) return;
    if (items.length === 0) {
      const t = setTimeout(() => router.push("/browse"), 400);
      return () => clearTimeout(t);
    }
    const t = setTimeout(() => setCelebrating(true), 2000);
    return () => clearTimeout(t);
  }, [isAutoRunning, items.length, celebrating, router]);

  if (items.length === 0) {
    return (
      <div className="flex min-h-[60vh] flex-col items-center justify-center gap-4 px-4">
        <IconShoppingCart className="size-12 text-muted-foreground" />
        <h2 className="text-lg font-semibold text-foreground">
          Your cart is empty
        </h2>
        <p className="text-sm text-muted-foreground text-center">
          Head to Meals and we&apos;ll predict your weekly basket!
        </p>
        <Button onClick={() => router.push("/browse")}>Browse Meals</Button>
        <Button
          variant={isAutoRunning ? "destructive" : "outline"}
          onClick={isAutoRunning ? stopAuto : startAuto}
          className="gap-1.5"
        >
          {isAutoRunning ? (
            <><IconPlayerStop className="size-4" />Stop Auto</>
          ) : (
            <><IconRobot className="size-4" />Auto Shop</>
          )}
        </Button>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-lg px-4 py-8">
      {/* Celebration overlay */}
      {celebrating && (
        <div className="fixed inset-0 z-[9999] flex items-center justify-center">
          {/* Backdrop */}
          <div className="absolute inset-0 animate-[fadeIn_0.3s_ease-out] bg-black/80" />

          {/* Confetti canvas */}
          <canvas
            ref={canvasRef}
            className="absolute inset-0 pointer-events-none"
          />

          {/* Success card */}
          <div className="relative z-10 flex flex-col items-center gap-4 animate-[scaleIn_0.5s_ease-out]">
            <div className="flex size-20 items-center justify-center rounded-full bg-primary shadow-xl animate-[bounceIn_0.6s_ease-out]">
              <IconCheck className="size-10 text-primary-foreground" strokeWidth={3} />
            </div>
            <Image
              src="/picky-mascot.png"
              alt="Picky"
              width={100}
              height={100}
              className="animate-[bounceIn_0.8s_ease-out]"
            />
            <p className="text-xl font-bold text-white drop-shadow-lg animate-[fadeIn_0.8s_ease-out]">
              Order placed!
            </p>
            <p className="text-sm text-white/80 drop-shadow animate-[fadeIn_1s_ease-out]">
              Picky is preparing your groceries
            </p>
          </div>
        </div>
      )}

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
        disabled={celebrating}
        onClick={handlePurchase}
      >
        Order with Picnic
      </Button>

      <Button
        className="mt-2 w-full gap-1.5"
        variant={isAutoRunning ? "destructive" : "outline"}
        disabled={celebrating}
        onClick={isAutoRunning ? stopAuto : startAuto}
      >
        {isAutoRunning ? (
          <><IconPlayerStop className="size-4" />Stop Auto</>
        ) : (
          <><IconRobot className="size-4" />Auto Shop</>
        )}
      </Button>
      {isAutoRunning && (
        <p className="mt-2 text-center text-xs text-muted-foreground animate-pulse">
          Auto purchasing… purchasing in 2s
        </p>
      )}

      {/* Keyframe animations */}
      <style jsx global>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes scaleIn {
          from { opacity: 0; transform: scale(0.5); }
          to { opacity: 1; transform: scale(1); }
        }
        @keyframes bounceIn {
          0% { opacity: 0; transform: scale(0.3); }
          50% { opacity: 1; transform: scale(1.1); }
          70% { transform: scale(0.95); }
          100% { transform: scale(1); }
        }
      `}</style>
    </div>
  );
}
