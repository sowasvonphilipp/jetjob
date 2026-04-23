<template>
  <div class="callback-page">
    <div class="spinner" />
    <p class="callback-text">
      Signing you in...
    </p>
  </div>
</template>

<script setup>
const supabase = useSupabase()

onMounted(async () => {
  // Supabase will parse the hash/query params from Discord redirect
  const { data: { session }, error } = await supabase.auth.getSession()

  if (error) {
    console.error('Auth callback error:', error)
    navigateTo('/login')
    return
  }

  if (session) {
    // Give time for the profile trigger to fire
    await new Promise(r => setTimeout(r, 500))
    const { fetchProfile } = useAuth()
    await fetchProfile(session.user.id)
    navigateTo('/jobs')
  } else {
    navigateTo('/login')
  }
})

useSeoMeta({ title: 'Signing in... — Sunshine Studio' })
</script>

<style scoped>
.callback-page {
  min-height: 60vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 20px;
}

.spinner {
  width: 36px;
  height: 36px;
  border: 3px solid var(--border);
  border-top-color: var(--red);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.callback-text {
  color: var(--muted);
  font-size: 0.9rem;
}
</style>
