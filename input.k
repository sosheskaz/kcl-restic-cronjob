import k8s.api.core.v1 as corev1

schema Input:
    # used globally for all resources
    name: str
    namespace?: str
    extra_labels: {str:str} = {}
    # settings that impact the cronjob directly
    cronjob: CronjobSettings = CronjobSettings {}
    # Settings that affect the pod
    service_account?: str
    # Step options — enable/disable various steps.
    enable_check: bool = True
    enable_backup: bool = True
    enable_forget: bool = True
    enable_prune: bool = True
    enable_post_check: bool = False
    # Restic settings for all steps
    restic: ResticOptions
    # Restic Cache settings — by default, a PVC is created for the cache to persist between runs.
    cache: CacheOptions = CacheOptions {}
    # Any extra volumes you'd like to add to all steps.
    volumes: [corev1.Volume] = []
    volume_mounts: [corev1.VolumeMount] = []
    # Hooks — these are containers that run before/after various steps.
    # hooks that run before anything else
    pre_exec_hooks: [corev1.Container] = []
    # hooks that run after everything else
    post_exec_hooks: [corev1.Container] = []
    # hooks that run before the backup
    pre_backup_hooks: [corev1.Container] = []
    # hooks that run after the backup
    post_backup_hooks: [corev1.Container] = []
    node_selector?: {str:str}

schema CacheOptions:
    # Size of the cache PVC in Gi
    size: int = 5

schema CronjobSettings:
    # When would you like it to run?
    schedule: str = "@daily"
    # In what timezone?
    timezone?: str
    # Suspend the cronjob
    suspend?: bool
    # Leave this alone
    concurrency_policy?: str = "Forbid"
    # Other misc CJ settings
    starting_deadline_seconds?: int
    failed_jobs_history_limit?: int
    successful_jobs_history_limit?: int

schema ResticOptions:
    # global opts
    image_repo: str = "docker.io/restic/restic"
    image_tag: str = "latest"
    image: str = image_repo + ":" + image_tag
    host?: str
    paths: [str] = ["/backup"]
    repo_pass_secret?: str
    repo_pass_secret_file: str = "repo-password"
    repo: str
    compression?: str
    # check opts
    read_data: bool = False
    extra_check_args: [str] = []
    # backup opts
    # no_scan makes sense in most programmatic use-cases, so it's enabled by default.
    no_scan: bool = True
    one_file_system: bool = False
    exclude: [str] = []
    exclude_file: [str] = []
    extra_backup_args: [str] = []
    read_concurrency?: int
    ignore_ctime: bool = False
    ignore_inode: bool = False
    # prune opts
    max_unused?: str
    prune_dry_run: bool = False
    extra_prune_args: [str] = []
    # forget opts
    keep_last?: int
    keep_hourly?: int
    keep_daily?: int
    keep_weekly?: int
    keep_monthly?: int
    keep_yearly?: int
    group_by?: str
    # This can be handy for safety
    forget_dry_run: bool = False
    extra_forget_args: [str] = []
