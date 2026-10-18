import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import TicketSection from './TicketSection.vue'

const setup = (id: string, slot = '<p class="body">two notes</p>') =>
  mount(TicketSection, { props: { id, title: 'Notes', hint: '2' }, slots: { default: slot } })

describe('TicketSection', () => {
  it('closes from its title, keeps its count, and stays closed on the next ticket', async () => {
    const w = setup('notes-test')
    const btn = w.find('button')
    expect(btn.attributes('aria-expanded')).toBe('true')
    expect(w.find('.body').exists()).toBe(true)
    await btn.trigger('click')
    expect(btn.attributes('aria-expanded')).toBe('false')
    expect(w.find('.body').exists()).toBe(false)
    expect(w.find('.tsec-n').text()).toBe('2')
    expect(JSON.parse(localStorage.getItem('ticketSectionsClosed') ?? '[]')).toContain('notes-test')

    // Another ticket page: the same section starts closed; others do not.
    const next = setup('notes-test', '<p class="body">other</p>')
    expect(next.find('.body').exists()).toBe(false)
    expect(setup('checks-test').find('.body').exists()).toBe(true)
    await next.find('button').trigger('click')
    expect(next.find('.body').text()).toBe('other')
  })
})
