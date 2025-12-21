import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function POST() {
  const supabaseServer = await createServerSupabaseClient();
  await supabaseServer.auth.signOut()
  return NextResponse.json({ success: true })
}
