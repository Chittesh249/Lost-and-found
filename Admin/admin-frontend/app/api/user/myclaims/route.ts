import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '../../../../lib/supabase-server'

export async function POST(req: Request) {
  const { user_id } = await req.json()
  const supabaseServer = await createServerSupabaseClient()

  const { data, error } = await supabaseServer
    .from('claims')
    .select(`
      id,
      status,
      created_at,
      list_items (
        id,
        title,
        image_path
      )
    `)
    .eq('user_id', user_id)
    .order('created_at', { ascending: false })

  if (error) {
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    )
  }

  return NextResponse.json(data)
}
