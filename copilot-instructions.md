Copilot instructions - ebms-docker

Scope

- Applies to files under ebms-docker/.
- Contains Dockerfiles, image scripts, and compose-based runtime examples.

Validation

- Syntax-check compose files before proposing changes.
- Keep image tags, architecture variants, and script usage aligned.
- Prefer minimal, explicit environment changes in compose files.

High-impact change rules

- If changing image build scripts, verify amd64/arm64 flows remain consistent.
- If changing demo compose setup, update matching README instructions.
- Do not introduce breaking port or volume changes without documenting migration.

Review checklist

- Include exact docker or compose commands used for validation.
- Call out runtime assumptions (certs, ports, mounted files, env vars).
- Avoid hidden behavior in shell scripts; prefer clear arguments and defaults.
