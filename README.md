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
