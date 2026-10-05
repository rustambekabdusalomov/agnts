<script setup lang="ts">
import { useI18n } from 'vue-i18n'

// Footer of a scroll-paged list: loading, a retry after an error, a manual
// "Load more", or the end. The parent puts its sentinel ref on this element.
defineProps<{ loading: boolean; failed: boolean; hasMore: boolean; end: string }>()
defineEmits<{ more: [] }>()
const { t } = useI18n()
</script>

<template>
  <div class="cm-more">
    <span v-if="loading" class="hint">{{ t('common.loading') }}</span>
    <p v-else-if="failed" class="hint">{{ t('repo.moreError') }}</p>
    <button v-if="hasMore && !loading" type="button" class="btn btn-s" @click="$emit('more')">{{ t('repo.loadMore') }}</button>
    <span v-else-if="!hasMore" class="hint">{{ end }}</span>
  </div>
</template>
