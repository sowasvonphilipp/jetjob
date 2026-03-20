<template>
  <main class="page">
    <div class="container">
      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
        <p>Loading your application...</p>
      </div>

      <div
        v-else-if="!app"
        class="empty-state"
      >
        <h2>Application not found</h2>
        <NuxtLink
          to="/applications"
          class="btn btn-primary"
        >My Applications</NuxtLink>
      </div>

      <template v-else>
        <div class="header-section">
          <NuxtLink
            to="/applications"
            class="back-link"
          >
            <ArrowLeftIcon class="back-icon" /> My Applications
          </NuxtLink>

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

          <div class="app-hero">
            <h1 class="page-title">
              {{ app.jobs?.title }}
            </h1>
            <div class="stepper-wrap">
              <div class="stepper">
                <!-- 1. APPLIED -->
                <div :class="['step', { active: app.status === 'pending', completed: app.status !== 'pending' }]">
                  <div class="step-dot">
                    <CheckIcon
                      v-if="app.status !== 'pending'"
                      class="step-check"
                    />
                  </div>
                  <div class="step-label">
                    Applied
                  </div>
                </div>
                <div
                  class="step-line"
                  :class="{ filled: app.status !== 'pending' }"
                />

                <!-- 2. REVIEWING -->
                <div :class="['step', { active: app.status === 'reviewing', completed: ['interview', 'accepted', 'rejected'].includes(app.status) }]">
                  <div class="step-dot">
                    <CheckIcon
                      v-if="['interview', 'accepted', 'rejected'].includes(app.status)"
                      class="step-check"
                    />
                  </div>
                  <div class="step-label">
                    Reviewing
                  </div>
                </div>
                <div
                  class="step-line"
                  :class="{ filled: ['interview', 'accepted', 'rejected'].includes(app.status) }"
                />

                <!-- 3. INTERVIEW -->
                <div :class="['step', { active: app.status === 'interview', completed: ['accepted', 'rejected'].includes(app.status) }]">
                  <div class="step-dot">
                    <CheckIcon
                      v-if="['accepted', 'rejected'].includes(app.status)"
                      class="step-check"
                    />
                  </div>
                  <div class="step-label">
                    Interview
                  </div>
                </div>
                <div
                  class="step-line"
                  :class="{ filled: ['accepted', 'rejected'].includes(app.status) }"
                />

                <!-- 4. DECISION -->
                <div :class="['step', { active: ['accepted', 'rejected'].includes(app.status), [app.status]: true }]">
                  <div class="step-dot">
                    <CheckIcon
                      v-if="['accepted', 'rejected'].includes(app.status)"
                      class="step-check"
                    />
                  </div>
                  <div class="step-label">
                    <span v-if="app.status === 'accepted'">Accepted</span>
                    <span v-else-if="app.status === 'rejected'">Rejected</span>
                    <span v-else>Decision</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Result Cards -->
        <div
          v-if="app.status === 'accepted'"
          class="result-card result-accepted"
        >
          <h3 class="result-title">
            <CheckCircleIcon class="result-icon" /> Welcome to Jet2!
          </h3>
          <p class="result-text">
            Congratulations, your application has been <strong>Accepted</strong>. We are thrilled to have you join the team.
          </p>
          <div
            class="feedback-box"
            style="margin-top: 24px; padding: 16px; background: rgba(16, 185, 129, 0.08); border-radius: 12px; border: 1px solid rgba(16, 185, 129, 0.15);"
          >
            <h4 style="margin: 0 0 8px; font-size: 0.8rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em; color: #059669;">
              Staff Feedback
            </h4>
            <p style="margin: 0; font-size: 0.95rem; line-height: 1.5; color: var(--text); white-space: pre-wrap;">
              {{ app.applicant_feedback || 'No feedback given' }}
            </p>
          </div>
          <div class="result-steps">
            <h4>Next Steps</h4>
            <ul>
              <li>Join the Jet2 Staff Communications Server.</li>
              <li>Wait for your department Head to assign you a training role.</li>
              <li>Review the staff handbook available in the server.</li>
            </ul>
          </div>
        </div>

        <div
          v-else-if="app.status === 'rejected'"
          class="result-card result-rejected"
        >
          <h3 class="result-title">
            <XCircleIcon class="result-icon" /> Application Update
          </h3>
          <p class="result-text">
            Thank you for your interest in Jet2. Unfortunately, your application has been <strong>Rejected</strong> at this time.
          </p>
          <p class="result-text">
            Due to the high volume of applicants and strict requirements, we could not proceed with your application. We encourage you to improve your skills and apply again during the next hiring wave.
          </p>
          <div
            class="feedback-box"
            style="margin-top: 24px; padding: 16px; background: rgba(239, 68, 68, 0.08); border-radius: 12px; border: 1px solid rgba(239, 68, 68, 0.15);"
          >
            <h4 style="margin: 0 0 8px; font-size: 0.8rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em; color: #dc2626;">
              Staff Feedback
            </h4>
            <p style="margin: 0; font-size: 0.95rem; line-height: 1.5; color: var(--text); white-space: pre-wrap;">
              {{ app.applicant_feedback || 'No feedback given' }}
            </p>
          </div>
        </div>

        <div
          v-else-if="app.status === 'interview'"
          class="result-card result-interview"
        >
          <h3 class="result-title">
            <CalendarIcon class="result-icon" /> Interview Stage
          </h3>
          <p class="result-text">
            Great news! Your application is moving to the <strong>Interview</strong> stage.
          </p>
          <p class="result-text">
            Please keep an eye on your Discord DMs or email for an invitation to schedule an interview with human resources.
          </p>
        </div>

        <div class="content-grid">
          <!-- Left: Details & Answers -->
          <div class="main-content">
            <section class="info-block">
              <h3 class="block-title">
                Your Submission
              </h3>
              <div class="answers-list">
                <div
                  v-for="(ans, idx) in answers"
                  :key="ans.id"
                  class="ans-item"
                >
                  <div class="ans-label">
                    {{ idx + 1 }}. {{ ans.job_questions?.question }}
                  </div>
                  <div class="ans-value">
                    {{ ans.answer || '—' }}
                  </div>
                </div>
              </div>
            </section>

            <section
              v-if="app.cover_letter"
              class="info-block"
            >
              <h3 class="block-title">
                Cover Letter
              </h3>
              <div class="cover-text">
                "{{ app.cover_letter }}"
              </div>
            </section>
          </div>

          <!-- Right: Sidebar -->
          <aside class="sidebar">
            <div class="sidebar-card job-box">
              <h3 class="block-title">
                Job Details
              </h3>
              <div class="job-mini-info">
                <div class="mini-row">
                  <BriefcaseIcon class="mini-icon" />
                  <span>{{ app.jobs?.department }}</span>
                </div>
                <div class="mini-row">
                  <MapPinIcon class="mini-icon" />
                  <span>{{ app.jobs?.location }}</span>
                </div>
              </div>
            </div>

            <div class="sidebar-card">
              <h3 class="block-title">
                Activity Timeline
              </h3>
              <div class="vertical-timeline">
                <div
                  v-for="event in timeline"
                  :key="event.id"
                  class="t-item"
                >
                  <div class="t-line" />
                  <div class="t-marker" />
                  <div class="t-info">
                    <div class="t-type">
                      {{ event.event_type.replace('_', ' ') }}
                    </div>
                    <div class="t-desc">
                      {{ getPublicDesc(event) }}
                    </div>
                    <div
                      v-if="event.author_name"
                      class="t-author"
                    >
                      by {{ event.author_name }}
                    </div>
                    <div class="t-date">
                      {{ formatDate(event.created_at) }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </aside>
        </div>
      </template>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ArrowLeftIcon, CheckIcon, MapPinIcon, BriefcaseIcon, CheckCircleIcon, XCircleIcon, CalendarIcon } from '@heroicons/vue/24/outline'

const route = useRoute()
const supabase = useSupabase()

const app = ref(null)
const answers = ref([])
const timeline = ref([])
const notices = ref([])
const loading = ref(true)

async function fetchApplication() {
  loading.value = true

  // 1. Get Application (Ensures it belongs to the user via RLS)
  const { data: appData } = await supabase
    .from('applications')
    .select('*, jobs(*)')
    .eq('id', route.params.id)
    .single()

  if (appData) {
    app.value = appData

    // 2. Get Answers
    const { data: ansData } = await supabase
      .from('application_answers')
      .select('*, job_questions(question)')
      .eq('application_id', appData.id)
    if (ansData) answers.value = ansData

    // 3. Get Events (Public ones only)
    const { data: evData } = await supabase
      .from('application_events')
      .select('*')
      .eq('application_id', appData.id)
      .in('event_type', ['submitted', 'status_change', 'custom'])
      .order('created_at', { ascending: false })
    if (evData) timeline.value = evData

    // 4. Get Notices (global + job-specific)
    const jobId = appData.job_id
    const { data: noticeData } = await supabase
      .from('application_notices')
      .select('*')
      .eq('is_active', true)
      .or(`target.eq.all,target_job_id.eq.${jobId}`)
      .order('created_at', { ascending: false })
    if (noticeData) notices.value = noticeData
  }

  loading.value = false
}

function getPublicDesc(event) {
  if (event.event_type === 'submitted') return 'We securely received your application and it is in queue for review.'
  if (event.event_type === 'status_change') {
    if (event.description.includes('reviewing')) return 'We are actively reviewing your application details.'
    if (event.description.includes('interview')) return 'You have been selected for an interview! Keep an eye on your Discord or email.'
    if (event.description.includes('accepted')) return 'Congratulations! You have been accepted for the position.'
    if (event.description.includes('rejected')) return 'Unfortunately, we are moving forward with other candidates at this time.'
    return event.description
  }
  return event.description
}

function formatDate(d) {
  return new Date(d).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
}

onMounted(() => fetchApplication())
</script>

<style scoped>
.page { padding-top: 40px; padding-bottom: 80px; }
.container { max-width: 1000px; margin: 0 auto; padding: 0 24px; }

.header-section { margin-bottom: 40px; }
.back-link { display: inline-flex; align-items: center; gap: 6px; color: var(--muted); text-decoration: none; font-size: 0.85rem; margin-bottom: 24px; }
.back-icon { width: 14px; height: 14px; }

.app-hero { margin-bottom: 20px; }
.page-title { font-size: 2.22rem; font-weight: 900; margin: 0 0 32px; color: var(--text); letter-spacing: -0.02em; }

/* Stepper */
.stepper-wrap { background: var(--surface); border: 1px solid var(--border); padding: 24px; border-radius: 16px; }
.stepper { display: flex; align-items: center; justify-content: space-between; position: relative; max-width: 600px; margin: 0 auto; }
.step { display: flex; flex-direction: column; align-items: center; position: relative; z-index: 2; width: 80px; }
.step-dot { width: 32px; height: 32px; border-radius: 50%; background: var(--bg); border: 2px solid var(--border); display: flex; align-items: center; justify-content: center; transition: all 0.3s ease; margin-bottom: 8px; }
.step-check { width: 18px; height: 18px; color: white; }
.step-label { font-size: 0.7rem; font-weight: 800; text-transform: uppercase; color: var(--muted); letter-spacing: 0.05em; text-align: center; }

.step.active .step-dot { border-color: var(--red); box-shadow: 0 0 0 4px rgba(239, 68, 68, 0.1); }
.step.active .step-label { color: var(--text); }
.step.completed .step-dot { background: var(--red); border-color: var(--red); }
.step.completed .step-label { color: var(--text); }

/* Status specific decision cell */
.step.accepted.completed .step-dot { background: #10b981; border-color: #10b981; }
.step.rejected.completed .step-dot { background: #ef4444; border-color: #ef4444; }

.step-line { flex: 1; height: 2px; background: var(--border); margin: 0 -20px; position: relative; top: -11px; z-index: 1; }
.step-line.filled { background: var(--red); }

/* Job sidebar box */
.job-box { margin-bottom: 20px; border-left: 4px solid var(--red); }
.job-mini-info { display: flex; flex-direction: column; gap: 12px; }
.mini-row { display: flex; align-items: center; gap: 10px; font-size: 0.85rem; color: var(--text); font-weight: 600; }
.mini-icon { width: 16px; height: 16px; color: var(--muted); }

.content-grid { display: grid; grid-template-columns: 1fr 320px; gap: 40px; }

.info-block { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 32px; margin-bottom: 24px; }
.block-title { font-size: 0.85rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); margin-bottom: 24px; }

.ans-item { margin-bottom: 20px; padding-bottom: 20px; border-bottom: 1px solid var(--border); }
.ans-item:last-child { border: none; padding-bottom: 0; }
.ans-label { font-size: 0.95rem; font-weight: 700; color: var(--text); margin-bottom: 8px; }
.ans-value { color: var(--muted); font-size: 0.9rem; line-height: 1.6; }

.cover-text { font-style: italic; font-size: 0.95rem; color: var(--text); line-height: 1.6; }

.sidebar-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px; }
.vertical-timeline { position: relative; padding-left: 24px; }
.t-item { position: relative; padding-bottom: 32px; }
.t-item:last-child { padding-bottom: 0; }
.t-line { position: absolute; left: -19px; top: 18px; bottom: -14px; width: 2px; background: var(--border); }
.t-item:last-child .t-line { display: none; }
.t-marker { position: absolute; left: -24px; top: 4px; width: 12px; height: 12px; border-radius: 50%; background: var(--red); border: 2px solid var(--bg); }
.t-info { display: flex; flex-direction: column; gap: 4px; }
.t-type { font-size: 0.7rem; font-weight: 800; text-transform: uppercase; color: var(--text); }
.t-desc { font-size: 0.85rem; color: var(--muted); }
.t-date { font-size: 0.7rem; color: var(--subtle); }
.t-author { font-size: 0.68rem; color: #3b82f6; font-weight: 600; }

/* Notices */
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

/* Result Cards */
.result-card {
  margin: 40px 0 20px;
  padding: 24px 32px;
  border-radius: 16px;
  border: 1px solid var(--border);
}
.result-icon { width: 28px; height: 28px; flex-shrink: 0; }
.result-title { display: flex; align-items: center; gap: 10px; font-size: 1.4rem; font-weight: 800; margin-top: 0; margin-bottom: 12px; }
.result-text { font-size: 1rem; line-height: 1.6; margin-bottom: 12px; color: var(--text); }
.result-text:last-child { margin-bottom: 0; }
.result-steps { background: var(--bg); border: 1px solid rgba(0,0,0,0.05); padding: 20px; border-radius: 12px; margin-top: 20px; }
.result-steps h4 { margin: 0 0 12px; font-size: 0.85rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text); }
.result-steps ul { margin: 0; padding-left: 20px; font-size: 0.95rem; line-height: 1.6; color: var(--text); }
.result-steps li { margin-bottom: 6px; }
.result-steps li:last-child { margin-bottom: 0; }

/* Accepted */
.result-accepted { background: rgba(16, 185, 129, 0.05); border-color: rgba(16, 185, 129, 0.2); }
.result-accepted .result-title { color: #10b981; }
.result-accepted .result-steps { border-color: rgba(16, 185, 129, 0.1); }

/* Rejected */
.result-rejected { background: rgba(239, 68, 68, 0.05); border-color: rgba(239, 68, 68, 0.15); }
.result-rejected .result-title { color: #ef4444; }

/* Interview */
.result-interview { background: rgba(59, 130, 246, 0.05); border-color: rgba(59, 130, 246, 0.2); }
.result-interview .result-title { color: #3b82f6; }

@media (max-width: 800px) {
  .content-grid { grid-template-columns: 1fr; }
  .result-card { padding: 20px; margin-top: 30px; }
  .result-title { font-size: 1.25rem; }
}
</style>
