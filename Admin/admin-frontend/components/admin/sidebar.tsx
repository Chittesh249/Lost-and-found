"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import { LayoutDashboard, PlusCircleIcon, Users, Settings, ShoppingBasket } from "lucide-react"

const nav = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/dashboard/AddItems", label: "Add Items", icon: PlusCircleIcon },
  { href: "/dashboard/users", label: "Users", icon: Users },
  { href: "/dashboard/lostitems", label: "Lost Items", icon: ShoppingBasket },
]

export default function Sidebar() {
  const pathname = usePathname()

  return (
    <nav className="flex h-full flex-col">
      <div className="flex items-center gap-2 border-b p-4">
        <div className="size-8 rounded-md bg-blue-600" aria-hidden />
        <div>
          <p className="leading-none font-semibold">{""}</p>
          <p className="text-xs text-muted-foreground">{""}</p>
        </div>
      </div>

      <ul className="flex-1 space-y-1 p-2">
        {nav.map((item) => {
          const Icon = item.icon
          const active = pathname.startsWith(item.href)
          return (
            <li key={item.href}>
              <Link
                href={item.href}
                className={cn(
                  "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
                  active ? "bg-primary/10 text-primary" : "text-muted-foreground hover:bg-muted hover:text-foreground",
                )}
                aria-current={active ? "page" : undefined}
              >
                <Icon className="size-4" aria-hidden />
                <span>{item.label}</span>
              </Link>
            </li>
          )
        })}
      </ul>

      <div className="border-t p-4">
        <div className="rounded-md bg-muted p-3 text-xs text-muted-foreground">
          Tip: Use the menu button on mobile to open this sidebar.
        </div>
      </div>
    </nav>
  )
}
