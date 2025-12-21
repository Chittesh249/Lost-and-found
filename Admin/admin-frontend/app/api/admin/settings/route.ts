import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function GET() {
  const supabaseServer = await createServerSupabaseClient()
  const { data: { user } } = await supabaseServer.auth.getUser()

  if (!user || user.app_metadata?.role !== 'admin') {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { data } = await supabaseServer
    .from('settings')
    .select('*')
    .single()

  return NextResponse.json(data)
}

export async function PUT(req: Request) {
  const updates = await req.json()
  const supabaseServer = await createServerSupabaseClient()
  const { data: { user } } = await supabaseServer.auth.getUser()

  if (!user || user.app_metadata?.role !== 'admin') {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { error } = await supabaseServer
    .from('settings')
    .update(updates)
    .eq('id', 1)

  if (error) {
    return NextResponse.json(
      { error: error.message },
      { status: 400 }
    )
  }

  return NextResponse.json({ success: true })
}
