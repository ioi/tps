import sys
import os

from util import simple_usage_message, check_file_exists, load_json, log_warning
from json_extract import navigate_json


SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')


def get_test_subtasks_from_tests_dir(test_name, tests_dir):
    if not os.path.isdir(tests_dir):
        sys.stderr.write("Tests directory not found or not a valid directory: '{}'\n".format(tests_dir))
        sys.exit(3)
    MAPPING_FILE_NAME = os.environ.get('MAPPING_FILE_NAME')
    mapping_file = os.path.join(tests_dir, MAPPING_FILE_NAME)
    check_file_exists(mapping_file)
    with open(mapping_file, 'r') as f:
        subtask_test_relations = [tuple(line.split()) for line in f.readlines()]
    if not all(len(rel) == 2 for rel in subtask_test_relations):
        sys.stderr.write("Subtasks mapping file '{}' does not have the correct format.".format(mapping_file))
        sys.exit(3)
    return [
        rel_subtask
        for rel_subtask, rel_test_name in subtask_test_relations
        if rel_test_name == test_name
    ]


def get_test_validators(test_name, tests_dir):
    test_subtasks = get_test_subtasks_from_tests_dir(test_name, tests_dir)

    if len(test_subtasks) == 0:
        log_warning("Test '%s' is in no subtasks." % test_name)

    data = load_json(SUBTASKS_JSON)

    global_validators = data.get('global_validators', [])
    subtask_sensitive_validators = data.get('subtask_sensitive_validators', [])

    def check_subtask_sensitive_validators(subtask_sensitive_validators):
        subtask_placeholder_var = "subtask"
        subtask_placeholder_test_substitute = "___SUBTASK_PLACEHOLDER_SUBSTITUTE___"
        for subtask_sensitive_validator in subtask_sensitive_validators:
            try:
                subtask_validator_substituted = subtask_sensitive_validator.format(**{
                    subtask_placeholder_var : subtask_placeholder_test_substitute
                })
            except KeyError as e:
                sys.stderr.write('Subtask-sensitive validator "{}" contains unknown placeholder {{{}}}.\n'.format(subtask_sensitive_validator, e.args[0]))
                sys.exit(3)
            else:
                if subtask_placeholder_test_substitute not in subtask_validator_substituted:
                    log_warning('Subtask-sensitive validator "{}" does not contain the subtask placeholder {{{}}}.'.format(subtask_sensitive_validator, subtask_placeholder_var))
    check_subtask_sensitive_validators(subtask_sensitive_validators)

    test_validators = list(global_validators)
    for subtask in test_subtasks:
        test_validators += [validator.format(subtask=subtask) for validator in subtask_sensitive_validators]
        test_validators += navigate_json(data, 'subtasks/%s' % subtask, SUBTASKS_JSON).get('validators', [])

    if len(test_validators) == 0:
        log_warning("There is no validator for test {}.".format(test_name))

    def unify_list(l):
        seen = []
        for e in l:
            if e not in seen:
                seen.append(e)
        return seen

    return unify_list(test_validators)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        simple_usage_message("<test-name> <tests-dir>")

    for validator in get_test_validators(test_name=sys.argv[1], tests_dir=sys.argv[2]):
        print(validator)
