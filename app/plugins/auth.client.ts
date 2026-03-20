export default defineNuxtPlugin(async () => {
  if (import.meta.server) return
  const { init } = useAuth()
  await init()
})
