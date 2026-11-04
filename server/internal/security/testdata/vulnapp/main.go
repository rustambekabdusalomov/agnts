// Command vulnapp is agnts's security test fixture: a small app with
// known weaknesses that a security scan must find. Never deploy it.
package main

import (
	"database/sql"
	"log"
	"net/http"

	"example.com/vulnapp/handlers"
)

func main() {
	db, err := sql.Open("postgres", "postgres://localhost/vulnapp")
	if err != nil {
		log.Fatal(err)
	}
	h := &handlers.Orders{DB: db}
	http.HandleFunc("/api/orders", h.Search)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
