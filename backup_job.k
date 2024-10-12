import k8s.api.batch.v1 as batchv1
import k8s.api.core.v1 as corev1

_backupEnvSource: corev1.EnvFromSource = {
    configMapRef: {name: backup_env.metadata.name}
}
_backup_containers_base: [corev1.Container] = [
    *[_restic_container | {k = v for k, v in hook} for hook in _input.pre_exec_hooks]
    if _input.enable_check:
        _restic_check_container
    *[_restic_container | {k = v for k, v in hook} for hook in _input.pre_backup_hooks]
    if _input.enable_backup:
        _restic_backup_container
    *[_restic_container | {k = v for k, v in hook} for hook in _input.post_backup_hooks]
    if _input.enable_forget:
        _restic_forget_container
    if _input.enable_prune:
        _restic_prune_container
    if _input.enable_post_check:
        _restic_check_container
    *[_restic_container | {k = v for k, v in hook} for hook in _input.post_exec_hooks]
]
_backup_containers_enumerated = [_backup_containers_base[i] | {name = str(i) + "-" + _backup_containers_base[i].name} for i in range(len(_backup_containers_base))]
cj = batchv1.CronJob {
    metadata: {
        name: _input.name + "-restic"
        namespace: _input.namespace
        labels: _labels
    }
    spec: {
        schedule: _input.cronjob.schedule
        concurrencyPolicy: _input.cronjob.concurrency_policy
        timeZone: _input.cronjob.timezone
        suspend: _input.cronjob.suspend
        startingDeadlineSeconds: _input.cronjob.starting_deadline_seconds
        failedJobsHistoryLimit: _input.cronjob.failed_jobs_history_limit
        successfulJobsHistoryLimit: _input.cronjob.successful_jobs_history_limit
        jobTemplate: {
            spec: {
                template: {
                    metadata: {labels: _labels}
                    spec: {
                        serviceAccountName: _input.service_account
                        initContainers: _backup_containers_enumerated[:-1:]
                        containers: [_backup_containers_enumerated[-1]]
                        restartPolicy: "Never"
                        volumes: [
                            {
                                name: "cache"
                                persistentVolumeClaim: {claimName: _cache_pvc.metadata.name}
                            }
                            {
                                name: "secret"
                                secret: {
                                    secretName: _secret_name
                                    optional: True
                                }
                            }
                        ] + _input.volumes
                        nodeSelector: _input.node_selector
                    }
                }
            }
        }
    }
}
