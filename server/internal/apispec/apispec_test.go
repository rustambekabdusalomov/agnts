package apispec

import (
	"encoding/json"
	"os"
	"strings"
	"testing"

	"agnts/internal/domain"
)

const swagger2 = `{
  "swagger": "2.0",
  "info": {"title": "Petstore", "version": "1.0"},
  "basePath": "/v2",
  "securityDefinitions": {"api_key": {"type": "apiKey", "name": "X-Api-Key", "in": "header"}},
  "security": [{"api_key": []}],
  "paths": {
    "/pets": {"get": {"operationId": "listPets", "tags": ["pets"], "responses": {"200": {"description": "ok", "schema": {"type": "array", "items": {"$ref": "#/definitions/Pet"}}}}}},
    "/pets/{id}": {"get": {"operationId": "getPet", "parameters": [{"name": "id", "in": "path", "required": true, "type": "integer"}],
      "responses": {"200": {"description": "ok", "schema": {"$ref": "#/definitions/Pet"}}, "404": {"description": "missing"}}}},
    "/auth/logout": {"get": {"responses": {"204": {"description": "bye"}}}},
    "/old": {"get": {"deprecated": true, "responses": {"200": {"description": "ok"}}}}
  },
  "definitions": {"Pet": {"type": "object", "required": ["id"], "properties": {"id": {"type": "integer"}, "name": {"type": "string"}}}}
}`

const openapi30 = `openapi: 3.0.3
info: {title: Shop, version: "2"}
servers:
  - url: https://{env}.shop.example/api
    variables:
      env: {default: prod, enum: [prod, staging]}
components:
  securitySchemes:
    bearer: {type: http, scheme: bearer}
  schemas:
    Order:
      type: object
      required: [id, total]
      properties:
        id: {type: integer}
        total: {type: number}
        customer: {$ref: '#/components/schemas/Customer'}
    Customer: {type: object, properties: {name: {type: string}}}
    Unused: {type: string}
security: [{bearer: []}]
paths:
  /orders:
    get:
      description: ` + "\"" + `long description that keeps going` + "\"" + `
      responses:
        "200":
          description: ok
          content:
            application/json:
              schema: {type: array, items: {$ref: '#/components/schemas/Order'}}
  /orders/{id}:
    parameters: [{name: id, in: path, required: true, schema: {type: integer}}]
    get:
      responses:
        "200": {description: ok, content: {application/json: {schema: {$ref: '#/components/schemas/Order'}}}}
        "404": {description: missing}
    delete:
      responses: {"204": {description: gone}}
`

func TestParseSwagger2(t *testing.T) {
	d, err := Parse([]byte(swagger2), "https://petstore.test/docs/swagger.json")
	if err != nil {
		t.Fatal(err)
	}
	if d.Title != "Petstore" || !strings.HasPrefix(d.Format, "swagger 2") {
		t.Errorf("%s %s", d.Title, d.Format)
	}
	if len(d.Servers) != 1 || d.Servers[0].URL != "https://petstore.test/v2" {
		t.Errorf("servers = %+v (no host: resolved against the spec URL)", d.Servers)
	}
	ops := map[string]Operation{}
	for _, o := range d.Operations {
		ops[o.Key()] = o
	}
	if len(ops) != 4 || !ops["GET /pets"].Default || ops["GET /auth/logout"].SideEffect != "logout" || ops["GET /auth/logout"].Default || ops["GET /old"].Default {
		t.Errorf("operations = %+v", d.Operations)
	}
	if len(d.SecuritySchemes) != 1 || d.SecuritySchemes[0].AuthKind != domain.AuthHeader || d.SecuritySchemes[0].Param != "X-Api-Key" {
		t.Errorf("schemes = %+v", d.SecuritySchemes)
	}
	if got := ops["GET /pets"].Security; len(got) != 1 || got[0] != "api_key" {
		t.Errorf("security = %v", got)
	}
	var v3 map[string]any
	if err := json.Unmarshal(d.JSON, &v3); err != nil || !strings.HasPrefix(v3["openapi"].(string), "3") {
		t.Errorf("not converted to OpenAPI 3: %v", err)
	}
}

func TestParseOpenAPI30YAML(t *testing.T) {
	d, err := Parse([]byte(openapi30), "https://docs.shop.example/openapi.yaml")
	if err != nil {
		t.Fatal(err)
	}
	if len(d.Servers) != 1 || d.Servers[0].URL != "https://prod.shop.example/api" || d.Servers[0].Variables[0].Name != "env" {
		t.Errorf("servers = %+v", d.Servers)
	}
	if len(d.Operations) != 3 || d.SecuritySchemes[0].AuthKind != domain.AuthBearer {
		t.Errorf("ops %d, schemes %+v", len(d.Operations), d.SecuritySchemes)
	}
}

func TestParseOpenAPI31(t *testing.T) {
	spec := `{"openapi":"3.1.0","info":{"title":"t","version":"1"},"servers":[{"url":"/api"}],
	"paths":{"/a":{"get":{"responses":{"200":{"description":"ok","content":{"application/json":{"schema":{"type":["string","null"]}}}}}}}}}`
	d, err := Parse([]byte(spec), "https://x.test/spec/openapi.json")
	if err != nil {
		t.Fatal(err)
	}
	if d.Servers[0].URL != "https://x.test/api" {
		t.Errorf("relative server = %s", d.Servers[0].URL)
	}
}

func TestParseOwnSpec(t *testing.T) {
	b, err := os.ReadFile("../../../shared/openapi/openapi.yaml")
	if err != nil {
		t.Skip(err)
	}
	d, err := Parse(b, "http://localhost:8080/openapi.yaml")
	if err != nil {
		t.Fatal(err)
	}
	if len(d.Operations) < 50 {
		t.Errorf("only %d operations", len(d.Operations))
	}
	trimmed, full, err := Trim(d.JSON, []string{"GET /tickets", "GET /tickets/{key}"}, TrimCap)
	if err != nil || full || len(trimmed) > TrimCap {
		t.Errorf("trim: %d bytes, full %v, %v", len(trimmed), full, err)
	}
}

func TestParseRefusals(t *testing.T) {
	ext := `{"openapi":"3.0.0","info":{"title":"t","version":"1"},"paths":{"/a":{"get":{"responses":{"200":{"description":"ok","content":{"application/json":{"schema":{"$ref":"https://evil.test/s.json#/X"}}}}}}}}}`
	if _, err := Parse([]byte(ext), ""); err == nil || !strings.Contains(err.Error(), "external") {
		t.Errorf("external ref: %v", err)
	}
	if _, err := Parse(make([]byte, MaxBytes+1), ""); err == nil {
		t.Error("a file over 5 MB")
	}
	if _, err := Parse([]byte(`{"hello":"world"}`), ""); err == nil {
		t.Error("not a spec")
	}
}

func TestTrim(t *testing.T) {
	d, err := Parse([]byte(openapi30), "")
	if err != nil {
		t.Fatal(err)
	}
	out, full, err := Trim(d.JSON, []string{"GET /orders/{id}"}, TrimCap)
	if err != nil || full {
		t.Fatal(err, full)
	}
	s := string(out)
	for _, want := range []string{`"Order"`, `"Customer"`, `"parameters"`, `"bearer"`} {
		if !strings.Contains(s, want) {
			t.Errorf("missing %s: %s", want, s)
		}
	}
	for _, not := range []string{`"Unused"`, `"delete"`, `"/orders":`} {
		if strings.Contains(s, not) {
			t.Errorf("kept %s: %s", not, s)
		}
	}
	list, full, err := Trim(d.JSON, []string{"GET /orders/{id}", "GET /orders"}, 100)
	if err != nil || !full || !strings.Contains(string(list), "agnts-api describe") || !strings.Contains(string(list), "GET /orders") {
		t.Errorf("over the cap: full %v %s", full, list)
	}
}

func TestCheck(t *testing.T) {
	d, err := Parse([]byte(openapi30), "")
	if err != nil {
		t.Fatal(err)
	}
	json := map[string]string{"Content-Type": "application/json"}
	log := []domain.APIExchange{
		{ID: "r-001", Method: "GET", URL: "http://203.0.113.7:8080/api/orders", Status: 200, RespHeaders: json, RespBody: `[{"id":1,"total":"12.50"}]`},
		{ID: "r-002", Method: "GET", URL: "http://203.0.113.7:8080/api/orders/1", Status: 200, RespHeaders: json, RespBody: `{"id":1,"total":12.5}`},
		{ID: "r-003", Method: "GET", URL: "http://203.0.113.7:8080/api/orders/99", Status: 500, RespHeaders: json, RespBody: `{}`},
		{ID: "r-004", Method: "GET", URL: "http://203.0.113.7:8080/api/nowhere", Status: 404},
		{ID: "r-005", Method: "GET", URL: "http://203.0.113.7:8080/api/orders/2", Error: "timeout"},
	}
	fs, err := Check(d.JSON, "http://203.0.113.7:8080/api", log)
	if err != nil {
		t.Fatal(err)
	}
	var got []string
	for _, f := range fs {
		got = append(got, f.Operation+" | "+f.Problem+" | "+strings.Join(f.Requests, ","))
	}
	all := strings.Join(got, "\n")
	if !strings.Contains(all, "GET /orders | ") || !strings.Contains(all, "r-001") {
		t.Errorf("total as a string was not caught (the spec's servers point at prod; the base URL must be used):\n%s", all)
	}
	if !strings.Contains(all, "status 500 is not documented") || !strings.Contains(all, "r-003") {
		t.Errorf("undocumented 500:\n%s", all)
	}
	if !strings.Contains(all, "matches no operation") || !strings.Contains(all, "r-004") {
		t.Errorf("no route:\n%s", all)
	}
	if strings.Contains(all, "r-002") || strings.Contains(all, "r-005") {
		t.Errorf("a valid response or a failed request was reported:\n%s", all)
	}
	cs := Cases(fs)
	if cs[0].Source != domain.CaseBySchema || cs[0].Verdict != domain.VerdictFail || cs[0].ID != "schema-1" {
		t.Errorf("%+v", cs[0])
	}
}
