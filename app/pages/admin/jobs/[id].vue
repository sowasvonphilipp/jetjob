<template>
  <main class="page">
    <div class="container">
      <div v-if="loading" class="loading-state"><div class="spinner" /></div>
      <div v-else class="form-wrapper">
        <NuxtLink to="/admin" class="back-link"><ArrowLeftIcon class="back-icon" /> Back to Admin</NuxtLink>
        <h1 class="page-title">{{ isNew ? 'Create New Job' : 'Edit Job' }}</h1>
        <p class="page-sub">Configure every granular detail for this position.</p>

        <form class="job-form" @submit.prevent="saveJob">
          <div class="form-grid">
            <!-- Header Info -->
            <div class="form-group col-span-2"><label>Job Title</label><input v-model="jobForm.title" class="form-input" required></div>
            <div class="form-group"><label>Department</label><input v-model="jobForm.department" class="form-input" required></div>
            <div class="form-group"><label>Experience Level</label>
              <select v-model="jobForm.experience_level" class="form-input">
                <option value="Entry Level">Entry Level</option><option value="Intermediate">Intermediate</option>
                <option value="Senior">Senior</option><option value="Management">Management</option>
              </select>
            </div>
            
            <div class="form-group col-span-2"><label>Short Summary</label><textarea v-model="jobForm.short_description" class="form-input" rows="2" maxlength="150" required /></div>
            <div class="form-group col-span-2"><label>Detailed Description (Markdown)</label><textarea v-model="jobForm.long_description" class="form-input" rows="4" required /></div>

            <hr style="margin:10px 0; border:none; border-top:1px solid #eee;" class="col-span-2" />

            <!-- Prerequisites -->
            <div class="form-group"><label>Min Age</label><input v-model="jobForm.min_age" type="number" class="form-input"></div>
            <div class="form-group"><label>Max Age</label><input v-model="jobForm.max_age" type="number" class="form-input"></div>
            <div class="form-group"><label>Experience Hours</label><input v-model="jobForm.flight_hours_required" type="number" class="form-input"></div>
            <div class="form-group"><label>Training Hours</label><input v-model="jobForm.atc_hours_required" type="number" class="form-input"></div>
            <div class="form-group"><label>Primary Location</label><input v-model="jobForm.base_hub" class="form-input"></div>
            <div class="form-group"><label>Preferred Platform/Tool</label><input v-model="jobForm.sim_platform_preference" class="form-input"></div>

            <hr style="margin:10px 0; border:none; border-top:1px solid #eee;" class="col-span-2" />

            <!-- Operations -->
            <div class="form-group"><label>Salary</label><input v-model="jobForm.salary" class="form-input"></div>
            <div class="form-group"><label>Location</label><input v-model="jobForm.location" class="form-input"></div>
            <div class="form-group"><label>Deadline</label><input v-model="jobForm.closing_at" type="date" class="form-input"></div>
            <div class="form-group"><label>Job Difficulty</label>
              <select v-model="jobForm.application_difficulty" class="form-input">
                <option value="Easy">Easy</option><option value="Medium">Medium</option><option value="Hard">Hard</option><option value="Extreme">Extreme</option>
              </select>
            </div>
            
            <div class="form-group col-span-2"><label>Benefits</label><textarea v-model="jobForm.benefits" class="form-input" rows="2" /></div>
            <div class="form-group col-span-2"><label>Success Message (Shown after applying)</label><textarea v-model="jobForm.custom_success_message" class="form-input" rows="2" /></div>

            <hr style="margin:10px 0; border:none; border-top:1px solid #eee;" class="col-span-2" />

            <!-- Toggles -->
            <div class="form-group col-span-2 checkbox-grid">
              <label class="cb-label"><input v-model="jobForm.is_active" type="checkbox"> Active</label>
              <label class="cb-label"><input v-model="jobForm.is_featured" type="checkbox"> Featured</label>
              <label class="cb-label"><input v-model="jobForm.discord_required" type="checkbox"> Discord Req</label>
              <label class="cb-label"><input v-model="jobForm.training_required" type="checkbox"> Training Req</label>
              <label class="cb-label"><input v-model="jobForm.interview_required" type="checkbox"> Interview Req</label>
              <label class="cb-label"><input v-model="jobForm.auto_reject_if_not_met" type="checkbox"> Auto-Reject</label>
              <label class="cb-label"><input v-model="jobForm.microphone_required" type="checkbox"> Mic Req</label>
              <label class="cb-label"><input v-model="jobForm.hide_applicant_count" type="checkbox"> Hide Count</label>
            </div>
          </div>

          <div class="form-actions">
            <NuxtLink to="/admin" class="btn btn-outline">Cancel</NuxtLink>
            <button type="submit" class="btn btn-primary" :disabled="saving">{{ saving ? 'Saving...' : 'Save Job' }}</button>
          </div>
          <p v-if="jobError" class="error-text">{{ jobError }}</p>
        </form>

        <div v-if="!isNew" class="questions-section">
          <h2>Application Questions</h2>
          <div class="questions-list">
            <div v-for="(q, idx) in questions" :key="q.id" class="q-row">
              <div class="q-row-header"><span>Question {{ idx + 1 }}</span></div>
              <input v-model="q.question" class="form-input" @change="updateQuestion(q)">
              <div class="q-row-meta">
                <select v-model="q.type" class="form-input sm-select" @change="updateQuestion(q)">
                  <option value="text">Short Text</option><option value="textarea">Paragraph</option><option value="number">Number</option><option value="checkbox">Boolean</option><option value="select">Dropdown</option>
                </select>
                <label><input v-model="q.required" type="checkbox" @change="updateQuestion(q)"> Required</label>
                <button class="btn-icon-red" @click="deleteQuestion(q)"><TrashIcon class="w-4 h-4" /></button>
              </div>
              <div v-if="q.type === 'select'" class="q-row-options">
                <label>Options (comma separated)</label>
                <input v-model="q.options" class="form-input" placeholder="Option 1, Option 2, ..." @change="updateQuestion(q)">
              </div>
            </div>
          </div>
          <button class="btn btn-primary btn-sm" @click="addQuestion"><PlusIcon class="w-4 h-4" /> Add New Question</button>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
definePageMeta({ layout: 'admin' })
import { ref, onMounted, computed } from 'vue'
import { ArrowLeftIcon, PlusIcon, TrashIcon } from '@heroicons/vue/24/outline'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const supabase = useSupabase()
const isNew = computed(() => route.params.id === 'new')
const loading = ref(true)
const saving = ref(false)
const jobError = ref('')

const jobForm = ref({
  title: '', department: '', short_description: '', long_description: '', requirements: '', image_url: '',
  salary: 'Volunteer', location: 'In-game (Roblox)', closing_at: null, start_date: '', applicant_limit: null,
  min_age: null, max_age: null, experience_level: 'Entry Level', flight_hours_required: 0, atc_hours_required: 0,
  discord_required: true, microphone_required: false, timezone_preference: '', language_requirements: '',
  aircraft_types: '', base_hub: '', benefits: '', application_difficulty: 'Medium', interview_required: false,
  probation_period: '', supervisor_name: '', contact_email: '', is_featured: false, hide_applicant_count: false,
  flying_vatsim_required: false, livery_installation_required: false, sim_platform_preference: 'Any',
  weekly_flight_requirement: 0, minimum_rank_required: '', training_duration: '',
  application_review_time: '2-3 Days', referral_required: false, auto_reject_if_not_met: false,
  custom_success_message: 'Your application has been received.', is_active: true
})

const questions = ref([])

onMounted(async () => {
  if (isNew.value) { loading.value = false; return }
  const { data } = await supabase.from('jobs').select('*').eq('id', route.params.id).single()
  if (data) { jobForm.value = { ...jobForm.value, ...data }; await fetchQuestions() }
  else router.push('/admin')
  loading.value = false
})

async function fetchQuestions() {
  const { data } = await supabase.from('job_questions').select('*').eq('job_id', route.params.id).order('sort_order', { ascending: true })
  if (data) {
    questions.value = data.map(q => ({
      ...q,
      options: (q.type === 'select' && Array.isArray(q.options)) ? q.options.join(', ') : q.options
    }))
  }
}

async function addQuestion() {
  const newQ = { job_id: route.params.id, question: 'New Question', type: 'text', options: '', required: false, sort_order: questions.value.length }
  const { data } = await supabase.from('job_questions').insert(newQ).select().single()
  if (data) questions.value.push(data)
}

async function updateQuestion(q) {
  let finalOptions = q.options
  if (q.type === 'select' && typeof q.options === 'string') {
    finalOptions = q.options.split(',').map(o => o.trim()).filter(Boolean)
  }
  await supabase.from('job_questions').update({ 
    question: q.question, 
    type: q.type, 
    options: finalOptions, 
    required: q.required, 
    sort_order: q.sort_order 
  }).eq('id', q.id)
}

async function deleteQuestion(q) {
  if(!confirm('Delete?')) return
  const { error } = await supabase.from('job_questions').delete().eq('id', q.id)
  if (!error) questions.value = questions.value.filter(x => x.id !== q.id)
}

async function saveJob() {
  saving.value = true; jobError.value = ''
  try {
    const payload = { ...jobForm.value }
    payload.position = payload.title
    delete payload.requirements
    Object.keys(payload).forEach(key => { if (payload[key] === '') payload[key] = null })

    const { error } = isNew.value 
      ? await supabase.from('jobs').insert(payload)
      : await supabase.from('jobs').update(payload).eq('id', route.params.id)
    if (error) throw error
    router.push('/admin')
  } catch (e) { jobError.value = e.message } finally { saving.value = false }
}
</script>

<style scoped>
.page { padding: 40px 0; background: var(--bg); min-height: 100vh; color: var(--text); }
.container { max-width: 900px; margin: 0 auto; padding: 0 20px; }
.form-wrapper { background: var(--surface); padding: 40px; border-radius: 16px; border: 1px solid var(--border); }
.back-link { display: flex; align-items: center; gap: 8px; color: var(--muted); text-decoration: none; margin-bottom: 24px; font-weight: 600; }
.page-title { font-size: 2rem; font-weight: 900; color: var(--text); margin-bottom: 8px; }
.page-sub { color: var(--muted); margin-bottom: 40px; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 0.8rem; font-weight: 800; color: var(--muted); text-transform: uppercase; }
.form-input { padding: 12px; border: 2px solid var(--border); border-radius: 8px; background: var(--bg); color: var(--text); }
.form-input:focus { border-color: var(--red); outline: none; }
.col-span-2 { grid-column: span 2; }
.checkbox-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 15px; background: var(--bg-alt); padding: 20px; border-radius: 12px; }
.cb-label { display: flex; align-items: center; gap: 8px; font-weight: 700; color: var(--text); font-size: 0.85rem; }
.form-actions { margin-top: 40px; display: flex; justify-content: flex-end; gap: 16px; }
.questions-section { margin-top: 60px; padding-top: 40px; border-top: 2px solid var(--border); }
.questions-list { margin-bottom: 30px; }
.q-row { background: var(--bg-alt); padding: 20px; border-radius: 12px; border: 1px solid var(--border); margin-bottom: 15px; }
.q-row-header { font-weight: 900; margin-bottom: 10px; font-size: 0.8rem; color: var(--muted); }
.q-row-meta { display: flex; align-items: center; gap: 20px; margin-top: 15px; }
.sm-select { width: 140px; }
.btn-icon-red { color: #ef4444; border: none; background: none; cursor: pointer; }
.q-row-options { margin-top: 15px; display: flex; flex-direction: column; gap: 6px; }
.q-row-options label { font-size: 0.75rem; font-weight: 800; color: var(--muted); text-transform: uppercase; }
.error-text { color: #ef4444; font-weight: 700; margin-top: 20px; text-align: right; }
</style>
