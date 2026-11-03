package domain

import "testing"

func TestFoldName(t *testing.T) {
	for in, want := range map[string]string{
		"Азиза":            "aziza",
		"Шохрух Каримов":   "shohruh karimov",
		"Shoxrux":          "shohruh",
		"Khurshid":         "hurshid",
		"Gʻayrat O'tkir":   "gayrat otkir",
		"  rustam.aka_99 ": "rustam aka 99",
		"Şükrü":            "sukru",
	} {
		if got := FoldName(in); got != want {
			t.Errorf("FoldName(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestMatchMember(t *testing.T) {
	people := []NameCandidate{
		{UserID: 1, Names: []string{"Aziza Rahimova", "aziza", "aziza.r@example.com"}, Near: true},
		{UserID: 2, Names: []string{"Rustambek Abdusalomov", "rustam"}, Near: true},
		{UserID: 3, Names: []string{"Bekzod Tursunov", "bekzod"}},
		{UserID: 4, Names: []string{"Aziz Karimov", "aziz"}},
		{UserID: 5, Names: []string{"Jasur Aliyev"}, Near: true},
		{UserID: 6, Names: []string{"Jasur Olimov"}, Near: true},
	}
	for _, c := range []struct {
		said string
		want int64
	}{
		{"Aziza", 1},
		{"Азиза", 1},
		{"aziza rahimova", 1},
		{"Azizа Rahimowa", 1}, // a Cyrillic а, and one letter off
		{"Rustam aka", 2},
		{"Рустамбек", 2},
		{"Bekzod", 3}, // not near, the only one in the workspace
		{"Aziz", 4},   // not Aziza: names this short must be exact
		{"Jasur", 0},  // two near people are called Jasur
		{"Jasur Olimov", 6},
		{"I", 0},
		{"", 0},
		{"Kamola", 0},
		{"Aziza and Bekzod", 0},
	} {
		got, ok := MatchMember(c.said, people)
		if !ok {
			got = 0
		}
		if got != c.want {
			t.Errorf("MatchMember(%q) = %d, want %d", c.said, got, c.want)
		}
	}
	if !IsSelf("men") || !IsSelf("Я") || IsSelf("Aziza") {
		t.Error("IsSelf")
	}
}
