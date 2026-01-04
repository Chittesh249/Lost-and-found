import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { cn } from "@/lib/utils"

type Props = {
  title: string
  value: string
  trend?: string
  trendTone?: "positive" | "neutral" | "negative"
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
              trendTone === "negative"
              ? "bg-red-50 text-red-700 dark:bg-red-900/30 dark:text-red-300"
              : null
            )}
          >
            {trend}
          </span>
        ) : null}
      </CardContent>
    </Card>
  )
}
