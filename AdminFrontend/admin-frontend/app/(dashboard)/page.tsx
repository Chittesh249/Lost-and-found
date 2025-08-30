import { KpiCard } from "@/components/admin/kpi-card"

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <section aria-labelledby="overview" className="space-y-4">
        <h1 id="overview" className="text-balance text-2xl font-semibold tracking-tight md:text-3xl">
          Dashboard Overview
        </h1>
        <p className="text-sm text-muted-foreground">Quick snapshot of your business metrics.</p>
      </section>

      <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-2">
        <KpiCard title="Total Items" value="$128,420" trend="+12.4%" trendTone="positive" />
        <KpiCard title="Active Users" value="24,581" trend="+5.2%" trendTone="positive" />
      </section>

      <section className="grid gap-4 lg:grid-cols-3">
      </section>
    </div>
  )
}
