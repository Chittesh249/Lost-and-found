"use client"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import Sidebar from "./sidebar"
import { Menu, Bell } from "lucide-react"
import { ThemeToggle } from "./theme-toggle"
import { useRouter } from "next/navigation"

export default function Topbar() {
  const router = useRouter();
  return (
    <header className="sticky top-0 z-30 w-full border-b bg-background/80 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="mx-auto flex h-14 max-w-7xl items-center gap-3 px-4 md:px-6">
        <Sheet>
          <SheetTrigger asChild className="md:hidden">
            <Button size="icon" variant="outline" aria-label="Open navigation menu">
              <Menu className="size-4" aria-hidden />
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="p-0">
            <SheetHeader className="sr-only">
              <SheetTitle>Navigation</SheetTitle>
            </SheetHeader>
            <Sidebar />
          </SheetContent>
        </Sheet>

        <div className="ml-0 w-full md:ml-2 md:w-auto md:flex-1">
          <form role="search" className="w-full max-w-sm">
            <Input type="search" placeholder="Search..." className="w-full" aria-label="Search" />
          </form>
        </div>

        <div className="ml-auto flex items-center gap-2">
          <Button variant="ghost" size="icon" aria-label="Notifications">
            <Bell className="size-4" aria-hidden />
          </Button>
          <ThemeToggle />
          <Button variant="default" size="default" aria-label="Notifications" onClick={() => {
            router.push("/Login");
          }}>
            Logout
          </Button>
        </div>
      </div>
    </header>
  )
}
