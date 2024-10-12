import k8s.api.core.v1 as corev1

env_config_name = _input.name + "-env"
_restic_host = _input.restic.host if _input.restic.host else _input.name
_secret_name = _input.restic.repo_pass_secret or _input.name
backup_env = corev1.ConfigMap {
    metadata: {
        name: env_config_name
        namespace: _input.namespace
        labels: _labels
    }
    data: {
        "RESTIC_REPOSITORY": _input.restic.repo
        "RESTIC_HOST": _input.restic.host if _input.restic.host != None else _input.name
        if _input.restic.read_concurrency:
            "RESTIC_READ_CONCURRENCY": str(_input.restic.read_concurrency)
        "RESTIC_PASSWORD_FILE": _secret_volume_mount.mountPath + "/" + _input.restic.repo_pass_secret_file
        if _input.restic.compression:
            "RESTIC_COMPRESSION": _input.restic.compression
    }
}
