<template>
  <main class="page">
    <div class="container legal-content">
      <h1 class="page-title">
        Terms of Service
      </h1>
      <p class="last-updated">
        Last Updated: {{ new Date().toLocaleDateString() }}
      </p>

      <section class="prose">
        <h2>1. Acceptance of Terms</h2>
        <p>By accessing and using the Jet2 Roblox Airline system, you accept and agree to be bound by the terms and provision of this agreement.</p>

        <h2>2. Use License</h2>
        <p>Permission is granted to temporarily use this application for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.</p>

        <h2>3. Disclaimer</h2>
        <p>The materials on Jet2's website are provided on an 'as is' basis. Jet2 makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.</p>

        <h2>4. Governing Law</h2>
        <p>Any claim relating to Jet2's website shall be governed by the laws of our operating jurisdiction without regard to its conflict of law provisions.</p>
      </section>
    </div>
  </main>
</template>

<script setup>
useSeoMeta({
  title: 'Terms of Service — Jet2 Jobs',
  description: 'Terms of Service for Jet2 Roblox Airline applications.'
})
</script>

<style scoped>
.page { min-height: 100vh; padding: 64px 0; }
.container { max-width: 800px; margin: 0 auto; padding: 0 24px; }
.page-title { font-size: 2.5rem; font-weight: 900; color: var(--text); margin-bottom: 8px; letter-spacing: -0.02em; }
.last-updated { color: var(--muted); font-size: 0.9rem; margin-bottom: 40px; }

.prose {
  color: var(--subtle);
  line-height: 1.7;
}
.prose h2 {
  color: var(--text);
  font-size: 1.3rem;
  font-weight: 700;
  margin: 32px 0 16px;
}
.prose p {
  margin-bottom: 16px;
  font-size: 1.05rem;
}
</style>
