<template>
  <main class="page">
    <div class="container">
      <h1 class="page-title">
        My Applications
      </h1>
      <p class="page-sub">
        Track the status of your job applications.
      </p>

      <!-- Application Notices -->
      <div
        v-if="notices.length > 0"
        class="notices-section"
      >
        <div
          v-for="notice in notices"
          :key="notice.id"
          class="notice-banner"
        >
          <div class="notice-icon">
            ℹ️
          </div>
          <div class="notice-body">
            <h4 class="notice-title">
              {{ notice.title }}
            </h4>
            <p class="notice-message">
              {{ notice.message }}
            </p>
            <span
              v-if="notice.author_name"
              class="notice-author"
            >Posted by {{ notice.author_name }}</span>
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
        <p>Loading applications…</p>
      </div>

      <!-- Empty -->
      <div
        v-else-if="applications.length === 0"
        class="empty-state"
      >
        <ClipboardDocumentListIcon
          class="empty-icon"
          aria-hidden="true"
        />
        <h3>No applications yet</h3>
        <p>Browse open positions and submit your first application.</p>
        <NuxtLink
          to="/jobs"
          class="btn btn-primary"
        >
          Browse Jobs
          <ArrowRightIcon
            class="btn-icon"
            aria-hidden="true"
          />
        </NuxtLink>
      </div>

      <!-- Applications list -->
      <div
        v-else
        class="applications-list"
      >
        <div
          v-for="app in applications"
          :key="app.id"
          class="app-card"
        >
          <div class="app-main">
            <div class="app-header">
              <NuxtLink
                :to="`/applications/${app.id}`"
                class="app-title"
              >
                {{ app.jobs?.title || 'Unknown Position' }}
              </NuxtLink>
              <span :class="['status-badge', `status-${app.status}`]">
                {{ app.status }}
              </span>
            </div>
            <div class="app-meta">
              <span class="meta-item">
                <BriefcaseIcon
                  class="meta-icon"
                  aria-hidden="true"
                />
                {{ app.jobs?.department || '—' }}
              </span>
              <span class="meta-item">
                <CalendarIcon
                  class="meta-icon"
                  aria-hidden="true"
                />
                Applied {{ formatDate(app.created_at) }}
              </span>
            </div>
            <p
              v-if="app.cover_letter"
              class="app-cover"
            >
              "{{ app.cover_letter }}"
            </p>
          </div>

          <div class="app-actions">
            <NuxtLink
              :to="`/applications/${app.id}`"
              class="btn btn-outline btn-sm"
            >
              View Progress
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  ArrowRightIcon,
  ClipboardDocumentListIcon,
  BriefcaseIcon,
  CalendarIcon,
  MapPinIcon
} from '@heroicons/vue/24/outline'

const supabase = useSupabase()
const { user } = useAuth()
const applications = ref([])
const notices = ref([])
const loading = ref(true)

function formatDate(date) {
  return new Date(date).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
}

async function fetchNotices() {
  const { data } = await supabase
    .from('application_notices')
    .select('*')
    .eq('is_active', true)
    .eq('target', 'all')
    .order('created_at', { ascending: false })
  if (data) notices.value = data
}

async function fetchApplications() {
  loading.value = true
  if (!user.value) {
    loading.value = false
    return
  }

  const { data, error } = await supabase
    .from('applications')
    .select('*, jobs(title, department, location)')
    .eq('user_id', user.value.id)
    .order('created_at', { ascending: false })

  if (data) applications.value = data
  if (error) console.error('Error fetching applications:', error)
  loading.value = false
}

onMounted(() => {
  fetchApplications()
  fetchNotices()
})

useSeoMeta({
  title: 'My Applications — Sunshine Studio',
  description: 'Track your job applications at Sunshine Studio.'
})
</script>

<style scoped>
.page { min-height: 100vh; padding-bottom: 64px; }
.container { max-width: 800px; margin: 0 auto; padding: 0 24px; }

.page-title {
  font-size: 1.5rem;
  font-weight: 900;
  color: var(--text);
  margin: 48px 0 6px;
  letter-spacing: -0.02em;
}
.page-sub {
  font-size: 0.9rem;
  color: var(--muted);
  margin: 0 0 32px;
}

/* Buttons */
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
  transition: background 150ms ease, transform 130ms ease, box-shadow 150ms ease;
  white-space: nowrap;
}
.btn-sm { padding: 7px 14px; font-size: 0.8rem; }
.btn-icon { width: 15px; height: 15px; }
.btn-primary {
  background: var(--red);
  color: #fff;
  box-shadow: 0 2px 8px rgba(232,55,42,0.25);
}
.btn-primary:hover {
  background: var(--red-hover);
  transform: translateY(-1px);
}
.btn-outline {
  background: transparent;
  color: var(--muted);
  border: 1px solid var(--border);
}
.btn-outline:hover {
  color: var(--text);
  border-color: var(--muted);
}

/* Loading & empty */
.loading-state, .empty-state {
  text-align: center;
  padding: 80px 20px;
  color: var(--muted);
}
.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--border);
  border-top-color: var(--red);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  margin: 0 auto 16px;
}
@keyframes spin { to { transform: rotate(360deg); } }
.empty-icon {
  width: 48px;
  height: 48px;
  color: var(--subtle);
  margin-bottom: 12px;
}
.empty-state h3 {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--text);
  margin: 0 0 6px;
}

/* Application cards */
.applications-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.app-card {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px;
  transition: border-color 160ms ease, box-shadow 160ms ease;
}
.app-card:hover {
  border-color: rgba(232,55,42,0.3);
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
}

.app-main { flex: 1; }

.app-header {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 8px;
}

.app-title {
  font-size: 1rem;
  font-weight: 700;
  color: var(--text);
  text-decoration: none;
  transition: color 150ms ease;
}
.app-title:hover { color: var(--red); }

.status-badge {
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 3px 10px;
  border-radius: 99px;
}
.status-pending { background: rgba(245,158,11,0.12); color: #f59e0b; }
.status-reviewing { background: rgba(59,130,246,0.12); color: #3b82f6; }
.status-accepted { background: rgba(34,197,94,0.12); color: #22c55e; }
.status-rejected { background: rgba(239,68,68,0.12); color: #ef4444; }

.app-meta {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 8px;
}
.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.78rem;
  color: var(--subtle);
}
.meta-icon { width: 13px; height: 13px; flex-shrink: 0; }

.app-cover {
  font-size: 0.82rem;
  color: var(--muted);
  font-style: italic;
  margin: 4px 0 0;
  line-height: 1.5;
}

.app-actions {
  flex-shrink: 0;
}

@media (max-width: 560px) {
  .app-card { flex-direction: column; }
  .app-actions { align-self: stretch; }
  .app-actions .btn { width: 100%; justify-content: center; }
}
/* Notices section */
.notices-section {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 24px;
}
.notice-banner {
  display: flex;
  gap: 14px;
  align-items: flex-start;
  background: rgba(59,130,246,0.06);
  border: 1px solid rgba(59,130,246,0.18);
  border-left: 4px solid #3b82f6;
  border-radius: 12px;
  padding: 16px 20px;
}
.notice-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
  margin-top: 2px;
}
.notice-body {
  flex: 1;
}
.notice-title {
  font-size: 0.95rem;
  font-weight: 800;
  color: var(--text);
  margin: 0 0 4px;
}
.notice-message {
  font-size: 0.85rem;
  color: var(--muted);
  margin: 0 0 6px;
  line-height: 1.5;
}
.notice-author {
  font-size: 0.72rem;
  color: var(--subtle);
  font-weight: 600;
}
</style>
