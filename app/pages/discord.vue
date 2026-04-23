<template>
  <main class="login-page">
    <!-- Animated Background -->
    <div class="bg-blobs" aria-hidden="true">
      <div class="blob blob-1"></div>
      <div class="blob blob-2"></div>
      <div class="blob blob-3"></div>
    </div>

    <div class="login-card">
      <!-- Logo -->
      <div class="login-brand">
        <div class="logo-outer">
          <img
            src="/logo.png"
            alt="Sunshine Studio logo"
            class="login-logo"
            @error="(e) => (e.target.src = 'https://cdn.discordapp.com/embed/avatars/0.png')"
          >
        </div>
        <h1 class="login-title">Sunshine Studio Activity</h1>
        <p class="login-sub">
          Welcome to the Sunshine Studio Discord Activity.<br>
          Please agree to our terms before connecting your account.
        </p>
      </div>

      <!-- Error Message -->
      <Transition name="shake">
        <div v-if="errorMsg" class="error-banner">
          <ExclamationTriangleIcon class="error-badge-icon" />
          <span>{{ errorMsg }}</span>
        </div>
      </Transition>

      <!-- Agreements -->
      <div class="agreements">
        <label class="agreement-label">
          <input type="checkbox" v-model="agreedTos" class="agreement-checkbox">
          <span>I agree to the <NuxtLink to="/tos" target="_blank">Terms of Service</NuxtLink></span>
        </label>
        
        <label class="agreement-label">
          <input type="checkbox" v-model="agreedPrivacy" class="agreement-checkbox">
          <span>I agree to the <NuxtLink to="/datenschutz" target="_blank">Privacy Policy</NuxtLink></span>
        </label>
      </div>

      <!-- Discord button -->
      <button
        class="discord-btn"
        :disabled="isLoading || !agreedTos || !agreedPrivacy"
        @click="handleLogin"
      >
        <svg
          v-if="!isLoading"
          class="discord-icon"
          viewBox="0 0 24 24"
          fill="currentColor"
          aria-hidden="true"
        >
          <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028c.462-.63.874-1.295 1.226-1.994a.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z" />
        </svg>
        <div v-else class="mini-spinner"></div>
        <span>{{ isLoading ? 'Redirecting to Discord...' : 'Continue with Discord' }}</span>
      </button>

      <p class="login-note">
        We only access your Discord username and ID to create your account.
      </p>
    </div>
  </main>
</template>

<script setup>
import { ref } from 'vue'
import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'

const { signInWithDiscord, isLoggedIn } = useAuth()
const isLoading = ref(false)
const errorMsg = ref('')

const agreedTos = ref(false)
const agreedPrivacy = ref(false)

// If already logged in, redirect
if (import.meta.client && isLoggedIn.value) {
  navigateTo('/jobs')
}

async function handleLogin() {
  if (!agreedTos.value || !agreedPrivacy.value) {
    errorMsg.value = 'You must agree to the Terms of Service and Privacy Policy to continue.'
    return
  }
  
  isLoading.value = true
  errorMsg.value = ''
  try {
    await signInWithDiscord()
  } catch (e) {
    console.error('Login error:', e)
    errorMsg.value = e.message || 'Failed to connect to Discord'
    isLoading.value = false
  }
}

useSeoMeta({
  title: 'Discord Activity — Sunshine Studio',
  description: 'Connect your Discord account to Sunshine Studio through the Discord Activity.'
})
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 24px;
  position: relative;
  overflow: hidden;
}

/* Glassmorphism Card */
.login-card {
  width: 100%;
  max-width: 440px;
  background: rgba(var(--surface-rgb, 255, 255, 255), 0.8);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 24px;
  padding: 56px 40px;
  text-align: center;
  box-shadow: 0 20px 40px rgba(0,0,0,0.1);
  position: relative;
  z-index: 10;
}
.dark .login-card {
  background: rgba(24, 24, 27, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.08);
  box-shadow: 0 20px 40px rgba(0,0,0,0.3);
}

.login-brand { margin-bottom: 32px; }

.logo-outer {
  width: 72px;
  height: 72px;
  background: #fff;
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
  box-shadow: 0 4px 12px rgba(232, 55, 42, 0.2);
}
.login-logo { width: 50px; height: 50px; object-fit: contain; }

.login-title {
  font-size: 1.8rem;
  font-weight: 950;
  color: var(--text);
  margin: 0 0 10px;
  letter-spacing: -0.03em;
}

.login-sub {
  font-size: 0.92rem;
  color: var(--muted);
  line-height: 1.6;
  margin: 0;
}

/* Agreements */
.agreements {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 24px;
  text-align: left;
  background: rgba(0,0,0,0.03);
  padding: 16px;
  border-radius: 12px;
  border: 1px solid rgba(0,0,0,0.05);
}
.dark .agreements {
  background: rgba(255,255,255,0.03);
  border-color: rgba(255,255,255,0.05);
}
.agreement-label {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 0.9rem;
  color: var(--text);
  cursor: pointer;
  user-select: none;
}
.agreement-checkbox {
  width: 18px;
  height: 18px;
  border-radius: 4px;
  border: 2px solid var(--muted);
  accent-color: var(--red);
  cursor: pointer;
}
.agreement-label a {
  color: var(--red);
  text-decoration: none;
  font-weight: 600;
  transition: color 0.15s;
}
.agreement-label a:hover {
  text-decoration: underline;
  color: #c81e1e;
}

/* Discord button */
.discord-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  width: 100%;
  padding: 15px 24px;
  background: #5865F2;
  color: #fff;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 15px rgba(88, 101, 242, 0.35);
}
.discord-btn:hover:not(:disabled) {
  background: #4752c4;
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(88, 101, 242, 0.45);
}
.discord-btn:active:not(:disabled) { transform: translateY(0); }
.discord-btn:disabled { 
  opacity: 0.5; 
  cursor: not-allowed; 
  transform: none; 
  box-shadow: none;
  filter: grayscale(0.5);
}

.discord-icon { width: 24px; height: 24px; flex-shrink: 0; }

.mini-spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

.login-note {
  margin-top: 24px;
  font-size: 0.78rem;
  color: var(--subtle);
  line-height: 1.6;
}

/* Blobs */
.bg-blobs {
  position: absolute;
  inset: 0;
  z-index: 1;
  pointer-events: none;
}
.blob {
  position: absolute;
  width: 400px;
  height: 400px;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.15;
  animation: blob-float 20s infinite alternate;
}
.dark .blob { opacity: 0.12; }
.blob-1 { background: var(--red); top: -100px; left: -100px; }
.blob-2 { background: #3b82f6; bottom: -150px; right: -100px; animation-duration: 25s; }
.blob-3 { background: #8b5cf6; top: 20%; right: 20%; animation-duration: 18s; animation-direction: reverse; }

@keyframes blob-float {
  from { transform: translate(0, 0) scale(1); }
  to { transform: translate(50px, 30px) scale(1.1); }
}

/* Error banner */
.error-banner {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.2);
  color: #ef4444;
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 0.82rem;
  margin-bottom: 24px;
  text-align: left;
}
.error-badge-icon { width: 18px; height: 18px; flex-shrink: 0; }

/* Shake animation */
.shake-enter-active { animation: shake 0.4s cubic-bezier(.36,.07,.19,.97) both; }
@keyframes shake {
  10%, 90% { transform: translate3d(-1px, 0, 0); }
  20%, 80% { transform: translate3d(2px, 0, 0); }
  30%, 50%, 70% { transform: translate3d(-4px, 0, 0); }
  40%, 60% { transform: translate3d(4px, 0, 0); }
}
</style>
