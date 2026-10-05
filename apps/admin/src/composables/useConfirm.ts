import { reactive } from 'vue'

export interface ConfirmOptions {
  title: string
  message?: string
  confirmLabel: string
  /** Red confirm button, for destructive or live-environment actions. */
  danger?: boolean
}

// One confirm dialog for the whole app (ConfirmHost.vue renders it), so
// callers can simply `if (await askConfirm({...}))` like window.confirm.
export const confirmState = reactive({
  open: false,
  opts: null as ConfirmOptions | null,
  resolve: null as ((ok: boolean) => void) | null,
})

export function askConfirm(opts: ConfirmOptions): Promise<boolean> {
  confirmState.resolve?.(false) // a newer question replaces an unanswered one
  return new Promise((resolve) => {
    confirmState.opts = opts
    confirmState.resolve = resolve
    confirmState.open = true
  })
}

export function answerConfirm(ok: boolean) {
  confirmState.resolve?.(ok)
  confirmState.resolve = null
  confirmState.open = false
}
