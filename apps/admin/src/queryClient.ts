import { QueryClient } from '@tanstack/vue-query'

/** The app's query cache, shared so switching workspaces can empty it. */
export const queryClient = new QueryClient()
