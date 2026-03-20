<template>
  <main class="page">
    <div class="container">
      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
      </div>

      <div
        v-else
        class="form-wrapper"
      >
        <NuxtLink
          to="/admin"
          class="back-link"
        >
          <ArrowLeftIcon
            class="back-icon"
            aria-hidden="true"
          />
          Back to Admin
        </NuxtLink>

        <h1 class="page-title">
          {{ isNew ? 'Create New Job' : 'Edit Job' }}
        </h1>
        <p class="page-sub">
          Fill out position details and requirements.
        </p>

        <form
          class="job-form"
          @submit.prevent="saveJob"
        >
          <div class="form-grid">
            <div class="form-group col-span-2">
              <label>Job Title</label>
              <input
                v-model="jobForm.title"
                type="text"
                class="form-input"
                required
                placeholder="e.g. First Officer"
              >
            </div>

            <div class="form-group">
              <label>Department</label>
              <input
                v-model="jobForm.department"
                type="text"
                class="form-input"
                required
                placeholder="e.g. Flight Operations"
              >
            </div>

            <div class="form-group">
              <label>Location</label>
              <input
                v-model="jobForm.location"
                type="text"
                class="form-input"
                placeholder="e.g. In-game (Roblox)"
              >
            </div>

            <div class="form-group">
              <label>Salary / Rank</label>
              <input
                v-model="jobForm.salary"
                type="text"
                class="form-input"
                placeholder="e.g. Volunteer / HR"
              >
            </div>

            <div class="form-group">
              <label>Applicant Limit (Optional)</label>
              <input
                v-model="jobForm.applicant_limit"
                type="number"
                class="form-input"
                placeholder="Leave empty for unlimited"
              >
            </div>

            <div class="form-group col-span-2">
              <label>Short Description (for listing cards)</label>
              <textarea
                v-model="jobForm.short_description"
                class="form-input"
                rows="2"
                maxlength="150"
                required
                placeholder="A brief summary..."
              />
            </div>

            <div class="form-group col-span-2">
              <label>Long Description (Markdown supported)</label>
              <textarea
                v-model="jobForm.long_description"
                class="form-input"
                rows="6"
                required
                placeholder="Detailed job description and expectations..."
              />
            </div>

            <div class="form-group col-span-2">
              <label>Image URL (Optional)</label>
              <input
                v-model="jobForm.image_url"
                type="url"
                class="form-input"
                placeholder="https://..."
              >
            </div>

            <div class="form-group col-span-2 checkbox-group">
              <label class="checkbox-label">
                <input
                  v-model="jobForm.is_active"
                  type="checkbox"
                >
                Active (Visible to applicants)
              </label>
            </div>
          </div>

          <div class="form-actions">
            <NuxtLink
              to="/admin"
              class="btn btn-outline"
            >Cancel</NuxtLink>
            <button
              type="submit"
              class="btn btn-primary"
              :disabled="saving"
            >
              {{ saving ? 'Saving...' : (isNew ? 'Create Job' : 'Save Changes') }}
            </button>
          </div>

          <p
            v-if="jobError"
            class="error-text"
          >
            {{ jobError }}
          </p>
        </form>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ArrowLeftIcon } from '@heroicons/vue/24/outline'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const supabase = useSupabase()

const isNew = computed(() => route.params.id === 'new')
const loading = ref(true)
const saving = ref(false)
const jobError = ref('')

const jobForm = ref({
  title: '',
  department: '',
  short_description: '',
  long_description: '',
  salary: 'Volunteer',
  location: 'In-game (Roblox)',
  image_url: '',
  requirements: 0,
  applicant_limit: null,
  closing_at: null,
  is_active: true
})

onMounted(async () => {
  if (isNew.value) {
    loading.value = false
    return
  }

  const { data } = await supabase.from('jobs').select('*').eq('id', route.params.id).single()
  if (data) {
    jobForm.value = data
  } else {
    router.push('/admin')
  }
  loading.value = false
})

async function saveJob() {
  saving.value = true
  jobError.value = ''

  const payload = { ...jobForm.value }
  // Ensure we don't send empty strings for numeric limits
  if (payload.applicant_limit === '') payload.applicant_limit = null

  if (isNew.value) {
    const { error } = await supabase.from('jobs').insert(payload)
    if (error) jobError.value = error.message
    else router.push('/admin')
  } else {
    const { error } = await supabase.from('jobs').update(payload).eq('id', route.params.id)
    if (error) jobError.value = error.message
    else router.push('/admin')
  }

  saving.value = false
}
</script>

<style scoped>
.page { padding-top: 40px; padding-bottom: 80px; }
.container { max-width: 800px; margin: 0 auto; padding: 0 24px; }

.back-link { display: inline-flex; align-items: center; gap: 6px; color: var(--muted); text-decoration: none; font-size: 0.9rem; margin-bottom: 20px; }
.back-icon { width: 16px; height: 16px; }

.page-title { font-size: 2rem; font-weight: 900; color: var(--text); margin: 0 0 8px; }
.page-sub { color: var(--muted); margin: 0 0 32px; }

.form-wrapper { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 32px; box-shadow: 0 8px 30px rgba(0,0,0,0.05); }

.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
.col-span-2 { grid-column: span 2; }

.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 0.85rem; font-weight: 700; color: var(--text); text-transform: uppercase; letter-spacing: 0.05em; }

.form-input { width: 100%; background: var(--bg); border: 1px solid var(--border); color: var(--text); border-radius: 8px; padding: 12px 16px; font-size: 0.95rem; font-family: inherit; transition: border-color 0.2s, box-shadow 0.2s; }
.form-input:focus { outline: none; border-color: var(--red); box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1); }
textarea.form-input { resize: vertical; min-height: 80px; }

.checkbox-group { margin-top: 8px; }
.checkbox-label { display: inline-flex; align-items: center; gap: 10px; font-size: 0.95rem; font-weight: 600; cursor: pointer; user-select: none; }
.checkbox-label input { width: 18px; height: 18px; accent-color: var(--red); cursor: pointer; }

.form-actions { display: flex; justify-content: flex-end; gap: 12px; margin-top: 32px; padding-top: 24px; border-top: 1px solid var(--border); }
.error-text { color: #ef4444; font-size: 0.85rem; text-align: right; margin-top: 12px; font-weight: 600; }

.btn { display: inline-flex; align-items: center; justify-content: center; font-weight: 700; border-radius: 8px; padding: 12px 24px; cursor: pointer; transition: all 0.2s; font-size: 0.95rem; text-decoration: none; }
.btn-primary { background: var(--red); color: white; border: none; }
.btn-primary:hover:not(:disabled) { background: #dc2626; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2); }
.btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-outline { background: transparent; border: 1px solid var(--border); color: var(--text); }
.btn-outline:hover { border-color: var(--muted); background: var(--bg); }

@media (max-width: 600px) {
  .form-grid { grid-template-columns: 1fr; }
  .col-span-2 { grid-column: span 1; }
  .form-actions { flex-direction: column-reverse; }
  .btn { width: 100%; }
}
</style>
