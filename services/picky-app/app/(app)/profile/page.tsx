import {
    Card,
    CardHeader,
    CardTitle,
    CardDescription,
    CardContent,
} from "@workspace/ui/components/card"
import { Separator } from "@workspace/ui/components/separator"
import { Button } from "@workspace/ui/components/button"
import {
    IconUser,
    IconBabyCarriage,
    IconDog,
    IconCat,
    IconEdit,
} from "@tabler/icons-react"

export default function ProfilePage() {
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
                            <span className="font-medium">user@example.com</span>
                        </div>
                        <Separator />
                        <div className="flex items-center justify-between">
                            <span className="text-muted-foreground">Member since</span>
                            <span className="font-medium">April 2026</span>
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
                            <span>2 adults</span>
                        </div>
                        <div className="flex items-center gap-3">
                            <IconBabyCarriage className="size-4 text-secondary" />
                            <span>0 kids</span>
                        </div>
                        <div className="flex items-center gap-3">
                            <IconDog className="size-4 text-amber-700" />
                            <span>1 dog</span>
                        </div>
                        <div className="flex items-center gap-3">
                            <IconCat className="size-4 text-muted-foreground" />
                            <span>0 cats</span>
                        </div>
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
                            <span className="font-medium">Italian, Thai, Indian</span>
                        </div>
                        <Separator />
                        <div className="flex items-center justify-between">
                            <span className="text-muted-foreground">Restrictions</span>
                            <span className="font-medium">Gluten Free</span>
                        </div>
                        <Separator />
                        <div className="flex items-center justify-between">
                            <span className="text-muted-foreground">Health goal</span>
                            <span className="font-medium">Balanced</span>
                        </div>
                        <Separator />
                        <div className="flex items-center justify-between">
                            <span className="text-muted-foreground">Cooking time</span>
                            <span className="font-medium">Moderate</span>
                        </div>
                        <Separator />
                        <div className="flex items-center justify-between">
                            <span className="text-muted-foreground">Budget</span>
                            <span className="font-medium">Moderate</span>
                        </div>
                    </CardContent>
                </Card>

                {/* Sign out */}
                <Button variant="outline" className="w-full">
                    Sign out
                </Button>
            </div>
        </div>
    )
}
