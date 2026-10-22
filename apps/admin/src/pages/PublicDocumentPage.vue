<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, onBeforeUnmount, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import DownloadMenu from '../components/documents/DownloadMenu.vue'
import { publicDownloadPath } from '../components/documents/useDocuments'
import ReportView from '../components/ticket/ReportView.vue'

// A public document, for anyone with its link: the title, the text, when
// it was last updated, and downloads. Nothing about the workspace, its
// people or its tickets.
const { t, locale } = useI18n()
const route = useRoute()
const token = computed(() => String(route.params.token))
const doc = useQuery({
  queryKey: computed(() => ['public-document', token.value]),
  queryFn: () => unwrap(api.GET('/public/documents/{token}', { params: { path: { token: token.value } } })),
  retry: (n, e) => !(e instanceof HttpError && (e.status === 404 || e.status === 429)) && n < 2,
})
const d = computed(() => doc.data.value)
watch(d, (v) => {
  if (v) document.title = v.title
})
// The link is the credential: links in the text must not carry it away in
// a Referer (the server sends the same policy as a header).
const referrer = document.createElement('meta')
referrer.name = 'referrer'
referrer.content = 'no-referrer'
document.head.appendChild(referrer)
onBeforeUnmount(() => referrer.remove())
</script>

<template>
  <main class="pd">
    <p v-if="doc.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="doc.isError.value || !d" class="pd-gone">
      <h1>{{ t('documents.publicGoneTitle') }}</h1>
      <p>{{ t('documents.publicGone') }}</p>
    </div>
    <article v-else>
      <header class="pd-h">
        <h1>{{ d.title }}</h1>
        <p class="hint">{{ t('documents.publicUpdated', { when: new Date(d.updatedAt).toLocaleDateString(locale) }) }}</p>
        <DownloadMenu :md-path="publicDownloadPath(token, 'md')" :pdf-path="publicDownloadPath(token, 'pdf')" :name="d.title" small />
      </header>
      <ReportView :markdown="d.body" />
    </article>
  </main>
</template>

<style scoped>
.pd { max-width: 860px; margin: 0 auto; padding: 32px 16px 64px; }
.pd-h { border-bottom: 1px solid var(--line); padding-bottom: 16px; margin-bottom: 20px; display: flex; flex-direction: column; gap: 8px; }
.pd-h h1 { margin: 0; font-size: 28px; line-height: 1.2; overflow-wrap: anywhere; }
.pd-h .hint { margin: 0; }
.pd-gone { text-align: center; padding: 64px 0; }
</style>
