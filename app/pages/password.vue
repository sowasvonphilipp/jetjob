<template>
  <main class="password-page">
    <div class="password-card">
      <div class="lock-icon">
        <LockClosedIcon />
      </div>
      <h2>Site Protected</h2>
      <p>Please enter the access passcode to enter the Jet2 Jobs platform.</p>
      
      <form @submit.prevent="verifyCode" class="passcode-form">
        <input 
          v-model="passcode"
          type="password"
          placeholder="••••••"
          class="pass-input"
          autofocus
        />
        <button type="submit" class="btn btn-primary btn-full">Enter Site</button>
        <span v-if="error" class="error-msg">Incorrect passcode. Please try again.</span>
      </form>

      <div class="demo-info">
        <span>DEMO ACCESS ONLY</span>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref } from 'vue'
import { LockClosedIcon } from '@heroicons/vue/24/outline'

const passcode = ref('')
const error = ref(false)

definePageMeta({ layout: false })

function verifyCode() {
  if (passcode.value === '230512') {
    // Set cookie for 7 days
    const d = new Date()
    d.setTime(d.getTime() + (7 * 24 * 60 * 60 * 1000))
    document.cookie = `jet2_access_granted=true; expires=${d.toUTCString()}; path=/`
    
    // Also use localStorage just in case
    localStorage.setItem('jet2_access', 'true')
    
    navigateTo('/')
  } else {
    error.value = true
    setTimeout(() => error.value = false, 3000)
  }
}

useSeoMeta({
  title: 'Access Protected — Jet2 Roblox'
})
</script>

<style scoped>
.password-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #09090b;
  color: #fff;
  padding: 24px;
}

.password-card {
  width: 100%;
  max-width: 360px;
  background: #18181b;
  border: 1px solid #27272a;
  border-radius: 20px;
  padding: 40px 32px;
  text-align: center;
  box-shadow: 0 10px 40px rgba(0,0,0,0.5);
}

.lock-icon {
  width: 54px;
  height: 54px;
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
}
.lock-icon svg { width: 28px; height: 28px; }

h2 { font-size: 1.5rem; font-weight: 800; margin-bottom: 8px; letter-spacing: -0.02em; }
p { font-size: 0.9rem; color: #a1a1aa; line-height: 1.5; margin-bottom: 24px; }

.passcode-form { display: flex; flex-direction: column; gap: 12px; }
.pass-input {
  background: #09090b;
  border: 1px solid #27272a;
  border-radius: 10px;
  padding: 14px;
  color: #fff;
  font-size: 1.2rem;
  text-align: center;
  letter-spacing: 0.5em;
  outline: none;
  transition: border-color 0.2s;
}
.pass-input:focus { border-color: #ef4444; }

.btn {
  display: flex; align-items: center; justify-content: center;
  padding: 12px; border-radius: 10px; border: none; font-weight: 700; cursor: pointer;
  transition: 0.2s;
}
.btn-primary { background: #ef4444; color: #fff; }
.btn-primary:hover { background: #dc2626; transform: translateY(-1px); }

.error-msg { font-size: 0.75rem; color: #ef4444; margin-top: 8px; }

.demo-info {
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #27272a;
  font-size: 0.65rem;
  font-weight: 800;
  letter-spacing: 0.1em;
  color: #52525b;
}
</style>
