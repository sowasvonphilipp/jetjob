<template>
  <main class="login-page">
    <div class="login-card">
      <!-- Logo -->
      <div class="login-brand">
        <img
          src="/logo.png"
          alt="Jet2 logo"
          class="login-logo"
        >
        <h1 class="login-title">
          Jet2 Jobs
        </h1>
        <p class="login-sub">
          Sign in to view listings, apply for roles, and track your applications.
        </p>
      </div>

      <!-- Discord button -->
      <button
        class="discord-btn"
        :disabled="isLoading"
        @click="handleLogin"
      >
        <svg
          class="discord-icon"
          viewBox="0 0 24 24"
          fill="currentColor"
          aria-hidden="true"
        >
          <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028c.462-.63.874-1.295 1.226-1.994a.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z" />
        </svg>
        <span v-if="!isLoading">Continue with Discord</span>
        <span v-else>Redirecting…</span>
      </button>

      <p class="login-note">
        We'll use your Discord account to identify you.<br>
        No password required.
      </p>
    </div>
  </main>
</template>

<script setup>
import { ref } from 'vue'

const { signInWithDiscord, isLoggedIn } = useAuth()
const isLoading = ref(false)

// If already logged in, redirect
if (import.meta.client && isLoggedIn.value) {
  navigateTo('/jobs')
}

async function handleLogin() {
  isLoading.value = true
  try {
    await signInWithDiscord()
  } catch (e) {
    console.error('Login error:', e)
    isLoading.value = false
  }
}

useSeoMeta({
  title: 'Sign In — Jet2 Jobs',
  description: 'Sign in with Discord to access the Jet2 Roblox airline job portal.'
})
</script>

<style scoped>
.login-page {
  min-height: 80vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 24px;
}

.login-card {
  width: 100%;
  max-width: 400px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 48px 36px;
  text-align: center;
  box-shadow: 0 8px 32px rgba(0,0,0,0.08);
}

.login-brand {
  margin-bottom: 32px;
}

.login-logo {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  object-fit: contain;
  margin-bottom: 16px;
}

.login-title {
  font-size: 1.5rem;
  font-weight: 900;
  color: var(--text);
  margin: 0 0 8px;
  letter-spacing: -0.02em;
}

.login-sub {
  font-size: 0.88rem;
  color: var(--muted);
  line-height: 1.6;
  margin: 0;
}

/* Discord button */
.discord-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  width: 100%;
  padding: 13px 20px;
  background: #5865F2;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 150ms ease, transform 130ms ease, box-shadow 150ms ease;
  box-shadow: 0 2px 12px rgba(88, 101, 242, 0.3);
}

.discord-btn:hover {
  background: #4752c4;
  transform: translateY(-1px);
  box-shadow: 0 4px 18px rgba(88, 101, 242, 0.4);
}

.discord-btn:active {
  transform: none;
}

.discord-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

.discord-icon {
  width: 22px;
  height: 22px;
  flex-shrink: 0;
}

.login-note {
  margin-top: 20px;
  font-size: 0.76rem;
  color: var(--subtle);
  line-height: 1.6;
}
</style>
