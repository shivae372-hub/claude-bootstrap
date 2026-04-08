# Java Stack — Bootstrap Configuration

## Detection
- `pom.xml` (Maven) or `build.gradle` / `build.gradle.kts` (Gradle)

## Key Commands
```yaml
# Maven
install_cmd: "mvn dependency:resolve"
dev_cmd: "mvn spring-boot:run"
test_cmd: "mvn test"
build_cmd: "mvn package -DskipTests"
format_cmd: "mvn spotless:apply"

# Gradle
install_cmd: "gradle dependencies"
dev_cmd: "./gradlew bootRun"
test_cmd: "./gradlew test"
build_cmd: "./gradlew build"
format_cmd: "./gradlew spotlessApply"
```

## Common Frameworks
- **Spring Boot** — `spring-boot-starter` in pom.xml/build.gradle
- **Quarkus** — `quarkus` in pom.xml
- **Micronaut** — `micronaut` in pom.xml
- **Jakarta EE** — `jakarta.ee` dependencies

## Recommended Agent Set
- explore (Haiku) — Java package structure, Spring annotation awareness
- test-runner (Haiku) — JUnit/TestNG runner with report parsing
- code-reviewer (Sonnet) — Spring patterns, exception handling, thread safety

## Java-Specific Rules for CLAUDE.md
```
- Always check Java version: `java --version` (target: 21 LTS)
- Never catch generic `Exception` — catch specific exceptions
- Use constructor injection, not field injection (@Autowired on constructor)
- Run full test suite before any DB migration: `mvn test`
- Use `Optional<T>` instead of returning null
- Log with SLF4J — never use System.out.println in production
```
