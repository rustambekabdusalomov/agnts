package domain

import (
	"crypto/sha256"
	"encoding/hex"
)

// Languages agnts translates ticket texts into: code to the English name
// Claude is given.
var Languages = map[string]string{
	"en": "English", "ru": "Russian", "uz": "Uzbek (Latin script)", "kk": "Kazakh", "tr": "Turkish", "de": "German",
	"es": "Spanish", "fr": "French", "zh": "Simplified Chinese", "ja": "Japanese", "ko": "Korean", "ar": "Arabic",
}

// TextHash identifies a text in the translation store: the same text is
// translated once per language, whichever ticket it appears in.
func TextHash(s string) string {
	h := sha256.Sum256([]byte(s))
	return hex.EncodeToString(h[:])
}
