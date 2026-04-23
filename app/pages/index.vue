<template>
  <main class="page">
    <!-- ─── Hero ──────────────────────────────────────────────────────────── -->
    <section class="hero">
      <div class="container">
        <p class="hero-eyebrow">
          Sunshine Studio
        </p>
        <h1 class="hero-title">
          Find your role<br><span class="red">in our team</span>
        </h1>
        <p class="hero-sub">
          Start your careers with Sunshine Studio today!
        </p>
        <div class="hero-actions">
          <NuxtLink
            to="/jobs"
            class="btn btn-primary"
          >
            View open roles
            <ArrowRightIcon
              class="btn-icon"
              aria-hidden="true"
            />
          </NuxtLink>
          <NuxtLink
            to="/applications"
            class="btn btn-outline"
          >My applications</NuxtLink>
        </div>
      </div>
    </section>

    <!-- ─── Announcements ────────────────────────────────────────────────────── -->
    <section
      v-if="announcements.length > 0"
      class="section section-announcements"
    >
      <div class="container">
        <h2 class="section-title">
          <MegaphoneIcon
            class="title-icon"
            aria-hidden="true"
          /> Live Updates
        </h2>
        <div class="announcements-list">
          <div
            v-for="ann in announcements"
            :key="ann.id"
            class="announcement-card"
          >
            <h3 class="ann-title">
              {{ ann.title }}
            </h3>
            <p class="ann-content">
              {{ ann.content }}
            </p>
            <span class="ann-date">{{ formatDate(ann.created_at) }}</span>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── Job posts ──────────────────────────────────────────────────────── -->
    <section class="section">
      <div class="container">
        <h2 class="section-title">
          Open positions
        </h2>
        <p class="section-sub">
          We only hire when we need — here's what's available right now.
        </p>

        <div
          v-if="loading"
          class="loading-state"
        >
          <div class="spinner" />
        </div>

        <div
          v-else-if="jobPosts.length === 0"
          class="empty-jobs"
        >
          <div class="empty-icon-wrap">
            <UserGroupIcon class="empty-icon" />
          </div>
          <h3>No openings right now</h3>
          <p>We aren't currently hiring for any positions. Keep an eye on our announcements for the next wave!</p>
        </div>

        <div
          v-else
          class="cards-grid"
        >
          <article
            v-for="post in jobPosts"
            :key="post.id"
            class="job-card"
            @click="navigateTo(`/jobs/${post.id}`)"
          >
            <!-- Picture / banner -->
            <div class="card-banner">
              <img
                v-if="post.image_url"
                :src="post.image_url"
                :alt="post.title"
                class="banner-img"
              >
              <div
                v-else
                class="banner-placeholder"
              >
                <PaperAirplaneIcon
                  class="banner-icon"
                  aria-hidden="true"
                />
              </div>
            </div>

            <!-- Body -->
            <div class="card-body">
              <span class="dept-tag">{{ post.department }}</span>
              <h3 class="card-title">
                {{ post.title }}
              </h3>
              <p class="card-desc">
                {{ post.short_description }}
              </p>

              <!-- Badges row -->
              <div class="badges">
                <span class="badge">
                  <ClipboardDocumentCheckIcon
                    class="badge-icon"
                    aria-hidden="true"
                  />
                  {{ post.requirements }} requirement{{
                    post.requirements !== 1 ? "s" : ""
                  }}
                </span>
                <span class="badge">
                  <UsersIcon
                    class="badge-icon"
                    aria-hidden="true"
                  />
                  {{ post.applicant_count }} applied
                </span>
              </div>

              <!-- Date range -->
              <div
                v-if="post.closing_at"
                class="date-range"
              >
                <CalendarIcon
                  class="date-icon"
                  aria-hidden="true"
                />
                <span>{{ formatDate(post.posted_at) }} — {{ formatDate(post.closing_at) }}</span>
              </div>
            </div>

            <!-- Footer -->
            <div class="card-footer">
              <NuxtLink
                :to="`/jobs/${post.id}`"
                class="btn btn-primary btn-full"
              >
                Apply now
                <ArrowRightIcon
                  class="btn-icon"
                  aria-hidden="true"
                />
              </NuxtLink>
            </div>
          </article>
        </div>
      </div>
    </section>

    <!-- ─── Why join ───────────────────────────────────────────────────────── -->
    <section class="section">
      <div class="container">
        <h2 class="section-title">
          Why join us?
        </h2>
        <p class="section-sub">
          We're a community, not a corporation.
        </p>

        <div class="perks-grid">
          <div
            v-for="perk in perks"
            :key="perk.title"
            class="perk"
          >
            <component
              :is="perk.icon"
              class="perk-icon"
              aria-hidden="true"
            />
            <div>
              <h3 class="perk-title">
                {{ perk.title }}
              </h3>
              <p class="perk-desc">
                {{ perk.desc }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── CTA ────────────────────────────────────────────────────────────── -->
    <section class="cta">
      <div class="container cta-inner">
        <h2 class="cta-title">
          Ready to apply?
        </h2>
        <NuxtLink
          to="/jobs"
          class="btn btn-primary"
        >
          See all roles
          <ArrowRightIcon
            class="btn-icon"
            aria-hidden="true"
          />
        </NuxtLink>
      </div>
    </section>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  ArrowRightIcon,
  UsersIcon,
  CalendarIcon,
  ClipboardDocumentCheckIcon,
  HeartIcon,
  StarIcon,
  ChatBubbleLeftRightIcon,
  UserGroupIcon,
  PaperAirplaneIcon,
  MegaphoneIcon
} from '@heroicons/vue/24/outline'

const supabase = useSupabase()
const jobPosts = ref([])
const loading = ref(true)
const announcements = ref([])

function formatDate(date) {
  return new Date(date).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
}

onMounted(async () => {
  if (import.meta.client) {
    const route = useRoute()
    const { isLoggedIn } = useAuth()

    // Discord Activity Launch Detection
    if (route.query.frame_id || document.referrer.includes('discord.com')) {
      if (!isLoggedIn.value) {
        return navigateTo('/discord')
      } else {
        return navigateTo('/jobs')
      }
    }

    loading.value = true
    try {
      const { data, error } = await supabase
        .from('jobs')
        .select('*')
        .eq('is_active', true)
        .order('created_at', { ascending: false }) // Changed from posted_at
        .limit(6) // Changed from 4
      
      if (error) throw error
      if (data) jobPosts.value = data

      // Also get announcements
      const { data: annData, error: annError } = await supabase
        .from('announcements')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(3) // New limit
      
      if (annError) throw annError
      if (annData) announcements.value = annData // Changed from activeAnnouncements
    } catch (e) {
      console.error('Failed to load landing data:', e)
    } finally {
      loading.value = false
    }
  }
})
const perks = [
  {
    icon: StarIcon,
    title: 'Active community',
    desc: 'Join a growing community of creators and enthusiasts.'
  },
  {
    icon: ChatBubbleLeftRightIcon,
    title: 'Friendly team',
    desc: 'No drama, collaborative team — people who enjoy building together.'
  },
  {
    icon: HeartIcon,
    title: 'Regular events',
    desc: 'Group sessions, training and community events every week.'
  }
]

useSeoMeta({
    title: 'Sunshine Studio — Join the Team',
    description:
      'Apply to join Sunshine Studio. View open roles for staff and service positions.'
})
</script>

<style scoped>
/* ─── Layout ─────────────────────────────────────────────────────────────── */
.page {
  min-height: 100vh;
}

.container {
  max-width: 760px;
  margin: 0 auto;
  padding: 0 24px;
}

.section {
  padding: 64px 0;
  border-top: 1px solid var(--border);
}

.section-title {
  font-size: 1.35rem;
  font-weight: 800;
  color: var(--text);
  margin: 0 0 6px;
  letter-spacing: -0.02em;
}

.section-sub {
  font-size: 0.9rem;
  color: var(--muted);
  margin: 0 0 32px;
}

/* ─── Announcements ──────────────────────────────────────────────────────── */
.section-announcements { padding: 40px 0; background: rgba(232, 55, 42, 0.03); border-bottom: 1px solid var(--border); border-top: none; }
.title-icon { width: 22px; height: 22px; color: var(--red); vertical-align: text-bottom; margin-right: 6px; }
.announcements-list { display: flex; flex-direction: column; gap: 12px; margin-top: 24px; }
.announcement-card { background: var(--surface); border-left: 4px solid var(--red); padding: 16px 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
.ann-title { margin: 0 0 6px; font-size: 1.05rem; font-weight: 800; color: var(--text); }
.ann-content { margin: 0 0 8px; font-size: 0.9rem; color: var(--text); line-height: 1.5; }
.ann-date { font-size: 0.75rem; color: var(--subtle); font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }

/* ─── Buttons ─────────────────────────────────────────────────────────────── */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-size: 0.875rem;
  font-weight: 600;
  padding: 10px 20px;
  border-radius: 7px;
  text-decoration: none;
  transition:
    background 150ms ease,
    transform 130ms ease,
    box-shadow 150ms ease;
  white-space: nowrap;
}
.btn-icon {
  width: 15px;
  height: 15px;
}

.btn-primary {
  background: var(--red);
  color: #fff;
  box-shadow: 0 2px 8px rgba(232, 55, 42, 0.25);
}
.btn-primary:hover {
  background: var(--red-hover);
  transform: translateY(-1px);
  box-shadow: 0 4px 14px rgba(232, 55, 42, 0.35);
}
.btn-primary:active {
  transform: none;
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

.btn-full {
  width: 100%;
  justify-content: center;
}

/* ─── Hero ───────────────────────────────────────────────────────────────── */
.hero {
  padding: 72px 0 64px;
}

.hero-eyebrow {
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.07em;
  text-transform: uppercase;
  color: var(--red);
  margin: 0 0 16px;
}

.hero-title {
  font-size: clamp(2rem, 5vw, 3rem);
  font-weight: 900;
  line-height: 1.1;
  letter-spacing: -0.03em;
  color: var(--text);
  margin: 0 0 18px;
}

.red {
  color: var(--red);
}

.hero-sub {
  font-size: 1rem;
  color: var(--muted);
  line-height: 1.65;
  max-width: 480px;
  margin: 0 0 32px;
}

.hero-actions {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

/* ─── Empty States ────────────────────────────────────────────────────────── */
.empty-jobs {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 60px 24px;
  text-align: center;
  max-width: 500px;
  margin: 40px auto;
}
.empty-icon-wrap {
  width: 64px;
  height: 64px;
  background: rgba(232, 55, 42, 0.1);
  color: var(--red);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
}
.empty-icon { width: 32px; height: 32px; }
.empty-jobs h3 { font-size: 1.25rem; font-weight: 800; color: var(--text); margin-bottom: 8px; }
.empty-jobs p { font-size: 0.95rem; color: var(--muted); line-height: 1.5; }

/* ─── Job cards ──────────────────────────────────────────────────────────── */
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
  transition:
    border-color 160ms ease,
    box-shadow 160ms ease,
    transform 140ms ease;
}

.job-card:hover {
  border-color: var(--red);
  box-shadow: 0 4px 22px rgba(232, 55, 42, 0.1);
  transform: translateY(-2px);
}

/* Banner / picture */
.card-banner {
  height: 90px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  overflow: hidden;
}

.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.banner-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #1e3a6e, #2a4a8e);
  display: flex;
  align-items: center;
  justify-content: center;
}

.banner-icon {
  width: 36px;
  height: 36px;
  color: rgba(255, 255, 255, 0.5);
}

/* Loading */
.loading-state {
  text-align: center;
  padding: 40px 20px;
}
.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--border);
  border-top-color: var(--red);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  margin: 0 auto;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* Body */
.card-body {
  flex: 1;
  padding: 18px 18px 14px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.dept-tag {
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--red);
  background: rgba(232, 55, 42, 0.09);
  padding: 2px 8px;
  border-radius: 99px;
  align-self: flex-start;
}

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
}

/* Badges */
.badges {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--muted);
  background: var(--bg-alt, var(--bg));
  border: 1px solid var(--border);
  padding: 3px 9px;
  border-radius: 99px;
}

.badge-icon {
  width: 13px;
  height: 13px;
  flex-shrink: 0;
}

/* Date range */
.date-range {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.78rem;
  color: var(--subtle);
}

.date-icon {
  width: 13px;
  height: 13px;
  flex-shrink: 0;
}

/* Footer */
.card-footer {
  padding: 0 18px 18px;
}

/* ─── Perks ──────────────────────────────────────────────────────────────── */
.perks-grid {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.perk {
  display: flex;
  align-items: flex-start;
  gap: 14px;
}

.perk-icon {
  width: 22px;
  height: 22px;
  color: var(--red);
  flex-shrink: 0;
  margin-top: 2px;
}

.perk-title {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--text);
  margin: 0 0 3px;
}

.perk-desc {
  font-size: 0.85rem;
  color: var(--muted);
  margin: 0;
  line-height: 1.6;
}

/* ─── CTA ────────────────────────────────────────────────────────────────── */
.cta {
  padding: 56px 0;
  border-top: 1px solid var(--border);
}

.cta-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  flex-wrap: wrap;
}

.cta-title {
  font-size: 1.3rem;
  font-weight: 800;
  color: var(--text);
  margin: 0;
  letter-spacing: -0.02em;
}

/* ─── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 560px) {
  .cards-grid {
    grid-template-columns: 1fr;
  }
}
</style>
