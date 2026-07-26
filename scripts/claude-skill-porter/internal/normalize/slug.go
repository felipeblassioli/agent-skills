package normalize

import (
	"strings"
	"unicode"
)

func Slug(s string) string {
	var b strings.Builder
	dash := false
	for _, r := range strings.TrimSpace(s) {
		if unicode.IsUpper(r) && b.Len() > 0 {
			dash = true
		}
		if unicode.IsLetter(r) || unicode.IsDigit(r) {
			if dash && b.Len() > 0 {
				b.WriteByte('-')
			}
			b.WriteRune(unicode.ToLower(r))
			dash = false
		} else {
			dash = true
		}
	}
	return strings.Trim(b.String(), "-")
}
