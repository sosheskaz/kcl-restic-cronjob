import k8s.api.core.v1 as corev1
import units

_cache_pvc = corev1.PersistentVolumeClaim {
    metadata: {
        name: _input.name + "-restic-cache"
        namespace: _input.namespace
        labels: _labels
    }
    spec: {
        accessModes: ["ReadWriteOnce"]
        resources: {
            requests: {storage: units.to_Gi(_input.cache.size * units.Gi)}
        }
    }
}

_cache_mount_name = "cache"
_cache_volume_mount = corev1.VolumeMount {
    name: _cache_mount_name
    mountPath: "/cache"
}

_cache_volume = corev1.Volume {
    name: _cache_mount_name
    persistentVolumeClaim: {claimName: _cache_pvc.metadata.name}
}
