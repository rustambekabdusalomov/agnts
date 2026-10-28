import { describe, expect, it } from 'vitest'
import { encodeWav, VOICE_RATE } from './useVoiceRecorder'

describe('encodeWav', () => {
  it('writes 16 kHz mono 16-bit PCM, clipping out-of-range samples', () => {
    const wav = encodeWav(new Float32Array([0, 1, -1, 0.5, 2, -3]), VOICE_RATE)
    const v = new DataView(wav.buffer)
    const ascii = (at: number, n: number) => String.fromCharCode(...wav.slice(at, at + n))
    expect(wav.length).toBe(44 + 12)
    expect([ascii(0, 4), ascii(8, 8), ascii(36, 4)]).toEqual(['RIFF', 'WAVEfmt ', 'data'])
    expect(v.getUint32(4, true)).toBe(36 + 12)
    expect(v.getUint16(20, true)).toBe(1) // PCM
    expect(v.getUint16(22, true)).toBe(1) // mono
    expect(v.getUint32(24, true)).toBe(16000)
    expect(v.getUint32(28, true)).toBe(32000)
    expect(v.getUint16(34, true)).toBe(16)
    expect(v.getUint32(40, true)).toBe(12)
    const samples = Array.from({ length: 6 }, (_, i) => v.getInt16(44 + i * 2, true))
    expect(samples).toEqual([0, 32767, -32768, 16383, 32767, -32768])
  })
})
