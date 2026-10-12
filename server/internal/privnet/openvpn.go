package privnet

import (
	"bufio"
	"errors"
	"fmt"
	"strings"
)

// OpenVPN is what agnts reads from an .ovpn file before running it.
type OpenVPN struct {
	Remotes []string // "host port" as written
	// NeedsAuth is set by auth-user-pass: a username and password go with
	// the config.
	NeedsAuth bool
	// HasDev is set when the config names its device; without one the
	// sidecar adds dev tun.
	HasDev bool
}

// forbiddenOpenVPN are directives that run programs, write files on the
// sidecar, or change how it runs. A config with any of them is refused;
// the sidecar also passes --script-security 1 after the config.
var forbiddenOpenVPN = map[string]bool{
	"up": true, "down": true, "route-up": true, "route-pre-down": true, "ipchange": true,
	"client-connect": true, "client-disconnect": true, "learn-address": true, "tls-verify": true,
	"auth-user-pass-verify": true, "script-security": true, "plugin": true, "management": true,
	"management-external-key": true, "log": true, "log-append": true, "status": true, "writepid": true,
	"config": true, "cd": true, "chroot": true, "daemon": true, "user": true, "group": true,
	"tmp-dir": true, "dev-node": true, "iproute": true, "setenv": true, "setenv-safe": true,
	"pkcs11-providers": true, "askpass": true, "auth-gen-token-secret": true, "mlock": true,
	"echo": true, "service": true, "dhcp-renew": true, "dhcp-release": true, "register-dns": true,
	"providers": true, "engine": true,
}

// ParseOpenVPN checks a client config. Certificates and keys must be
// inline (<ca>, <cert>, <key>, <tls-auth>...): there are no files beside it.
func ParseOpenVPN(text string) (OpenVPN, error) {
	var o OpenVPN
	if strings.TrimSpace(text) == "" {
		return o, errors.New("the config is empty")
	}
	sc := bufio.NewScanner(strings.NewReader(text))
	sc.Buffer(make([]byte, 64<<10), 1<<20)
	inline := ""
	line := 0
	client, dev := false, ""
	for sc.Scan() {
		line++
		l := strings.TrimSpace(sc.Text())
		if inline != "" {
			if strings.EqualFold(l, "</"+inline+">") {
				inline = ""
			}
			continue
		}
		if l == "" || l[0] == '#' || l[0] == ';' {
			continue
		}
		if strings.HasPrefix(l, "<") && strings.HasSuffix(l, ">") && !strings.HasPrefix(l, "</") {
			inline = strings.ToLower(strings.Trim(l, "<>"))
			continue
		}
		fields := strings.Fields(l)
		name := strings.ToLower(strings.TrimPrefix(fields[0], "--"))
		// "setenv opt X" only marks X optional (pfSense and Access Server
		// exports carry setenv opt block-outside-dns); other setenv lines
		// feed scripts, which never run here, but are refused all the same.
		if name == "setenv" && len(fields) > 1 && strings.EqualFold(fields[1], "opt") {
			continue
		}
		if forbiddenOpenVPN[name] {
			return o, fmt.Errorf("line %d: %q is not allowed (it runs programs or writes files)", line, name)
		}
		switch name {
		case "client", "pull", "tls-client":
			client = true
		case "dev":
			if len(fields) > 1 {
				dev = strings.ToLower(fields[1])
			}
		case "remote":
			if len(fields) < 2 {
				return o, fmt.Errorf("line %d: remote needs a host", line)
			}
			o.Remotes = append(o.Remotes, strings.Join(fields[1:min(len(fields), 3)], " "))
		case "auth-user-pass":
			if len(fields) > 1 {
				return o, fmt.Errorf("line %d: auth-user-pass must not name a file: enter the username and password in agnts", line)
			}
			o.NeedsAuth = true
		case "ca", "cert", "key", "tls-auth", "tls-crypt", "tls-crypt-v2", "pkcs12", "secret", "crl-verify", "extra-certs", "http-proxy-user-pass":
			// The inline form is <ca>...</ca>; a file name points outside the config.
			if len(fields) > 1 && fields[1] != "[inline]" {
				return o, fmt.Errorf("line %d: %s names a file: paste it inline as <%s>...</%s>", line, name, name, name)
			}
		}
	}
	if inline != "" {
		return o, fmt.Errorf("<%s> is not closed", inline)
	}
	if len(o.Remotes) == 0 {
		return o, errors.New("the config has no remote")
	}
	if !client {
		return o, errors.New("this is not a client config (no client or pull line)")
	}
	if dev != "" && !strings.HasPrefix(dev, "tun") {
		return o, fmt.Errorf("dev %s is not supported: agnts runs routed VPNs (dev tun)", dev)
	}
	o.HasDev = dev != ""
	return o, nil
}

// Summary describes the config: "remote vpn.corp.com 1194".
func (o OpenVPN) Summary() string {
	s := "remote " + strings.Join(o.Remotes, ", ")
	if o.NeedsAuth {
		s += " · username and password"
	}
	return s
}
