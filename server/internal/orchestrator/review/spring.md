# Spring Boot review checklist

- Transactions: `@Transactional` on public methods called from outside the bean (self-invocation skips the proxy); read-only where possible; no long remote calls inside a transaction.
- JPA: no N+1 (fetch joins or entity graphs); lazy collections not touched outside a transaction; entities not exposed directly as API responses; `equals`/`hashCode` safe for entities.
- Validation: `@Valid` on request bodies; constraint annotations on DTOs; errors mapped to 4xx by an exception handler.
- Security: endpoints covered by the security configuration (no accidental `permitAll`); method security where object ownership matters; no secrets in `application.yml`.
- Configuration: `@ConfigurationProperties` over scattered `@Value`; profiles do not leak dev settings to production.
- Beans: constructor injection; no field injection in new code; no circular dependencies.
- Migrations: Flyway/Liquibase scripts are new files, never edits of applied ones.
- Tests: slice tests (`@WebMvcTest`, `@DataJpaTest`) where enough; Testcontainers for DB behaviour.
