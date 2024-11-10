import k8s.api.core.v1 as corev1

_secret_mount_name: str = "secret"
_secret_volume_mount = corev1.VolumeMount {
    name: _secret_mount_name
    mountPath: "/secret"
}

_secret_volume = corev1.Volume {
    name: _secret_mount_name
    secret: {
        secretName: _secret_name
        optional: True
    }
}

_restic_common_args: [str] = ["--cache-dir=" + _cache_volume_mount.mountPath]
_image: str = _input.restic.image
_restic_volume_mounts: [corev1.VolumeMount] = [
    _cache_volume_mount
    _secret_volume_mount
] + _input.volume_mounts
_restic_container = corev1.Container {
    name: "restic"
    image: _input.restic.image
    envFrom: [_backupEnvSource]
    volumeMounts: _restic_volume_mounts
}

_restic_check_container = _restic_container | {
    name = _restic_container.name + "-check"
    args = _restic_common_args + ["check"]
}
_restic_backup_container = _restic_container | {
    name = _restic_container.name + "-backup"
    args = _restic_common_args + [
        "backup"
        if _input.restic.no_scan:
            "--no-scan"
        if _input.restic.one_file_system:
            "--one-file-system"
        if _input.restic.ignore_inode:
            "--ignore-inode"
        if _input.restic.ignore_ctime:
            "--ignore-ctime"
        *_input.restic.paths
    ]
}
_restic_prune_container = _restic_check_container | {
    name = _restic_container.name + "-prune"
    args = _restic_common_args + [
        "prune"
        if _input.restic.max_unused:
            "--max-unused=" + _input.restic.max_unused
        if _input.restic.prune_dry_run:
            "--dry-run"
        *_input.restic.extra_prune_args
    ]
}
_restic_forget_container = _restic_container | {
    name = _restic_container.name + "-forget"
    args = _restic_common_args + [
        "forget"
        if _input.restic.group_by:
            "--group-by=" + _input.restic.group_by
        if _input.restic.keep_last:
            "--keep-last=" + str(_input.restic.keep_last)
        if _input.restic.keep_hourly:
            "--keep-hourly=" + str(_input.restic.keep_hourly)
        if _input.restic.keep_daily:
            "--keep-daily=" + str(_input.restic.keep_daily)
        if _input.restic.keep_weekly:
            "--keep-weekly=" + str(_input.restic.keep_weekly)
        if _input.restic.keep_monthly:
            "--keep-monthly=" + str(_input.restic.keep_monthly)
        if _input.restic.keep_yearly:
            "--keep-yearly=" + str(_input.restic.keep_yearly)
        if _input.restic.forget_dry_run:
            "--dry-run"
        *_input.restic.extra_forget_args
    ]
}
