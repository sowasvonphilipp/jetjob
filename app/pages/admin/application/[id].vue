<template>
  <main class="page">
    <div class="container">
      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
        <p>Loading application...</p>
      </div>

      <div
        v-else-if="!app"
        class="empty-state"
      >
        <h2>Application not found</h2>
        <NuxtLink
          to="/admin"
          class="btn btn-primary"
        >Back to Admin</NuxtLink>
      </div>

      <template v-else>
        <!-- Header -->
        <div class="detail-header">
          <NuxtLink
            to="/admin"
            class="back-link"
          >
            <ArrowLeftIcon class="back-icon" /> Back to Admin
          </NuxtLink>

          <div class="header-main">
            <div class="applicant-hero">
              <img
                v-if="app.discord_avatar"
                :src="app.discord_avatar"
                class="hero-avatar"
              >
              <div
                v-else
                class="hero-avatar-placeholder"
              >
                {{ app.discord_username[0] }}
              </div>
              <div>
                <h1 class="hero-name">
                  {{ app.discord_username }}
                  <span
                    v-if="app.profiles?.roblox_username"
                    class="roblox-badge"
                  >
                    {{ app.profiles.roblox_username }}
                  </span>
                </h1>
                <p class="hero-sub">
                  Applying for <strong>{{ app.jobs?.title }}</strong>
                </p>
              </div>
            </div>

            <div class="header-actions">
              <div style="display:flex; align-items:center; gap: 12px;">
                <select
                  v-model="pendingStatus"
                  class="status-select-lg"
                >
                  <option value="pending">
                    Pending
                  </option>
                  <option value="reviewing">
                    Reviewing
                  </option>
                  <option value="interview">
                    Interview
                  </option>
                  <option value="accepted">
                    Accepted
                  </option>
                  <option value="rejected">
                    Rejected
                  </option>
                </select>
                <button
                  class="btn btn-primary"
                  :disabled="savingStatus || app.status === pendingStatus"
                  @click="saveStatus"
                >
                  Save Status
                </button>
                <span
                  v-if="savingStatus"
                  class="text-muted"
                  style="font-size: 0.8rem;"
                >Saving...</span>
                <span
                  v-else-if="savedStatus"
                  class="text-green"
                  style="font-size: 0.8rem; color:#10b981; font-weight:bold;"
                >✔ Saved</span>
              </div>
            </div>
          </div>
        </div>

        <div class="detail-grid">
          <!-- Main Content -->
          <div class="detail-main">
            <!-- AI Flags -->
            <div
              v-if="app.ai_flagged"
              class="alert-box alert-danger"
            >
              <ExclamationTriangleIcon class="alert-icon" />
              <div>
                <strong>Flagged for Secondary Inspection</strong>
                <p>AI Detector flagged 3 or more answers as potentially generated (90%+ probability).</p>
              </div>
            </div>

            <!-- Questionnaire -->
            <section class="review-section">
              <h3 class="section-title">
                Questionnaire Answers
              </h3>
              <div class="answers-stack">
                <div
                  v-for="(ans, idx) in answers"
                  :key="ans.id"
                  class="answer-card"
                >
                  <div class="answer-header">
                    <span class="q-num">{{ idx + 1 }}.</span>
                    <span class="q-text">{{ ans.job_questions?.question }}</span>
                    <span
                      v-if="ans.ai_score > 80"
                      class="ai-badge"
                      :title="`AI Probability: ${ans.ai_score}%` "
                    >
                      AI: {{ ans.ai_score }}%
                    </span>
                  </div>
                  <div class="answer-body">
                    {{ ans.answer || '—' }}
                  </div>
                </div>
              </div>
            </section>

            <!-- Cover Letter -->
            <section
              v-if="app.cover_letter"
              class="review-section"
            >
              <h3 class="section-title">
                Cover Letter
              </h3>
              <div class="cover-letter-box">
                {{ app.cover_letter }}
              </div>
            </section>

            <!-- Timeline -->
            <section class="review-section">
              <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                <h3
                  class="section-title"
                  style="margin:0;"
                >
                  Activity Timeline
                </h3>
                <button
                  class="btn btn-outline btn-sm"
                  @click="showAddEvent = !showAddEvent"
                >
                  {{ showAddEvent ? 'Cancel' : '+ Add Entry' }}
                </button>
              </div>

              <!-- Compose custom event -->
              <div
                v-if="showAddEvent"
                class="event-compose"
              >
                <div class="compose-row">
                  <select
                    v-model="customEventType"
                    class="form-input"
                    style="max-width:180px;"
                  >
                    <option value="custom">
                      Custom Note
                    </option>
                    <option value="status_change">
                      Status Change
                    </option>
                    <option value="note_added">
                      Internal Note
                    </option>
                    <option value="submitted">
                      Application Event
                    </option>
                  </select>
                  <input
                    v-model="customEventDesc"
                    class="form-input"
                    placeholder="Write a timeline entry..."
                    style="flex:1;"
                  >
                  <button
                    class="btn btn-primary btn-sm"
                    :disabled="!customEventDesc.trim()"
                    @click="postCustomEvent"
                  >
                    Post
                  </button>
                </div>
              </div>

              <div class="timeline">
                <div
                  v-for="event in events"
                  :key="event.id"
                  class="timeline-item"
                >
                  <div :class="['timeline-dot', `dot-${event.event_type}`]" />
                  <div class="timeline-content">
                    <!-- Normal view -->
                    <template v-if="editingEventId !== event.id">
                      <div class="timeline-header">
                        <span class="event-type">{{ event.event_type.replace('_', ' ') }}</span>
                        <div class="event-actions-row">
                          <span class="event-time">{{ formatFullDate(event.created_at) }}</span>
                          <button
                            class="event-action-btn"
                            title="Edit"
                            @click="startEditEvent(event)"
                          >
                            <PencilIcon class="event-action-icon" />
                          </button>
                          <button
                            class="event-action-btn event-action-delete"
                            title="Delete"
                            @click="deleteEvent(event)"
                          >
                            <TrashIcon class="event-action-icon" />
                          </button>
                        </div>
                      </div>
                      <p class="event-desc">
                        {{ event.description }}
                      </p>
                      <p
                        v-if="event.author_name"
                        class="event-author"
                      >
                        by {{ event.author_name }}
                      </p>
                    </template>

                    <!-- Edit mode -->
                    <template v-else>
                      <div class="event-edit-form">
                        <input
                          v-model="editEventDesc"
                          class="form-input"
                          style="font-size:0.85rem;"
                        >
                        <div style="display:flex; gap:6px; margin-top:8px;">
                          <button
                            class="btn btn-primary btn-sm"
                            :disabled="!editEventDesc.trim()"
                            @click="saveEditEvent(event)"
                          >
                            Save
                          </button>
                          <button
                            class="btn btn-outline btn-sm"
                            @click="cancelEditEvent"
                          >
                            Cancel
                          </button>
                        </div>
                      </div>
                    </template>
                  </div>
                </div>
              </div>
            </section>
          </div>

          <!-- Sidebar -->
          <aside class="detail-sidebar">
            <!-- Advanced User Profile -->
            <div
              v-if="app.profiles"
              class="sidebar-block profile-block"
            >
              <div
                class="profile-header"
                style="display:flex; align-items:center; gap:12px; margin-bottom:16px;"
              >
                <img
                  :src="app.profiles.discord_avatar || 'https://cdn.discordapp.com/embed/avatars/0.png'"
                  class="profile-avatar"
                  style="width:50px; height:50px; border-radius:50%; object-fit:cover; border:2px solid var(--border);"
                >
                <div
                  class="profile-names"
                  style="display:flex; flex-direction:column;"
                >
                  <span
                    class="profile-username"
                    style="font-weight:800; color:var(--text); font-size:0.95rem;"
                  >{{ app.discord_username || 'Unknown' }}</span>
                  <span
                    v-if="app.profiles.roblox_username"
                    class="profile-role"
                    style="font-size:0.75rem; color:var(--muted); font-family:monospace;"
                  >@{{ app.profiles.roblox_username }}</span>
                </div>
              </div>
              <div class="user-info-section">
                <!-- Bio removed since it is locally stored only -->
                <div class="info-row">
                  <span class="info-label">Discord ID</span>
                  <span class="info-val"><code class="discord-id-code">{{ app.profiles.discord_id || 'Unknown' }}</code></span>
                </div>
                <div class="info-row">
                  <span class="info-label">Joined Jet2 Platform</span>
                  <span class="info-val">{{ app.profiles.created_at ? formatDate(app.profiles.created_at) : 'Unknown' }}</span>
                </div>
                <div
                  class="info-row"
                  style="margin-top: 6px;"
                >
                  <span class="info-label">Account Status</span>
                  <span
                    v-if="isBanned"
                    style="color: #ef4444; font-weight:700; font-size:0.8rem;"
                  >Currently Banned</span>
                  <span
                    v-else
                    style="color: #10b981; font-weight:700; font-size:0.8rem;"
                  >Clean Record</span>
                </div>
              </div>
            </div>

            <!-- Quick Actions -->
            <div
              v-if="app.profiles && user?.id !== app.user_id"
              class="sidebar-block"
            >
              <h3 class="sidebar-title">
                Quick Actions
              </h3>
              <div style="display:grid; grid-template-columns:1fr 1fr; gap:8px;">
                <button
                  class="btn btn-primary btn-sm"
                  style="background:#10b981; color:#fff;"
                  @click="updateApplicationStatus(app, 'accepted')"
                >
                  Accept
                </button>
                <button
                  class="btn btn-outline btn-sm"
                  style="color:#ef4444; border-color:#ef4444;"
                  @click="updateApplicationStatus(app, 'rejected')"
                >
                  Reject
                </button>
                <button
                  v-if="permissions?.can_ban_users && !isBanned"
                  class="btn btn-danger btn-sm"
                  style="grid-column: 1 / -1; width:100%; justify-content:center; background:rgba(239,68,68,0.1); color:#ef4444; border:1px solid rgba(239,68,68,0.2);"
                  @click="banApplicant"
                >
                  Blacklist User
                </button>
              </div>
            </div>

            <!-- Direct Notification -->
            <div
              v-if="app.profiles && permissions?.can_send_notifications && user?.id !== app.user_id"
              class="sidebar-block"
            >
              <h3 class="sidebar-title">
                Quick Notification
              </h3>
              <p style="font-size: 0.75rem; color: var(--muted); margin-bottom: 8px;">
                Ping applicant directly via Webhook/In-app metrics.
              </p>
              <textarea
                v-model="quickNotificationMsg"
                class="notes-box"
                rows="2"
                placeholder="Send a direct alert..."
              />
              <button
                class="btn btn-primary btn-sm"
                style="width:100%; margin-top:8px; justify-content:center;"
                :disabled="sendingNotif || !quickNotificationMsg"
                @click="sendQuickNotification"
              >
                {{ sendingNotif ? 'Sending...' : 'Send Message' }}
              </button>
              <span
                v-if="notifSent"
                class="text-green"
                style="font-size:0.75rem; margin-top:4px; display:block; text-align:center; font-weight:bold; color:#10b981;"
              >✔ Ping Sent!</span>
            </div>

            <!-- Applicant Feedback -->
            <div
              v-if="app.profiles"
              class="sidebar-block"
            >
              <h3 class="sidebar-title">
                External Applicant Feedback
              </h3>
              <p style="font-size: 0.75rem; color: var(--muted); margin-bottom: 8px;">
                Provide constructive feedback visible explicitly to the applicant when they login.
              </p>
              <textarea
                v-model="applicantFeedback"
                class="notes-box"
                rows="4"
                placeholder="What they did great / what went wrong..."
                @input="savedFeedback = false"
              />
              <div style="display:flex; justify-content:space-between; align-items:center; margin-top: 8px;">
                <span
                  v-if="savingFeedback"
                  class="text-muted"
                  style="font-size: 0.75rem;"
                >Saving...</span>
                <span
                  v-else-if="savedFeedback"
                  style="font-size: 0.75rem; color:#10b981; font-weight:bold;"
                >✔ Published publicly</span>
                <span v-else />
                <button
                  class="btn btn-primary btn-sm"
                  :disabled="savingFeedback"
                  @click="saveApplicantFeedback"
                >
                  Publish Feedback
                </button>
              </div>
            </div>

            <!-- Rating -->
            <div class="sidebar-block">
              <h3 class="sidebar-title">
                Score & Rating
              </h3>
              <div class="rating-display">
                <button
                  v-for="star in 5"
                  :key="star"
                  :class="['star-btn-lg', { filled: star <= app.rating }]"
                  @click="updateRating(star)"
                >
                  ★
                </button>
              </div>
            </div>

            <!-- Notes -->
            <div class="sidebar-block">
              <h3 class="sidebar-title">
                Internal Notes
              </h3>
              <textarea
                v-model="adminNotes"
                class="notes-box"
                placeholder="Add private review notes..."
              />
              <div style="display:flex; justify-content:space-between; align-items:center; margin-top: 8px;">
                <span
                  v-if="savingNotes"
                  class="text-muted"
                  style="font-size: 0.75rem;"
                >Saving...</span>
                <span
                  v-else-if="savedNotes"
                  style="font-size: 0.75rem; color:#10b981; font-weight:bold;"
                >✔ Saved</span>
                <span v-else />
                <button
                  class="btn btn-primary btn-sm"
                  :disabled="savingNotes"
                  @click="saveNotes"
                >
                  Save Notes
                </button>
              </div>
            </div>

            <!-- Stats -->
            <div class="sidebar-block">
              <h3 class="sidebar-title">
                AI Metrics
              </h3>
              <div class="stat-row">
                <span>Mean AI Prob.</span>
                <strong>{{ averageAI }}%</strong>
              </div>
              <div class="stat-row">
                <span>High Risk (>90%)</span>
                <strong :class="{ 'text-red': app.ai_flagged }">{{ highRiskCount }} answers</strong>
              </div>
            </div>
          </aside>
        </div>
      </template>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  ArrowLeftIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  PencilIcon,
  TrashIcon
} from '@heroicons/vue/24/outline'

const route = useRoute()
const supabase = useSupabase()
const { user, permissions } = useAuth()

const adminDisplayName = computed(() => user.value?.user_metadata?.full_name || user.value?.user_metadata?.name || 'Admin')

function formatDate(date) {
  if (!date) return 'Unknown'
  return new Date(date).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
}

const app = ref(null)
const answers = ref([])
const events = ref([])
const loading = ref(true)
const adminNotes = ref('')
const savingNotes = ref(false)
const savedNotes = ref(false)
const isBanned = ref(false)

const applicantFeedback = ref('')
const savingFeedback = ref(false)
const savedFeedback = ref(false)

const quickNotificationMsg = ref('')
const sendingNotif = ref(false)
const notifSent = ref(false)

async function saveApplicantFeedback() {
  savingFeedback.value = true
  try {
    await supabase.from('applications')
      .update({ applicant_feedback: applicantFeedback.value, updated_at: new Date().toISOString() })
      .eq('id', app.value.id)
    app.value.applicant_feedback = applicantFeedback.value
    savedFeedback.value = true
    setTimeout(() => savedFeedback.value = false, 2500)
  } finally {
    savingFeedback.value = false
  }
}

async function sendQuickNotification() {
  if (!quickNotificationMsg.value) return
  sendingNotif.value = true
  try {
    await supabase.from('notifications').insert({
      user_id: app.value.user_id,
      title: 'Message from Admin',
      message: quickNotificationMsg.value,
      type: 'info',
      category: 'admin_broadcast',
      sent_by_name: adminDisplayName.value
    })
    quickNotificationMsg.value = ''
    notifSent.value = true
    setTimeout(() => notifSent.value = false, 2500)
  } catch (e) {
    alert('Failed to send: ' + e.message)
  } finally {
    sendingNotif.value = false
  }
}

async function banApplicant() {
  if (!confirm(`Are you sure you want to ban ${app.value.discord_username}?`)) return
  try {
    await supabase.from('banned_users').insert({ user_id: app.value.user_id, reason: 'Banned from application view', admin_id: user.value.id })
    await supabase.from('profiles').update({ role: 'user', staff_role: null }).eq('id', app.value.user_id)
    isBanned.value = true
  } catch (e) { alert(e.message) }
}

const pendingStatus = ref('')
const savingStatus = ref(false)
const savedStatus = ref(false)

// Editable timeline
const showAddEvent = ref(false)
const customEventType = ref('custom')
const customEventDesc = ref('')
const editingEventId = ref(null)
const editEventDesc = ref('')

const averageAI = computed(() => {
  if (!answers.value || !answers.value.length) return 0
  const scores = answers.value.map(a => a.ai_score || 0)
  const sum = scores.reduce((a, b) => a + b, 0)
  return Math.round(sum / scores.length)
})

const highRiskCount = computed(() => {
  if (!answers.value) return 0
  return answers.value.filter(a => (a.ai_score || 0) > 90).length
})

async function fetchData() {
  loading.value = true

  // Fetch application
  const { data: appData } = await supabase
    .from('applications')
    .select('*, jobs(title)')
    .eq('id', route.params.id)
    .single()

  if (appData) {
    // Manually fetch profile to get roblox_username safely without strict foreign keys
    const { data: profileData } = await supabase
      .from('profiles')
      .select('roblox_username, discord_id, created_at, id, discord_avatar')
      .eq('id', appData.user_id)
      .maybeSingle()

    if (profileData) {
      appData.profiles = profileData
      applicantFeedback.value = appData.applicant_feedback || ''

      const { data: banData } = await supabase
        .from('banned_users')
        .select('id')
        .eq('user_id', profileData.id)
        .maybeSingle()

      isBanned.value = !!banData
    }

    app.value = appData
    pendingStatus.value = appData.status
    adminNotes.value = appData.admin_notes || ''
  }

  // Fetch answers
  const { data: ansData } = await supabase
    .from('application_answers')
    .select('*, job_questions(question)')
    .eq('application_id', route.params.id)
  if (ansData) answers.value = ansData

  // Fetch events
  const { data: evData } = await supabase
    .from('application_events')
    .select('*')
    .eq('application_id', route.params.id)
    .order('created_at', { ascending: false })
  if (evData) events.value = evData

  loading.value = false
}

async function updateApplicationStatus(appRecord, newStatus) {
  pendingStatus.value = newStatus
  await saveStatus()
}

async function saveStatus() {
  if (pendingStatus.value === app.value.status) return
  savingStatus.value = true
  savedStatus.value = false
  const status = pendingStatus.value

  try {
    console.log('Attempting status update to:', status)
    const { data, error } = await supabase.from('applications').update({ status }).eq('id', app.value.id).select()
    if (error) {
      console.error('Supabase application update error:', error)
      throw new Error(`DB Update failed: ${error.message || error.details || JSON.stringify(error)}`)
    }
    if (!data || data.length === 0) throw new Error('Status update rejected by Database Security Rules!')

    app.value.status = status
    await addEvent('status_change', `Status changed to ${status}`)

    const jobTitle = app.value.jobs?.title || 'a job'
    console.log('Attempting notification insert for:', jobTitle)
    const { error: notifError } = await supabase.from('notifications').insert({
      user_id: app.value.user_id,
      title: 'Application Update',
      message: `Your application for ${jobTitle} has been marked as ${status}.`,
      type: 'status_update',
      category: 'status_update',
      sent_by_name: adminDisplayName.value,
      link: `/applications/${app.value.id}`
    })
    
    if (notifError) {
      console.warn('Failed to send notification, but status was updated:', notifError)
    }

    savedStatus.value = true
    setTimeout(() => savedStatus.value = false, 2500)
  } catch (error) {
    console.error('Final caught error in saveStatus:', error)
    alert(`Status Change Error: ${error.message}`)
  } finally {
    savingStatus.value = false
  }
}

async function updateRating(rating) {
  try {
    const { error } = await supabase.from('applications').update({ rating }).eq('id', app.value.id)
    if (error) throw error
    app.value.rating = rating
    await addEvent('rated', `Application rated ${rating} stars`)
  } catch (err) {
    alert(`Failed to save rating: ${err.message}`)
  }
}

async function saveNotes() {
  if (adminNotes.value === app.value.admin_notes) return
  savingNotes.value = true
  savedNotes.value = false
  try {
    await supabase.from('applications').update({ admin_notes: adminNotes.value }).eq('id', app.value.id)
    app.value.admin_notes = adminNotes.value
    await addEvent('note_added', 'Internal note updated')
    savedNotes.value = true
    setTimeout(() => savedNotes.value = false, 2500)
  } catch (err) {
    alert(`Failed to save notes: ${err.message}`)
  } finally {
    savingNotes.value = false
  }
}

async function addEvent(type, desc) {
  try {
    const { data, error } = await supabase.from('application_events').insert({
      application_id: app.value.id,
      event_type: type,
      description: desc,
      author_name: adminDisplayName.value
    }).select().single()
    if (error) throw error
    if (data) events.value.unshift(data)
  } catch (err) {
    console.error('Failed to add event:', err)
  }
}

async function postCustomEvent() {
  if (!customEventDesc.value.trim()) return
  const btn = event.target || null
  if (btn) btn.disabled = true
  try {
    await addEvent(customEventType.value, customEventDesc.value.trim())
    customEventDesc.value = ''
    showAddEvent.value = false
  } finally {
    if (btn) btn.disabled = false
  }
}

function startEditEvent(event) {
  editingEventId.value = event.id
  editEventDesc.value = event.description
}

function cancelEditEvent() {
  editingEventId.value = null
  editEventDesc.value = ''
}

async function saveEditEvent(ev) {
  if (!editEventDesc.value.trim()) return
  const btn = event.target || null
  if (btn) btn.disabled = true
  try {
    const { error } = await supabase
      .from('application_events')
      .update({ description: editEventDesc.value.trim() })
      .eq('id', ev.id)
    if (!error) {
      ev.description = editEventDesc.value.trim()
    } else throw error
    editingEventId.value = null
    editEventDesc.value = ''
  } catch (err) {
    alert(`Failed to save edit: ${err.message}`)
  } finally {
    if (btn) btn.disabled = false
  }
}

async function deleteEvent(ev) {
  if (!confirm('Delete this timeline entry?')) return
  const btn = event.target || null
  if (btn) btn.disabled = true
  try {
    const { error } = await supabase
      .from('application_events')
      .delete()
      .eq('id', ev.id)
    if (!error) {
      events.value = events.value.filter(e => e.id !== ev.id)
    } else throw error
  } catch (err) {
    alert(`Failed to delete event: ${err.message}`)
  } finally {
    if (btn) btn.disabled = false
  }
}

function formatFullDate(d) {
  return new Date(d).toLocaleString('en-GB', {
    day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit'
  })
}

onMounted(() => fetchData())
</script>

<style scoped>
.page { padding-bottom: 80px; }
.container { max-width: 1100px; margin: 0 auto; padding: 0 24px; }

.detail-header { margin: 32px 0; }
.back-link { display: inline-flex; align-items: center; gap: 6px; color: var(--muted); text-decoration: none; font-size: 0.9rem; margin-bottom: 20px; }
.back-icon { width: 16px; height: 16px; }

.header-main { display: flex; justify-content: space-between; align-items: flex-end; }
.applicant-hero { display: flex; align-items: center; gap: 20px; }
.hero-avatar { width: 64px; height: 64px; border-radius: 50%; border: 3px solid var(--border); }
.hero-avatar-placeholder { width: 64px; height: 64px; border-radius: 50%; background: var(--surface); color: var(--red); display: flex; align-items: center; justify-content: center; font-size: 1.5rem; font-weight: 800; border: 3px solid var(--border); }
.hero-name { font-size: 2rem; font-weight: 900; color: var(--text); line-height: 1; margin: 0 0 4px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.hero-sub { color: var(--muted); margin: 0; }
.roblox-badge {
  font-size: 0.75rem;
  font-weight: 800;
  color: #fff;
  background: var(--red);
  padding: 3px 8px;
  border-radius: 6px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  line-height: 1.2;
}

.status-select-lg { background: var(--surface); border: 1px solid var(--border); color: var(--text); padding: 10px 16px; border-radius: 8px; font-weight: 700; cursor: pointer; }

.detail-grid { display: grid; grid-template-columns: 1fr 340px; gap: 40px; margin-top: 40px; }

.review-section { margin-bottom: 40px; }
.section-title { font-size: 1rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); margin-bottom: 20px; }

.alert-box { display: flex; gap: 16px; padding: 20px; border-radius: 12px; margin-bottom: 32px; align-items: flex-start; }
.alert-danger { background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.2); color: #ef4444; }
.alert-icon { width: 24px; height: 24px; flex-shrink: 0; }

.answer-card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 20px; margin-bottom: 12px; }
.answer-header { display: flex; gap: 10px; margin-bottom: 8px; align-items: baseline; }
.q-num { font-weight: 800; color: var(--red); font-size: 0.8rem; }
.q-text { font-weight: 700; color: var(--text); font-size: 0.95rem; }
.ai-badge { font-size: 0.7rem; font-weight: 800; background: #ef4444; color: white; padding: 2px 6px; border-radius: 4px; }
.answer-body { color: var(--text); font-size: 0.9rem; line-height: 1.5; white-space: pre-wrap; }

.cover-letter-box { background: var(--bg); border: 1px solid var(--border); padding: 20px; border-radius: 12px; font-style: italic; color: var(--text); }

.timeline { position: relative; padding-left: 20px; border-left: 2px solid var(--border); margin-left: 10px; }
.timeline-item { position: relative; margin-bottom: 24px; }
.timeline-dot { position: absolute; left: -27px; top: 4px; width: 12px; height: 12px; border-radius: 50%; background: var(--red); border: 2px solid var(--bg); }
.dot-custom { background: #3b82f6; }
.dot-status_change { background: var(--red); }
.dot-note_added { background: #8b5cf6; }
.dot-submitted { background: #10b981; }
.dot-rated { background: #f59e0b; }
.timeline-header { display: flex; justify-content: space-between; margin-bottom: 4px; align-items: center; }
.event-type { font-size: 0.75rem; font-weight: 800; text-transform: uppercase; color: var(--text); }
.event-time { font-size: 0.75rem; color: var(--subtle); }
.event-desc { font-size: 0.85rem; color: var(--muted); margin: 0; }
.event-author { font-size: 0.72rem; color: #3b82f6; font-weight: 600; margin: 4px 0 0; }

.event-actions-row { display: flex; align-items: center; gap: 4px; }
.event-action-btn {
  border: none;
  background: transparent;
  color: var(--subtle);
  cursor: pointer;
  padding: 3px;
  border-radius: 4px;
  display: inline-flex;
  transition: color 150ms ease, background 150ms ease;
}
.event-action-btn:hover { color: var(--text); background: var(--bg-alt, rgba(0,0,0,0.04)); }
.event-action-delete:hover { color: #ef4444; background: rgba(239,68,68,0.08); }
.event-action-icon { width: 13px; height: 13px; }

.event-compose {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 20px;
}
.compose-row { display: flex; gap: 8px; align-items: center; }

.event-edit-form {
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 12px;
}

.form-input {
  padding: 8px 12px;
  border: 1px solid var(--border);
  border-radius: 7px;
  background: var(--bg);
  color: var(--text);
  font-size: 0.85rem;
  outline: none;
  font-family: inherit;
  transition: border-color 150ms ease;
}
.form-input:focus { border-color: var(--red); }

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
  transition: background 150ms ease;
  white-space: nowrap;
}
.btn-sm { padding: 7px 14px; font-size: 0.82rem; }
.btn-primary { background: var(--red); color: #fff; }
.btn-primary:hover { background: var(--red-hover); }
.btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-outline { background: transparent; color: var(--muted); border: 1px solid var(--border); }
.btn-outline:hover { color: var(--text); border-color: var(--muted); }

.sidebar-block { background: var(--surface); border: 1px solid var(--border); padding: 24px; border-radius: 16px; margin-bottom: 24px; }
.sidebar-title { font-size: 0.85rem; font-weight: 700; text-transform: uppercase; color: var(--muted); margin-bottom: 16px; }

.rating-display { display: flex; gap: 5px; }
.star-btn-lg { background: none; border: none; font-size: 2rem; color: var(--border); cursor: pointer; transition: 0.2s; padding: 0; }
.star-btn-lg.filled { color: #f59e0b; }

.notes-box { width: 100%; height: 120px; background: var(--bg); border: 1px solid var(--border); border-radius: 8px; color: var(--text); padding: 12px; font-size: 0.9rem; resize: none; margin-bottom: 8px; font-family: inherit; }

.stat-row { display: flex; justify-content: space-between; font-size: 0.9rem; margin-bottom: 10px; }
.text-red { color: #ef4444; }

.user-info-section { display: flex; flex-direction: column; gap: 8px; }
.info-row { display: flex; justify-content: space-between; align-items: center; }
.info-label { font-size: 0.8rem; color: var(--muted); }
.info-val { font-size: 0.85rem; font-weight: 600; color: var(--text); }
.discord-id-code { background: var(--bg-alt); padding: 2px 6px; border-radius: 4px; font-size: 0.75rem; }

@media (max-width: 800px) {
  .detail-grid { grid-template-columns: 1fr; }
  .header-main { flex-direction: column; align-items: flex-start; gap: 20px; }
}
</style>
