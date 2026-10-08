<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import AuthCard from '../../components/AuthCard.vue'
import { useSession } from '../../stores/session'
import { useWorkspace } from '../../stores/workspace'

// Where Payme and Click send the person back after paying.
const { t } = useI18n()
const session = useSession()
const workspace = useWorkspace()
const slug = workspace.slug || session.homeWorkspace()
</script>

<template>
  <AuthCard :title="t('account.returnTitle')" :lede="t('account.returnLede')">
    <RouterLink class="btn btn-p login-submit" :to="slug ? `/w/${slug}/workspace?tab=billing` : '/'">{{ t('account.returnBack') }}</RouterLink>
  </AuthCard>
</template>
