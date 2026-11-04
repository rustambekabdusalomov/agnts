package security

import (
	"go/ast"
	"go/parser"
	"go/token"
	"path"
	"regexp"
	"strings"
)

// Symbol names the function, method or handler around line in a file
// ("Orders.Search", "UserController.show"), so a finding keeps its
// identity when lines shift; "" when the language is not parsed or the
// line is outside any function (the file alone then identifies it).
func Symbol(file string, src []byte, line int) string {
	if line <= 0 || len(src) == 0 || len(src) > 2<<20 {
		return ""
	}
	switch strings.ToLower(path.Ext(file)) {
	case ".go":
		return goSymbol(src, line)
	case ".js", ".jsx", ".mjs", ".cjs", ".ts", ".tsx":
		return headerSymbol(src, line, jsHeaders, jsClass)
	case ".py":
		return pySymbol(src, line)
	case ".java", ".kt", ".cs", ".scala":
		return headerSymbol(src, line, javaHeaders, javaClass)
	case ".php":
		return headerSymbol(src, line, phpHeaders, phpClass)
	case ".rb":
		return headerSymbol(src, line, rubyHeaders, rubyClass)
	}
	return ""
}

func goSymbol(src []byte, line int) string {
	fset := token.NewFileSet()
	f, err := parser.ParseFile(fset, "", src, parser.SkipObjectResolution)
	if err != nil && f == nil {
		return ""
	}
	for _, d := range f.Decls {
		fn, ok := d.(*ast.FuncDecl)
		if !ok || fn.Body == nil {
			continue
		}
		if fset.Position(fn.Pos()).Line > line || fset.Position(fn.End()).Line < line {
			continue
		}
		if fn.Recv != nil && len(fn.Recv.List) > 0 {
			return recvName(fn.Recv.List[0].Type) + "." + fn.Name.Name
		}
		return fn.Name.Name
	}
	return ""
}

func recvName(e ast.Expr) string {
	switch t := e.(type) {
	case *ast.StarExpr:
		return recvName(t.X)
	case *ast.IndexExpr:
		return recvName(t.X)
	case *ast.IndexListExpr:
		return recvName(t.X)
	case *ast.Ident:
		return t.Name
	}
	return "?"
}

var (
	jsHeaders = []*regexp.Regexp{
		regexp.MustCompile(`^\s*(?:export\s+)?(?:default\s+)?(?:async\s+)?function\s*\*?\s*([A-Za-z_$][\w$]*)\s*\(`),
		regexp.MustCompile(`^\s*(?:export\s+)?(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:async\s+)?(?:function\b|\([^)]*\)\s*(?::[^=]+)?=>|[A-Za-z_$][\w$]*\s*=>)`),
		regexp.MustCompile(`^\s*(?:public\s+|private\s+|protected\s+|static\s+|async\s+|readonly\s+)*([A-Za-z_$][\w$]*)\s*\([^;]*\)\s*(?::[^{]+)?\{\s*$`),
		// Express-style routes: app.get("/orders", ...)
		regexp.MustCompile(`^\s*(?:app|router|server)\.(get|post|put|patch|delete|all)\(\s*['"\x60]([^'"\x60]+)`),
	}
	jsClass   = regexp.MustCompile(`^\s*(?:export\s+)?(?:default\s+)?(?:abstract\s+)?class\s+([A-Za-z_$][\w$]*)`)
	pyHeader  = regexp.MustCompile(`^(\s*)(?:async\s+)?def\s+([A-Za-z_]\w*)\s*\(`)
	pyClass   = regexp.MustCompile(`^(\s*)class\s+([A-Za-z_]\w*)`)
	javaClass = regexp.MustCompile(`^\s*(?:public\s+|private\s+|protected\s+|internal\s+|abstract\s+|final\s+|static\s+|sealed\s+|data\s+|open\s+)*(?:class|interface|object|record|enum)\s+([A-Za-z_]\w*)`)
	// A method: modifiers, a type and a name, then "(", not a call or a
	// control statement.
	javaHeaders = []*regexp.Regexp{
		regexp.MustCompile(`^\s*(?:@\w+(?:\([^)]*\))?\s+)*(?:public|private|protected|internal|static|final|override|suspend|open|abstract|synchronized|async|virtual|\s)*\s*(?:fun\s+|[\w<>\[\],.?]+\s+)([A-Za-z_]\w*)\s*\([^;]*$`),
	}
	phpHeaders  = []*regexp.Regexp{regexp.MustCompile(`^\s*(?:public\s+|private\s+|protected\s+|static\s+|final\s+|abstract\s+)*function\s+&?\s*([A-Za-z_]\w*)\s*\(`)}
	phpClass    = regexp.MustCompile(`^\s*(?:final\s+|abstract\s+)?(?:class|trait|interface)\s+([A-Za-z_]\w*)`)
	rubyHeaders = []*regexp.Regexp{regexp.MustCompile(`^\s*def\s+(?:self\.)?([A-Za-z_]\w*[?!=]?)`)}
	rubyClass   = regexp.MustCompile(`^\s*(?:class|module)\s+([A-Z]\w*(?:::\w+)*)`)
	notMethods  = map[string]bool{"if": true, "for": true, "while": true, "switch": true, "catch": true, "return": true, "new": true, "else": true, "function": true, "synchronized": true}
)

// headerSymbol finds the nearest function header at or above line, and
// the nearest class above that, by pattern. It is a heuristic: the
// identity it gives is stable under edits elsewhere in the file, which
// is what fingerprints need.
func headerSymbol(src []byte, line int, headers []*regexp.Regexp, class *regexp.Regexp) string {
	lines := strings.Split(string(src), "\n")
	if line > len(lines) {
		return ""
	}
	fn, at := "", -1
	for i := line - 1; i >= 0 && fn == ""; i-- {
		for _, re := range headers {
			m := re.FindStringSubmatch(lines[i])
			if m == nil {
				continue
			}
			name := m[len(m)-1]
			if len(m) == 3 && (m[1] == "get" || m[1] == "post" || m[1] == "put" || m[1] == "patch" || m[1] == "delete" || m[1] == "all") {
				name = strings.ToUpper(m[1]) + " " + m[2]
			}
			if notMethods[name] {
				continue
			}
			fn, at = name, i
			break
		}
	}
	if fn == "" {
		return ""
	}
	for i := at - 1; i >= 0; i-- {
		if m := class.FindStringSubmatch(lines[i]); m != nil {
			return m[1] + "." + fn
		}
	}
	return fn
}

// pySymbol follows indentation: the innermost def around line, and its
// class.
func pySymbol(src []byte, line int) string {
	lines := strings.Split(string(src), "\n")
	if line > len(lines) {
		return ""
	}
	indent := func(s string) int { return len(s) - len(strings.TrimLeft(s, " \t")) }
	target := indent(lines[line-1])
	var names []string
	limit := target + 1
	for i := line - 1; i >= 0; i-- {
		l := lines[i]
		if strings.TrimSpace(l) == "" {
			continue
		}
		if m := pyHeader.FindStringSubmatch(l); m != nil && len(m[1]) < limit {
			names = append([]string{m[2]}, names...)
			limit = len(m[1])
		} else if m := pyClass.FindStringSubmatch(l); m != nil && len(m[1]) < limit {
			names = append([]string{m[2]}, names...)
			limit = len(m[1])
		} else if indent(l) < limit && i != line-1 {
			limit = min(limit, indent(l)+1)
		}
		if limit == 0 {
			break
		}
	}
	return strings.Join(names, ".")
}
