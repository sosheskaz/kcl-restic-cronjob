_labels = {
    "app.kubernetes.io/name": _input.name
    "app.kubernetes.io/component": "restic"
    if _input.restic_family:
        "restic-family": _input.restic_family
} | {k = v for k, v in _input.extra_labels}
