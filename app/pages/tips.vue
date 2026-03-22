<template>
  <main class="static-page">
    <div class="container">
      <h1 class="page-title">Application Tips</h1>
      <p class="page-sub">How to stand out and succeed at Jet2 Virtual</p>
      
      <div class="content-block">
        <h2>1. Be Genuine</h2>
        <p>At Jet2 Virtual, we value authenticity. Do not use AI generators (like ChatGPT or Claude) to write your application answers or cover letter. Our system flags AI-generated responses automatically, and relying on them can result in an instant rejection. Write in your own unique voice!</p>
        
        <h2>2. Read the Requirements</h2>
        <p>Before applying for any position—whether it's a First Officer or a Staff role—please carefully read the listed requirements. If a role requires a certain number of flight hours or specific simulator platforms, ensure you actually meet them before submitting. Lying about meeting requirements will result in a blacklist.</p>
        
        <h2>3. Put Effort into Your Answers</h2>
        <p>Short, one-word answers usually won't cut it, especially for staff positions. Take the time to explain your thought process, showcase your experience, and prove why you are the best fit for the role.</p>
        
        <h2>4. Wait Patiently</h2>
        <p>Our Human Resources team processes dozens of applications a day. Please do not open tickets or message staff to ask about the status of your application. You will be notified via this portal or Discord the moment a decision is made.</p>
      </div>
    </div>
  </main>
</template>

<script setup>
useSeoMeta({
  title: 'Application Tips — Jet2 Jobs',
  description: 'Learn how to submit a successful application at Jet2 Virtual.'
})
</script>

<style scoped>
.static-page { padding: 60px 0; min-height: 80vh; }
.container { max-width: 800px; margin: 0 auto; padding: 0 24px; }
.page-title { font-size: 2.5rem; font-weight: 900; color: var(--text); margin: 0 0 12px; letter-spacing: -0.02em; line-height: 1.1; }
.page-sub { font-size: 1.1rem; color: var(--muted); margin: 0 0 40px; }

.content-block {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.05);
}

.content-block h2 {
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--red);
  margin: 30px 0 12px;
}
.content-block h2:first-child {
  margin-top: 0;
}

.content-block p {
  font-size: 1rem;
  line-height: 1.7;
  color: var(--text);
  margin: 0 0 16px;
}
.content-block p:last-child {
  margin-bottom: 0;
}
</style>
