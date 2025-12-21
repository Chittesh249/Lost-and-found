import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function POST(req: Request) {
  const { item_id, answer, email } = await req.json()
  const supabaseServer = await createServerSupabaseClient()

  const { data: item } = await supabaseServer
    .from('lost_items')
    .select('claimed, answer')
    .eq('item_id', item_id)
    .single()

  if (!item || item.claimed) {
    return NextResponse.json(
      { error: 'Item already claimed or not found' },
      { status: 400 }
    )
  }

  if (item.answer !== answer) {
    return NextResponse.json(
      { error: 'Incorrect answer' },
      { status: 403 }
    )
  }

  await supabaseServer
    .from('lost_items')
    .update({
      claimed: true,
      claimed_by: {
        email,
        claimed_at: new Date().toISOString(),
      },
    })
    .eq('item_id', item_id)

  return NextResponse.json({ success: true })
}
