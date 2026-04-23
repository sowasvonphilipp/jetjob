<template>
  <main class="page">
    <div class="container">
      <div class="page-header">
        <h1 class="page-title">
          Notifications
        </h1>
        <p class="page-sub">
          View recent updates about your applications.
        </p>
      </div>

      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
        <p>Loading notifications...</p>
      </div>

      <div
        v-else-if="notifications.length === 0"
        class="empty-state"
      >
        <BellIcon
          class="empty-icon"
          aria-hidden="true"
        />
        <h2>All caught up</h2>
        <p>You have no new notifications right now.</p>
      </div>

      <div
        v-else
        class="notif-list"
      >
        <div class="toolbar">
          <button
            class="btn btn-outline btn-sm"
            :disabled="unreadCount === 0"
            @click="markAllAsRead"
          >
            Mark all as read
          </button>
        </div>

        <div
          v-for="notif in notifications"
          :key="notif.id"
          :class="['notif-card', { unread: !notif.is_read }]"
        >
          <div class="notif-header">
            <div style="display:flex; align-items:center; gap:8px;">
              <h3 class="notif-title">
                {{ notif.title }}
              </h3>
              <span
                v-if="notif.type && notif.type !== 'system'"
                :class="['notif-type-badge', `ntype-${notif.type}`]"
              >{{ notif.type }}</span>
            </div>
            <span class="notif-date">{{ formatDate(notif.created_at) }}</span>
          </div>
          <p class="notif-message">
            {{ notif.message }}
          </p>
          <div
            v-if="notif.sent_by_name"
            class="notif-sender"
          >
            Sent by {{ notif.sent_by_name }}
          </div>
          <div
            v-if="notif.link || !notif.is_read"
            class="notif-actions"
          >
            <NuxtLink
              v-if="notif.link"
              :to="notif.link"
              class="btn btn-primary btn-sm"
              @click="markAsRead(notif.id)"
            >
              View Details
            </NuxtLink>
            <button
              v-if="!notif.is_read"
              class="btn btn-outline btn-sm"
              @click="markAsRead(notif.id)"
            >
              Mark as Read
            </button>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { BellIcon } from '@heroicons/vue/24/outline'

const supabase = useSupabase()
const { user, isLoggedIn } = useAuth()

const notifications = ref([])
const loading = ref(true)

const unreadCount = computed(() => notifications.value.filter(n => !n.is_read).length)

async function fetchNotifications() {
  if (!user.value) return
  loading.value = true
  const { data } = await supabase
    .from('notifications')
    .select('*')
    .eq('user_id', user.value.id)
    .order('created_at', { ascending: false })

  if (data) notifications.value = data
  loading.value = false
}

async function markAsRead(id) {
  await supabase.from('notifications').update({ is_read: true }).eq('id', id)
  const notif = notifications.value.find(n => n.id === id)
  if (notif) notif.is_read = true
  if (typeof window !== 'undefined') window.dispatchEvent(new CustomEvent('notifications:refresh'))
}

async function markAllAsRead() {
  const unreadIds = notifications.value.filter(n => !n.is_read).map(n => n.id)
  if (!unreadIds.length) return

  await supabase.from('notifications').update({ is_read: true }).in('id', unreadIds)
  notifications.value.forEach(n => n.is_read = true)
  if (typeof window !== 'undefined') window.dispatchEvent(new CustomEvent('notifications:refresh'))
}

function formatDate(date) {
  return new Date(date).toLocaleString('en-GB', {
    day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit'
  })
}

onMounted(() => {
  if (isLoggedIn.value) fetchNotifications()
})

useSeoMeta({ title: 'Notifications — Sunshine Studio' })
</script>

<style scoped>
.page { min-height: 100vh; padding-bottom: 64px; }
.container { max-width: 680px; margin: 0 auto; padding: 0 24px; }

.page-header { padding: 48px 0 24px; border-bottom: 1px solid var(--border); margin-bottom: 24px; }
.page-title { font-size: 1.8rem; font-weight: 900; color: var(--text); margin: 0 0 6px; letter-spacing: -0.02em; }
.page-sub { font-size: 0.95rem; color: var(--muted); margin: 0; }

.toolbar { display: flex; justify-content: flex-end; margin-bottom: 16px; }

.notif-list { display: flex; flex-direction: column; gap: 12px; }
.notif-card {
  background: var(--surface);
  border: 1px solid var(--border);
  padding: 20px;
  border-radius: 12px;
  transition: border-color 150ms ease;
}
.notif-card.unread { border-color: rgba(232,55,42,0.4); background: rgba(232,55,42,0.02); }

.notif-header { display: flex; justify-content: space-between; margin-bottom: 8px; align-items: flex-start; }
.notif-title { font-size: 1rem; font-weight: 800; color: var(--text); margin: 0; }
.notif-date { font-size: 0.75rem; color: var(--subtle); font-weight: 600; }
.notif-message { font-size: 0.9rem; color: var(--muted); line-height: 1.5; margin: 0 0 16px; }

.notif-actions { display: flex; gap: 8px; }

.notif-sender {
  font-size: 0.72rem;
  color: #3b82f6;
  font-weight: 600;
  margin-bottom: 10px;
}

.notif-type-badge {
  font-size: 0.62rem;
  font-weight: 800;
  padding: 2px 7px;
  border-radius: 99px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.ntype-info { background: rgba(59,130,246,0.1); color: #3b82f6; }
.ntype-warning { background: rgba(245,158,11,0.12); color: #f59e0b; }
.ntype-urgent { background: rgba(239,68,68,0.1); color: #ef4444; }
.ntype-application_notice { background: rgba(139,92,246,0.1); color: #8b5cf6; }
.ntype-status_update { background: rgba(34,197,94,0.1); color: #22c55e; }

.btn {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-size: 0.875rem;
  font-weight: 600;
  padding: 10px 20px;
  border-radius: 7px;
  text-decoration: none;
  border: none;
  cursor: pointer;
  transition: background 150ms ease, transform 130ms ease;
}
.btn-sm { padding: 6px 14px; font-size: 0.8rem; }
.btn-primary { background: var(--red); color: #fff; }
.btn-primary:hover { background: var(--red-hover); }
.btn-outline { background: transparent; color: var(--muted); border: 1px solid var(--border); }
.btn-outline:hover { color: var(--text); border-color: var(--muted); }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }

.loading-state, .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
.empty-icon { width: 48px; height: 48px; margin: 0 auto 16px; opacity: 0.3; }
.empty-state h2 { font-size: 1.25rem; font-weight: 800; color: var(--text); margin: 0 0 8px; }
.spinner {
  width: 32px; height: 32px;
  border: 3px solid var(--border);
  border-top-color: var(--red);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  margin: 0 auto 16px;
}
@keyframes spin { to { transform: rotate(360deg); } }
</style>
