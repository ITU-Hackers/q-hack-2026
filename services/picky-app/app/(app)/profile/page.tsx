"use client";

import {
  IconBabyCarriage,
  IconCat,
  IconDog,
  IconEdit,
  IconUser,
} from "@tabler/icons-react";
import { Button } from "@workspace/ui/components/button";
import {
  Card,
  CardAction,
  CardContent,
  CardHeader,
  CardTitle,
} from "@workspace/ui/components/card";
import { Separator } from "@workspace/ui/components/separator";
import { useRouter } from "next/navigation";
import { useUser } from "@/components/user-context";
import { TransparencyPane } from "./transparency-pane";

function capitalize(s: string) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

export default function ProfilePage() {
  const { user, logout } = useUser();
  const router = useRouter();

  // The (app) layout already handles the unauthenticated redirect,
  // but guard here too in case of a brief render before that effect fires.
  if (!user) return null;

  function handleSignOut() {
    logout();
    router.replace("/");
  }

  const cuisinesLabel =
    user.cuisines.length > 0 ? user.cuisines.join(", ") : "None selected";

  const restrictionsLabel =
    user.restrictions.length > 0 ? user.restrictions.join(", ") : "None";

  return (
    <div className="mx-auto max-w-lg px-4 py-8">
      <h1 className="mb-6 text-2xl font-bold text-foreground">Profile</h1>

      <div className="flex flex-col gap-4">
        {/* Account */}
        <Card size="sm">
          <CardHeader>
            <CardTitle>Account</CardTitle>
          </CardHeader>
          <CardContent className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">Email</span>
            <span className="font-medium truncate max-w-[60%] text-right">{user.email}</span>
          </CardContent>
        </Card>

        {/* Household */}
        <Card size="sm">
          <CardHeader>
            <CardTitle>Household</CardTitle>
            <CardAction>
              <Button variant="ghost" size="icon-sm">
                <IconEdit className="size-3.5" />
              </Button>
            </CardAction>
          </CardHeader>
          <CardContent className="flex gap-4 text-sm flex-wrap">
            <span className="flex items-center gap-1.5">
              <IconUser className="size-3.5 text-primary" />
              {user.adults} adult{user.adults !== 1 ? "s" : ""}
            </span>
            <span className="flex items-center gap-1.5">
              <IconBabyCarriage className="size-3.5 text-secondary" />
              {user.kids} kid{user.kids !== 1 ? "s" : ""}
            </span>
            {user.dogs > 0 && (
              <span className="flex items-center gap-1.5">
                <IconDog className="size-3.5 text-amber-700" />
                {user.dogs} dog{user.dogs !== 1 ? "s" : ""}
              </span>
            )}
            {user.cats > 0 && (
              <span className="flex items-center gap-1.5">
                <IconCat className="size-3.5 text-muted-foreground" />
                {user.cats} cat{user.cats !== 1 ? "s" : ""}
              </span>
            )}
          </CardContent>
        </Card>

        {/* Preferences */}
        <Card size="sm">
          <CardHeader>
            <CardTitle>Preferences</CardTitle>
            <CardAction>
              <Button variant="ghost" size="icon-sm">
                <IconEdit className="size-3.5" />
              </Button>
            </CardAction>
          </CardHeader>
          <CardContent className="flex flex-col gap-2 text-sm">
            {[
              { label: "Cuisines", value: "1. Italian · 2. Asian · 3. Mediterranean" },
              { label: "Restrictions", value: "Gluten-free" },
              { label: "Health goal", value: "High protein" },
              { label: "Cooking time", value: "Quick (under 30 min)" },
              { label: "Budget", value: "Moderate (€50–80/wk)" },
            ].map(({ label, value }, i, arr) => (
              <div key={label}>
                <div className="flex items-center justify-between py-1">
                  <span className="text-muted-foreground">{label}</span>
                  <span className="font-medium text-right max-w-[60%]">{value}</span>
                </div>
                {i < arr.length - 1 && <Separator />}
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Transparency Pane */}
        <TransparencyPane user={user} />

        {/* Sign out */}
        <Button variant="outline" className="w-full" onClick={handleSignOut}>
          Sign out
        </Button>
      </div>
    </div>
  );
}
