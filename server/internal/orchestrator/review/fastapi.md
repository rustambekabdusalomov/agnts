# FastAPI review checklist

- Async: `async def` endpoints do not call blocking code (sync DB drivers, requests, heavy CPU); use `def` endpoints or run in a threadpool.
- Validation: request bodies, query and path params are typed Pydantic models/annotations; response models declared so internal fields do not leak.
- Dependencies: auth and DB sessions through `Depends`; sessions closed (yield dependencies); per-request state not stored globally.
- Errors: `HTTPException` with correct status codes; validation errors not turned into 500s; no stack traces in responses.
- Security: authorization checked per resource, not only authentication; CORS origins explicit; no secrets in OpenAPI examples.
- DB: no N+1 in list endpoints; transactions committed or rolled back explicitly.
- OpenAPI: operation ids and schemas stay compatible for existing clients.
- Tests: `TestClient`/`httpx.AsyncClient` with dependency overrides; no real network.
