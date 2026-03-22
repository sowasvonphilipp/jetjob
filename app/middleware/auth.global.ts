export default defineNuxtRouteMiddleware((to) => {
  // Auth Check
  const publicRoutes = ['/', '/login', '/auth/callback']
  if (publicRoutes.includes(to.path)) return

  const { isLoggedIn, loading } = useAuth()
  if (loading.value) return

  if (!isLoggedIn.value) {
    return navigateTo('/login')
  }
})
