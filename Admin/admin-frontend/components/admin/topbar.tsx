"use client"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import Sidebar from "./sidebar"
import { Menu, Bell } from "lucide-react"
import { ThemeToggle } from "./theme-toggle"
import { useRouter } from "next/navigation"
import axios from "axios"
import { useEffect, useState } from "react"
import { supabase } from "../../lib/realtimeSupabaseClient"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { ScrollArea } from "@/components/ui/scroll-area"

interface Notification {
  id: string
  message: string
  timestamp: Date
  read: boolean
  sourceId: string // claim_request.id (prevents duplicates)
}

export default function Topbar() {
  const router = useRouter()

  const [notifications, setNotifications] = useState<Notification[]>([])
  const [unreadCount, setUnreadCount] = useState(0)

  // --------------------------------------------------
  // LOAD EXISTING PENDING CLAIM REQUESTS
  // --------------------------------------------------
  const loadPendingClaims = async () => {
    const { data, error } = await supabase
      .from("claim_requests")
      .select("id, item_id, created_at")
      .eq("status", "pending")
      .order("created_at", { ascending: false })

    if (error) {
      console.error("Failed to load pending claims:", error)
      return
    }
    const pendingNotifications: Notification[] = data.map((row) => ({
      id: crypto.randomUUID(),
      sourceId: row.id,
      message: `Pending claim request for item ${row.item_id}`,
      timestamp: new Date(row.created_at),
      read: false,
    }))

    setNotifications(pendingNotifications)
    setUnreadCount(pendingNotifications.length)
  }

  // --------------------------------------------------
  // REALTIME SUBSCRIPTION
  // --------------------------------------------------
  useEffect(() => {
    loadPendingClaims()

    const channel = supabase
      .channel("admin-claim-notifications")

      // 🔔 NEW CLAIM REQUEST
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "claim_requests",
        },
        (payload) => {
          console.log({payload});
          const row = payload.new as any

          setNotifications((prev) => {
            // Prevent duplicates
            if (prev.some((n) => n.sourceId === row.id)) {
              return prev
            }

            const notification: Notification = {
              id: crypto.randomUUID(),
              sourceId: row.id,
              message: `New claim request for item ${row.item_id}`,
              timestamp: new Date(row.created_at),
              read: false,
            }

            setUnreadCount((count) => count + 1)
            return [notification, ...prev]
          })
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  const handleLogout = async () => {
    await axios.post("/api/admin/auth/logout")
    router.replace("/Login")
    router.refresh()
  }

  const handleNotificationClick = () => {
    setUnreadCount(0)
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  return (
    <header className="sticky top-0 z-30 w-full border-b bg-background/80 backdrop-blur">
      <div className="mx-auto flex h-14 max-w-7xl items-center gap-3 px-4 md:px-6">
        <Sheet>
          <SheetTrigger asChild className="md:hidden">
            <Button size="icon" variant="outline">
              <Menu className="size-4" />
            </Button>
          </SheetTrigger>
          <SheetContent side="bottom" className="p-0">
            <SheetHeader className="sr-only">
              <SheetTitle>Navigation</SheetTitle>
            </SheetHeader>
            <Sidebar />
          </SheetContent>
        </Sheet>

        <div className="flex-1">
          <Input type="search" placeholder="Search..." />
        </div>

        <Popover>
          <PopoverTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className="relative"
              onClick={handleNotificationClick}
            >
              <Bell className="size-4" />
              {unreadCount > 0 && (
                <span className="absolute -top-1 -right-1 h-5 w-5 text-xs rounded-full bg-red-600 text-white flex items-center justify-center font-semibold">{unreadCount}</span>
              )}
            </Button>
          </PopoverTrigger>

          <PopoverContent className="w-80 p-0" align="end">
            <div className="p-4 border-b font-semibold">
              Pending Notifications
            </div>

            <ScrollArea className="h-[300px]">
              {notifications.length === 0 ? (
                <div className="p-4 text-center text-sm text-muted-foreground">
                  No pending claim requests
                </div>
              ) : (
                notifications.map((n) => (
                  <div key={n.id} className="p-4 border-b cursor-pointer hover:bg-accent/50">
                    <p className="text-sm font-medium">{n.message}</p>
                    <p className="text-xs text-muted-foreground">
                      {n.timestamp.toLocaleString()}
                    </p>
                  </div>
                ))
              )}
            </ScrollArea>
          </PopoverContent>
        </Popover>

        <ThemeToggle />
        <Button onClick={handleLogout}>Logout</Button>
      </div>
    </header>
  )
}
