<template>
  <footer :class="['app-footer', { dark: isDark }]">
    <div class="footer-inner">
      <!-- Brand -->
      <div class="footer-brand">
        <img
          src="/logo.png"
          alt="Jet2 logo"
          class="footer-logo"
        >
        <div>
          <span class="footer-name">Jet2 Jobs</span>
          <span class="footer-tagline">Roblox Airline · Application Portal</span>
        </div>
      </div>

      <!-- Nav columns -->
      <nav
        class="footer-nav"
        aria-label="Footer navigation"
      >
        <div class="footer-col">
          <span class="col-label">Roles</span>
          <NuxtLink
            to="/jobs"
            class="footer-link"
          >Job Listings</NuxtLink>
          <NuxtLink
            to="/applications"
            class="footer-link"
          >My Applications</NuxtLink>
        </div>
        <div class="footer-col">
          <span class="col-label">Account</span>
          <NuxtLink
            to="/profile"
            class="footer-link"
          >Profile</NuxtLink>
          <NuxtLink
            to="/settings"
            class="footer-link"
          >Settings</NuxtLink>
        </div>
        <div class="footer-col">
          <span class="col-label">Legal</span>
          <NuxtLink
            to="/tos"
            class="footer-link"
          >Terms of Service</NuxtLink>
          <NuxtLink
            to="/datenschutz"
            class="footer-link"
          >Datenschutz</NuxtLink>
        </div>
      </nav>
    </div>

    <!-- Bottom bar -->
    <div class="footer-bottom">
      <span>© {{ year }} Jet2 Roblox Airline — not affiliated with the real Jet2.</span>
      <div class="footer-status">
        <span
          class="status-dot"
          aria-hidden="true"
        />
        All systems operational
      </div>
    </div>
  </footer>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const year = new Date().getFullYear()

// Mirror the theme state so the footer responds to dark mode
const isDark = ref(false)

onMounted(() => {
  isDark.value = document.documentElement.classList.contains('dark')

  // Watch for class changes on <html> made by the header toggle
  const observer = new MutationObserver(() => {
    isDark.value = document.documentElement.classList.contains('dark')
  })
  observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] })
})
</script>

<style scoped>
/* ─── Tokens ─────────────────────────────────────────────────────────────── */
.app-footer {
  --ft-bg:      #1a326a;
  --ft-border:  rgba(255,255,255,0.09);
  --ft-text:    rgba(255,255,255,0.55);
  --ft-strong:  #ffffff;
  --ft-muted:   rgba(255,255,255,0.30);
  --ft-hover:   #ffffff;
  --ft-tag:     rgba(255,255,255,0.18);
}

.app-footer.dark {
  --ft-bg:      #0a0d14;
  --ft-border:  rgba(255,255,255,0.07);
  --ft-text:    rgba(200,220,255,0.50);
  --ft-strong:  #e8f0ff;
  --ft-muted:   rgba(200,220,255,0.22);
  --ft-hover:   #e8f0ff;
  --ft-tag:     rgba(200,220,255,0.10);
}

/* ─── Shell ──────────────────────────────────────────────────────────────── */
.app-footer {
  background: var(--ft-bg);
  color: var(--ft-text);
  border-top: 1px solid var(--ft-border);
  transition: background 300ms ease, color 300ms ease;
}

/* ─── Inner ──────────────────────────────────────────────────────────────── */
.footer-inner {
  max-width: 760px;
  margin: 0 auto;
  padding: 44px 24px 36px;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 40px;
  flex-wrap: wrap;
}

/* ─── Brand ──────────────────────────────────────────────────────────────── */
.footer-brand {
  display: flex;
  align-items: center;
  gap: 14px;
}

.footer-logo {
  width: 38px;
  height: 38px;
  border-radius: 9px;
  object-fit: contain;
  opacity: 0.85;
  transition: opacity 200ms ease, transform 200ms ease;
}

.footer-logo:hover {
  opacity: 1;
  transform: scale(1.05);
}

.footer-name {
  display: block;
  font-size: 0.95rem;
  font-weight: 800;
  color: var(--ft-strong);
  letter-spacing: -0.01em;
}

.footer-tagline {
  display: block;
  font-size: 0.70rem;
  color: var(--ft-muted);
  margin-top: 3px;
  letter-spacing: 0.01em;
}

/* ─── Nav ────────────────────────────────────────────────────────────────── */
.footer-nav {
  display: flex;
  gap: 44px;
}

.footer-col {
  display: flex;
  flex-direction: column;
  gap: 9px;
}

.col-label {
  font-size: 0.67rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--ft-muted);
  margin-bottom: 3px;
}

.footer-link {
  font-size: 0.83rem;
  color: var(--ft-text);
  text-decoration: none;
  transition: color 150ms ease, transform 150ms ease;
  display: inline-block;
}

.footer-link:hover {
  color: var(--ft-hover);
  transform: translateX(2px);
}

/* ─── Bottom bar ─────────────────────────────────────────────────────────── */
.footer-bottom {
  max-width: 760px;
  margin: 0 auto;
  padding: 14px 24px;
  border-top: 1px solid var(--ft-border);
  font-size: 0.72rem;
  color: var(--ft-muted);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}

.footer-status {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.72rem;
  color: var(--ft-muted);
}

.status-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #22c55e;
  box-shadow: 0 0 0 2px rgba(34,197,94,0.25);
  flex-shrink: 0;
  animation: pulse-dot 2.5s ease infinite;
}

@keyframes pulse-dot {
  0%, 100% { box-shadow: 0 0 0 2px rgba(34,197,94,0.25); }
  50%       { box-shadow: 0 0 0 5px rgba(34,197,94,0.08); }
}

/* ─── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 560px) {
  .footer-inner { flex-direction: column; gap: 28px; }
  .footer-nav   { gap: 24px; }
  .footer-bottom { flex-direction: column; align-items: flex-start; gap: 8px; }
}
</style>
