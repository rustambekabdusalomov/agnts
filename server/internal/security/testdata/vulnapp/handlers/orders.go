// Package handlers serves the fixture's API.
package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
)

// Orders serves order search.
type Orders struct {
	DB *sql.DB
}

// Search finds the caller's orders by a search term.
func (o *Orders) Search(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query().Get("q")
	// Deliberately vulnerable: the search term is concatenated into SQL.
	query := fmt.Sprintf("SELECT id, title FROM orders WHERE title LIKE '%%%s%%'", q)
	rows, err := o.DB.Query(query)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()
	var out []string
	for rows.Next() {
		var id int
		var title string
		if err := rows.Scan(&id, &title); err == nil {
			out = append(out, title)
		}
	}
	_ = json.NewEncoder(w).Encode(out)
}
