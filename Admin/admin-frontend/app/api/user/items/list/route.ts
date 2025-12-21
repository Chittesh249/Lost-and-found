import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function GET() {
  const supabaseServer = await createServerSupabaseClient()
  const { data, error } = await supabaseServer
    .from('lost_items')
    .select(`
      item_id,
      item_name,
      description,
      location_lost,
      date_lost,
      image_url,
      claimed
    `)
    .order('created_post', { ascending: false })

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json(data)
}
