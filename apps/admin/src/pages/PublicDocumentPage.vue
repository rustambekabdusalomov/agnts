<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import CommentableText from '../components/documents/CommentableText.vue'
import CommentsPanel from '../components/documents/CommentsPanel.vue'
import DownloadMenu from '../components/documents/DownloadMenu.vue'
import GuestGate from '../components/documents/GuestGate.vue'
import PresentMode from '../components/documents/PresentMode.vue'
import SlideDeck from '../components/documents/SlideDeck.vue'
import ViewersBar from '../components/documents/ViewersBar.vue'
import type { Anchor } from '../components/documents/anchors'
import { guestTarget, useComments, usePresence } from '../components/documents/useComments'
import { publicDownloadPath } from '../components/documents/useDocuments'
import ReportView from '../components/ticket/ReportView.vue'
import HiIcon from '../components/ui/HiIcon.vue'

// A public document, for anyone with its link once they say who they are
// (a name, or Google): the text, comments on selected words, who else is
// looking, and downloads; a deck as slides, to present. Guests see every
// comment and viewer; nothing else about the workspace, and no speaker
// notes (the server leaves them out).
const { t, locale } = useI18n()
const route = useRoute()
const token = computed(() => String(route.params.token))

// The guest's own token for this link, kept in this browser.
const storeKey = computed(() => `agnts.guest.${token.value}`)
function readGuest(): string {
  try {
    return localStorage.getItem(storeKey.value) ?? ''
  } catch {
    return ''
  }
}
const guest = ref(readGuest())
function setGuest(v: string) {
  guest.value = v
  try {
    if (v) localStorage.setItem(storeKey.value, v)
    else localStorage.removeItem(storeKey.value)
  } catch {
    // Private windows: the guest lasts as long as the page.
  }
}
const header = computed(() => ({ 'X-Guest-Token': guest.value }))

const info = useQuery({
  queryKey: computed(() => ['public-document-info', token.value]),
  queryFn: () => unwrap(api.GET('/public/documents/{token}/info', { params: { path: { token: token.value } } })),
  retry: (n, e) => !(e instanceof HttpError && (e.status === 404 || e.status === 429)) && n < 2,
})
const doc = useQuery({
  queryKey: computed(() => ['public-document', token.value, guest.value]),
  queryFn: () => unwrap(api.GET('/public/documents/{token}', { params: { path: { token: token.value }, header: header.value } })),
  enabled: computed(() => !!guest.value),
  retry: (n, e) => !(e instanceof HttpError && [401, 404, 429].includes(e.status)) && n < 2,
})
// A token the server no longer knows (the link was reset): ask again.
watch(doc.error, (e) => {
  if (e instanceof HttpError && e.status === 401) setGuest('')
})
const d = computed(() => doc.data.value)
watch([d, () => info.data.value], ([v, i]) => {
  const title = v?.title ?? i?.title
  if (title) document.title = title
})

// Built once per guest, not on every refetch: a new target restarts presence.
const loaded = computed(() => !!d.value)
const target = computed(() => (guest.value && loaded.value ? guestTarget(token.value, guest.value) : null))
const comments = useComments(target)
const { viewers } = usePresence(target, comments.refresh)
const pending = ref<{ anchor: Anchor; slide?: number } | null>(null)
const active = ref<number | null>(null)
const missing = ref<number[]>([])
const commentable = ref<InstanceType<typeof CommentableText> | null>(null)
function activate(id: number) {
  active.value = id
  commentable.value?.reveal(id)
}

const presentOpen = ref(false)
const presentStart = ref(0)
function present(from = 0) {
  presentStart.value = from
  presentOpen.value = true
}

// The link is the credential: links in the text must not carry it away in
// a Referer. Only the origin goes, never the path with the token; Google's
// button needs that origin to accept the page.
const referrer = document.createElement('meta')
referrer.name = 'referrer'
referrer.content = 'strict-origin'
document.head.appendChild(referrer)
onBeforeUnmount(() => referrer.remove())
</script>

<template>
  <main class="pd">
    <p v-if="info.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="info.isError.value || !info.data.value" class="pd-gone">
      <h1>{{ t('documents.publicGoneTitle') }}</h1>
      <p>{{ t('documents.publicGone') }}</p>
    </div>
    <GuestGate v-else-if="!guest" :token="token" :info="info.data.value" @joined="setGuest" />
    <p v-else-if="doc.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="doc.isError.value || !d" class="pd-gone">
      <h1>{{ t('documents.publicGoneTitle') }}</h1>
      <p>{{ t('documents.publicGone') }}</p>
    </div>
    <template v-else>
      <header class="pd-h">
        <h1>{{ d.title }}</h1>
        <p class="hint">{{ t('documents.publicUpdated', { when: new Date(d.updatedAt).toLocaleDateString(locale) }) }}</p>
        <div class="pd-act">
          <button v-if="d.kind === 'slides'" type="button" class="btn btn-p btn-s" @click="present()"><HiIcon name="play" />{{ t('documents.present') }}</button>
          <DownloadMenu :md-path="publicDownloadPath(token, 'md')" :pdf-path="publicDownloadPath(token, 'pdf')" :name="d.title" :headers="header" small />
          <ViewersBar :viewers="viewers" />
        </div>
      </header>
      <div class="pd-grid">
        <article class="pd-body">
          <CommentableText
            ref="commentable"
            :threads="comments.threads.value"
            :active-id="active"
            :slides="d.kind === 'slides'"
            :can-comment="true"
            :content-key="d.body"
            @select="(v) => (pending = v)"
            @activate="activate"
            @missing="(ids) => (missing = ids)"
          >
            <SlideDeck v-if="d.kind === 'slides'" :markdown="d.body" @present="present" />
            <ReportView v-else :markdown="d.body" />
          </CommentableText>
        </article>
        <aside class="pd-side">
          <CommentsPanel :c="comments" :pending="pending" :active-id="active" :missing="missing" :can-comment="true" @activate="activate" @cancel="pending = null" />
        </aside>
      </div>
      <PresentMode v-if="d.kind === 'slides'" v-model="presentOpen" :markdown="d.body" :start="presentStart" />
    </template>
  </main>
</template>

<style scoped>
.pd { max-width: 1240px; margin: 0 auto; padding: 32px 16px 64px; }
.pd-h { border-bottom: 1px solid var(--line); padding-bottom: 16px; margin-bottom: 20px; display: flex; flex-direction: column; gap: 8px; }
.pd-h h1 { margin: 0; font-size: 28px; line-height: 1.2; overflow-wrap: anywhere; }
.pd-h .hint { margin: 0; }
.pd-gone { text-align: center; padding: 64px 0; }
.pd-act { display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
.pd-grid { display: grid; grid-template-columns: minmax(0, 1fr) 340px; gap: 24px; align-items: start; }
.pd-body { min-width: 0; }
.pd-side { position: sticky; top: 16px; max-height: calc(100vh - 32px); overflow: auto; }
@media (max-width: 1000px) {
  .pd-grid { grid-template-columns: minmax(0, 1fr); }
  .pd-side { position: static; max-height: none; }
}
</style>
