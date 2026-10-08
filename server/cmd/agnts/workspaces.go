package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"strconv"
	"text/tabwriter"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// cliWorkspace returns ctx acting in the workspace the CLI was pointed at:
// --workspace <slug> (taken out of args), else AGNTS_WORKSPACE, else the
// install's default workspace.
func cliWorkspace(ctx context.Context, pool postgresPool, args []string) (context.Context, domain.Workspace, []string, error) {
	slug := os.Getenv("AGNTS_WORKSPACE")
	var rest []string
	for i := 0; i < len(args); i++ {
		switch a := args[i]; {
		case a == "--workspace" || a == "-w":
			if i+1 >= len(args) {
				return ctx, domain.Workspace{}, nil, errors.New("--workspace needs a slug")
			}
			slug = args[i+1]
			i++
		case len(a) > 12 && a[:12] == "--workspace=":
			slug = a[12:]
		default:
			rest = append(rest, a)
		}
	}
	ws := postgres.NewWorkspaces(pool)
	sys := domain.System(ctx)
	var w domain.Workspace
	var err error
	if slug != "" {
		w, err = ws.BySlug(sys, slug)
	} else {
		w, err = ws.Default(sys)
	}
	if errors.Is(err, domain.ErrNotFound) {
		if slug != "" {
			return ctx, w, nil, fmt.Errorf("no workspace %q (see agnts workspace list)", slug)
		}
		return ctx, w, nil, errors.New("there is no workspace yet: create a user first (agnts user create <name>)")
	}
	if err != nil {
		return ctx, w, nil, err
	}
	return domain.WithWorkspace(ctx, w.ID), w, rest, nil
}

// workspaceCmd manages workspaces (the platform's Admin tasks).
func workspaceCmd(ctx context.Context, pool postgresPool, args []string, out io.Writer) error {
	ws := postgres.NewWorkspaces(pool)
	users := postgres.NewUsers(pool)
	sys := domain.System(ctx)
	usage := errors.New("usage: agnts workspace list | create <name> --owner <username> | slots <slug> <n> | members <slug> <limit> | suspend <slug> | resume <slug>")
	if len(args) == 0 {
		return usage
	}
	byslug := func(slug string) (domain.Workspace, error) {
		w, err := ws.BySlug(sys, slug)
		if errors.Is(err, domain.ErrNotFound) {
			return w, fmt.Errorf("no workspace %q", slug)
		}
		return w, err
	}
	switch args[0] {
	case "list":
		list, err := ws.List(sys, false)
		if err != nil {
			return err
		}
		tw := tabwriter.NewWriter(out, 0, 4, 2, ' ', 0)
		_, _ = fmt.Fprintln(tw, "ID\tSLUG\tNAME\tPLAN\tSLOTS\tMEMBERS\tCREDITS\tSTATE")
		for _, w := range list {
			state := "active"
			if w.SuspendedAt != nil {
				state = "suspended"
			}
			_, _ = fmt.Fprintf(tw, "%d\t%s\t%s\t%s\t%d\t%d\t%d\t%s\n", w.ID, w.Slug, w.Name, w.Plan, w.Slots, w.Members, w.CreditsBalance, state)
		}
		return tw.Flush()
	case "create":
		if len(args) != 4 || args[2] != "--owner" {
			return usage
		}
		u, err := users.ByUsername(ctx, args[3])
		if err != nil {
			return fmt.Errorf("no user %q", args[3])
		}
		w, err := ws.Create(ctx, postgres.NewWorkspace{Name: args[1], OwnerID: u.ID, Plan: "self-hosted", Slots: 1})
		if err != nil {
			return err
		}
		_, _ = fmt.Fprintf(out, "Created workspace %q (address %s), owned by %s.\n", w.Name, w.Slug, u.Username)
		return nil
	case "slots", "members":
		if len(args) != 3 {
			return usage
		}
		w, err := byslug(args[1])
		if err != nil {
			return err
		}
		n, err := strconv.Atoi(args[2])
		if err != nil || n < 0 || (args[0] == "slots" && (n < 1 || n > 50)) {
			return errors.New("give a number (slots: 1 to 50; members: 0 for no limit)")
		}
		p := postgres.PlanUpdate{Slots: &n}
		if args[0] == "members" {
			p = postgres.PlanUpdate{MemberLimit: &n}
		}
		if _, err := ws.SetPlan(sys, w.ID, p); err != nil {
			return err
		}
		_, _ = fmt.Fprintf(out, "%s: %s set to %d.\n", w.Slug, args[0], n)
		return nil
	case "suspend", "resume":
		if len(args) != 2 {
			return usage
		}
		w, err := byslug(args[1])
		if err != nil {
			return err
		}
		if _, err := ws.SetSuspended(sys, w.ID, args[0] == "suspend"); err != nil {
			return err
		}
		_, _ = fmt.Fprintf(out, "%s %sed.\n", w.Slug, args[0])
		return nil
	}
	return usage
}

// adminCmd grants or removes the system Admin role.
func adminCmd(ctx context.Context, pool postgresPool, args []string, out io.Writer) error {
	if len(args) != 2 || (args[0] != "grant" && args[0] != "revoke") {
		return errors.New("usage: agnts admin grant|revoke <username>")
	}
	users := postgres.NewUsers(pool)
	u, err := users.ByUsername(ctx, args[1])
	if err != nil {
		return fmt.Errorf("no user %q", args[1])
	}
	if err := users.SetAdmin(ctx, u.ID, args[0] == "grant"); err != nil {
		return err
	}
	_, _ = fmt.Fprintf(out, "%s is %s.\n", u.Username, map[bool]string{true: "an Admin now", false: "no longer an Admin"}[args[0] == "grant"])
	return nil
}

// creditsCmd grants credits to a workspace.
func creditsCmd(ctx context.Context, pool postgresPool, args []string, out io.Writer) error {
	if len(args) < 3 || args[0] != "grant" {
		return errors.New("usage: agnts credits grant <slug> <amount> [note]")
	}
	w, err := postgres.NewWorkspaces(pool).BySlug(domain.System(ctx), args[1])
	if err != nil {
		return fmt.Errorf("no workspace %q", args[1])
	}
	n, err := strconv.ParseInt(args[2], 10, 64)
	if err != nil || n == 0 {
		return errors.New("the amount is a whole number of credits (negative takes back)")
	}
	note := "granted from the CLI"
	if len(args) > 3 {
		note = args[3]
	}
	bal, err := postgres.NewCredits(pool).Add(domain.System(ctx), postgres.LedgerEntry{WorkspaceID: w.ID, Amount: n, Reason: postgres.CreditGrant, Note: note})
	if err != nil {
		return err
	}
	_, _ = fmt.Fprintf(out, "%s now has %d credits.\n", w.Slug, bal)
	return nil
}
