<template>
  <div class="lock-overlay">
    <div class="lock-backdrop" />

    <div class="lock-card" role="alertdialog" aria-modal="true" aria-labelledby="lock-title">

      <!-- fake close -->
      <button
        class="lock-close"
        aria-label="Cannot close"
        @mouseenter="closeHovered = true"
        @mouseleave="closeHovered = false"
        @click.prevent
      >
        <Transition name="swap" mode="out-in">
          <svg v-if="closeHovered" key="lock" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="btn-icon amber shake">
            <path fill-rule="evenodd" d="M12 1.5a5.25 5.25 0 0 0-5.25 5.25v3a3 3 0 0 0-3 3v6.75a3 3 0 0 0 3 3h10.5a3 3 0 0 0 3-3v-6.75a3 3 0 0 0-3-3v-3A5.25 5.25 0 0 0 12 1.5Zm3.75 8.25v-3a3.75 3.75 0 1 0-7.5 0v3h7.5Z" clip-rule="evenodd" />
          </svg>
          <span v-else key="x" class="close-x">✕</span>
        </Transition>
      </button>

      <!-- pulsing lock -->
      <div class="icon-ring">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="hero-lock">
          <path fill-rule="evenodd" d="M12 1.5a5.25 5.25 0 0 0-5.25 5.25v3a3 3 0 0 0-3 3v6.75a3 3 0 0 0 3 3h10.5a3 3 0 0 0 3-3v-6.75a3 3 0 0 0-3-3v-3A5.25 5.25 0 0 0 12 1.5Zm3.75 8.25v-3a3.75 3.75 0 1 0-7.5 0v3h7.5Z" clip-rule="evenodd" />
        </svg>
      </div>

      <!-- badge -->
      <span class="status-badge">🔧 Maintenance Mode</span>

      <h1 id="lock-title" class="lock-title">Site Temporarily Closed</h1>

      <p class="lock-body">
        We've taken the site offline due to <strong>ongoing maintenance</strong> and some critical bugs we're actively fixing.<br /><br />
        Join our Discord to stay updated, or wait for us to come back online.
      </p>

      <div class="divider" />

      <div class="lock-actions">
        <!-- Discord — real link -->
        <a :href="appConfig.discordUrl" target="_blank" rel="noopener noreferrer" class="btn btn-discord">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
            <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057c.002.022.015.043.03.053a19.9 19.9 0 0 0 5.993 3.03.077.077 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03Z"/>
          </svg>
          Join Discord
        </a>

        <!-- Enter page — locked -->
        <button
          class="btn btn-enter"
          @mouseenter="enterHovered = true"
          @mouseleave="enterHovered = false"
          @click.prevent
        >
          <Transition name="swap" mode="out-in">
            <svg v-if="enterHovered" key="lock" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="btn-icon amber shake">
              <path fill-rule="evenodd" d="M12 1.5a5.25 5.25 0 0 0-5.25 5.25v3a3 3 0 0 0-3 3v6.75a3 3 0 0 0 3 3h10.5a3 3 0 0 0 3-3v-6.75a3 3 0 0 0-3-3v-3A5.25 5.25 0 0 0 12 1.5Zm3.75 8.25v-3a3.75 3.75 0 1 0-7.5 0v3h7.5Z" clip-rule="evenodd" />
            </svg>
            <svg v-else key="arrow" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="btn-icon">
              <path fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm4.28 10.28a.75.75 0 0 0 0-1.06l-3-3a.75.75 0 1 0-1.06 1.06l1.72 1.72H8.25a.75.75 0 0 0 0 1.5h5.69l-1.72 1.72a.75.75 0 1 0 1.06 1.06l3-3Z" clip-rule="evenodd" />
            </svg>
          </Transition>
          <Transition name="swap" mode="out-in">
            <span v-if="enterHovered" key="locked-label" class="amber">Locked</span>
            <span v-else key="enter-label">Enter Page</span>
          </Transition>
        </button>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
const appConfig = useAppConfig()
const closeHovered = ref(false)
const enterHovered = ref(false)
</script>

<style scoped>
.lock-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
}

.lock-backdrop {
  position: absolute;
  inset: 0;
  backdrop-filter: blur(22px) saturate(0.3) brightness(0.25);
  -webkit-backdrop-filter: blur(22px) saturate(0.3) brightness(0.25);
  background: rgba(0, 0, 0, 0.6);
}

.lock-card {
  position: relative;
  z-index: 1;
  background: linear-gradient(160deg, #0f172a 0%, #0c1526 100%);
  border: 1px solid rgba(255, 255, 255, 0.07);
  border-radius: 1.5rem;
  padding: 2.5rem 2.25rem 2rem;
  max-width: 440px;
  width: 92%;
  text-align: center;
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.85), 0 0 0 1px rgba(255,255,255,0.04) inset;
  color: #f1f5f9;
}

.lock-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 2rem;
  height: 2rem;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.09);
  color: #64748b;
  cursor: not-allowed;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  transition: background 0.2s;
}
.lock-close:hover { background: rgba(255, 255, 255, 0.1); }
.close-x { font-size: 0.8rem; line-height: 1; }

.icon-ring {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 4.5rem;
  height: 4.5rem;
  border-radius: 50%;
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.25);
  margin: 0 auto 1.25rem;
  animation: ring-pulse 2.5s ease-in-out infinite;
}

.hero-lock {
  width: 2rem;
  height: 2rem;
  color: #f59e0b;
}

@keyframes ring-pulse {
  0%, 100% { box-shadow: 0 0 0 0 rgba(245,158,11,0.25); }
  50%       { box-shadow: 0 0 0 10px rgba(245,158,11,0); }
}

.status-badge {
  display: inline-block;
  font-size: 0.7rem;
  font-weight: 600;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: #f59e0b;
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.25);
  border-radius: 999px;
  padding: 0.2rem 0.75rem;
  margin-bottom: 0.85rem;
}

.lock-title {
  font-size: 1.45rem;
  font-weight: 700;
  margin-bottom: 0.85rem;
  color: #f1f5f9;
  line-height: 1.25;
}

.lock-body {
  font-size: 0.875rem;
  line-height: 1.65;
  color: #94a3b8;
  margin-bottom: 1.5rem;
}
.lock-body strong { color: #cbd5e1; }

.divider {
  height: 1px;
  background: rgba(255, 255, 255, 0.06);
  margin-bottom: 1.5rem;
}

.lock-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.45rem;
  padding: 0.6rem 1.3rem;
  border-radius: 0.75rem;
  font-weight: 600;
  font-size: 0.875rem;
  text-decoration: none;
  border: none;
  cursor: pointer;
  transition: background 0.2s, transform 0.15s, box-shadow 0.2s;
  min-width: 8.5rem;
}

.btn-discord {
  background: #5865f2;
  color: #fff;
  box-shadow: 0 4px 14px rgba(88, 101, 242, 0.35);
}
.btn-discord:hover {
  background: #4752c4;
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(88, 101, 242, 0.5);
}

.btn-enter {
  background: rgba(255, 255, 255, 0.06);
  color: #94a3b8;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
  cursor: not-allowed;
}
.btn-enter:hover { background: rgba(255, 255, 255, 0.09); }

.btn-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.amber { color: #f59e0b; }

.shake { animation: lock-shake 0.45s ease; }

@keyframes lock-shake {
  0%, 100% { transform: translateX(0) rotate(0); }
  20%       { transform: translateX(-3px) rotate(-10deg); }
  40%       { transform: translateX(3px) rotate(10deg); }
  60%       { transform: translateX(-2px) rotate(-5deg); }
  80%       { transform: translateX(2px) rotate(5deg); }
}

.swap-enter-active,
.swap-leave-active {
  transition: opacity 0.12s ease, transform 0.12s ease;
}
.swap-enter-from { opacity: 0; transform: scale(0.7); }
.swap-leave-to   { opacity: 0; transform: scale(0.7); }
</style>
