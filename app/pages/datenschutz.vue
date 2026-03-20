<template>
  <main class="page">
    <div class="container legal-content">
      <h1 class="page-title">
        Datenschutzerklärung (Privacy Policy)
      </h1>
      <p class="last-updated">
        Stand: {{ new Date().toLocaleDateString('de-DE') }}
      </p>

      <section class="prose">
        <h2>1. Datenschutz auf einen Blick</h2>
        <h3>Allgemeine Hinweise</h3>
        <p>Die folgenden Hinweise geben einen einfachen Überblick darüber, was mit Ihren personenbezogenen Daten passiert, wenn Sie diese Website besuchen. Personenbezogene Daten sind alle Daten, mit denen Sie persönlich identifiziert werden können.</p>

        <h2>2. Datenerfassung auf dieser Website</h2>
        <h3>Wer ist verantwortlich für die Datenerfassung auf dieser Website?</h3>
        <p>Die Datenverarbeitung auf dieser Website erfolgt durch den Websitebetreiber. Dessen Kontaktdaten können Sie dem Impressum dieser Website entnehmen.</p>

        <h3>Wie erfassen wir Ihre Daten?</h3>
        <p>Ihre Daten werden zum einen dadurch erhoben, dass Sie uns diese mitteilen. Hierbei kann es sich z. B. um Daten handeln, die Sie in ein Kontaktformular eingeben oder über Discord OAuth bereitstellen.</p>

        <h2>3. Analyse-Tools und Tools von Drittanbietern</h2>
        <p>Beim Besuch dieser Website kann Ihr Surf-Verhalten statistisch ausgewertet werden. Das geschieht vor allem mit sogenannten Analyseprogrammen.</p>

        <h2>4. Discord Integration</h2>
        <p>Wir nutzen Discord OAuth zur Authentifizierung. Es werden nur die für den Betrieb notwendigen Daten (Ihre Discord-ID, Ihr Benutzername und Avatar) abgerufen und gespeichert. Sie können diese Verbindung jederzeit in Ihren Discord-Konto-Einstellungen widerrufen.</p>
      </section>
    </div>
  </main>
</template>

<script setup>
useSeoMeta({
  title: 'Datenschutz — Jet2 Jobs',
  description: 'Datenschutzerklärung für Jet2 Roblox Airline.'
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
.prose h3 {
  color: var(--text);
  font-size: 1.1rem;
  font-weight: 600;
  margin: 24px 0 12px;
}
.prose p {
  margin-bottom: 16px;
  font-size: 1.05rem;
}
</style>
