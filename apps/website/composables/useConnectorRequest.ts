/** Whether the "Request a connector" dialog is open; shared by the button and the dialog. */
export function useConnectorRequest() {
  const open = useState('connector-request-open', () => false)
  return { open, show: () => (open.value = true) }
}
