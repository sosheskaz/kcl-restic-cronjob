# KCL Restic CronJob

This KCL Module can generate a Kubernetes CronJob and some associated components from a (relatively)
reduced configuration file. Works well with Kustomize.

The module can be run with e.g.

```
kcl run oci://ghcr.io/sosheskaz/kcl-restic-cronjob/kcl-restic-cronjob -D input.yaml
```

Where `input.yaml` is a custom input file. Some sample configurations can be found in
[`samples`](./samples/).

Documentation of the types and their fields can be found at [docs/kcl-restic-cronjob.md](docs/kcl-restic-cronjob.md#input).

## Sourcing the repository URL from a Secret

`restic.repo` is optional. Set **exactly one** non-empty value: either
`restic.repo` (plaintext, rendered into the generated ConfigMap) or
`restic.repo_secret_file`. Setting both, or neither, is a hard error. (Validation
is truthiness-based, so an empty string counts as unset.)

`repo_secret_file` names the key inside the mounted Secret that holds the
repository URL, e.g. `"repository"`. That Secret is the one named by
`restic.repo_pass_secret`, or — when `repo_pass_secret` is unset — a Secret named
after the app's `name`. This mirrors how `repo_pass_secret_file` sources
`RESTIC_PASSWORD_FILE`: the value is mounted at `/secret/<repo_secret_file>` and
referenced via `RESTIC_REPOSITORY_FILE`, so a `rest:` backend's embedded
`user:pass@host` never appears in plaintext. When using `repo_secret_file`, the
referenced Secret must carry both the password key (`repo-password` by default,
per `repo_pass_secret_file`) and the repository-URL key (e.g. `repository`).
