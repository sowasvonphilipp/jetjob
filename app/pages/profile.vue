<template>
  <main class="page">
    <div class="container">
      <h1 class="page-title">
        My Profile
      </h1>
      <p class="page-sub">
        Your Discord account details and portal activity.
      </p>

      <!-- Loading -->
      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
      </div>

      <template v-else-if="user">
        <!-- Profile card -->
        <div class="profile-card">
          <div class="profile-header">
            <img
              v-if="user.user_metadata?.avatar_url"
              :src="user.user_metadata.avatar_url"
              alt="Your avatar"
              class="profile-avatar"
            >
            <div
              v-else
              class="profile-avatar-placeholder"
            >
              {{ (user.user_metadata?.full_name || '?')[0] }}
            </div>

            <div class="profile-info">
              <h2 class="profile-name">
                {{ user.user_metadata?.full_name || user.user_metadata?.name || 'User' }}
              </h2>
              <span class="profile-email">{{ user.email || 'No email' }}</span>
              <span
                v-if="profile?.role === 'admin'"
                class="role-badge role-admin"
              >
                <ShieldCheckIcon
                  class="role-icon"
                  aria-hidden="true"
                />
                Admin
              </span>
              <span
                v-else
                class="role-badge role-user"
              >
                <UserIcon
                  class="role-icon"
                  aria-hidden="true"
                />
                Member
              </span>
            </div>
          </div>

          <div class="profile-details">
            <div class="detail-row">
              <span class="detail-label">Roblox Username</span>
              <div
                v-if="editingRoblox"
                class="roblox-edit"
              >
                <input
                  v-model="editRobloxName"
                  type="text"
                  placeholder="Username"
                  class="roblox-input"
                  @keyup.enter="saveRobloxUsername"
                >
                <button
                  class="btn-micro btn-primary"
                  @click="saveRobloxUsername"
                >
                  Save
                </button>
                <button
                  class="btn-micro btn-outline"
                  @click="editingRoblox = false"
                >
                  Cancel
                </button>
              </div>
              <div
                v-else
                class="roblox-display"
                @click="startEditingRoblox"
              >
                <span
                  class="detail-value"
                  :class="{ 'text-muted': !profile?.roblox_username }"
                >
                  {{ profile?.roblox_username || 'Click to link account' }}
                </span>
                <PencilIcon
                  class="edit-icon"
                  aria-hidden="true"
                />
              </div>
            </div>
            <div class="detail-row">
              <span class="detail-label">Discord ID</span>
              <span class="detail-value">{{ profile?.discord_id || '—' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Member since</span>
              <span class="detail-value">{{ profile?.created_at ? formatDate(profile.created_at) : '—' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Auth provider</span>
              <span class="detail-value">Discord</span>
            </div>
          </div>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
          <div class="stat-card">
            <ClipboardDocumentListIcon
              class="stat-icon"
              aria-hidden="true"
            />
            <div class="stat-value">
              {{ applicationCount }}
            </div>
            <div class="stat-label">
              Applications submitted
            </div>
          </div>
          <div class="stat-card">
            <CheckCircleIcon
              class="stat-icon stat-icon-green"
              aria-hidden="true"
            />
            <div class="stat-value">
              {{ acceptedCount }}
            </div>
            <div class="stat-label">
              Accepted
            </div>
          </div>
          <div class="stat-card">
            <ClockIcon
              class="stat-icon stat-icon-amber"
              aria-hidden="true"
            />
            <div class="stat-value">
              {{ pendingCount }}
            </div>
            <div class="stat-label">
              Pending
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="profile-actions">
          <NuxtLink
            to="/applications"
            class="btn btn-outline"
          >
            <ClipboardDocumentListIcon
              class="btn-icon"
              aria-hidden="true"
            />
            View Applications
          </NuxtLink>
          <button
            class="btn btn-danger"
            @click="handleSignOut"
          >
            <ArrowRightStartOnRectangleIcon
              class="btn-icon"
              aria-hidden="true"
            />
            Sign Out
          </button>
        </div>
      </template>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  UserIcon,
  ShieldCheckIcon,
  ClipboardDocumentListIcon,
  CheckCircleIcon,
  ClockIcon,
  ArrowRightStartOnRectangleIcon,
  PencilIcon
} from '@heroicons/vue/24/outline'

const supabase = useSupabase()
const { user, profile, loading, signOut } = useAuth()

const applicationCount = ref(0)
const acceptedCount = ref(0)
const pendingCount = ref(0)

const editingRoblox = ref(false)
const editRobloxName = ref('')

function startEditingRoblox() {
  editRobloxName.value = profile.value?.roblox_username || ''
  editingRoblox.value = true
}

async function saveRobloxUsername() {
  if (!user.value) return
  const { error } = await supabase
    .from('profiles')
    .update({ roblox_username: editRobloxName.value.trim() })
    .eq('id', user.value.id)

  if (!error && profile.value) {
    profile.value.roblox_username = editRobloxName.value.trim()
  }
  editingRoblox.value = false
}

function formatDate(date) {
  return new Date(date).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  })
}

async function handleSignOut() {
  await signOut()
}

async function fetchStats() {
  if (!user.value) return

  const { data } = await supabase
    .from('applications')
    .select('status')
    .eq('user_id', user.value.id)

  if (data) {
    applicationCount.value = data.length
    acceptedCount.value = data.filter(a => a.status === 'accepted').length
    pendingCount.value = data.filter(a => a.status === 'pending').length
  }
}

onMounted(fetchStats)

// Re-fetch when user loads
watch(user, (val) => {
  if (val) fetchStats()
})

useSeoMeta({
  title: 'My Profile — Jet2 Jobs',
  description: 'View your profile and application stats.'
})
</script>

<style scoped>
.page { min-height: 100vh; padding-bottom: 64px; }
.container { max-width: 680px; margin: 0 auto; padding: 0 24px; }

.page-title {
  font-size: 1.5rem;
  font-weight: 900;
  color: var(--text);
  margin: 48px 0 6px;
  letter-spacing: -0.02em;
}
.page-sub { font-size: 0.9rem; color: var(--muted); margin: 0 0 32px; }

/* Profile card */
.profile-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 14px;
  overflow: hidden;
  margin-bottom: 24px;
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 28px 28px 20px;
}

.profile-avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid var(--border);
  flex-shrink: 0;
}

.profile-avatar-placeholder {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--red), #ff6b5b);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.6rem;
  font-weight: 800;
  flex-shrink: 0;
}

.profile-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.profile-name {
  font-size: 1.2rem;
  font-weight: 800;
  color: var(--text);
  margin: 0;
  letter-spacing: -0.01em;
}

.profile-email {
  font-size: 0.82rem;
  color: var(--muted);
}

.role-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 3px 10px;
  border-radius: 99px;
  align-self: flex-start;
  margin-top: 4px;
}
.role-icon { width: 12px; height: 12px; }
.role-admin { background: rgba(232,55,42,0.1); color: var(--red); }
.role-user { background: rgba(59,130,246,0.1); color: #3b82f6; }

.profile-details {
  border-top: 1px solid var(--border);
  padding: 16px 28px 20px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}
.detail-row + .detail-row {
  border-top: 1px solid var(--border);
}

.detail-label {
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--muted);
}
.detail-value {
  font-size: 0.85rem;
  color: var(--text);
  font-weight: 500;
}

/* Stats */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px 16px;
  text-align: center;
  transition: border-color 160ms ease;
}
.stat-card:hover { border-color: rgba(232,55,42,0.3); }

.stat-icon {
  width: 24px;
  height: 24px;
  color: var(--red);
  margin: 0 auto 8px;
}
.stat-icon-green { color: #22c55e; }
.stat-icon-amber { color: #f59e0b; }

.stat-value {
  font-size: 1.5rem;
  font-weight: 900;
  color: var(--text);
  letter-spacing: -0.02em;
}
.stat-label {
  font-size: 0.72rem;
  font-weight: 600;
  color: var(--subtle);
  text-transform: uppercase;
  letter-spacing: 0.03em;
  margin-top: 2px;
}

/* Actions */
.profile-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-size: 0.85rem;
  font-weight: 600;
  padding: 10px 18px;
  border-radius: 7px;
  text-decoration: none;
  border: none;
  cursor: pointer;
  transition: background 150ms ease, transform 130ms ease, box-shadow 150ms ease;
  white-space: nowrap;
}
.btn-icon { width: 16px; height: 16px; }
.btn-outline {
  background: transparent;
  color: var(--muted);
  border: 1px solid var(--border);
}
.btn-outline:hover { color: var(--text); border-color: var(--muted); }
.btn-danger {
  background: rgba(239,68,68,0.1);
  color: #ef4444;
}
.btn-danger:hover {
  background: rgba(239,68,68,0.18);
}

/* Loading */
.loading-state { text-align: center; padding: 80px 20px; }
.spinner {
  width: 32px; height: 32px;
  border: 3px solid var(--border);
  border-top-color: var(--red);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  margin: 0 auto;
}
@keyframes spin { to { transform: rotate(360deg); } }

@media (max-width: 500px) {
  .stats-grid { grid-template-columns: 1fr; }
  .profile-header { flex-direction: column; text-align: center; }
  .profile-info { align-items: center; }
  .role-badge { align-self: center; }
  .detail-row { flex-direction: column; align-items: flex-start; gap: 8px; }
}

/* Roblox Edit */
.roblox-display {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
  margin: -4px -8px;
  transition: background 150ms ease;
}
.roblox-display:hover {
  background: rgba(0,0,0,0.03);
}
.roblox-display .text-muted {
  color: var(--subtle);
  font-style: italic;
}
.edit-icon {
  width: 14px;
  height: 14px;
  color: var(--muted);
  opacity: 0;
  transition: opacity 150ms ease;
}
.roblox-display:hover .edit-icon { opacity: 1; }

.roblox-edit {
  display: flex;
  align-items: center;
  gap: 6px;
}
.roblox-input {
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--text);
  font-size: 0.82rem;
  padding: 4px 8px;
  border-radius: 4px;
  width: 140px;
  outline: none;
}
.roblox-input:focus { border-color: var(--red); }
.btn-micro {
  font-size: 0.75rem;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  border: 1px solid transparent;
}
.btn-micro.btn-primary { background: var(--red); color: white; }
.btn-micro.btn-outline { background: transparent; border-color: var(--border); color: var(--text); }
</style>
