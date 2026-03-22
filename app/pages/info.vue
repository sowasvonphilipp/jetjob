<template>
  <main class="static-page">
    <div class="container">
      <h1 class="page-title">General Information</h1>
      <p class="page-sub">About Jet2 Virtual and our operations.</p>
      
      <div class="content-block">
        <h2>Who We Are</h2>
        <p>Jet2 Virtual is a premier virtual airline operating primarily on Roblox. We simulate real-world airline operations with a focus on professionalism, community engagement, and high-quality roleplay, delivering the ultimate aviation experience on the platform.</p>
        
        <h2>Our Fleet & Operations</h2>
        <p>We operate a strictly maintained fleet, flying popular medium-haul and short-haul routes across Europe. Our pilots are trained to uphold the highest standards of safety, communication, and operational realism, whether operating a 737 or an A320.</p>
        
        <h2>The Community</h2>
        <p>Joining Jet2 Virtual means joining a family of aviation enthusiasts. Whether you're a seasoned virtual pilot, an aspiring flight attendant, or looking to coordinate events from the control tower, you'll find a welcoming environment with dedicated staff ready to help you grow your skills.</p>
        
        <h2>Contact & Support</h2>
        <p>If you have any questions regarding your application, a moderation action, or general inquiries, please open a ticket in our official Discord server. Our Human Resources and Moderation teams are active daily and will be happy to assist you.</p>
      </div>
    </div>
  </main>
</template>

<script setup>
useSeoMeta({
  title: 'Information — Jet2 Jobs',
  description: 'General information about Jet2 Virtual operations and community.'
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
