<template>
  <div class="fullpage-wizard">
    <div class="wizard-sidebar">
      <div class="sidebar-header">
        <NuxtLink to="/admin" class="back-link">
          <ArrowLeftIcon class="w-4 h-4" /> Exit
        </NuxtLink>
        <h1>Create Position</h1>
        <p>Set up a new role at Sunshine Studio</p>
      </div>

      <div class="steps-nav">
        <div :class="['step-item', { active: step === 1, completed: step > 1 }]">
           <div class="step-indicator">1</div>
           <span>Identity</span>
        </div>
        <div :class="['step-item', { active: step === 2, completed: step > 2 }]">
           <div class="step-indicator">2</div>
           <span>Prerequisites</span>
        </div>
        <div :class="['step-item', { active: step === 3, completed: step > 3 }]">
           <div class="step-indicator">3</div>
           <span>Role Scope</span>
        </div>
        <div :class="['step-item', { active: step === 4, completed: step > 4 }]">
           <div class="step-indicator">4</div>
           <span>Operations</span>
        </div>
        <div :class="['step-item', { active: step === 5, completed: step > 5 }]">
           <div class="step-indicator">5</div>
           <span>Questions</span>
        </div>
      </div>
    </div>

    <div class="wizard-main">
      <div class="creation-progress">
        <div class="progress-track">
          <div class="progress-fill" :style="{ width: progress + '%' }"></div>
        </div>
        <div class="progress-text">{{ progress }}% complete</div>
      </div>
      <div class="wizard-content">
        <Transition name="fade-slide" mode="out-in">
          
          <!-- STAGE 1: IDENTITY -->
          <div v-if="step === 1" :key="1" class="stage-container">
            <h2>Identity & Basics</h2>
            <div class="grid-2">
              <div class="form-group large"><label>Job Title</label><input v-model="form.title" class="form-input" autofocus></div>
              <div class="form-group large"><label>Department</label><input v-model="form.department" class="form-input"></div>
            </div>
            <div class="grid-2">
              <div class="form-group"><label>Experience Level</label>
                <select v-model="form.experience_level" class="form-input">
                  <option value="Entry Level">Entry Level</option><option value="Intermediate">Intermediate</option>
                  <option value="Senior">Senior</option><option value="Management">Management</option>
                </select>
              </div>
              <div class="form-group"><label>Primary Location</label><input v-model="form.base_hub" class="form-input"></div>
            </div>
            <div class="grid-2">
              <div class="form-group">
                <label>Role Type</label>
                <select v-model="form.role_type" class="form-input">
                  <option value="general">General</option>
                  <option value="organization">Organization</option>
                </select>
              </div>
              <div class="form-group">
                <label>Template</label>
                  <div class="setting-desc">Apply template from Admin → Advanced to prefill fields.</div>
                  <div style="margin-top:8px; display:flex; gap:8px; align-items:center;">
                    <input ref="jsonImportFile" type="file" accept=".json,application/json" style="display:none" @change="handleImportJson" />
                    <button type="button" class="btn btn-outline btn-sm" @click="triggerImportJson">Import JSON</button>
                    <button type="button" class="btn btn-outline btn-sm" @click="() => { sessionStorage.removeItem('jobTemplate'); sessionStorage.removeItem('aiTemplate'); alert('Cleared session template'); }">Clear Session Template</button>
                  </div>
              </div>
            </div>
              <div class="form-group">
                <label>AI Assistant Template (optional)</label>
                <textarea v-model="form.ai_prompt" class="form-input" rows="3" placeholder="Optional AI prompt to help generate or screen applications..."></textarea>
              </div>
            <div class="form-group"><label>Short Description (Card Summary)</label><textarea v-model="form.short_description" class="form-input" rows="2"></textarea></div>
            <div class="form-group"><label>Full Description (Markdown)</label><textarea v-model="form.long_description" class="form-input text-mono" rows="4"></textarea></div>
          </div>

          <!-- STAGE 2: PREREQUISITES -->
          <div v-else-if="step === 2" :key="2" class="stage-container">
            <h2>Prerequisites & Hardware</h2>
            <div class="grid-2">
               <div class="form-group"><label>Min Age</label><input v-model="form.min_age" type="number" class="form-input"></div>
               <div class="form-group"><label>Max Age</label><input v-model="form.max_age" type="number" class="form-input"></div>
               <div class="form-group"><label>Experience Hours</label><input v-model="form.flight_hours_required" type="number" class="form-input"></div>
               <div class="form-group"><label>Training Hours</label><input v-model="form.atc_hours_required" type="number" class="form-input"></div>
               <div class="form-group"><label>Language</label><input v-model="form.language_requirements" class="form-input"></div>
               <div class="form-group"><label>Preferred Tools/Platforms</label><input v-model="form.sim_platform_preference" class="form-input"></div>
            </div>
            <div class="hardware-toggles">
              <label class="toggle-box"><input type="checkbox" v-model="form.discord_required"> Discord Account</label>
              <label class="toggle-box"><input type="checkbox" v-model="form.microphone_required"> Working Microphone</label>
              <label class="toggle-box"><input type="checkbox" v-model="form.flying_vatsim_required"> External Network Experience</label>
              <label class="toggle-box"><input type="checkbox" v-model="form.livery_installation_required"> Asset Installation</label>
            </div>
          </div>

          <!-- STAGE 3: SCOPE -->
          <div v-else-if="step === 3" :key="3" class="stage-container">
            <h2>Role Scope & Training</h2>
            <div class="grid-2">
               <div class="form-group"><label>Required Skills</label><input v-model="form.aircraft_types" class="form-input"></div>
               <div class="form-group"><label>Direct Supervisor</label><input v-model="form.supervisor_name" class="form-input"></div>
               <div class="form-group"><label>Probation Period</label><input v-model="form.probation_period" class="form-input"></div>
               <div class="form-group"><label>Weekly Commitment (Hrs)</label><input v-model="form.weekly_flight_requirement" type="number" class="form-input"></div>
               <div class="form-group"><label>Minimum Rank/Level</label><input v-model="form.minimum_rank_required" class="form-input"></div>
               <div class="form-group"><label>Training Duration</label><input v-model="form.training_duration" class="form-input"></div>
            </div>
            <div class="hardware-toggles">
              <label class="toggle-box"><input type="checkbox" v-model="form.training_required"> Academy Required</label>
              <label class="toggle-box"><input type="checkbox" v-model="form.interview_required"> Interview Required</label>
            </div>
          </div>

          <!-- STAGE 4: OPERATIONS -->
          <div v-else-if="step === 4" :key="4" class="stage-container">
            <h2>Operations & Visibility</h2>
            <div class="grid-2">
               <div class="form-group"><label>Salary</label><input v-model="form.salary" class="form-input"></div>
               <div class="form-group"><label>Location</label><input v-model="form.location" class="form-input"></div>
               <div class="form-group"><label>Apply Deadline</label><input v-model="form.closing_at" type="date" class="form-input"></div>
               <div class="form-group"><label>Review Time</label><input v-model="form.application_review_time" class="form-input"></div>
               <div class="form-group"><label>Difficulty</label>
                 <select v-model="form.application_difficulty" class="form-input">
                    <option value="Easy">Easy</option><option value="Medium">Medium</option>
                    <option value="Hard">Hard</option><option value="Extreme">Extreme</option>
                 </select>
               </div>
               <div class="form-group"><label>Hard Limit</label><input v-model="form.applicant_limit" type="number" class="form-input"></div>
            </div>
            <div class="hardware-toggles">
              <label class="toggle-box alert-box"><input type="checkbox" v-model="form.is_featured"> Featured Listing</label>
              <label class="toggle-box"><input type="checkbox" v-model="form.referral_required"> Referral Req.</label>
              <label class="toggle-box"><input type="checkbox" v-model="form.auto_reject_if_not_met"> Auto-Reject</label>
            </div>
          </div>

          <!-- STAGE 5: QUESTIONS -->
          <div v-else-if="step === 5" :key="5" class="stage-container">
            <h2>Custom Form & Success</h2>
            <div class="form-group"><label>Custom Success Message</label><textarea v-model="form.custom_success_message" class="form-input" rows="2" placeholder="Shown after submission..."></textarea></div>
            <div class="questions-list">
              <div v-for="(q, idx) in questions" :key="q.temp_id" class="q-card">
                <div class="q-header"><span>Q{{ idx + 1 }}</span><button class="delete-q" :aria-label="'Remove question ' + (idx + 1)" @click="removeQ(idx)"><TrashIcon class="w-4 h-4" aria-hidden="true"/></button></div>
                <input v-model="q.question" class="form-input q-title" placeholder="Prompt...">
                <div class="q-config">
                  <select v-model="q.type" class="form-input w-auth">
                    <option value="text">Text</option><option value="textarea">Paragraph</option><option value="number">Num</option><option value="checkbox">ChkBx</option><option value="select">Dropdown</option>
                  </select>
                  <label class="q-req-label"><input type="checkbox" v-model="q.required"> Req</label>
                </div>
                <input v-if="q.type === 'select'" v-model="q.options" class="form-input option-input" placeholder="A, B, C">
              </div>
            </div>
            <button class="btn btn-outline btn-add-q" @click="addQ"><PlusIcon class="w-5 h-5" /> Append Question</button>
          </div>
        </Transition>
      </div>

      <div class="wizard-footer">
        <div v-if="errorMsg" class="error-banner">{{ errorMsg }}</div>
        <div class="action-buttons">
          <button class="btn btn-outline" :disabled="step === 1 || submitting" @click="step--">Go Back</button>
          <button v-if="step < 5" class="btn btn-primary btn-large" @click="nextStep">Next <ArrowRightIcon class="w-5 h-5" /></button>
          <button v-if="step === 5" class="btn btn-primary btn-large" :disabled="submitting" @click="submitPipeline">
            <span v-if="submitting">Publishing...</span><template v-else>Publish Position <CheckIcon class="w-5 h-5" /></template>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowLeftIcon, ArrowRightIcon, PlusIcon, TrashIcon, CheckIcon } from '@heroicons/vue/24/outline'

definePageMeta({ layout: 'admin' })
const router = useRouter()
const supabase = useSupabase()
const step = ref(1)
const submitting = ref(false)
const errorMsg = ref('')
const TOTAL_STEPS = 5
const progress = computed(() => Math.round(((step.value - 1) / (TOTAL_STEPS - 1)) * 100))

const form = ref({
  title: '', department: '', short_description: '', long_description: '', requirements: '', image_url: '',
  salary: 'Volunteer', location: 'In-game (Roblox)', closing_at: null, start_date: '', applicant_limit: null,
  min_age: null, max_age: null, experience_level: 'Entry Level', flight_hours_required: 0, atc_hours_required: 0,
  role_type: 'general',
  ai_prompt: '',
  discord_required: true, microphone_required: false, timezone_preference: '', language_requirements: '',
  aircraft_types: '', base_hub: '', benefits: '', application_difficulty: 'Medium', interview_required: false,
  probation_period: '', supervisor_name: '', contact_email: '', is_featured: false, hide_applicant_count: false,
  flying_vatsim_required: false, livery_installation_required: false, sim_platform_preference: 'Any',
  weekly_flight_requirement: 0, minimum_rank_required: '', training_duration: '',
  application_review_time: '2-3 Days', referral_required: false, auto_reject_if_not_met: false,
  custom_success_message: 'Your application has been received. Our team will review it shortly.',
  is_active: true
})

const questions = ref([{ temp_id: 1, question: 'Why Sunshine Studio?', type: 'textarea', options: '', required: true, sort_order: 0 }])
let qCount = 1
const jsonImportFile = ref(null)

onMounted(() => {
  const t = sessionStorage.getItem('jobTemplate')
  if (t) {
    try {
      const data = JSON.parse(t)
      // Merge template data into the form, prefer template values
      Object.assign(form.value, data)
      sessionStorage.removeItem('jobTemplate')
    } catch (e) {
      console.error('Failed to apply job template', e)
    }
  }
  const a = sessionStorage.getItem('aiTemplate')
  if (a) {
    try {
      form.value.ai_prompt = JSON.parse(a)
    } catch (e) {
      form.value.ai_prompt = a
    }
    sessionStorage.removeItem('aiTemplate')
  }
})

function nextStep() {
  errorMsg.value = ''
  if (step.value === 1 && (!form.value.title || !form.value.short_description)) {
    errorMsg.value = 'Fill out Title & Summary.'
    return
  }
  step.value++
}

function addQ() {
  qCount++
  questions.value.push({ temp_id: qCount, question: '', type: 'text', options: '', required: false, sort_order: questions.value.length })
}

function removeQ(idx) { questions.value.splice(idx, 1) }

function triggerImportJson() { if (jsonImportFile.value) jsonImportFile.value.click() }

async function handleImportJson(e) {
  const f = (e?.target && e.target.files && e.target.files[0]) || (jsonImportFile.value && jsonImportFile.value.files && jsonImportFile.value.files[0])
  if (!f) return
  try {
    const text = await f.text()
    const parsed = JSON.parse(text)
    const data = parsed.data || parsed
    Object.assign(form.value, data)
    if (parsed.questions && Array.isArray(parsed.questions)) {
      questions.value = []
      parsed.questions.forEach((q, i) => {
        qCount++
        const opts = Array.isArray(q.options) ? q.options.join(',') : (q.options || '')
        questions.value.push({ temp_id: qCount, question: q.question || q.prompt || '', type: q.type || 'text', options: opts, required: !!q.required, sort_order: i })
      })
    }
    if (parsed.ai_prompt || data.ai_prompt) form.value.ai_prompt = parsed.ai_prompt || data.ai_prompt
    alert('Imported JSON applied to the form')
  } catch (err) {
    console.error('Import JSON failed', err)
    alert('Failed to import JSON: ' + (err?.message || 'Invalid file'))
  } finally {
    if (e && e.target) e.target.value = ''
    if (jsonImportFile.value) jsonImportFile.value.value = ''
  }
}

async function submitPipeline() {
  errorMsg.value = ''
  submitting.value = true
  let newJobId = null
  try {
    const payload = { ...form.value }
    payload.position = payload.title
    delete payload.requirements
    Object.keys(payload).forEach(key => { if (payload[key] === '') payload[key] = null })

    const { data: jobRes, error: jobErr } = await supabase.from('jobs').insert(payload).select('id').single()
    if (jobErr) throw new Error('Job Failed: ' + jobErr.message)

    newJobId = jobRes.id
    if (questions.value.length > 0) {
      const qPayload = questions.value.map((q, i) => {
        let finalOptions = q.options
        if (q.type === 'select' && typeof q.options === 'string') {
          finalOptions = q.options.split(',').map(o => o.trim()).filter(Boolean)
        }
        return {
          job_id: newJobId,
          question: q.question,
          type: q.type,
          options: finalOptions,
          required: q.required,
          sort_order: i
        }
      })
      const { error: qErr } = await supabase.from('job_questions').insert(qPayload)
      if (qErr) {
        await supabase.from('jobs').delete().eq('id', newJobId)
        throw new Error('Questions Failed: ' + qErr.message)
      }
    }
    router.push('/admin')
  } catch (e) { errorMsg.value = e.message } finally { submitting.value = false }
}
</script>

<style scoped>
.fullpage-wizard { display: flex; height: 100vh; background: #0b1120; z-index: 50; }
.wizard-sidebar { width: 300px; background: #0f172a; border-right: 1px solid #1e293b; padding: 40px; display: flex; flex-direction: column; gap: 40px; }
.back-link { display: flex; align-items: center; gap: 8px; color: #94a3b8; text-decoration: none; font-size: 0.9rem; font-weight: 600; }
.sidebar-header h1 { font-size: 1.6rem; color: #fff; margin: 20px 0 8px; }
.sidebar-header p { color: #64748b; font-size: 0.9rem; }
.steps-nav { display: flex; flex-direction: column; gap: 24px; }
.step-item { display: flex; align-items: center; gap: 16px; opacity: 0.4; }
.step-item.active { opacity: 1; transform: translateX(8px); }
.step-indicator { width: 30px; height: 30px; border-radius: 50%; background: #1e293b; color: #94a3b8; display: flex; align-items: center; justify-content: center; font-weight: 800; }
.step-item.active .step-indicator { background: var(--red); color: #fff; }
.step-item span { font-weight: 700; color: #cbd5e1; font-size: 0.8rem; text-transform: uppercase; }

.wizard-main { flex: 1; display: flex; flex-direction: column; background: var(--bg); color: var(--text); }
.wizard-content { flex: 1; max-width: 800px; margin: 0 auto; width: 100%; padding: 60px 40px; overflow-y: auto; }
.stage-container h2 { font-size: 2rem; font-weight: 900; color: var(--text); margin-bottom: 30px; }
.form-group { margin-bottom: 20px; display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 0.85rem; font-weight: 800; color: var(--muted); text-transform: uppercase; }
.form-input { padding: 12px 14px; border: 2px solid var(--border); border-radius: 8px; font-size: 1rem; background: var(--surface); color: var(--text); }
.form-input:focus { border-color: var(--red); outline: none; }
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.hardware-toggles { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 10px; }
.toggle-box { background: var(--bg-alt); border: 2px solid var(--border); padding: 10px 16px; border-radius: 8px; display: flex; align-items: center; gap: 8px; font-weight: 700; cursor: pointer; font-size: 0.85rem; }
.toggle-box.alert-box { border-color: #fecaca; background: rgba(232, 55, 42, 0.1); color: var(--red); }

.q-card { background: var(--bg-alt); border: 2px solid var(--border); padding: 20px; border-radius: 12px; margin-bottom: 16px; display: flex; flex-direction: column; gap: 12px; }
.q-header { display: flex; justify-content: space-between; font-weight: 900; }
.delete-q { color: #ef4444; border: none; background: none; cursor: pointer; }
.q-config { display: flex; gap: 12px; align-items: center; }
.w-auth { width: 100px; }
.btn-add-q { width: 100%; border-style: dashed; padding: 15px; font-weight: 800; color: var(--muted); }

.wizard-footer { padding: 30px 40px; border-top: 1px solid var(--border); }
.action-buttons { max-width: 800px; margin: 0 auto; display: flex; justify-content: space-between; }
.btn-large { padding: 12px 30px; font-size: 1rem; display: flex; align-items: center; gap: 10px; }
.error-banner { max-width: 800px; margin: 0 auto 15px; color: #ef4444; font-weight: 700; background: rgba(239, 68, 68, 0.1); padding: 10px; border-radius: 6px; }

.fade-slide-enter-active, .fade-slide-leave-active { transition: all 0.2s; }
.fade-slide-enter-from { opacity: 0; transform: translateX(15px); }
.fade-slide-leave-to { opacity: 0; transform: translateX(-15px); }

.creation-progress { max-width: 800px; margin: 18px auto 0; width: 100%; padding: 0 40px; display: flex; align-items: center; gap: 12px; }
.progress-track { flex: 1; height: 10px; background: rgba(148,163,184,0.08); border-radius: 8px; overflow: hidden; }
.progress-fill { height: 100%; background: linear-gradient(90deg, var(--red), #2563eb); width: 0; transition: width 250ms ease; }
.progress-text { width: 84px; text-align: right; color: var(--muted); font-weight: 800; font-size: 0.875rem; }
</style>
