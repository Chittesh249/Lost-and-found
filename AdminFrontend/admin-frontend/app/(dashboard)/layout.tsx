import type React from "react"
import Sidebar from "@/components/admin/sidebar"
import Topbar from "@/components/admin/topbar"

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <div className="flex">
        <aside className="hidden md:block w-64 border-r bg-card">
          <Sidebar />
        </aside>
        <div className="flex-1 flex min-h-screen flex-col">
          <Topbar />
          <main className="p-4 md:p-6 lg:p-8">
            <div className="mx-auto w-full max-w-7xl">{children}</div>
          </main>
        </div>
      </div>
    </div>
  )
}
