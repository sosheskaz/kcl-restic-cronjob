import file
import manifests
import yaml

# Mark: Variables
_input_file = option("input", 'str', True)
_raw_input = file.read(_input_file)
_input: Input = yaml.decode(_raw_input)

manifests.yaml_stream([backup_env, _cache_pvc, cj])
