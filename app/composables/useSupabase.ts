import { computed, onMounted, ref } from 'vue'
import { useState, useRuntimeConfig, navigateTo } from '#imports'
import { createClient } from '@supabase/supabase-js'
import type { User } from '@supabase/supabase-js'

let client: ReturnType<typeof createClient> | null = null

export function useSupabase() {
  const config = useRuntimeConfig()

  // Client-side singleton
  if (import.meta.client) {
    if (!client) {
      client = createClient(config.public.supabaseUrl as string, config.public.supabaseKey as string)
    }
    return client
  }

  // Server-side unique instance without session persistence to prevent lock steals
  return createClient(config.public.supabaseUrl as string, config.public.supabaseKey as string, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false
    }
  })
}

export function useAuth() {
  const user = useState<User | null>('auth-user', () => null)
  const profile = useState<any>('auth-profile', () => null)
  const loading = useState<boolean>('auth-loading', () => true)
  const supabase = useSupabase()

  async function fetchProfile(userId: string) {
    const { data } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle()
    profile.value = data
  }

  async function init() {
    loading.value = true
    const { data: { session } } = await supabase.auth.getSession()
    if (session?.user) {
      user.value = session.user
      await fetchProfile(session.user.id)
    }
    loading.value = false

    supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'INITIAL_SESSION') return // Prevent locking deadlocks

      if (session?.user) {
        user.value = session.user
        await fetchProfile(session.user.id)
      } else {
        user.value = null
        profile.value = null
      }
    })
  }

  async function signInWithDiscord() {
    const response = await supabase.auth.signInWithOAuth({
      provider: 'discord',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`
      }
    })
    if (response?.error) throw response.error
  }

  async function signOut() {
    await supabase.auth.signOut()
    user.value = null
    profile.value = null
    navigateTo('/')
  }

  const isAdmin = computed(() => {
    if (user.value?.id === 'a1cd4ac8-bc83-4084-b78e-e70997ba2a4c') return true
    return profile.value?.role === 'admin'
  })

  const isLoggedIn = computed(() => !!user.value)

  const permissions = computed(() => {
    const isOwner = profile.value?.discord_username === 'derkloking' || false
    return {
      can_manage_jobs: isOwner || profile.value?.can_manage_jobs || false,
      can_manage_staff: isOwner || profile.value?.can_manage_staff || false,
      can_ban_users: isOwner || profile.value?.can_ban_users || false,
      can_post_announcements: isOwner || profile.value?.can_post_announcements || false,
      can_send_notifications: isOwner || profile.value?.can_send_notifications || false,
      can_manage_notices: isOwner || profile.value?.can_manage_notices || false,
      isOwner
    }
  })

  return {
    user,
    profile,
    loading,
    isAdmin,
    isLoggedIn,
    permissions,
    init,
    signInWithDiscord,
    signOut,
    fetchProfile
  }
}
