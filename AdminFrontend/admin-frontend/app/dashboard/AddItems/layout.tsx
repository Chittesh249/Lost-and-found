import type React from "react"
import DashboardPage from "./page"

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <div className="flex">
        <div className="flex min-h-screen flex-1 flex-col"> 
          <main className="p-4 md:p-6 lg:p-8">
            <div className="mx-auto w-full max-w-7xl">{<DashboardPage />}</div>
          </main>
        </div>
      </div>
    </div>
  )
}
