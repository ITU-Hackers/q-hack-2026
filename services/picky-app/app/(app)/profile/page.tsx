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
  CardContent,
  CardHeader,
  CardTitle,
} from "@workspace/ui/components/card";
import { Separator } from "@workspace/ui/components/separator";
import { useRouter } from "next/navigation";
import { useUser } from "@/components/user-context";

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
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Account</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col gap-3 text-sm">
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Email</span>
              <span className="font-medium truncate max-w-[60%] text-right">
                {user.email}
              </span>
            </div>
          </CardContent>
        </Card>

        {/* Household */}
        <Card>
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle className="text-base">Household</CardTitle>
            <Button variant="ghost" size="icon-sm">
              <IconEdit className="size-4" />
            </Button>
          </CardHeader>
          <CardContent className="flex flex-col gap-3 text-sm">
            <div className="flex items-center gap-3">
              <IconUser className="size-4 text-primary" />
              <span>
                {user.adults} adult{user.adults !== 1 ? "s" : ""}
              </span>
            </div>
            <div className="flex items-center gap-3">
              <IconBabyCarriage className="size-4 text-secondary" />
              <span>
                {user.kids} kid{user.kids !== 1 ? "s" : ""}
              </span>
            </div>
            {user.dogs > 0 && (
              <div className="flex items-center gap-3">
                <IconDog className="size-4 text-amber-700" />
                <span>
                  {user.dogs} dog{user.dogs !== 1 ? "s" : ""}
                </span>
              </div>
            )}
            {user.cats > 0 && (
              <div className="flex items-center gap-3">
                <IconCat className="size-4 text-muted-foreground" />
                <span>
                  {user.cats} cat{user.cats !== 1 ? "s" : ""}
                </span>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Preferences */}
        <Card>
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle className="text-base">Preferences</CardTitle>
            <Button variant="ghost" size="icon-sm">
              <IconEdit className="size-4" />
            </Button>
          </CardHeader>
          <CardContent className="flex flex-col gap-3 text-sm">
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Cuisines</span>
              <span className="font-medium text-right max-w-[60%]">
                {cuisinesLabel}
              </span>
            </div>
            <Separator />
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Restrictions</span>
              <span className="font-medium text-right max-w-[60%]">
                {restrictionsLabel}
              </span>
            </div>
            <Separator />
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Health goal</span>
              <span className="font-medium">
                {capitalize(user.health_goal)}
              </span>
            </div>
            <Separator />
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Cooking time</span>
              <span className="font-medium">
                {capitalize(user.cooking_time)}
              </span>
            </div>
            <Separator />
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Budget</span>
              <span className="font-medium">{capitalize(user.budget)}</span>
            </div>
          </CardContent>
        </Card>

        {/* Sign out */}
        <Button variant="outline" className="w-full" onClick={handleSignOut}>
          Sign out
        </Button>
      </div>
    </div>
  );
}
