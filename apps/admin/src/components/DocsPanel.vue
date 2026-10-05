<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api } from '../api/client'
import HiIcon from './ui/HiIcon.vue'

// The "How this page works" drawer. Docs are Markdown on the server
// (# title, intro paragraph, then "## item" sections) and are rendered as
// plain text here, never as HTML.
const props = defineProps<{ page: string }>()
const open = defineModel<boolean>({ default: false })
const { t, locale } = useI18n()
const closeBtn = ref<HTMLButtonElement | null>(null)

const doc = useQuery({
  queryKey: computed(() => ['doc', props.page, locale.value]),
  queryFn: async () => {
    const { data, response } = await api.GET('/docs/{page}', {
      params: { path: { page: props.page }, query: { lang: locale.value as 'en' | 'ru' | 'uz' } },
      parseAs: 'text',
    })
    if (!response.ok) throw new Error(String(response.status))
    return String(data ?? '')
  },
  enabled: open,
  staleTime: 5 * 60_000,
})

const parsed = computed(() => {
  const md = doc.data.value ?? ''
  let title = ''
  const intro: string[] = []
  const items: { title: string; text: string[] }[] = []
  for (const block of md.split(/\n{2,}/)) {
    const b = block.trim()
    if (!b) continue
    if (b.startsWith('# ')) title = b.slice(2)
    else if (b.startsWith('## ')) items.push({ title: b.slice(3), text: [] })
    else if (items.length) items[items.length - 1].text.push(b)
    else intro.push(b)
  }
  return { title, intro, items }
})

watch(open, async (v) => {
  if (v) {
    await nextTick()
    closeBtn.value?.focus()
  }
})
</script>

<template>
  <div v-if="open" @keydown.esc="open = false">
    <button class="gd-back" :aria-label="t('nav.close')" @click="open = false" />
    <div class="gd" role="dialog" aria-modal="true" aria-labelledby="docsTitle">
      <div class="gd-h">
        <div>
          <p class="docs-kicker">{{ t('nav.guide') }}</p>
          <h2 id="docsTitle">{{ parsed.title }}</h2>
        </div>
        <button ref="closeBtn" class="x-btn" :aria-label="t('nav.close')" @click="open = false"><HiIcon name="close" /></button>
      </div>
      <div class="gd-b">
        <p v-if="doc.isPending.value" class="hint">{{ t('common.loading') }}</p>
        <p v-for="(p, i) in parsed.intro" :key="i" class="docs-intro">{{ p }}</p>
        <div>
          <div v-for="it in parsed.items" :key="it.title" class="gd-item">
            <b>{{ it.title }}</b>
            <span v-for="(x, i) in it.text" :key="i">{{ x }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
