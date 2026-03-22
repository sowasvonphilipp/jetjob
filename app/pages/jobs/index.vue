<template>
  <main class="page">
    <div class="container">
      <div class="page-header">
        <div>
          <h1 class="page-title">
            Job Listings
          </h1>
          <p class="page-sub">
            Browse all open positions and apply to join the crew.
          </p>
        </div>
        <ClientOnly>
          <NuxtLink
            v-if="isAdmin"
            to="/admin"
            class="btn btn-outline btn-sm"
          >
            <ShieldCheckIcon
              class="btn-icon"
              aria-hidden="true"
            />
            Admin Panel
          </NuxtLink>
        </ClientOnly>
      </div>

      <!-- Filters -->
      <div class="filters">
        <div class="search-wrap">
          <MagnifyingGlassIcon
            class="search-icon"
            aria-hidden="true"
          />
          <input
            v-model="search"
            type="search"
            class="search-input"
            placeholder="Search positions…"
          >
        </div>
        <div class="filter-tags">
          <button
            v-for="dept in departments"
            :key="dept"
            :class="['filter-tag', { active: activeDept === dept }]"
            @click="activeDept = activeDept === dept ? null : dept"
          >
            {{ dept }}
          </button>
        </div>
      </div>

      <!-- Loading -->
      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
        <p>Loading positions…</p>
      </div>

      <!-- Empty state -->
      <div
        v-else-if="filteredJobs.length === 0"
        class="empty-state"
      >
        <BriefcaseIcon
          class="empty-icon"
          aria-hidden="true"
        />
        <h3>No positions found</h3>
        <p>Check back soon — new roles open regularly.</p>
      </div>

      <!-- Job cards -->
      <div
        v-else
        class="cards-grid"
      >
        <article
          v-for="job in filteredJobs"
          :key="job.id"
          class="job-card"
          @click="navigateTo(`/jobs/${job.id}`)"
        >
          <!-- Banner -->
          <div class="card-banner">
            <img
              v-if="job.image_url"
              :src="job.image_url"
              :alt="job.title"
              class="banner-img"
            >
            <div
              v-else
              class="banner-placeholder"
            >
              <BriefcaseIcon
                class="banner-icon"
                aria-hidden="true"
              />
            </div>
            <div v-if="job.is_featured" class="featured-badge">
              <StarIcon class="star-icon" /> Featured
            </div>
          </div>

          <!-- Body -->
          <div class="card-body">
            <span class="dept-tag">{{ job.department }}</span>
            <h3 class="card-title">
              {{ job.title }}
            </h3>
            <p class="card-desc">
              {{ job.short_description }}
            </p>

            <div class="card-meta">
              <span class="meta-item">
                <MapPinIcon
                  class="meta-icon"
                  aria-hidden="true"
                />
                {{ job.location }}
              </span>
              <span class="meta-item">
                <UsersIcon
                  class="meta-icon"
                  aria-hidden="true"
                />
                {{ job.applicant_count }}{{ job.applicant_limit ? `/${job.applicant_limit}` : '' }} applied
              </span>
              <span
                v-if="job.closing_at"
                class="meta-item"
              >
                <CalendarIcon
                  class="meta-icon"
                  aria-hidden="true"
                />
                Closes {{ formatDate(job.closing_at) }}
              </span>
            </div>
          </div>

          <div class="card-footer">
            <span class="btn btn-primary btn-full btn-sm">
              View & Apply
              <ArrowRightIcon
                class="btn-icon"
                aria-hidden="true"
              />
            </span>
          </div>
        </article>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  ArrowRightIcon,
  UsersIcon,
  CalendarIcon,
  MapPinIcon,
  BriefcaseIcon,
  MagnifyingGlassIcon,
  ShieldCheckIcon,
  StarIcon
} from '@heroicons/vue/24/solid'

const supabase = useSupabase()
const { isAdmin } = useAuth()

const jobs = ref([])
const loading = ref(true)
const search = ref('')
const activeDept = ref(null)

const departments = computed(() => {
  const depts = [...new Set(jobs.value.map(j => j.department))]
  return depts.sort()
})

const filteredJobs = computed(() => {
  let result = jobs.value
  if (activeDept.value) {
    result = result.filter(j => j.department === activeDept.value)
  }
  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    result = result.filter(j =>
      j.title.toLowerCase().includes(q)
      || j.short_description.toLowerCase().includes(q)
      || j.department.toLowerCase().includes(q)
    )
  }
  return result
})

function formatDate(date) {
  return new Date(date).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
}

async function fetchJobs() {
  loading.value = true
  const { data, error } = await supabase
    .from('jobs')
    .select('*')
    .eq('is_active', true)
    .order('is_featured', { ascending: false })
    .order('posted_at', { ascending: false })
  if (data) jobs.value = data
  if (error) console.error('Error fetching jobs:', error)
  loading.value = false
}

onMounted(fetchJobs)

useSeoMeta({
  title: 'Job Listings — Jet2 Jobs',
  description: 'Browse and apply for open positions at Jet2 Roblox Airline.'
})
</script>

<style scoped>
.page { min-height: 100vh; padding-bottom: 64px; }
.container { max-width: 900px; margin: 0 auto; padding: 0 24px; }

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  padding: 48px 0 24px;
  flex-wrap: wrap;
}
.page-title {
  font-size: 1.5rem;
  font-weight: 900;
  color: var(--text);
  margin: 0 0 6px;
  letter-spacing: -0.02em;
}
.page-sub {
  font-size: 0.9rem;
  color: var(--muted);
  margin: 0;
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
.btn-sm { padding: 8px 14px; font-size: 0.82rem; }
.btn-icon { width: 15px; height: 15px; }
.btn-primary {
  background: var(--red);
  color: #fff;
  box-shadow: 0 2px 8px rgba(232,55,42,0.25);
}
.btn-primary:hover {
  background: var(--red-hover);
  transform: translateY(-1px);
  box-shadow: 0 4px 14px rgba(232,55,42,0.35);
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
.btn-full { width: 100%; justify-content: center; }

/* Filters */
.filters {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 32px;
}

.search-wrap {
  position: relative;
  flex: 1;
  min-width: 200px;
}
.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  width: 16px;
  height: 16px;
  color: var(--muted);
  pointer-events: none;
}
.search-input {
  width: 100%;
  background: var(--surface);
  border: 1px solid var(--border);
  color: var(--text);
  font-size: 0.85rem;
  padding: 10px 14px 10px 36px;
  border-radius: 8px;
  outline: none;
  transition: border-color 160ms ease, box-shadow 160ms ease;
}
.search-input:focus {
  border-color: var(--red);
  box-shadow: 0 0 0 3px rgba(232,55,42,0.12);
}
.search-input::placeholder { color: var(--subtle); }

.filter-tags {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}
.filter-tag {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 5px 12px;
  border-radius: 99px;
  border: 1px solid var(--border);
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  transition: all 150ms ease;
}
.filter-tag:hover {
  border-color: var(--red);
  color: var(--red);
}
.filter-tag.active {
  background: rgba(232,55,42,0.1);
  border-color: var(--red);
  color: var(--red);
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

/* Cards grid */
.cards-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.job-card {
  display: flex;
  flex-direction: column;
  border-radius: 12px;
  border: 1px solid var(--border);
  background: var(--surface);
  overflow: hidden;
  cursor: pointer;
  transition: border-color 160ms ease, box-shadow 160ms ease, transform 140ms ease;
}
.job-card:hover {
  border-color: var(--red);
  box-shadow: 0 4px 22px rgba(232,55,42,0.1);
  transform: translateY(-2px);
}

.card-banner {
  height: 100px;
  overflow: hidden;
  flex-shrink: 0;
}
.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.banner-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, var(--navy, #1e3a6e), #2a4a8e);
  display: flex;
  align-items: center;
  justify-content: center;
}
.banner-icon {
  width: 32px;
  height: 32px;
  color: rgba(255,255,255,0.5);
}

.card-body {
  flex: 1;
  padding: 16px 16px 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
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
  align-self: flex-start;
}
.featured-badge {
  position: absolute; top: 10px; right: 10px;
  background: #fdf2f2; color: #b91c1c; 
  padding: 4px 10px; border-radius: 99px;
  font-size: 0.65rem; font-weight: 800; border: 1px solid #fecaca;
  display: flex; align-items: center; gap: 4px; z-index: 10;
  text-transform: uppercase; letter-spacing: 0.05em;
}
.star-icon { width: 12px; height: 12px; }
.card-banner { position: relative; }
.card-title {
  font-size: 1rem;
  font-weight: 800;
  color: var(--text);
  margin: 0;
  letter-spacing: -0.01em;
  line-height: 1.3;
}
.card-desc {
  font-size: 0.82rem;
  color: var(--muted);
  line-height: 1.6;
  margin: 0;
  display: -webkit-box;
  line-clamp: 2;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-top: auto;
}
.meta-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.76rem;
  color: var(--subtle);
}
.meta-icon {
  width: 13px;
  height: 13px;
  flex-shrink: 0;
}

.card-footer {
  padding: 0 16px 16px;
}

@media (max-width: 640px) {
  .cards-grid { grid-template-columns: 1fr; }
}
</style>
