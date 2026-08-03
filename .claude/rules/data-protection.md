# Data Protection (GDPR/CCPA)

Applies to: backend code handling customer or user PII (names, emails, phone numbers, addresses, etc.).

<!-- Remove this file (and its CLAUDE.md reference) if the project stores no personal data. -->
<!-- Replace the placeholder service/file names with your project's actual implementations. -->

## PII Handling

- **Always encrypt PII at rest** — never store plaintext names, emails, or phone numbers in the database
- **Column naming:** encrypted values use `_encrypted` suffix, blind indexes use `_index` suffix (e.g., `email_encrypted`, `email_index`)
- **Searchable fields require blind indexes** — store an HMAC-SHA256 blind index alongside the ciphertext and query by the `_index` column
- **Non-searchable fields** (e.g., phone numbers) may be encrypted without a blind index
- **Nullable PII fields must preserve nulls** — never encrypt a null/absent value into non-null ciphertext
- **Never compare plaintext to find encrypted records** — generate a blind index and query by the `_index` column
- **Decrypt the minimum** — list endpoints should decrypt only the fields the UI actually displays, and soft-fail to null on undecryptable ciphertext. Any exception (e.g., showing customer names in a list view) needs explicit sign-off — do not copy an approved exception into new endpoints without the same sign-off.
- **Addresses may use hybrid encryption** — encrypt the precise, premises-identifying fields (street lines, latitude/longitude) and keep coarse geography plaintext (city, region, postal code, country) when it is needed for region/shipping queries. Document the split.

## Logging & Monitoring

- **Never log plaintext PII** — not in request logs, error messages, or debug output
- **Scrub error-monitoring events** (e.g., a Sentry `beforeSend` hook) — when adding new PII fields, verify the scrubber patterns cover them
- **Log redaction:** use `[REDACTED_EMAIL]` / `[REDACTED_TOKEN]` placeholders when PII must appear in log context

## Data Subject Rights (GDPR Art. 15–17)

- **Route all new PII fields through the DSR processor** — it must support access (export) and erasure (deletion) requests
- **Access requests** must return all stored PII for a data subject in decrypted form
- **Erasure requests** must delete or nullify all PII for a data subject — verify no orphaned references remain
- **Audit logging is required** — all access and erasure operations must be logged for compliance evidence
- **Maintain a PII column registry** — a typed catalog of every PII column and its DSR treatment, with a guard test that reconciles the registry against the database schema so a new `*_encrypted`/`*_index` column cannot ship unclassified
- **Secrets are NOT PII** — a machine secret (e.g., a third-party access token) is encrypted but has no DSR path. Classify it in a separate secret registry, never the PII registry, so every encrypted column is provably **either** PII **or** a registered secret
- **Every JSON column needs a documented contract** — track whether each JSON blob can contain PII and reconcile the contracts against the schema in the guard test. A new JSON column without a contract turns the build red.
- **Free-text fields ARE PII** — comments, notes, and narrative fields can contain anything the user typed. Export them on access requests and scrub them on erasure.

## Data Retention

- **No unbounded PII storage** — every PII-bearing table must have a documented retention policy
- **TTL required on caches and queues** holding PII — never cache decrypted PII indefinitely
- **Soft-deleted records** containing PII must still be purged after the retention period

## Source of Truth

<!-- Replace with your project's actual files. Example:
| File | Purpose |
|------|---------|
| `src/crypto/PiiEncryptionService.ts` | Encryption + HMAC blind indexes |
| `src/crypto/piiColumnRegistry.ts` | Typed catalog of every PII column + its DSR treatment |
| `src/crypto/secretColumnRegistry.ts` | Typed catalog of every non-PII secret column |
| `src/crypto/__tests__/dsrCoverage.guard.test.ts` | Schema-derived guard: PII/secret reconciliation |
| `src/monitoring/piiScrubber.ts` | Error-monitoring PII redaction |
| `src/processors/DataSubjectRequestProcessor.ts` | GDPR access & erasure request handling |
-->
