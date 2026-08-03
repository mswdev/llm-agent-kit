# Security

## Security Rules

- **NEVER hardcode secrets in source code**
- **NEVER run destructive DB operations** (DROP, TRUNCATE, DELETE without WHERE)
- **Validate all API input** — NEVER TRUST CLIENT INPUT (use Joi, Zod, or equivalent)
- **Flag security concerns proactively** — exposed secrets, SQL injection, missing auth, XSS, CSRF, etc.
- **ALL MONETARY VALUES ARE IN CENTS** (integers), never floating-point dollars — prevents rounding vulnerabilities
