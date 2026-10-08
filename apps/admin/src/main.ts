import { VueQueryPlugin } from '@tanstack/vue-query'
import { createPinia } from 'pinia'
import { createApp } from 'vue'
import App from './App.vue'
import { setUnauthorizedHandler } from './api/client'
import { i18n } from './i18n'
import { router } from './router'
import { queryClient } from './queryClient'
import { useSession } from './stores/session'
import { useWorkspace } from './stores/workspace'
import './styles/tokens.css'
import './styles/demo.css'
import './styles/app.css'

const app = createApp(App)
app.use(createPinia())
app.use(i18n)
app.use(router)
app.use(VueQueryPlugin, { queryClient })

setUnauthorizedHandler(() => {
  const session = useSession()
  session.user = null
  useWorkspace().reset()
  if (router.currentRoute.value.name !== 'login') void router.push({ name: 'login' })
})

app.mount('#app')
