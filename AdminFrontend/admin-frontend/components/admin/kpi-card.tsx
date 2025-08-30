import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { cn } from "@/lib/utils"

type Props = {
  title: string
  value: string
  trend?: string
  trendTone?: "positive" | "neutral"
}

export function KpiCard({ title, value, trend, trendTone = "neutral" }: Props) {
  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-sm text-muted-foreground">{title}</CardTitle>
      </CardHeader>
      <CardContent className="flex items-end justify-between">
        <p className="text-2xl font-semibold">{value}</p>
        {trend ? (
          <span
            className={cn(
              "rounded-md px-2 py-1 text-xs font-medium",
              trendTone === "positive"
                ? "bg-emerald-50 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300"
                : "bg-muted text-foreground",
            )}
          >
            {trend}
          </span>
        ) : null}
      </CardContent>
    </Card>
  )
}
