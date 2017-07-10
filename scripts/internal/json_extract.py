import sys

from util import load_json


def usage():
    sys.stderr.write('Usage: python json_extract.py <json-file> <json-path>\n')
    exit(2)


def navigate_json(data, path):
    for part in path.split('/'):
        if part == '.':
            continue
        try:
            if isinstance(data, dict):
                data = data[part]
            elif isinstance(data, list):
                data = data[int(part)]
            else:
                raise KeyError
        except (KeyError, IndexError):
            sys.stderr.write("Requested key '%s' not found in '%s'\n" % (path, json_file))
            exit(4)
    return data


def navigate_json_file(file, path):
    return navigate_json(load_json(file), path)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        usage()

    json_file = sys.argv[1]
    json_path = sys.argv[2]

    result = navigate_json_file(json_file, json_path)

    if isinstance(result, dict):
        for key in result.keys():
            print(key)
    elif isinstance(result, list):
        for item in result:
            print(item)
    else:
        print(result)