import { createClient } from "@supabase/supabase-js";
import { KpiCard } from "@/components/admin/kpi-card";

// Initialize Supabase Client for Server Component
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
const supabase = createClient(supabaseUrl!, supabaseKey!);

async function getStats() {
  // Count Users
  const { count: usersCount, error: usersError } = await supabase
    .from("Users")
    .select("*", { count: "exact", head: true });

  // Count Lost Items
  const { count: lostItemsCount, error: lostItemsError } = await supabase
    .from("Lost_items")
    .select("*", { count: "exact", head: true });

  // Count Claimed Items (assuming 'claims' table tracks claims, OR we check a status)
  // Checking 'claims' table based on previously seen myclaims/route.ts
  const { count: claimedItemsCount, error: claimedItemsError } = await supabase
    .from("claims")
    .select("*", { count: "exact", head: true });

  return {
    users: usersCount || 0,
    lostItems: lostItemsCount || 0,
    claimedItems: claimedItemsCount || 0,
  };
}

export default async function DashboardPage() {
  const stats = await getStats();

  return (
    <div className="space-y-6">
      <section aria-labelledby="overview" className="space-y-2">
        <h1 id="overview" className="text-balance text-2xl font-semibold tracking-tight md:text-3xl">
          Dashboard Overview
        </h1>
        <p className="text-sm text-muted-foreground">Quick snapshot of your key metrics.</p>
      </section>

      <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <KpiCard title="Total Users" value={stats.users.toString()} trend="Active Accounts" trendTone="neutral" />
        <KpiCard title="Lost Items" value={stats.lostItems.toString()} trend="Reported Items" trendTone="neutral" />
        <KpiCard title="Claimed Items" value={stats.claimedItems.toString()} trend="Successfully Returned" trendTone="positive" />
      </section>
    </div>
  )
}
