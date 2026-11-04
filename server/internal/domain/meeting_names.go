package domain

import (
	"strings"
	"unicode"
)

// Who takes an action item: the notes write the person's name as it was
// said ("Aziza", "Азиза", "Rustam aka"), and agnts finds the member it
// names. Names are folded the same way on both sides (lower case, Latin,
// no apostrophes, the spellings of one sound made one) so a name Muse
// wrote in either alphabet, or a little off, still finds its member.

// NameCandidate is a member an action item may name: the names they go by
// (display name, username, the name they joined with, their email's
// name). Near is someone of the meeting: in the call, invited, a host, or
// in an uploaded recording.
type NameCandidate struct {
	UserID int64
	Names  []string
	Near   bool
}

// selfWords say the speaker took the task ("I'll do it"): the speaker is
// the one who takes it.
var selfWords = map[string]bool{"i": true, "me": true, "myself": true, "men": true, "ozim": true, "man": true, "ya": true, "sam": true}

// honorifics come with a name but are not part of it ("Rustam aka").
var honorifics = map[string]bool{"aka": true, "opa": true, "mr": true, "mrs": true, "ms": true, "bro": true}

// IsSelf reports whether a name as said is the speaker themself.
func IsSelf(said string) bool {
	f := FoldName(said)
	return f == "" || selfWords[f]
}

// MatchMember returns the member said names: among the near candidates
// first, else among all, and only when exactly one matches best.
func MatchMember(said string, cands []NameCandidate) (int64, bool) {
	var words []string
	for _, w := range strings.Fields(FoldName(said)) {
		if !honorifics[w] {
			words = append(words, w)
		}
	}
	if len(words) == 0 || IsSelf(said) {
		return 0, false
	}
	for _, near := range []bool{true, false} {
		best, who, ties := 0, int64(0), 0
		for _, c := range cands {
			if near && !c.Near {
				continue
			}
			sc := nameScore(words, c.Names)
			switch {
			case sc == 0:
			case sc > best:
				best, who, ties = sc, c.UserID, 1
			case sc == best && c.UserID != who:
				ties++
			}
		}
		if best > 0 {
			return who, ties == 1
		}
	}
	return 0, false
}

// nameScore is how well the words of a name as said fit a member's
// names: 3 when one of them is that name, 2 when every word is a word of
// one name, 1 when every word is one letter off one, 0 when they don't fit.
func nameScore(words []string, names []string) int {
	best := 0
	for _, n := range names {
		full := strings.Fields(FoldName(n))
		if len(full) == 0 {
			continue
		}
		if strings.Join(full, " ") == strings.Join(words, " ") {
			return 3
		}
		sc := 2
		for _, w := range words {
			fit := 0
			for _, f := range full {
				if w == f {
					fit = 2
					break
				}
				if len(w) >= 5 && len(f) >= 5 && oneEdit(w, f) {
					fit = 1
				}
			}
			sc = min(sc, fit)
		}
		best = max(best, sc)
	}
	return best
}

// oneEdit reports whether a and b differ by one letter added, dropped or
// changed.
func oneEdit(a, b string) bool {
	if a == b {
		return true
	}
	ra, rb := []rune(a), []rune(b)
	if len(ra) < len(rb) {
		ra, rb = rb, ra
	}
	if len(ra)-len(rb) > 1 {
		return false
	}
	i := 0
	for i < len(rb) && ra[i] == rb[i] {
		i++
	}
	if len(ra) == len(rb) {
		return string(ra[i+1:]) == string(rb[i+1:])
	}
	return string(ra[i+1:]) == string(rb[i:])
}

// cyrillicLatin writes Russian and Uzbek Cyrillic in Latin letters.
var cyrillicLatin = map[rune]string{
	'а': "a", 'б': "b", 'в': "v", 'г': "g", 'д': "d", 'е': "e", 'ё': "yo", 'ж': "j", 'з': "z", 'и': "i", 'й': "y",
	'к': "k", 'л': "l", 'м': "m", 'н': "n", 'о': "o", 'п': "p", 'р': "r", 'с': "s", 'т': "t", 'у': "u", 'ф': "f",
	'х': "h", 'ц': "ts", 'ч': "ch", 'ш': "sh", 'щ': "sh", 'ъ': "", 'ы': "i", 'ь': "", 'э': "e", 'ю': "yu", 'я': "ya",
	'ў': "o", 'қ': "q", 'ғ': "g", 'ҳ': "h",
}

// latinSounds make one the Latin spellings of one sound: Xurshid,
// Khurshid and Хуршид; Jasur and Zhasur.
var latinSounds = strings.NewReplacer("kh", "h", "x", "h", "zh", "j", "yo", "e", "ye", "e")

// FoldName is a name as names are compared: lower case, in Latin, letters
// and digits only, one space between words.
func FoldName(s string) string {
	var b strings.Builder
	for _, r := range strings.ToLower(s) {
		if l, ok := cyrillicLatin[r]; ok {
			b.WriteString(l)
			continue
		}
		switch {
		case r >= 'a' && r <= 'z', r >= '0' && r <= '9':
			b.WriteRune(r)
		case unicode.IsSpace(r), r == '-', r == '_', r == '.', r == ',', r == '@':
			b.WriteRune(' ')
		case unicode.IsLetter(r) && !unicode.Is(unicode.Lm, r): // ʻ and ʼ are modifier letters
			b.WriteRune(foldAccent(r))
		}
		// Apostrophes (oʻ, gʻ, ʼ) and other marks are dropped.
	}
	return strings.Join(strings.Fields(latinSounds.Replace(b.String())), " ")
}

// foldAccent drops the accent of the Latin letters names carry (ş, ç, ö, é).
func foldAccent(r rune) rune {
	switch r {
	case 'á', 'à', 'â', 'ä', 'ã':
		return 'a'
	case 'é', 'è', 'ê', 'ë':
		return 'e'
	case 'í', 'ì', 'î', 'ï', 'ı':
		return 'i'
	case 'ó', 'ò', 'ô', 'ö', 'õ':
		return 'o'
	case 'ú', 'ù', 'û', 'ü':
		return 'u'
	case 'ş':
		return 's'
	case 'ç':
		return 'c'
	case 'ğ':
		return 'g'
	case 'ñ':
		return 'n'
	}
	return r
}
