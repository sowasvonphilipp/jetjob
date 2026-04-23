<template>
  <main class="page">
    <div class="container">
      <!-- Loading -->
      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
        <p>Loading job details…</p>
      </div>

      <!-- Not found -->
      <div
        v-else-if="!job"
        class="empty-state"
      >
        <h2>Job not found</h2>
        <p>This listing may have been removed or doesn't exist.</p>
        <NuxtLink
          to="/jobs"
          class="btn btn-primary"
        >Back to listings</NuxtLink>
      </div>

      <!-- Job detail -->
      <template v-else>
        <NuxtLink
          to="/jobs"
          class="back-link"
        >
          <ArrowLeftIcon
            class="back-icon"
            aria-hidden="true"
          />
          Back to listings
        </NuxtLink>

        <!-- Banner -->
        <div
          v-if="job.image_url"
          class="detail-banner"
        >
          <img
            :src="job.image_url"
            :alt="job.title"
            class="detail-banner-img"
          >
        </div>

        <div class="detail-grid">
          <!-- Main content -->
          <div class="detail-main">
            <span class="dept-tag">{{ job.department }}</span>
            <h1 class="detail-title">
              {{ job.title }}
            </h1>
            <p class="detail-short">
              {{ job.short_description }}
            </p>

            <div
              class="detail-body"
              v-html="formattedDescription"
            />

            <div v-if="formattedRequirements" style="margin-top: 32px;">
              <h2 class="section-heading">Description</h2>
              <div
                class="detail-body"
                v-html="formattedRequirements"
              />
            </div>

            <!-- New Requirements Grid -->
            <div class="req-badges-grid">
               <div v-if="job.min_age" class="req-badge">
                 <span class="rb-label">Min Age</span>
                 <span class="rb-value">{{ job.min_age }}+</span>
               </div>
               <div v-if="job.flight_hours_required" class="req-badge">
                 <span class="rb-label">Experience Hours</span>
                 <span class="rb-value">{{ job.flight_hours_required }}h</span>
               </div>
               <div v-if="job.atc_hours_required" class="req-badge">
                 <span class="rb-label">Training Hours</span>
                 <span class="rb-value">{{ job.atc_hours_required }}h</span>
               </div>
               <div v-if="job.base_hub" class="req-badge">
                 <span class="rb-label">Primary Location</span>
                 <span class="rb-value">{{ job.base_hub }}</span>
               </div>
               <div class="req-badge">
                 <span class="rb-label">Discord</span>
                 <span class="rb-value">{{ job.discord_required ? 'Req' : 'No' }}</span>
               </div>
               <div class="req-badge">
                 <span class="rb-label">External Network</span>
                 <span class="rb-value">{{ job.flying_vatsim_required ? 'Req' : 'No' }}</span>
               </div>
            </div>
          </div>

          <!-- Sidebar -->
          <aside class="detail-sidebar">
            <div class="sidebar-card">
              <h3 class="sidebar-title">
                Position Details
              </h3>

              <div class="sidebar-row">
                <MapPinIcon
                  class="sidebar-icon"
                  aria-hidden="true"
                />
                <div>
                  <span class="sidebar-label">Location</span>
                  <span class="sidebar-value">{{ job.location }}</span>
                </div>
              </div>

              <div class="sidebar-row">
                <CurrencyDollarIcon
                  class="sidebar-icon"
                  aria-hidden="true"
                />
                <div>
                  <span class="sidebar-label">Salary</span>
                  <span class="sidebar-value">{{ job.salary || 'Not specified' }}</span>
                </div>
              </div>

              <div class="sidebar-row">
                <UsersIcon
                  class="sidebar-icon"
                  aria-hidden="true"
                />
                <div>
                  <span class="sidebar-label">Applicants</span>
                  <span class="sidebar-value">
                    {{ job.applicant_count }}{{ job.applicant_limit ? ` / ${job.applicant_limit}` : '' }}
                  </span>
                </div>
              </div>

              <div class="sidebar-row">
                <CalendarIcon
                  class="sidebar-icon"
                  aria-hidden="true"
                />
                <div>
                  <span class="sidebar-label">Posted</span>
                  <span class="sidebar-value">{{ formatDate(job.posted_at) }}</span>
                </div>
              </div>

              <div
                v-if="job.closing_at"
                class="sidebar-row"
              >
                <ClockIcon
                  class="sidebar-icon"
                  aria-hidden="true"
                />
                <div>
                  <span class="sidebar-label">Closes</span>
                  <span class="sidebar-value">{{ formatDate(job.closing_at) }}</span>
                </div>
              </div>

              <div
                v-if="job.start_date"
                class="sidebar-row"
              >
                <CalendarIcon
                  class="sidebar-icon"
                  aria-hidden="true"
                />
                <div>
                  <span class="sidebar-label">Expected Start</span>
                  <span class="sidebar-value">{{ job.start_date }}</span>
                </div>
              </div>



              <!-- Status messages -->
              <div
                v-if="bannedReason"
                class="status-badge status-closed"
                style="text-align:left; background:rgba(239,68,68,0.1); border:1px solid rgba(239,68,68,0.3); color:#ef4444;"
              >
                <XCircleIcon
                  class="status-icon"
                  aria-hidden="true"
                  style="flex-shrink:0"
                />
                <div>
                  <strong>Your account is blacklisted.</strong>
                  <div style="font-size:0.75rem; margin-top:2px; font-weight:normal; opacity:0.9;">
                    Reason: {{ bannedReason }}
                  </div>
                </div>
              </div>
              <div
                v-else-if="isFull"
                class="status-badge status-full"
              >
                <XCircleIcon
                  class="status-icon"
                  aria-hidden="true"
                />
                Applications full
              </div>
              <div
                v-else-if="isClosed"
                class="status-badge status-closed"
              >
                <XCircleIcon
                  class="status-icon"
                  aria-hidden="true"
                />
                Applications closed
              </div>

              <div
                v-else-if="hasApplied"
                class="applied-badge-container"
              >
                <div class="applied-badge">
                  <CheckCircleIcon class="status-icon" aria-hidden="true" />
                  Your Application is Pending
                </div>
                <p class="success-note">
                  {{ job.custom_success_message || 'Our team will review your application soon.' }}
                </p>
                <span class="status-pill">{{ existingApplication?.status }}</span>
              </div>

              <!-- Apply button (opens form) -->
              <div v-else-if="!isFull && !isClosed && !bannedReason">
                <button
                  class="btn btn-primary btn-full"
                  @click="showApplyForm = true"
                >
                  Apply Now ({{ questions.length }} question{{ questions.length !== 1 ? 's' : '' }})
                </button>
              </div>
            </div>
          </aside>
        </div>

        <!-- ═══ APPLICATION FORM (full width below) ═══ -->
        <div
          v-if="showApplyForm && !hasApplied && !isFull && !isClosed && !bannedReason"
          class="apply-form-section"
        >
          <div class="apply-form-card">
            <h2 class="apply-form-title">
              Apply for {{ job.title }}
            </h2>
            <p class="apply-form-sub">
              Complete the questions below and submit your application.
            </p>

            <!-- Questions -->
            <div class="questions-list">
              <div
                v-for="(q, idx) in questions"
                :key="q.id"
                class="question-block"
              >
                <label class="question-label">
                  <span class="question-number">{{ idx + 1 }}.</span>
                  {{ q.question }}
                  <span
                    v-if="q.required"
                    class="required-star"
                  >*</span>
                </label>

                <!-- Text -->
                <input
                  v-if="q.type === 'text'"
                  v-model="answers[q.id]"
                  type="text"
                  class="q-input"
                  :placeholder="q.required ? 'Required' : 'Optional'"
                >

                <!-- Number -->
                <input
                  v-else-if="q.type === 'number'"
                  v-model.number="answers[q.id]"
                  type="number"
                  class="q-input"
                  min="0"
                  :placeholder="q.required ? 'Required' : 'Optional'"
                >

                <!-- Textarea -->
                <textarea
                  v-else-if="q.type === 'textarea'"
                  v-model="answers[q.id]"
                  class="q-textarea"
                  rows="3"
                  :placeholder="q.required ? 'Required' : 'Optional'"
                />

                <!-- Select -->
                <select
                  v-else-if="q.type === 'select'"
                  v-model="answers[q.id]"
                  class="q-select"
                >
                  <option
                    value=""
                    disabled
                  >
                    Select an option…
                  </option>
                  <option
                    v-for="opt in parseOptions(q.options)"
                    :key="opt"
                    :value="opt"
                  >
                    {{ opt }}
                  </option>
                </select>

                <!-- Checkbox -->
                <label
                  v-else-if="q.type === 'checkbox'"
                  class="q-checkbox"
                >
                  <input
                    v-model="answers[q.id]"
                    type="checkbox"
                  >
                  <span>Yes</span>
                </label>
              </div>
            </div>

            <!-- Cover letter -->
            <div class="question-block">
              <label class="question-label">Cover letter <span class="optional-text">(optional)</span></label>
              <textarea
                v-model="coverLetter"
                class="q-textarea"
                rows="4"
                placeholder="Write a short cover letter…"
              />
            </div>

            <!-- Submit -->
            <div class="apply-form-actions" style="display:flex; flex-direction:column; gap:16px; margin-top:24px;">
              <label class="q-checkbox" style="display:flex; gap:10px; align-items:flex-start; cursor:pointer;" v-if="job.requirements">
                <input v-model="requirementsMet" type="checkbox" style="width:18px;height:18px;margin-top:2px;accent-color:var(--red);" />
                <span style="font-size: 0.9rem; font-weight: 600; color:var(--text); line-height:1.4;">I confirm that I meet all of the stated role requirements and understand that submitting false information may result in a blacklist.</span>
              </label>

              <div style="display:flex; align-items:center; justify-content:flex-end; gap:12px; border-top:1px solid var(--border); padding-top:20px;">
                <button
                  class="btn btn-outline"
                  @click="showApplyForm = false"
                >
                  Cancel
                </button>
                <button
                  class="btn btn-primary"
                  :disabled="applying || !canSubmit || (!!job.requirements && !requirementsMet)"
                  @click="applyForJob"
                >
                  <span v-if="!applying">Submit Application</span>
                  <span v-else>Submitting…</span>
                </button>
              </div>
            </div>

            <p
              v-if="applyError"
              class="error-text"
            >
              {{ applyError }}
            </p>
          </div>
        </div>
      </template>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  ArrowLeftIcon,
  MapPinIcon,
  CurrencyDollarIcon,
  UsersIcon,
  CalendarIcon,
  ClockIcon,
  ClipboardDocumentCheckIcon,
  CheckCircleIcon,
  XCircleIcon
} from '@heroicons/vue/24/outline'

const route = useRoute()
const supabase = useSupabase()
const { user } = useAuth()

const job = ref(null)
const loading = ref(true)
const coverLetter = ref('')
const applying = ref(false)
const applyError = ref('')
const existingApplication = ref(null)
const bannedReason = ref(null)
const questions = ref([])
const answers = ref({})
const showApplyForm = ref(false)
const requirementsMet = ref(false)

const hasApplied = computed(() => !!existingApplication.value)
const isFull = computed(() => job.value?.applicant_limit && job.value.applicant_count >= job.value.applicant_limit)
const isClosed = computed(() => job.value?.closing_at && new Date(job.value.closing_at) < new Date())

const canSubmit = computed(() => {
  return questions.value
    .filter(q => q.required)
    .every((q) => {
      const val = answers.value[q.id]
      if (q.type === 'checkbox') return val === true
      if (q.type === 'number') return val !== undefined && val !== null && val !== ''
      return val && String(val).trim() !== ''
    })
})

const formattedDescription = computed(() => {
  if (!job.value?.long_description) return ''
  return job.value.long_description
    .split('\n')
    .map(p => p.trim() ? `<p>${p}</p>` : '')
    .join('')
})

const formattedRequirements = computed(() => {
  if (!job.value?.requirements || job.value.requirements === '0') return ''
  return String(job.value.requirements)
    .split('\n')
    .map(p => p.trim() ? `<p>${p}</p>` : '')
    .join('')
})

function formatDate(date) {
  return new Date(date).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
}

function parseOptions(options) {
  if (!options) return []
  if (Array.isArray(options)) return options
  try { return JSON.parse(options) } catch { return [] }
}

async function fetchJob() {
  loading.value = true
  const { data, error } = await supabase
    .from('jobs')
    .select('*')
    .eq('id', route.params.id)
    .single()
  if (data) job.value = data
  if (error) console.error('Error fetching job:', error)
  loading.value = false
}

async function fetchQuestions() {
  const { data } = await supabase
    .from('job_questions')
    .select('*')
    .eq('job_id', route.params.id)
    .order('sort_order', { ascending: true })
  if (data) {
    questions.value = data
    // Init answers
    const init = {}
    data.forEach((q) => {
      if (q.type === 'checkbox') init[q.id] = false
      else if (q.type === 'number') init[q.id] = null
      else init[q.id] = ''
    })
    answers.value = init
  }
}

async function checkExistingApplication() {
  if (!user.value) return

  const { data: banData } = await supabase
    .from('banned_users')
    .select('reason')
    .eq('user_id', user.value.id)
    .maybeSingle()

  if (banData) {
    bannedReason.value = banData.reason || 'No reason provided.'
    return
  }

  const { data } = await supabase
    .from('applications')
    .select('*')
    .eq('job_id', route.params.id)
    .eq('user_id', user.value.id)
    .maybeSingle()
  if (data) existingApplication.value = data
}

// Extremely simple mock AI detection using common LLM markers
function scanForAI(text) {
  if (!text) return 0
  const t = text.toLowerCase()
  const markers = [
    'as an ai', 'language model', 'delve', 'crucial', 'furthermore',
    'moreover', 'in conclusion', 'tapestry', 'testament', 'multifaceted',
    'robust', 'aligns perfectly', 'fostering', 'symbiosis'
  ]
  let score = Math.floor(Math.random() * 8) // Base variance 0-7
  markers.forEach((m) => { if (t.includes(m)) score += 25 })
  if (t.length > 500 && score < 15) score += 10
  return Math.min(100, score)
}

async function applyForJob() {
  if (!user.value) {
    navigateTo('/login')
    return
  }

  applying.value = true
  applyError.value = ''

  // 1. Calculate AI Scores per answer
  const answerRows = questions.value.map((q) => {
    const val = answers.value[q.id]
    const textToScan = q.type === 'textarea' || q.type === 'text' ? String(val || '') : ''
    const score = textToScan ? scanForAI(textToScan) : 0
    return {
      question_id: q.id,
      answer: q.type === 'checkbox' ? String(val) : String(val ?? ''),
      ai_score: score
    }
  })

  const aiScores = answerRows.map(r => r.ai_score)
  const highScoresCount = aiScores.filter(s => s > 90).length
  const isFlagged = highScoresCount >= 3

  // 2. Create application
  const { data: appData, error: appError } = await supabase.from('applications').insert({
    job_id: job.value.id,
    user_id: user.value.id,
    discord_username: user.value.user_metadata?.full_name || user.value.user_metadata?.name || 'Unknown',
    discord_avatar: user.value.user_metadata?.avatar_url || null,
    cover_letter: coverLetter.value.trim() || null,
    ai_scores: aiScores,
    ai_flagged: isFlagged
  }).select().single()

  if (appError) {
    applyError.value = appError.message.includes('duplicate')
      ? 'You have already applied for this position.'
      : `Error: ${appError.message}`
    applying.value = false
    return
  }

  // 3. Insert answers with scores
  if (appData && answerRows.length > 0) {
    const rows = answerRows.map(r => ({
      ...r,
      application_id: appData.id
    }))
    await supabase.from('application_answers').insert(rows)

    // 4. Create timeline event
    await supabase.from('application_events').insert({
      application_id: appData.id,
      event_type: 'submitted',
      description: 'Application submitted through the portal.',
      metadata: { ai_flagged: isFlagged, high_risk_answers: highScoresCount }
    })
  }

  showApplyForm.value = false
  await checkExistingApplication()
  await fetchJob()
  applying.value = false
}

onMounted(async () => {
  await fetchJob()
  await Promise.all([fetchQuestions(), checkExistingApplication()])
})

useSeoMeta({
  title: computed(() => job.value ? `${job.value.title} — Sunshine Studio` : 'Job Details — Sunshine Studio'),
  description: computed(() => job.value?.short_description || 'View job details and apply.')
})
</script>

<style scoped>
.page { min-height: 100vh; padding-bottom: 64px; }
.container { max-width: 900px; margin: 0 auto; padding: 0 24px; }

.back-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--muted);
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 500;
  margin: 32px 0 20px;
  transition: color 150ms ease;
}
.back-link:hover { color: var(--text); }
.back-icon { width: 16px; height: 16px; }

.detail-banner {
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 24px;
  max-height: 200px;
}
.detail-banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 32px;
  align-items: start;
}

.dept-tag {
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--red);
  background: rgba(232,55,42,0.09);
  padding: 2px 8px;
  border-radius: 99px;
  display: inline-block;
  margin-bottom: 8px;
}

.detail-title {
  font-size: 1.6rem;
  font-weight: 900;
  color: var(--text);
  margin: 0 0 10px;
  letter-spacing: -0.02em;
  line-height: 1.2;
}

.detail-short {
  font-size: 0.95rem;
  color: var(--muted);
  line-height: 1.65;
  margin: 0 0 24px;
}

.detail-body {
  font-size: 0.9rem;
  color: var(--text);
  line-height: 1.7;
}
.detail-body :deep(p) {
  margin: 0 0 14px;
}

/* Sidebar */
.sidebar-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 24px;
  position: sticky;
  top: 80px;
}
.sidebar-title {
  font-size: 0.95rem;
  font-weight: 800;
  color: var(--text);
  margin: 0 0 18px;
}
.sidebar-row {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  margin-bottom: 14px;
}
.sidebar-icon {
  width: 16px;
  height: 16px;
  color: var(--red);
  flex-shrink: 0;
  margin-top: 2px;
}
.sidebar-label {
  display: block;
  font-size: 0.72rem;
  font-weight: 600;
  color: var(--subtle);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.sidebar-value {
  display: block;
  font-size: 0.85rem;
  color: var(--text);
  font-weight: 500;
}

/* Status badges */
.status-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.82rem;
  font-weight: 600;
  padding: 10px 14px;
  border-radius: 8px;
  margin-top: 16px;
}
.status-icon { width: 18px; height: 18px; flex-shrink: 0; }
.status-full { background: rgba(239,68,68,0.1); color: #ef4444; }
.status-closed { background: rgba(107,114,128,0.1); color: #6b7280; }

.applied-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  text-align: center;
  font-size: 0.85rem;
  font-weight: 600;
  color: #22c55e;
  background: rgba(34,197,94,0.08);
  padding: 14px;
  border-radius: 8px;
  margin-top: 16px;
}
.applied-status {
  font-size: 0.75rem;
  font-weight: 500;
  color: var(--muted);
  text-transform: capitalize;
}

/* Cover letter & apply */
.cover-textarea {
  width: 100%;
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--text);
  border-radius: 8px;
  padding: 10px 12px;
  font-size: 0.85rem;
  resize: vertical;
  outline: none;
  margin-top: 16px;
  margin-bottom: 12px;
  font-family: inherit;
  transition: border-color 150ms ease;
}
.cover-textarea:focus {
  border-color: var(--red);
}
.cover-textarea::placeholder { color: var(--subtle); }

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  font-size: 0.875rem;
  font-weight: 600;
  padding: 12px 20px;
  border-radius: 7px;
  text-decoration: none;
  border: none;
  cursor: pointer;
  transition: background 150ms ease, transform 130ms ease, box-shadow 150ms ease;
  white-space: nowrap;
}
.btn-primary {
  background: var(--red);
  color: #fff;
  box-shadow: 0 2px 8px rgba(232,55,42,0.25);
}
.btn-primary:hover {
  background: var(--red-hover);
  transform: translateY(-1px);
}
.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}
.btn-full { width: 100%; }

.error-text {
  color: #ef4444;
  font-size: 0.78rem;
  margin-top: 8px;
  text-align: center;
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

@media (max-width: 768px) {
  .detail-grid {
    grid-template-columns: 1fr;
  }
  .sidebar-card {
    position: static;
  }
}

/* ─── Application form ───────────────────────────────────────────────── */
.apply-form-section {
  margin-top: 32px;
  padding-top: 32px;
  border-top: 1px solid var(--border);
}

.apply-form-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 32px;
  max-width: 680px;
}

.apply-form-title {
  font-size: 1.2rem;
  font-weight: 800;
  color: var(--text);
  margin: 0 0 6px;
}
.apply-form-sub {
  font-size: 0.85rem;
  color: var(--muted);
  margin: 0 0 28px;
}

.questions-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-bottom: 24px;
}

.question-block {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.question-label {
  font-size: 0.88rem;
  font-weight: 600;
  color: var(--text);
  display: flex;
  align-items: baseline;
  gap: 5px;
  flex-wrap: wrap;
}
.question-number {
  color: var(--red);
  font-weight: 800;
  font-size: 0.82rem;
}
.required-star { color: var(--red); font-weight: 700; }
.optional-text { color: var(--subtle); font-weight: 400; font-size: 0.78rem; }

.q-input, .q-textarea, .q-select {
  padding: 10px 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  background: var(--bg);
  color: var(--text);
  font-size: 0.85rem;
  font-family: inherit;
  outline: none;
  transition: border-color 150ms ease;
}
.q-input:focus, .q-textarea:focus, .q-select:focus {
  border-color: var(--red);
}
.q-textarea { resize: vertical; min-height: 60px; }
.q-select { cursor: pointer; }

.q-checkbox {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: var(--text);
  cursor: pointer;
  padding: 6px 0;
}
.q-checkbox input[type="checkbox"] {
  width: 18px;
  height: 18px;
  accent-color: var(--red);
  cursor: pointer;
}

.apply-form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid var(--border);
}

.req-badges-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 12px; margin-top: 32px;
}
.req-badge {
  background: var(--surface); border: 1px solid var(--border);
  padding: 12px; border-radius: 10px; display: flex; flex-direction: column; gap: 4px;
}
.rb-label { font-size: 0.65rem; font-weight: 800; color: var(--subtle); text-transform: uppercase; }
.rb-value { font-size: 0.95rem; font-weight: 800; color: var(--text); }

.applied-badge-container { display: flex; flex-direction: column; gap: 12px; }
.success-note { font-size: 0.82rem; color: var(--muted); line-height: 1.5; margin: 0; }
.status-pill { background: rgba(232,55,42,0.1); color: var(--red); font-size: 0.75rem; font-weight: 800; padding: 4px 10px; border-radius: 99px; align-self: flex-start; text-transform: uppercase; }
.section-heading { font-size: 1.1rem; font-weight: 900; color: var(--text); margin-bottom: 12px; }
</style>
