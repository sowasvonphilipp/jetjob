<template>
  <AppHeader />
  <NuxtPage />
  <AppFooter />
  <ClientOnly><SiteLockOverlay v-if="appConfig.locked" /></ClientOnly>
</template>

<script setup lang="ts">
const appConfig = useAppConfig()
</script>
