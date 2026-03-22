<template>
  <div class="cv-builder">
    <div class="form-panel">
      <div class="form-header">
        <NuxtLink to="/" class="back-link">
          <ArrowLeftIcon class="w-4 h-4" /> Back Home
        </NuxtLink>
        <h1 class="page-title">CV Generator</h1>
        <p class="page-sub">Fill out the details below to generate a beautiful, ATS-friendly CV.</p>
        
        <button class="btn btn-primary print-trigger" @click="printCV">
          <PrinterIcon class="w-5 h-5" /> Download PDF
        </button>
      </div>

      <div class="form-section">
        <h2 class="section-title">Personal Information</h2>
        <div class="form-grid">
          <div class="form-group span-2">
            <label>Full Name</label>
            <input v-model="cv.fullName" type="text" class="form-input" placeholder="e.g. John Doe">
          </div>
          <div class="form-group">
            <label>Email Address</label>
            <input v-model="cv.email" type="email" class="form-input" placeholder="john@example.com">
          </div>
          <div class="form-group">
            <label>Phone Number</label>
            <input v-model="cv.phone" type="text" class="form-input" placeholder="+1 (555) 000-0000">
          </div>
          <div class="form-group">
            <label>Location</label>
            <input v-model="cv.location" type="text" class="form-input" placeholder="New York, NY">
          </div>
          <div class="form-group">
            <label>Portfolio / LinkedIn</label>
            <input v-model="cv.linkedIn" type="text" class="form-input" placeholder="linkedin.com/in/johndoe">
          </div>
        </div>
      </div>

      <div class="form-section">
        <h2 class="section-title">Professional Summary</h2>
        <div class="form-group">
          <label>Summary</label>
          <textarea v-model="cv.summary" class="form-input" rows="4" placeholder="A brief summary of your professional background and goals..."></textarea>
        </div>
      </div>

      <div class="form-section">
        <h2 class="section-title">Work Experience</h2>
        <div v-for="(exp, idx) in cv.experience" :key="idx" class="dynamic-card">
          <button class="delete-btn" @click="removeExperience(idx)"><TrashIcon class="w-4 h-4" /></button>
          <div class="form-grid">
            <div class="form-group">
              <label>Company / Organization</label>
              <input v-model="exp.company" type="text" class="form-input" placeholder="e.g. Jet2 Virtual">
            </div>
            <div class="form-group">
              <label>Role / Title</label>
              <input v-model="exp.role" type="text" class="form-input" placeholder="e.g. First Officer">
            </div>
            <div class="form-group">
              <label>Start Date</label>
              <input v-model="exp.start" type="text" class="form-input" placeholder="Jan 2023">
            </div>
            <div class="form-group">
              <label>End Date</label>
              <input v-model="exp.end" type="text" class="form-input" placeholder="Present">
            </div>
            <div class="form-group span-2">
              <label>Description & Achievements</label>
              <textarea v-model="exp.description" class="form-input doc-textarea" rows="3" placeholder="Describe your responsibilities and achievements... (supports bullet points with hyphens)"></textarea>
            </div>
          </div>
        </div>
        <button class="btn btn-outline btn-full add-btn" @click="addExperience">
          <PlusIcon class="w-5 h-5" /> Add Experience
        </button>
      </div>

      <div class="form-section">
        <h2 class="section-title">Education</h2>
        <div v-for="(edu, idx) in cv.education" :key="idx" class="dynamic-card">
          <button class="delete-btn" @click="removeEducation(idx)"><TrashIcon class="w-4 h-4" /></button>
          <div class="form-grid">
            <div class="form-group span-2">
              <label>Institution</label>
              <input v-model="edu.school" type="text" class="form-input" placeholder="e.g. University of Example">
            </div>
            <div class="form-group">
              <label>Degree / Certificate</label>
              <input v-model="edu.degree" type="text" class="form-input" placeholder="e.g. BSc Computer Science">
            </div>
            <div class="form-group">
              <label>Year</label>
              <input v-model="edu.year" type="text" class="form-input" placeholder="e.g. 2019 - 2023">
            </div>
          </div>
        </div>
        <button class="btn btn-outline btn-full add-btn" @click="addEducation">
          <PlusIcon class="w-5 h-5" /> Add Education
        </button>
      </div>

      <div class="form-section">
        <h2 class="section-title">Skills & Languages</h2>
        <div class="form-group">
          <label>Comma separated skills</label>
          <input v-model="cv.skills" type="text" class="form-input" placeholder="e.g. Piloting, ATC Communication, Leadership, English">
        </div>
      </div>
    </div>

    <!-- Right Side: Print Preview -->
    <div class="preview-panel">
      <!-- We scale it slightly down on screen so it fits entirely -->
      <div class="a4-container">
        <div class="a4-sheet" id="cv-print-area">
          <header class="cv-header">
            <h1 class="cv-name">{{ cv.fullName || 'Your Name' }}</h1>
            <div class="cv-contact">
              <span v-if="cv.email">{{ cv.email }}</span>
              <span v-if="cv.email && cv.phone"> • </span>
              <span v-if="cv.phone">{{ cv.phone }}</span>
              <span v-if="(cv.email || cv.phone) && cv.location"> • </span>
              <span v-if="cv.location">{{ cv.location }}</span>
              <span v-if="(cv.email || cv.phone || cv.location) && cv.linkedIn"> • </span>
              <span v-if="cv.linkedIn">{{ cv.linkedIn }}</span>
            </div>
          </header>

          <main class="cv-body">
            <section v-if="cv.summary" class="cv-section">
              <h2 class="cv-h2">Professional Summary</h2>
              <hr class="cv-hr" />
              <p class="cv-text">{{ cv.summary }}</p>
            </section>

            <section v-if="cv.experience.length > 0" class="cv-section">
              <h2 class="cv-h2">Experience</h2>
              <hr class="cv-hr" />
              <div v-for="(exp, idx) in cv.experience" :key="idx" class="cv-job">
                <div class="cv-job-header">
                  <div class="cv-job-left">
                    <h3 class="cv-h3">{{ exp.role || 'Role Title' }}</h3>
                    <span class="cv-company">{{ exp.company || 'Company Name' }}</span>
                  </div>
                  <div class="cv-job-right">
                    <span class="cv-dates">{{ exp.start || 'Start' }} – {{ exp.end || 'End' }}</span>
                  </div>
                </div>
                <ul v-if="exp.description" class="cv-bullet-list">
                  <li v-for="(line, lineIdx) in exp.description.split('\n')" :key="lineIdx" v-show="line.trim()">
                    {{ line.replace(/^-/, '').trim() }}
                  </li>
                </ul>
              </div>
            </section>

            <section v-if="cv.education.length > 0" class="cv-section">
              <h2 class="cv-h2">Education</h2>
              <hr class="cv-hr" />
              <div v-for="(edu, idx) in cv.education" :key="idx" class="cv-job">
                <div class="cv-job-header">
                  <div class="cv-job-left">
                    <h3 class="cv-h3">{{ edu.degree || 'Degree Title' }}</h3>
                    <span class="cv-company">{{ edu.school || 'Institution Name' }}</span>
                  </div>
                  <div class="cv-job-right">
                    <span class="cv-dates">{{ edu.year || 'Year' }}</span>
                  </div>
                </div>
              </div>
            </section>

            <section v-if="cv.skills" class="cv-section">
              <h2 class="cv-h2">Skills</h2>
              <hr class="cv-hr" />
              <p class="cv-text">
                {{ cv.skills.split(',').map(s => s.trim()).filter(s => s).join(' • ') }}
              </p>
            </section>
          </main>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ArrowLeftIcon, PrinterIcon, PlusIcon, TrashIcon } from '@heroicons/vue/24/outline'

const cv = ref({
  fullName: '',
  email: '',
  phone: '',
  location: '',
  linkedIn: '',
  summary: '',
  experience: [
    { company: 'Jet2 Virtual', role: 'First Officer', start: 'Mar 2025', end: 'Present', description: '- Operated daily flights across European routes.\n- Maintained perfect safety record.' }
  ],
  education: [
    { school: 'Roblox Aviation Academy', degree: 'Commercial Pilot License', year: '2024' }
  ],
  skills: 'Teamwork, Communication, Flight Simulator X, English'
})

function addExperience() {
  cv.value.experience.push({ company: '', role: '', start: '', end: '', description: '' })
}
function removeExperience(idx) {
  cv.value.experience.splice(idx, 1)
}

function addEducation() {
  cv.value.education.push({ school: '', degree: '', year: '' })
}
function removeEducation(idx) {
  cv.value.education.splice(idx, 1)
}

function printCV() {
  window.print()
}

useSeoMeta({
  title: 'CV Generator — Jet2 Jobs'
})
</script>

<style scoped>
/* App Layout */
.cv-builder {
  display: flex;
  height: 100vh;
  overflow: hidden;
  background: var(--bg);
}

.form-panel {
  flex: 0 0 500px;
  overflow-y: auto;
  padding: 32px;
  background: var(--surface);
  border-right: 1px solid var(--border);
  box-shadow: 2px 0 20px rgba(0,0,0,0.03);
  z-index: 10;
}

.preview-panel {
  flex: 1;
  overflow-y: auto;
  background: #f3f4f6; /* Soft gray for desk background */
  display: flex;
  justify-content: center;
  padding: 40px;
}

/* Form Styles */
.back-link { display: inline-flex; align-items: center; gap: 6px; color: var(--muted); text-decoration: none; font-size: 0.85rem; margin-bottom: 24px; font-weight: 500; }
.page-title { font-size: 2rem; font-weight: 900; color: var(--text); margin: 0 0 8px; }
.page-sub { font-size: 0.95rem; color: var(--muted); margin: 0 0 24px; line-height: 1.5; }
.print-trigger { margin-bottom: 32px; width: 100%; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 1rem; padding: 14px; border-radius: 8px; font-weight: 700; }

.section-title { font-size: 1.1rem; font-weight: 800; color: var(--text); text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 2px solid var(--border); padding-bottom: 8px; margin: 32px 0 20px; }

.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.span-2 { grid-column: span 2; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group label { font-size: 0.8rem; font-weight: 700; color: var(--text); }
.form-input { width: 100%; background: var(--bg); border: 1px solid var(--border); color: var(--text); border-radius: 6px; padding: 10px 14px; font-size: 0.9rem; font-family: inherit; transition: 0.2s; outline: none; }
.form-input:focus { border-color: var(--red); box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1); }
textarea.form-input { resize: vertical; }
.doc-textarea { font-family: monospace; font-size: 0.85rem; }

.dynamic-card { background: var(--bg); border: 1px solid var(--border); padding: 16px; border-radius: 8px; margin-bottom: 16px; position: relative; }
.delete-btn { position: absolute; top: 12px; right: 12px; background: rgba(239,68,68,0.1); color: #ef4444; border: none; padding: 6px; border-radius: 6px; cursor: pointer; transition: 0.2s; }
.delete-btn:hover { background: #ef4444; color: white; }
.add-btn { background: var(--bg); border: 1px dashed var(--muted); color: var(--text); font-weight: 600; padding: 12px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; transition: 0.2s; }
.add-btn:hover { border-style: solid; background: var(--border); }

.w-4 { width: 16px; height: 16px; }
.w-5 { width: 20px; height: 20px; }

/* A4 Sheet Styles */
.a4-container {
  /* Scale down for smaller screens to fit without scrolling too much horizontally */
  transform-origin: top center;
  margin-bottom: 40px;
}

.a4-sheet {
  width: 210mm;
  min-height: 297mm;
  background: white;
  color: #111827; /* Dark gray, crisp black */
  box-shadow: 0 20px 40px rgba(0,0,0,0.15);
  padding: 20mm;
  font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
  box-sizing: border-box;
}

/* Clean CV Typography */
.cv-header { text-align: center; margin-bottom: 8mm; }
.cv-name { font-size: 28pt; font-weight: 800; text-transform: uppercase; letter-spacing: 2px; margin: 0 0 4mm; color: #111827; }
.cv-contact { font-size: 10pt; color: #4b5563; }
.cv-contact span { margin: 0 2px; }

.cv-body { display: flex; flex-direction: column; gap: 6mm; }
.cv-section { margin-bottom: 2mm; }
.cv-h2 { font-size: 14pt; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #1f2937; margin: 0; }
.cv-hr { border: none; border-bottom: 1px solid #d1d5db; margin: 2mm 0 4mm; }

.cv-text { font-size: 10.5pt; line-height: 1.6; color: #374151; margin: 0; text-align: justify; }

.cv-job { margin-bottom: 5mm; }
.cv-job:last-child { margin-bottom: 0; }
.cv-job-header { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 2mm; }
.cv-h3 { font-size: 12pt; font-weight: 700; color: #111827; margin: 0; }
.cv-company { font-size: 11pt; font-weight: 500; color: #4b5563; font-style: italic; display: block; margin-top: 1mm; }
.cv-dates { font-size: 10pt; color: #6b7280; font-weight: 500; }

.cv-bullet-list { margin: 0; padding-left: 5mm; list-style-type: square; }
.cv-bullet-list li { font-size: 10.5pt; line-height: 1.5; color: #374151; margin-bottom: 1mm; }

/* Responsive adjustments for the builder */
@media (max-width: 1200px) {
  .a4-container { transform: scale(0.85); }
}
@media (max-width: 1024px) {
  .cv-builder { flex-direction: column; height: auto; overflow: visible; }
  .form-panel { flex: none; width: 100%; border-right: none; border-bottom: 1px solid var(--border); }
  .a4-container { transform: scale(1); max-width: 100%; overflow-x: auto; }
}

/* 
 * CRITICAL: Native Browser Print CSS 
 * This obliterates the application shell when printing
 */
@media print {
  @page {
    size: A4;
    margin: 0;
  }
  body, html {
    background: white;
    margin: 0;
    padding: 0;
  }
  
  /* Hide the rest of the application completely */
  .form-panel, header, nav, footer, #__nuxt > div > *:not(.cv-builder) {
    display: none !important;
  }
  
  .cv-builder {
    height: auto;
    background: transparent;
    display: block;
  }
  
  .preview-panel {
    padding: 0;
    background: transparent;
    display: block;
  }
  
  .a4-container {
    transform: none !important;
    margin: 0 !important;
    padding: 0 !important;
  }
  
  .a4-sheet {
    box-shadow: none !important;
    width: 210mm !important;
    min-height: 297mm !important;
    padding: 15mm !important; /* Printing margins handled by the sheet padding */
    margin: 0 !important;
  }
}
</style>
