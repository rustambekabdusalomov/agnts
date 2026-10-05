import { createRouter, createWebHistory } from 'vue-router'
import { useSession } from '../stores/session'

export const router = createRouter({
  history: createWebHistory(),
  scrollBehavior: (_to, _from, saved) => saved ?? { top: 0 },
  routes: [
    { path: '/login', name: 'login', component: () => import('../pages/LoginPage.vue'), meta: { public: true, bare: true } },
    { path: '/', redirect: '/dashboard' },
    { path: '/dashboard', name: 'dashboard', component: () => import('../pages/DashboardPage.vue') },
    { path: '/analytics', name: 'analytics', component: () => import('../pages/AnalyticsPage.vue') },
    { path: '/tickets', name: 'tickets', component: () => import('../pages/TicketsPage.vue') },
    { path: '/tickets/:key', name: 'ticket', component: () => import('../pages/TicketPage.vue') },
    { path: '/tasks', name: 'tasks', component: () => import('../pages/TasksPage.vue') },
    { path: '/logs', name: 'logs', component: () => import('../pages/LogsPage.vue') },
    { path: '/usage', name: 'usage', component: () => import('../pages/UsagePage.vue') },
    { path: '/integrations', name: 'integrations', component: () => import('../pages/IntegrationsPage.vue') },
    { path: '/integrations/:provider', name: 'integration', component: () => import('../pages/IntegrationPage.vue') },
    { path: '/repos', name: 'repos', component: () => import('../pages/ReposPage.vue') },
    { path: '/repos/:id', name: 'repo', component: () => import('../pages/RepoPage.vue') },
    { path: '/learn', name: 'learn', component: () => import('../pages/LearnPage.vue') },
    { path: '/learn-queue', name: 'learnQueue', component: () => import('../pages/LearnQueuePage.vue') },
    { path: '/learn/:id', name: 'lesson', component: () => import('../pages/LessonPage.vue') },
    { path: '/settings', name: 'settings', component: () => import('../pages/SettingsPage.vue') },
    { path: '/oauth/consent', name: 'consent', component: () => import('../pages/ConsentPage.vue'), meta: { bare: true } },
    { path: '/:pathMatch(.*)*', redirect: '/dashboard' },
  ],
})

router.beforeEach(async (to) => {
  const session = useSession()
  if (!session.checked) await session.load()
  if (to.meta.public) return session.user && to.name === 'login' ? { name: 'dashboard' } : true
  if (!session.user) return { name: 'login', query: to.fullPath === '/dashboard' ? {} : { next: to.fullPath } }
  return true
})
