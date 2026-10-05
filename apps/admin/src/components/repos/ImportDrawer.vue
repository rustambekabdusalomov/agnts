<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { RemoteRepository } from '../../api/types'
import { ago } from '../../composables/format'
import FormDrawer from '../form/FormDrawer.vue'
import SegButtons from '../form/SegButtons.vue'
import { useIntegrations } from '../integrations/useIntegrations'
import HiIcon from '../ui/HiIcon.vue'

// Pick a repository the connected GitHub or GitLab token can reach; the
// parent opens the repository drawer prefilled with it.
type Git = 'github' | 'gitlab'
const open = defineModel<boolean>({ default: false })
const emit = defineEmits<{ pick: [repo: RemoteRepository] }>()
const { t, locale } = useI18n()
const integrations = useIntegrations()

const connected = computed(() =>
  (['github', 'gitlab'] as Git[]).filter((p) => integrations.data.value?.some((i) => i.provider === p && i.connected)),
)
const provider = ref<Git>('github')
watch(
  [open, connected],
  () => {
    if (open.value && !connected.value.includes(provider.value) && connected.value.length) provider.value = connected.value[0]
  },
  { immediate: true },
)
const options = computed(() => connected.value.map((p) => ({ value: p, label: t(`integrations.name_${p}`) })))

const remote = useQuery({
  queryKey: computed(() => ['remote-repos', provider.value]),
  queryFn: () => unwrap(api.GET('/integrations/{provider}/repos', { params: { path: { provider: provider.value } } })),
  enabled: computed(() => open.value && connected.value.includes(provider.value)),
  staleTime: 60_000,
  retry: false,
})
const errorText = computed(() => {
  const e = remote.error.value
  return e instanceof HttpError ? e.message : e ? t('common.error') : ''
})

const q = ref('')
watch(open, (v) => { if (v) q.value = '' })
const rows = computed(() => {
  const s = q.value.trim().toLowerCase()
  return (remote.data.value ?? []).filter((r) => !s || r.fullName.toLowerCase().includes(s) || r.description?.toLowerCase().includes(s))
})

function pick(r: RemoteRepository) {
  open.value = false
  emit('pick', r)
}
</script>

<template>
  <FormDrawer v-model="open" :title="t('repos.importTitle')" :subtitle="t('repos.importSub')">
    <p v-if="integrations.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="!connected.length" class="help">
      <HiIcon name="info" />
      <p>{{ t('repos.importNone') }} <RouterLink to="/integrations">{{ t('repos.importConnect') }}</RouterLink></p>
    </div>
    <template v-else>
      <SegButtons v-if="options.length > 1" v-model="provider" :options="options" :label="t('repos.importFrom')" />
      <label class="search">
        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
        <input v-model="q" type="search" :placeholder="t('repos.importSearch')" :aria-label="t('repos.importSearch')">
      </label>
      <p v-if="remote.isPending.value" class="hint">{{ t('repos.importLoading') }}</p>
      <p v-else-if="errorText" class="ferr" role="alert">{{ errorText }}</p>
      <p v-else-if="!rows.length" class="empty">{{ remote.data.value?.length ? t('repos.noMatch') : t('repos.importEmpty') }}</p>
      <ul v-else class="imp-list">
        <li v-for="r in rows" :key="r.cloneUrl" class="imp-row">
          <div class="imp-main">
            <div class="imp-name">
              <b>{{ r.fullName }}</b>
              <span v-if="r.private" class="badge b-gray">{{ t('repos.importPrivate') }}</span>
            </div>
            <p v-if="r.description" class="imp-desc">{{ r.description }}</p>
            <span class="hint">
              {{ r.defaultBranch }}<template v-if="r.updatedAt"> · {{ t('repos.importUpdated', { time: ago(r.updatedAt, locale) }) }}</template>
            </span>
          </div>
          <span v-if="r.added" class="badge b-ok">{{ t('repos.importAdded') }}</span>
          <button v-else type="button" class="btn btn-s" @click="pick(r)">{{ t('repos.importPick') }}</button>
        </li>
      </ul>
    </template>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.close') }}</button>
    </template>
  </FormDrawer>
</template>
