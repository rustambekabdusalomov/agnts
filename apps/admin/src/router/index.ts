import { createRouter, createWebHistory } from 'vue-router'
import { useSession } from '../stores/session'
import { useWorkspace } from '../stores/workspace'

// Signed-in pages live under /w/<workspace>/...; a link without the
// workspace (older links, in-app paths) opens in the current workspace.
// Public pages (sign-in, sign-up, links from emails) and the workspace
// chooser stand alone.
export const router = createRouter({
  history: createWebHistory(),
  scrollBehavior: (_to, _from, saved) => saved ?? { top: 0 },
  routes: [
    { path: '/login', name: 'login', component: () => import('../pages/LoginPage.vue'), meta: { public: true, bare: true } },
    { path: '/signup', name: 'signup', component: () => import('../pages/account/SignupPage.vue'), meta: { public: true, bare: true } },
    { path: '/forgot', name: 'forgot', component: () => import('../pages/account/ForgotPage.vue'), meta: { public: true, bare: true } },
    { path: '/reset-password', name: 'reset', component: () => import('../pages/account/ResetPage.vue'), meta: { public: true, bare: true, any: true } },
    { path: '/verify', name: 'verify', component: () => import('../pages/account/VerifyPage.vue'), meta: { public: true, bare: true, any: true } },
    { path: '/invite/:token', name: 'invite', component: () => import('../pages/account/InvitePage.vue'), meta: { public: true, bare: true, any: true } },
    { path: '/workspaces', name: 'workspaces', component: () => import('../pages/account/WorkspacesPage.vue'), meta: { bare: true, global: true } },
    { path: '/oauth/consent', name: 'consent', component: () => import('../pages/ConsentPage.vue'), meta: { bare: true, global: true } },
    { path: '/billing/return', name: 'billingReturn', component: () => import('../pages/account/BillingReturnPage.vue'), meta: { bare: true, global: true } },
    { path: '/', name: 'home', component: () => import('../pages/account/WorkspacesPage.vue'), meta: { bare: true, global: true } },
    // The Admin cabinet: the platform's users, workspaces and Admins (system Admins only).
    { path: '/admin', name: 'adminDashboard', component: () => import('../pages/admin/AdminDashboardPage.vue'), meta: { admin: true, global: true } },
    { path: '/admin/workspaces', name: 'adminWorkspaces', component: () => import('../pages/admin/AdminWorkspacesPage.vue'), meta: { admin: true, global: true } },
    { path: '/admin/users', name: 'adminUsers', component: () => import('../pages/admin/AdminUsersPage.vue'), meta: { admin: true, global: true } },
    { path: '/admin/admins', name: 'adminAdmins', component: () => import('../pages/admin/AdminAdminsPage.vue'), meta: { admin: true, global: true } },
    { path: '/admin/feedback', name: 'adminFeedback', component: () => import('../pages/admin/AdminFeedbackPage.vue'), meta: { admin: true, global: true } },
    { path: '/admin/profile', name: 'adminProfile', component: () => import('../pages/account/ProfilePage.vue'), meta: { admin: true, global: true } },
    {
      path: '/w/:ws',
      children: [
        { path: '', redirect: (to) => `/w/${String(to.params.ws)}/dashboard` },
        { path: 'dashboard', name: 'dashboard', component: () => import('../pages/DashboardPage.vue') },
        { path: 'analytics', name: 'analytics', component: () => import('../pages/AnalyticsPage.vue') },
        { path: 'tickets', name: 'tickets', component: () => import('../pages/TicketsPage.vue') },
        { path: 'tickets/:key', name: 'ticket', component: () => import('../pages/TicketPage.vue') },
        { path: 'tasks', name: 'tasks', component: () => import('../pages/TasksPage.vue') },
        { path: 'reviews', name: 'reviews', component: () => import('../pages/ReviewsPage.vue') },
        { path: 'logs', name: 'logs', component: () => import('../pages/LogsPage.vue') },
        { path: 'usage', name: 'usage', component: () => import('../pages/UsagePage.vue') },
        { path: 'integrations', name: 'integrations', component: () => import('../pages/IntegrationsPage.vue') },
        { path: 'integrations/:provider', name: 'integration', component: () => import('../pages/IntegrationPage.vue') },
        { path: 'repos', name: 'repos', component: () => import('../pages/ReposPage.vue') },
        { path: 'repos/:id', name: 'repo', component: () => import('../pages/RepoPage.vue') },
        { path: 'learn', name: 'learn', component: () => import('../pages/LearnPage.vue') },
        { path: 'learn-queue', name: 'learnQueue', component: () => import('../pages/LearnQueuePage.vue') },
        { path: 'learn/:id', name: 'lesson', component: () => import('../pages/LessonPage.vue') },
        { path: 'rules', name: 'rules', component: () => import('../pages/RulesPage.vue') },
        { path: 'settings', name: 'settings', component: () => import('../pages/SettingsPage.vue') },
        { path: 'workspace', name: 'workspace', component: () => import('../pages/workspace/WorkspacePage.vue') },
        { path: 'profile', name: 'profile', component: () => import('../pages/account/ProfilePage.vue') },
        { path: 'platform', redirect: '/admin' },
        { path: ':rest(.*)*', redirect: (to) => `/w/${String(to.params.ws)}/dashboard` },
      ],
    },
    // A path without a workspace: opened in the current one (see beforeEach).
    { path: '/:pathMatch(.*)*', name: 'unscoped', component: () => import('../pages/account/WorkspacesPage.vue') },
  ],
})

router.beforeEach(async (to) => {
  const session = useSession()
  if (!session.checked) await session.load()
  if (to.meta.public) {
    // Links from emails work signed in or out; sign-in pages do not.
    if (session.user && !to.meta.any) return { path: '/' }
    return true
  }
  if (!session.user) return { name: 'login', query: to.fullPath === '/' ? {} : { next: to.fullPath } }
  if (to.meta.admin) return session.user.isAdmin ? true : { path: '/' }
  // An Admin account runs the platform and has no workspaces: the cabinet is its home.
  if (session.user.isAdmin && !session.user.workspaces?.length) return { name: 'adminDashboard', replace: true }

  const workspace = useWorkspace()
  const ws = typeof to.params.ws === 'string' ? to.params.ws : ''
  if (!ws) {
    const target = workspace.slug || session.homeWorkspace()
    if (to.name === 'unscoped' || to.name === 'home') {
      if (!target) return to.name === 'home' ? true : { name: 'workspaces' }
      const rest = to.name === 'home' ? '/dashboard' : to.fullPath
      return { path: `/w/${target}${rest}`, replace: true }
    }
    return true
  }
  if (!(await workspace.open(ws))) {
    // Not a member (or it was deleted): back to one that is theirs.
    await session.load()
    const home = session.homeWorkspace()
    return home && home !== ws ? { path: `/w/${home}/dashboard` } : { name: 'workspaces' }
  }
  return true
})
