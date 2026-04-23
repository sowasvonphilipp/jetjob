<template>
  <main class="page profile-page">
    <!-- Header Banner -->
    <div class="profile-header">
      <div class="profile-banner">
        <!-- Abstract gradient banner over the top -->
        <div class="banner-bg"></div>
        <div class="banner-blobs">
          <div class="blob b1"></div>
          <div class="blob b2"></div>
        </div>
      </div>
      
      <div class="container header-container">
        <div class="header-avatar-wrap">
          <img
            :src="profile?.discord_avatar || 'https://cdn.discordapp.com/embed/avatars/0.png'"
            class="header-avatar"
            :class="{ 'pulse-glow': opts.avatarGlow }"
            alt="User Avatar"
          >
          <div class="status-indicator" :class="{ 'pulse-indicator': opts.avatarGlow }"></div>
        </div>
        
        <div class="header-info">
          <h1 class="header-name">{{ profile?.full_name || profile?.discord_username || user?.email?.split('@')[0] || 'Loading...' }}</h1>
          <div class="header-badges">
            <span class="badge role-badge">{{ profile?.staff_role || profile?.role || 'User' }}</span>
            <span class="badge date-badge">Member since {{ formatDate(profile?.created_at || user?.created_at) }}</span>
          </div>
          <p class="header-status" v-if="profile?.status_msg">{{ profile.status_msg }}</p>
        </div>
        
        <div class="header-actions">
           <NuxtLink to="/settings" class="btn btn-primary">Edit Settings</NuxtLink>
        </div>
      </div>
    </div>

    <!-- Main Grid Content -->
    <div class="container profile-grid">
      <!-- Left Column: Identity Base -->
      <div class="profile-col profile-left">
        <div class="card glass-card fade-in">
          <h2 class="card-title">Identity Base</h2>
          <div class="identity-list">
            <div class="id-item">
              <span class="id-label">Discord ID</span>
              <span class="id-value"><code>{{ profile?.discord_id || 'Hidden' }}</code></span>
            </div>
            <div class="id-item">
              <span class="id-label">Roblox Username</span>
              <span class="id-value">{{ profile?.roblox_username || 'Not Linked' }}</span>
            </div>
            <div class="id-item">
              <span class="id-label">Location / Region</span>
              <span class="id-value">{{ profile?.location || 'Not Set' }}</span>
            </div>
            <div class="id-item">
              <span class="id-label">Pronouns</span>
              <span class="id-value">{{ profile?.pronouns || 'Not Set' }}</span>
            </div>
            <div class="id-item" v-if="profile?.website">
              <span class="id-label">Personal Website</span>
              <span class="id-value"><a :href="profile.website" target="_blank" style="color:var(--red); text-decoration:none;">{{ profile.website.replace('https://','') }}</a></span>
            </div>
          </div>
        </div>

        <div class="card glass-card fade-in delay-1">
          <h2 class="card-title">Biography</h2>
          <p class="bio-text">{{ profile?.bio || 'No biography written yet. Tell us about yourself!' }}</p>
        </div>
      </div>

      <!-- Right Column: Audit Log & Security -->
      <div class="profile-col profile-right">
        <div class="card glass-card fade-in delay-2">
          <div class="card-title-row">
             <h2 class="card-title">Personal Audit Log</h2>
             <span class="badge security-badge">Confidential</span>
          </div>
          <p class="card-sub">Recent security events and application actions.</p>
          
          <div class="audit-timeline">
            <div class="timeline-item" v-for="log in auditLogs" :key="log.id">
              <div class="timeline-dot" :class="`dot-${log.type}`"></div>
              <div class="timeline-content">
                <span class="timeline-date">{{ log.date }}</span>
                <span class="timeline-event">{{ log.event }}</span>
                <span class="timeline-detail">{{ log.detail }}</span>
              </div>
            </div>
            <div v-if="!auditLogs.length" style="color:var(--muted); font-size:0.85rem">No recent activity found.</div>
          </div>
          <div class="audit-footer">
            <span>Powered by Sunshine Studio Security Engine</span>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'

const { user, isLoggedIn } = useAuth()
const supabase = useSupabase()

const profile = ref(null)
const auditLogs = ref([])

function formatDate(ds) {
  if (!ds) return 'Recently'
  const d = new Date(ds)
  if (isNaN(d)) return 'Recently'
  return d.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
}

async function fetchProfileData() {
  if (!user.value) return
  const { data } = await supabase.from('profiles').select('*').eq('id', user.value.id).single()
  if (data) Object.assign(profile.value = data)
}

async function fetchAuditLogs() {
  if (!user.value) return
  const { data } = await supabase.from('audit_logs')
    .select('*')
    .eq('user_id', user.value.id)
    .order('created_at', { ascending: false })
    .limit(5)
  if (data) {
    auditLogs.value = data.map(l => ({
      id: l.id,
      type: l.type,
      date: formatDate(l.created_at),
      event: l.event,
      detail: l.detail
    }))
  }
}

const opts = reactive({ avatarGlow: true })
const THEME_KEY = 'jetjob-complex-settings'

function loadLocalSettings() {
  const stored = localStorage.getItem(THEME_KEY)
  if (stored) {
    try {
      const parsed = JSON.parse(stored)
      Object.assign(opts, parsed)
    } catch (e) {}
  }
}

onMounted(async () => {
  loadLocalSettings()
  if (isLoggedIn.value) {
    if (!profile.value) profile.value = {}
    await Promise.all([fetchProfileData(), fetchAuditLogs()])
  }
})

useSeoMeta({
  title: 'Profile — Sunshine Studio',
  description: 'View your Sunshine Studio account dashboard and audit logs.'
})
</script>

<style scoped>
.page.profile-page {
  min-height: 100vh;
  background: var(--bg-alt, #0f1117);
  padding-bottom: 80px;
}

/* ━━━ Header Banner ━━━ */
.profile-header {
  position: relative;
  background: var(--bg);
  border-bottom: 1px solid var(--border);
  margin-bottom: 60px;
}

.profile-banner {
  height: 220px;
  position: relative;
  overflow: hidden;
  background: #1e222d; /* fallback */
  border-bottom: 1px solid rgba(255,255,255,0.05);
}

.banner-bg {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(232, 55, 42, 0.4) 0%, rgba(30, 58, 110, 0.8) 100%);
  z-index: 1;
  opacity: 0.8;
}

.banner-blobs .blob {
  position: absolute;
  filter: blur(80px);
  border-radius: 50%;
  opacity: 0.5;
  z-index: 2;
  animation: float 20s infinite alternate;
}
.blob.b1 { width: 400px; height: 400px; background: var(--red); top: -100px; left: 10%; }
.blob.b2 { width: 500px; height: 500px; background: #3b82f6; bottom: -200px; right: 10%; animation-duration: 25s; animation-direction: reverse; }

@keyframes float {
  from { transform: translate(0, 0) scale(1); }
  to { transform: translate(60px, 40px) scale(1.1); }
}

.header-container {
  display: flex;
  align-items: flex-end;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px 30px;
  position: relative;
  top: -50px;
  z-index: 10;
}

.header-avatar-wrap {
  position: relative;
  margin-right: 24px;
}

.header-avatar {
  width: 130px;
  height: 130px;
  border-radius: 50%;
  border: 6px solid var(--bg);
  box-shadow: 0 8px 24px rgba(0,0,0,0.3);
  object-fit: cover;
  background: #fff;
  transition: transform 0.3s ease;
}

.pulse-glow {
  animation: avatarPulse 3s infinite;
  box-shadow: 0 0 0 0 rgba(232, 55, 42, 0.4);
}

@keyframes avatarPulse {
  0% { box-shadow: 0 0 0 0 rgba(232, 55, 42, 0.7); }
  70% { box-shadow: 0 0 0 15px rgba(232, 55, 42, 0); }
  100% { box-shadow: 0 0 0 0 rgba(232, 55, 42, 0); }
}

.status-indicator {
  position: absolute;
  bottom: 8px;
  right: 8px;
  width: 24px;
  height: 24px;
  background: #10b981;
  border: 4px solid var(--bg);
  border-radius: 50%;
}

.pulse-indicator {
  animation: indicatorPulse 2s infinite;
}

@keyframes indicatorPulse {
  0% { transform: scale(0.95); opacity: 0.8; }
  50% { transform: scale(1.1); opacity: 1; }
  100% { transform: scale(0.95); opacity: 0.8; }
}

.header-info {
  flex: 1;
  padding-bottom: 8px; /* align with avatar base */
}

.header-name {
  font-size: 2.2rem;
  font-weight: 900;
  color: var(--text);
  margin: 0 0 10px;
  letter-spacing: -0.02em;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
}

.header-badges {
  display: flex;
  gap: 12px;
  align-items: center;
  flex-wrap: wrap;
}

.badge {
  padding: 4px 10px;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.role-badge {
  background: var(--red);
  color: #fff;
  box-shadow: 0 2px 10px rgba(232, 55, 42, 0.4);
}

.date-badge {
  background: var(--surface);
  border: 1px solid var(--border);
  color: var(--muted);
}

.security-badge {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.header-status {
  margin: 12px 0 0;
  font-size: 0.95rem;
  color: var(--muted);
  font-style: italic;
}

.header-actions {
  padding-bottom: 12px;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  font-weight: 700;
  padding: 12px 24px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
}
.btn-primary {
  background: var(--red);
  color: #fff;
  box-shadow: 0 4px 14px rgba(232, 55, 42, 0.3);
}
.btn-primary:hover {
  background: #dc2626;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(232, 55, 42, 0.4);
}

/* ━━━ Grid Content ━━━ */
.profile-grid {
  display: grid;
  grid-template-columns: 1fr 1.2fr;
  gap: 30px;
  max-width: 1200px;
  margin: 0 auto;
  align-items: start;
}

/* Cards */
.card {
  padding: 30px;
  border-radius: 16px;
  margin-bottom: 30px;
}

.glass-card {
  background: rgba(var(--surface-rgb, 255, 255, 255), 0.03);
  backdrop-filter: blur(10px);
  border: 1px solid var(--border);
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.card-title {
  font-size: 1.2rem;
  font-weight: 900;
  color: var(--text);
  margin: 0 0 20px;
  letter-spacing: -0.01em;
}

.card-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.card-title-row .card-title { margin: 0; }

.card-sub {
  font-size: 0.85rem;
  color: var(--muted);
  margin: 0 0 24px;
}

/* Identity List */
.identity-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.id-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(255,255,255,0.05);
}
.id-item:last-child {
  padding-bottom: 0;
  border-bottom: none;
}

.id-label {
  font-size: 0.75rem;
  font-weight: 800;
  text-transform: uppercase;
  color: var(--muted);
  letter-spacing: 0.05em;
}

.id-value {
  font-size: 1.05rem;
  font-weight: 600;
  color: var(--text);
}
.id-value code {
  background: rgba(255,255,255,0.05);
  padding: 4px 8px;
  border-radius: 4px;
  font-family: monospace;
  font-size: 0.9rem;
}

.bio-text {
  font-size: 0.95rem;
  line-height: 1.7;
  color: var(--muted);
  white-space: pre-wrap;
  margin: 0;
}

/* ━━━ Audit Timeline ━━━ */
.audit-timeline {
  display: flex;
  flex-direction: column;
  position: relative;
  padding-left: 20px;
  margin-bottom: 24px;
}
.audit-timeline::before {
  content: '';
  position: absolute;
  top: 6px;
  bottom: 6px;
  left: 5px;
  width: 2px;
  background: var(--border);
}

.timeline-item {
  position: relative;
  padding-bottom: 24px;
}
.timeline-item:last-child {
  padding-bottom: 0;
}

.timeline-dot {
  position: absolute;
  left: -20px;
  top: 4px;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: var(--surface);
  border: 2px solid var(--muted);
  z-index: 2;
}
.dot-auth { border-color: #3b82f6; background: rgba(59, 130, 246, 0.2); }
.dot-app { border-color: #10b981; background: rgba(16, 185, 129, 0.2); }
.dot-sec { border-color: #ef4444; background: rgba(239, 68, 68, 0.2); }

.timeline-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.timeline-date {
  font-size: 0.75rem;
  color: var(--muted);
  font-weight: 700;
  text-transform: uppercase;
}

.timeline-event {
  font-size: 1rem;
  font-weight: 800;
  color: var(--text);
}

.timeline-detail {
  font-size: 0.85rem;
  color: var(--subtle, #a1a1aa);
}

.audit-footer {
  text-align: center;
  font-size: 0.7rem;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  opacity: 0.6;
  border-top: 1px solid var(--border);
  padding-top: 20px;
}

/* Animations */
.fade-in {
  opacity: 0;
  animation: fadeUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
.delay-1 { animation-delay: 0.1s; }
.delay-2 { animation-delay: 0.2s; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 900px) {
  .profile-grid { grid-template-columns: 1fr; }
  .header-container { flex-direction: column; align-items: center; text-align: center; top: -70px; }
  .header-avatar-wrap { margin-right: 0; margin-bottom: 16px; }
  .header-badges { justify-content: center; }
  .header-actions { margin-top: 20px; }
}
</style>