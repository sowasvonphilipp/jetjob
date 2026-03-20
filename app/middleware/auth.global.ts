export default defineNuxtRouteMiddleware((to) => {
  // 1. Passcode Check (Beta/Demo Protection)
  const passcodeCookie = useCookie('jet2_access_granted')
  if (to.path !== '/password' && !passcodeCookie.value) {
    return navigateTo('/password')
  }

  // 2. Auth Check
  const publicRoutes = ['/', '/login', '/auth/callback', '/password']
  if (publicRoutes.includes(to.path)) return

  const { isLoggedIn, loading } = useAuth()
  if (loading.value) return

  if (!isLoggedIn.value) {
    return navigateTo('/login')
  }
})
