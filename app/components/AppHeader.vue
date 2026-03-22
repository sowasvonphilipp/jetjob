<template>
  <header
    :class="['app-header', { dark: isDark }]"
    role="banner"
  >
    <!-- Announcement banner -->
    <Transition name="banner-slide">
      <div
        v-if="showBanner"
        class="announcement"
        role="alert"
      >
        <div class="announcement-inner">
          <MegaphoneIcon
            class="ann-icon"
            aria-hidden="true"
          />
          <span class="ann-text">{{ announcement.text }}</span>
          <NuxtLink
            v-if="announcement.link"
            :to="announcement.link.to"
            class="ann-link"
          >
            {{ announcement.link.label }}
            <ArrowRightIcon
              class="ann-arrow"
              aria-hidden="true"
            />
          </NuxtLink>
        </div>
        <button
          class="ann-close"
          aria-label="Dismiss announcement"
          @click="dismissBanner"
        >
          <XMarkIcon
            class="ann-close-icon"
            aria-hidden="true"
          />
        </button>
      </div>
    </Transition>

    <!-- Demo Disclaimer -->
    <div class="demo-disclaimer">
      <div class="demo-inner">
        <span class="demo-tag">DEMO</span>
        <span class="demo-text">This is a development preview of Jet2 Jobs. Some data may be reset periodically.</span>
      </div>
    </div>

    <!-- Nav bar -->
    <div class="header-inner">
      <!-- Brand -->
      <NuxtLink
        class="brand-link"
        to="/"
        @click="mobileOpen = false"
      >
        <img
          src="/logo.png"
          alt="Jet2 logo"
          class="logo"
        >
        <span class="brand-name">Jet2 Jobs</span>
      </NuxtLink>

      <!-- Desktop Nav -->
      <nav
        class="main-nav"
        aria-label="Main navigation"
      >
        <ul>
          <li
            v-for="link in navLinks"
            :key="link.to"
          >
            <NuxtLink
              :to="link.to"
              :class="['nav-link', { active: $route.path === link.to }]"
            >
              <component
                :is="link.icon"
                class="nav-icon"
                aria-hidden="true"
              />
              {{ link.label }}
            </NuxtLink>
          </li>
        </ul>
      </nav>

      <!-- Search -->
      <form
        class="search-form"
        role="search"
        @submit.prevent="submitSearch"
      >
        <label
          for="header-search"
          class="sr-only"
        >Search jobs</label>
        <div class="search-wrap">
          <MagnifyingGlassIcon
            class="search-icon"
            aria-hidden="true"
          />
          <input
            id="header-search"
            v-model="searchQuery"
            type="search"
            class="search-input"
            placeholder="Search roles…"
            autocomplete="off"
          >
        </div>
      </form>

      <!-- Controls -->
      <div class="controls">
        <!-- Admin link -->
        <ClientOnly>
          <NuxtLink
            v-if="isAdmin"
            to="/admin"
            class="admin-link icon-btn"
            title="Admin Panel"
          >
            <ShieldCheckIcon class="icon" />
          </NuxtLink>
        </ClientOnly>

        <ClientOnly>
          <button
            :class="['icon-btn', 'mode-toggle', { toggling }]"
            :aria-pressed="isDark"
            :title="isDark ? 'Switch to light mode' : 'Switch to dark mode'"
            @click="toggleTheme"
          >
            <span
              class="toggle-ripple"
              aria-hidden="true"
            />
            <Transition
              name="icon-swap"
              mode="out-in"
            >
              <SunIcon
                v-if="isDark"
                key="sun"
                class="icon"
                aria-hidden="true"
              />
              <MoonIcon
                v-else
                key="moon"
                class="icon"
                aria-hidden="true"
              />
            </Transition>
            <span class="sr-only">Toggle theme</span>
          </button>
          <template #fallback>
            <div style="width: 36px; height: 36px" />
          </template>
        </ClientOnly>

        <!-- Notifications Bell -->
        <ClientOnly>
          <NuxtLink
            v-if="isLoggedIn"
            to="/notifications"
            class="icon-btn notif-btn"
            title="Notifications"
          >
            <BellIcon
              class="icon"
              aria-hidden="true"
            />
            <span
              v-if="unreadCount > 0"
              class="notif-dot"
            />
          </NuxtLink>
        </ClientOnly>

        <!-- Auth button -->
        <ClientOnly>
          <template v-if="isLoggedIn">
            <div class="avatar-dropdown-wrapper">
              <button
                class="avatar-btn"
                title="Account menu"
                @click.stop="userMenuOpen = !userMenuOpen"
              >
                <img
                  v-if="user?.user_metadata?.avatar_url"
                  :src="user.user_metadata.avatar_url"
                  alt="Your avatar"
                  class="user-avatar"
                >
                <span
                  v-else
                  class="user-avatar-placeholder"
                >
                  {{ (user?.user_metadata?.full_name || '?')[0] }}
                </span>
              </button>

              <Transition name="dropdown">
                <div v-if="userMenuOpen" class="avatar-dropdown-menu">
                  <div class="dropdown-header">
                    <span class="dropdown-name">{{ user?.user_metadata?.full_name || user?.user_metadata?.custom_claims?.global_name || 'User' }}</span>
                  </div>
                  <NuxtLink to="/profile" class="dropdown-item" @click="userMenuOpen = false">
                    <component :is="UserIcon" class="dropdown-icon" /> Profile
                  </NuxtLink>
                  <NuxtLink to="/settings" class="dropdown-item" @click="userMenuOpen = false">
                    <component :is="Cog8ToothIcon" class="dropdown-icon" /> Settings
                  </NuxtLink>
                  <NuxtLink to="/cv-generator" class="dropdown-item" @click="userMenuOpen = false">
                    <component :is="ClipboardDocumentListIcon" class="dropdown-icon" /> CV Generator
                  </NuxtLink>
                  <div class="dropdown-divider"></div>
                  <button class="dropdown-item logout-item" @click="handleSignOut">
                    <component :is="ArrowRightOnRectangleIcon" class="dropdown-icon" /> Sign Out
                  </button>
                </div>
              </Transition>
            </div>
          </template>
          <NuxtLink
            v-else
            to="/login"
            class="login-btn"
          >
            Sign In
          </NuxtLink>
        </ClientOnly>

        <button
          class="hamburger"
          :class="{ open: mobileOpen }"
          :aria-expanded="mobileOpen"
          aria-controls="mobile-menu"
          aria-label="Toggle navigation menu"
          @click="mobileOpen = !mobileOpen"
        >
          <span />
          <span />
          <span />
        </button>
      </div>
    </div>

    <!-- Mobile Menu -->
    <Transition name="mobile-slide">
      <nav
        v-if="mobileOpen"
        id="mobile-menu"
        class="mobile-nav"
        aria-label="Mobile navigation"
      >
        <form
          class="mobile-search-form"
          role="search"
          @submit.prevent="submitSearch"
        >
          <div class="search-wrap">
            <MagnifyingGlassIcon
              class="search-icon"
              aria-hidden="true"
            />
            <input
              v-model="searchQuery"
              type="search"
              class="search-input"
              placeholder="Search roles…"
              autocomplete="off"
            >
          </div>
        </form>
        <ul>
          <li
            v-for="link in navLinks"
            :key="link.to"
          >
            <NuxtLink
              :to="link.to"
              :class="['mobile-link', { active: $route.path === link.to }]"
              @click="mobileOpen = false"
            >
              <component
                :is="link.icon"
                class="nav-icon"
                aria-hidden="true"
              />
              {{ link.label }}
            </NuxtLink>
          </li>
        </ul>
      </nav>
    </Transition>
  </header>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import {
  SunIcon,
  MoonIcon,
  HomeIcon,
  BriefcaseIcon,
  ClipboardDocumentListIcon,
  UserIcon,
  Cog8ToothIcon,
  ShieldCheckIcon,
  Bars3Icon,
  XMarkIcon,
  MagnifyingGlassIcon,
  ArrowRightIcon,
  MegaphoneIcon,
  BellIcon,
  ArrowRightOnRectangleIcon
} from '@heroicons/vue/24/outline'

const { user, isLoggedIn, isAdmin, signOut } = useAuth()
const supabase = useSupabase()

const unreadCount = ref(0)

const router = useRouter()

// ── Theme ───────────────────────────────────────────────────────────────────
const THEME_KEY = 'jetjob-theme'
const isDark = ref(false)
const toggling = ref(false)
const mobileOpen = ref(false)
const userMenuOpen = ref(false)

function closeUserMenu(e) {
  if (!e.target.closest('.avatar-dropdown-wrapper')) {
    userMenuOpen.value = false
  }
}

function updateDocumentClass(dark) {
  if (import.meta.client) document.documentElement.classList.toggle('dark', dark)
}

function toggleTheme() {
  toggling.value = true
  setTimeout(() => {
    toggling.value = false
  }, 500)
  isDark.value = !isDark.value
  updateDocumentClass(isDark.value)
  if (import.meta.client)
    localStorage.setItem(THEME_KEY, isDark.value ? 'dark' : 'light')
}

// ── Nav ─────────────────────────────────────────────────────────────────────
const navLinks = [
  { to: '/', label: 'Home', icon: HomeIcon },
  { to: '/jobs', label: 'Job Listings', icon: BriefcaseIcon },
  {
    to: '/applications',
    label: 'My Applications',
    icon: ClipboardDocumentListIcon
  },
  { to: '/profile', label: 'Profile', icon: UserIcon },
  { to: '/settings', label: 'Settings', icon: Cog8ToothIcon }
]

async function handleSignOut() {
  await signOut()
}

// ── Search ───────────────────────────────────────────────────────────────────
const searchQuery = ref('')
function submitSearch() {
  const q = searchQuery.value.trim()
  if (!q) return
  mobileOpen.value = false
  router.push({ path: '/jobs', query: { q } })
}

// ── Announcement ─────────────────────────────────────────────────────────────
const BANNER_KEY = 'jetjob-banner-v1'
const showBanner = ref(false)
const announcement = {
  text: 'End of Q1 Application Wave opened! Apply now!',
  link: { to: '/jobs', label: 'Apply now' }
}
function dismissBanner() {
  showBanner.value = false
  if (import.meta.client) localStorage.setItem(BANNER_KEY, 'dismissed')
}

// ── Mount ───────────────────────────────────────────────────────────────────
onMounted(async () => {
  if (import.meta.client) {
    document.addEventListener('click', closeUserMenu)
    if (localStorage.getItem(THEME_KEY) === 'dark') {
      isDark.value = true
      updateDocumentClass(true)
    } else {
      // If not explicitly dark, check system preference or default to light
      isDark.value = window.matchMedia?.('(prefers-color-scheme: dark)').matches ?? false
      updateDocumentClass(isDark.value)
    }

    // Original banner logic used "dismissed", new instruction uses announcement.text
    // Assuming the instruction intends to check if the *current* announcement has been dismissed.
    // If the banner key is "dismissed" or if the stored banner text doesn't match the current announcement, show it.
    const storedBannerState = localStorage.getItem(BANNER_KEY)
    if (storedBannerState !== 'dismissed' && storedBannerState !== announcement.text) {
      showBanner.value = true
    }
  }

  async function fetchUnread() {
    if (isLoggedIn.value && user.value) {
      const { count } = await supabase
        .from('notifications')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', user.value.id)
        .eq('is_read', false)
      unreadCount.value = count || 0
    }
  }

  fetchUnread()
  if (import.meta.client) {
    window.addEventListener('notifications:refresh', fetchUnread)
  }
})

onBeforeUnmount(() => {
  if (import.meta.client) {
    document.removeEventListener('click', closeUserMenu)
    window.removeEventListener('notifications:refresh', fetchUnread)
  }
})
</script>

<style scoped>
/* ─── Tokens ─────────────────────────────────────────────────────────────── */
.app-header {
  --bg: #1e3a6e;
  --border: rgba(255, 255, 255, 0.1);
  --text: #fff;
  --muted: rgba(255, 255, 255, 0.52);
  --hover: rgba(255, 255, 255, 0.9);
  --active: #fff;
  --red: #e8372a;
  --red-hover: #ff4438;
  --red-glow: rgba(232, 55, 42, 0.3);
}
.app-header.dark {
  --bg: #0f1117;
  --border: rgba(255, 255, 255, 0.07);
  --text: #d4dff0;
  --muted: rgba(212, 223, 240, 0.42);
  --hover: #e8f0ff;
  --active: #fff;
}

/* ─── Shell ──────────────────────────────────────────────────────────────── */
.app-header {
  position: sticky;
  top: 0;
  width: 100%;
  z-index: 60;
  background: var(--bg);
  border-bottom: 1px solid var(--border);
  color: var(--text);
  transition: background 300ms ease;
}

/* ─── Demo Disclaimer ────────────────────────────────────────────────────── */
.demo-disclaimer {
  background: #000;
  color: #fff;
  padding: 6px 20px;
  border-bottom: 1px solid rgba(255,255,255,0.1);
}
.demo-inner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  max-width: 1400px;
  margin: 0 auto;
}
.demo-tag {
  background: #ef4444;
  color: #fff;
  font-size: 0.65rem;
  font-weight: 800;
  padding: 1px 6px;
  border-radius: 4px;
}
.demo-text {
  font-size: 0.72rem;
  font-weight: 600;
  color: #a1a1aa;
}

/* ─── Announcement ───────────────────────────────────────────────────────── */
.announcement {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 9px 20px;
  background: var(--red);
  color: #fff;
  font-size: 0.82rem;
  font-weight: 500;
}

.announcement-inner {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  flex-wrap: wrap;
}

.ann-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
  opacity: 0.9;
}

.ann-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #fff;
  font-weight: 700;
  text-decoration: underline;
  text-underline-offset: 2px;
  white-space: nowrap;
  transition: opacity 150ms ease;
}
.ann-link:hover {
  opacity: 0.8;
}
.ann-arrow {
  width: 13px;
  height: 13px;
}

.ann-close {
  border: 0;
  background: rgba(255, 255, 255, 0.18);
  color: #fff;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: background 150ms ease;
}
.ann-close:hover {
  background: rgba(255, 255, 255, 0.32);
}
.ann-close-icon {
  width: 15px;
  height: 15px;
}

/* Banner animation */
.banner-slide-enter-active,
.banner-slide-leave-active {
  overflow: hidden;
  transition:
    max-height 280ms ease,
    opacity 200ms ease,
    padding 280ms ease;
}
.banner-slide-enter-from,
.banner-slide-leave-to {
  max-height: 0;
  opacity: 0;
  padding-top: 0;
  padding-bottom: 0;
}
.banner-slide-enter-to,
.banner-slide-leave-from {
  max-height: 60px;
}

/* ─── Nav bar layout ─────────────────────────────────────────────────────── */
.header-inner {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  height: 60px;
  padding: 0 24px;
  gap: 24px;
}

/* ─── Brand ──────────────────────────────────────────────────────────────── */
.brand-link {
  display: flex;
  align-items: center;
  gap: 10px;
  text-decoration: none;
  color: inherit;
  flex-shrink: 0;
}
.logo {
  width: 32px;
  height: 32px;
  border-radius: 7px;
  object-fit: contain;
}
.brand-name {
  font-size: 1rem;
  font-weight: 700;
  letter-spacing: -0.01em;
  color: var(--active);
}

/* ─── Nav ────────────────────────────────────────────────────────────────── */
.main-nav {
  flex: 1;
}
.main-nav ul {
  display: flex;
  gap: 2px;
  list-style: none;
  padding: 0;
  margin: 0;
}

.nav-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--muted);
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 500;
  padding: 6px 10px;
  border-radius: 6px;
  position: relative;
  transition: color 160ms ease;
}
.nav-link:hover {
  color: var(--hover);
}
.nav-link.active {
  color: var(--active);
  font-weight: 600;
}
.nav-link.active::after {
  content: "";
  position: absolute;
  bottom: -1px;
  left: 10px;
  right: 10px;
  height: 2px;
  border-radius: 2px 2px 0 0;
  background: var(--red);
}
.nav-icon {
  width: 15px;
  height: 15px;
  flex-shrink: 0;
}

/* ─── Search ─────────────────────────────────────────────────────────────── */
.search-form {
  flex-shrink: 0;
}

.search-wrap {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 9px;
  width: 15px;
  height: 15px;
  color: var(--muted);
  pointer-events: none;
  transition: color 160ms ease;
}

.search-input {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.14);
  color: var(--text);
  font-size: 0.82rem;
  padding: 6px 10px 6px 30px;
  border-radius: 7px;
  width: 170px;
  outline: none;
  transition:
    width 240ms ease,
    border-color 160ms ease,
    box-shadow 160ms ease;
  appearance: none;
  -webkit-appearance: none;
}
.search-input::placeholder {
  color: var(--muted);
}
.search-input::-webkit-search-cancel-button {
  display: none;
}
.search-input:focus {
  width: 210px;
  border-color: var(--red);
  box-shadow: 0 0 0 3px rgba(232, 55, 42, 0.18);
}
.search-wrap:focus-within .search-icon {
  color: var(--red);
}

.mobile-search-form {
  padding: 8px 12px 2px;
}
.mobile-search-form .search-input,
.mobile-search-form .search-input:focus {
  width: 100%;
}

/* ─── Controls ───────────────────────────────────────────────────────────── */
.controls {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
}

/* Theme toggle */
.icon-btn {
  position: relative;
  border: 0;
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  padding: 8px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  transition:
    color 160ms ease,
    background 160ms ease,
    box-shadow 200ms ease,
    transform 160ms ease;
  overflow: visible;
}
.icon-btn:hover {
  color: var(--red-hover);
  background: rgba(232, 55, 42, 0.1);
  box-shadow: 0 0 0 3px var(--red-glow);
  transform: scale(1.08);
}
.icon-btn:active {
  transform: scale(0.95);
}
.icon {
  width: 18px;
  height: 18px;
}

/* Spin on toggle */
.mode-toggle.toggling .icon {
  animation: spin-once 420ms cubic-bezier(0.4, 0, 0.2, 1);
}
@keyframes spin-once {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

/* Ripple */
.toggle-ripple {
  position: absolute;
  inset: 0;
  border-radius: 6px;
  pointer-events: none;
}
.mode-toggle.toggling .toggle-ripple::after {
  content: "";
  position: absolute;
  inset: -2px;
  border-radius: 8px;
  border: 2px solid var(--red);
  animation: ripple-out 440ms ease forwards;
}
@keyframes ripple-out {
  from {
    opacity: 0.8;
    transform: scale(1);
  }
  to {
    opacity: 0;
    transform: scale(1.6);
  }
}

/* Icon swap */
.icon-swap-enter-active {
  transition:
    opacity 200ms ease,
    transform 200ms ease;
  transition-delay: 80ms;
}
.icon-swap-leave-active {
  transition:
    opacity 150ms ease,
    transform 150ms ease;
}
.icon-swap-enter-from {
  opacity: 0;
  transform: rotate(-90deg) scale(0.5);
}
.icon-swap-leave-to {
  opacity: 0;
  transform: rotate(90deg) scale(0.5);
}

/* ─── Hamburger ──────────────────────────────────────────────────────────── */
.hamburger {
  display: none;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 5px;
  width: 36px;
  height: 36px;
  background: transparent;
  border: 0;
  border-radius: 6px;
  cursor: pointer;
  padding: 0;
  color: var(--muted);
  transition:
    color 160ms ease,
    background 160ms ease,
    box-shadow 200ms ease,
    transform 160ms ease;
}
.hamburger:hover {
  color: var(--red-hover);
  background: rgba(232, 55, 42, 0.1);
  box-shadow: 0 0 0 3px var(--red-glow);
  transform: scale(1.08);
}
.hamburger:active {
  transform: scale(0.95);
}

.hamburger span {
  display: block;
  width: 18px;
  height: 1.5px;
  border-radius: 2px;
  background: currentColor;
  transition:
    transform 260ms ease,
    opacity 200ms ease,
    width 200ms ease;
  transform-origin: center;
}
.hamburger.open span:nth-child(1) {
  transform: translateY(6.5px) rotate(45deg);
}
.hamburger.open span:nth-child(2) {
  opacity: 0;
  width: 0;
}
.hamburger.open span:nth-child(3) {
  transform: translateY(-6.5px) rotate(-45deg);
}

/* ─── Mobile Nav ─────────────────────────────────────────────────────────── */
.mobile-nav {
  border-top: 1px solid var(--border);
  background: var(--bg);
  padding: 4px 12px 12px;
}
.mobile-nav ul {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
}

.mobile-link {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--muted);
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 500;
  padding: 10px 12px;
  border-radius: 6px;
  transition:
    color 160ms ease,
    background 160ms ease;
}
.mobile-link:hover {
  color: var(--hover);
  background: rgba(255, 255, 255, 0.05);
}
.mobile-link.active {
  color: var(--red);
  font-weight: 600;
}

/* Mobile menu slide */
.mobile-slide-enter-active,
.mobile-slide-leave-active {
  transition:
    opacity 180ms ease,
    transform 180ms ease;
}
.mobile-slide-enter-from,
.mobile-slide-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

/* ─── Auth controls ──────────────────────────────────────────────────────── */
.admin-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 8px;
  border-radius: 6px;
  color: var(--muted);
  text-decoration: none;
  transition: color 160ms ease, background 160ms ease;
}
.admin-link:hover {
  color: var(--red-hover);
  background: rgba(232, 55, 42, 0.1);
}

.notif-btn { position: relative; margin-right: 4px; display: inline-flex; align-items: center; justify-content: center; }
.notif-dot {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 8px;
  height: 8px;
  background: var(--red);
  border-radius: 50%;
  border: 2px solid var(--bg);
}

.avatar-btn {
  border: none;
  background: transparent;
  cursor: pointer;
  padding: 0;
  border-radius: 50%;
  transition: transform 160ms ease, box-shadow 160ms ease;
}
.avatar-btn:hover {
  transform: scale(1.08);
  box-shadow: 0 0 0 3px var(--red-glow);
}

.user-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid rgba(255,255,255,0.2);
}

.user-avatar-placeholder {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: rgba(232,55,42,0.2);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: 700;
}

/* ─── Avatar Dropdown ────────────────────────────────────────────────────── */
.avatar-dropdown-wrapper {
  position: relative;
  display: inline-flex;
  align-items: center;
}

.avatar-dropdown-menu {
  position: absolute;
  top: calc(100% + 12px);
  right: 0;
  width: 220px;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 12px;
  box-shadow: 0 12px 40px rgba(0,0,0,0.4);
  padding: 8px;
  z-index: 100;
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.dark .avatar-dropdown-menu {
  background: #18181b;
  border: 1px solid rgba(255,255,255,0.08);
}

.dropdown-header {
  padding: 10px 12px;
  margin-bottom: 4px;
}

.dropdown-name {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--text);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  display: block;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 10px 12px;
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--muted);
  background: transparent;
  border: none;
  border-radius: 8px;
  text-decoration: none;
  cursor: pointer;
  text-align: left;
  transition: all 150ms ease;
}

.dropdown-item:hover {
  background: rgba(255,255,255,0.08);
  color: var(--hover);
}

.dropdown-icon {
  width: 16px;
  height: 16px;
  color: inherit;
  opacity: 0.8;
}

.dropdown-divider {
  height: 1px;
  background: var(--border);
  margin: 4px 6px;
}

.logout-item {
  color: var(--red);
}
.logout-item:hover {
  background: rgba(239, 68, 68, 0.1);
  color: var(--red-hover);
}

.dropdown-enter-active,
.dropdown-leave-active {
  transition: opacity 150ms ease, transform 150ms ease;
}
.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

.login-btn {
  display: inline-flex;
  align-items: center;
  padding: 6px 14px;
  font-size: 0.82rem;
  font-weight: 600;
  color: #fff;
  background: var(--red);
  border-radius: 6px;
  text-decoration: none;
  transition: background 150ms ease, transform 130ms ease;
}
.login-btn:hover {
  background: var(--red-hover);
  transform: translateY(-1px);
}

/* ─── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 960px) {
  .main-nav {
    display: none;
  }
  .search-form {
    display: none;
  }
  .hamburger {
    display: flex;
  }
}

/* ─── A11y ───────────────────────────────────────────────────────────────── */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  border: 0;
}
</style>
