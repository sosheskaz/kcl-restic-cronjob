_labels = {
    "app.kubernetes.io/name": _input.name
    "app.kubernetes.io/component": "restic"
} | {k = v for k, v in _input.extra_labels}
