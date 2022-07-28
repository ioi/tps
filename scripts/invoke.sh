#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"


function usage {
	errcho -ne "\
Usage:
  tps invoke [options] <solution-path>

Description:
  Invokes a solution against the (already generated) test cases.

Options:
\
  -h, --help
\tShows this help.
\
  -s, --sensitive
\tTerminates on the first error and shows the error details.
\
  -w, --warning-sensitive
\tTerminates on the first warning or error and shows the details.
\
  -r, --show-reason
\tDisplays the reason for not being correct.
\tThe checker message is written in the case of wrong answer.
\
  -t, --test=<test-name-pattern>
\tInvokes only tests matching the given pattern. Examples: 1-01, '1-*', '1-0?'
\tMultiple patterns can be given using commas or pipes. Examples: '1-01, 2-*', '?-01|*2|0-*'
\tNote: Use quotation marks or escaping (with '\\') when using wildcards in the pattern to prevent shell expansion.
\t      Also, use escaping (with '\\') when separating multiple patterns using pipes.
\
      --tests-dir=<tests-directory-path>
\tOverrides the location of the tests directory
\
      --no-check
\tSkips running the checker on solution outputs.
\
      --no-sol-compile
\tSkips compiling the solution.
\tUses the solution already compiled and available in the sandbox.
\
      --no-tle
\tRemoves the default time limit on the execution of the solution.
\tActually, a limit of 24 hours is applied.
\
      --time-limit=<time-limit>
\tOverrides the (soft) time limit on the solution execution.
\tGiven in seconds, e.g. --time-limit=1.2 means 1.2 seconds
\
      --hard-time-limit=<hard-time-limit>
\tSolution process will be killed after <hard-time-limit> seconds.
\tDefaults to <time-limit> + 2.
\tNote: The hard time limit must be greater than the (soft) time limit.
"
}


tests_dir="${TESTS_DIR}"
SHOW_REASON="false"
SENSITIVE_RUN="false"
WARNING_SENSITIVE_RUN="false"
SPECIFIC_TESTS="false"
SPECIFIED_TESTS_PATTERN=""
SKIP_CHECK="false"
skip_compile_sol="false"


function handle_option {
	local -r curr_arg="$1"; shift
	case "${curr_arg}" in
		-h|--help)
			usage_exit 0
			;;
		-s|--sensitive)
			SENSITIVE_RUN="true"
			;;
		-w|--warning-sensitive)
			SENSITIVE_RUN="true"
			WARNING_SENSITIVE_RUN="true"
			;;
		-r|--show-reason)
			SHOW_REASON="true"
			;;
		-t|--test=*)
			fetch_nonempty_arg_value "SPECIFIED_TESTS_PATTERN" "-t" "--test" "test name pattern"
			SPECIFIC_TESTS="true"
			;;
		--tests-dir=*)
			fetch_nonempty_arg_value "tests_dir" "-@" "--tests-dir" "tests directory path"
			;;
		--no-check)
			SKIP_CHECK="true"
			;;
		--no-sol-compile)
			skip_compile_sol="true"
			;;
		--no-tle)
			SOFT_TL=$((24*60*60))
			;;
		--time-limit=*)
			fetch_nonempty_arg_value "SOFT_TL" "-@" "--time-limit" "soft time limit"
			;;
		--hard-time-limit=*)
			fetch_nonempty_arg_value "HARD_TL" "-@" "--hard-time-limit" "hard time limit"
			;;
		*)
			invalid_arg_with_usage "${curr_arg}" "undefined option"
			;;
	esac
}

function handle_positional_arg {
	local -r curr_arg="$1"; shift
	if variable_not_exists "solution" ; then
		solution="${curr_arg}"
		return
	fi
	invalid_arg_with_usage "${curr_arg}" "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "invalid_arg_with_usage" "$@"

if variable_not_exists "solution" ; then
	error_usage_exit 2 "Solution is not specified."
fi

if ! is_windows && ! "${PYTHON}" -c "import psutil" &> "/dev/null"; then
	cerrcho error -n "Error: "
	errcho "Package 'psutil' is not installed."
	errcho "You can install it using:"
	errcho -e "\tpip install psutil"
	errcho "or:"
	errcho -e "\t${PYTHON} -m pip install psutil"
	exit 1
fi

if variable_not_exists "SOFT_TL" ; then
	SOFT_TL="$(get_time_limit)"
fi

if ! check_float "${SOFT_TL}"; then
	error_usage_exit 2 "Provided time limit '${SOFT_TL}' is not a positive real number."
fi

if variable_not_exists "HARD_TL" ; then
	HARD_TL="$("${PYTHON}" -c "print(${SOFT_TL} + 2)")"
fi

if ! check_float "${HARD_TL}"; then
	error_usage_exit 2 "Provided hard time limit '${HARD_TL}' is not a positive real number."
fi

if py_test "${HARD_TL} <= ${SOFT_TL}"; then
	error_usage_exit 2 "Provided hard time limit (${HARD_TL}) is not greater than the soft time limit (${SOFT_TL})."
fi

sensitive check_file_exists "Solution file" "${solution}"
sensitive check_directory_exists "Tests directory" "${tests_dir}"

export SHOW_REASON SENSITIVE_RUN WARNING_SENSITIVE_RUN SPECIFIC_TESTS SPECIFIED_TESTS_PATTERN SKIP_CHECK SOFT_TL HARD_TL


recreate_dir "${LOGS_DIR}"

export STATUS_PAD=20

printf "%-${STATUS_PAD}scompile" "solution"
if "${skip_compile_sol}"; then
	echo_status "SKIP"
else
	sensitive reporting_guard "solution.compile" bash "${INTERNALS}/compile_solution.sh" "${solution}"
fi
echo

if "${HAS_CHECKER}"; then
	printf "%-${STATUS_PAD}scompile" "checker"
	if "${SKIP_CHECK}"; then
		echo_status "SKIP"
	else
		sensitive reporting_guard "checker.compile" build_with_make "${CHECKER_DIR}"
	fi
	echo
fi

ret=0
"${PYTHON}" "${INTERNALS}/invoke.py" "${tests_dir}" "${solution}" || ret=$?


echo

if [ ${ret} -eq 0 ]; then
	cecho success "Finished."
else
	cecho fail "Terminated."
fi

exit ${ret}
