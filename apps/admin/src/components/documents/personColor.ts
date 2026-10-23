// A colour per person, from their name, so the same person looks the same
// in the text's highlights, the comments and the viewers. Eight hues far
// apart (blue, red, green, orange, purple, teal, pink, gold) tell people
// apart better than any hue would; neighbours on the wheel look alike.
const HUES = [212, 4, 140, 28, 280, 180, 330, 52]

/** The hue (0–359) of a person's colour. */
export function personHue(name: string): number {
  let h = 7
  for (const c of name.trim().toLowerCase()) h = (h * 31 + c.codePointAt(0)!) % 100_003
  return HUES[h % HUES.length]
}
