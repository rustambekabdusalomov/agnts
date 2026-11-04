<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Repository } from '../../api/types'
import GitHubAvatar from '../ui/GitHubAvatar.vue'
import { useRepoMembers } from './useRepoMembers'

// Who has access to the repository on GitHub or GitLab. These are the
// people a pull request can be assigned to when a review is approved.
const props = defineProps<{ repo: Repository }>()
const { t } = useI18n()
const members = useRepoMembers(computed(() => props.repo.id))

const q = ref('')
const rows = computed(() => {
  const s = q.value.trim().toLowerCase()
  return (members.data.value ?? []).filter((m) => !s || m.username.toLowerCase().includes(s) || m.name?.toLowerCase().includes(s))
})
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t('repo.members') }}</h2>
        <p class="sub">{{ t(`repo.membersSub_${repo.provider}`) }}</p>
      </div>
      <label v-if="(members.data.value?.length ?? 0) > 8" class="search" style="flex: 0 1 260px">
        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
        <input v-model="q" type="search" :placeholder="t('repo.membersSearch')" :aria-label="t('repo.membersSearch')">
      </label>
    </div>
    <p v-if="members.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="members.isError.value" class="help bad"><p>{{ (members.error.value as Error)?.message || t('common.error') }}</p></div>
    <p v-else-if="!rows.length" class="empty">{{ q ? t('repos.noMatch') : t('repo.membersNone') }}</p>
    <ul v-else class="mem-list">
      <li v-for="m in rows" :key="m.username" class="mem">
        <GitHubAvatar :url="m.avatarUrl" :size="32" />
        <div class="mem-main">
          <a v-if="m.url" class="mem-name" :href="m.url" target="_blank" rel="noopener noreferrer">{{ m.name || m.username }}</a>
          <span v-else class="mem-name">{{ m.name || m.username }}</span>
          <span v-if="m.name" class="hint mono">@{{ m.username }}</span>
        </div>
        <span class="badge b-gray">{{ m.role }}</span>
      </li>
    </ul>
  </section>
</template>
