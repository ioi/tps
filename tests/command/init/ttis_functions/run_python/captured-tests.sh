# Do not edit this file manually. It is automatically generated.
# Edit 'capture-all.sh' instead.


source ../../definitions.sh
source ../definitions.sh
source definitions.sh

_TT_check_stage_not_in_a_tps_repo

unset PYTHON

stage_dir stage
expect_exec -oempty -e "captured-data/k-0/stderr" -r 2 run_init_run_python

stage_dir stage
expect_exec -oempty -e "captured-data/k-1/stderr" -r 2 run_init_run_python -- abc

stage_dir stage
expect_exec -oempty -e "captured-data/k-2/stderr" -r 2 run_init_run_python my_prog

stage_dir stage
expect_exec -oempty -e "captured-data/k-3/stderr" -r 2 run_init_run_python my_prog -- abc

stage_dir stage
expect_exec -oh3 "This is 'python3'." "#args: 0" "args:" -eempty run_init_run_python python3

stage_dir stage
expect_exec -oh3 "This is 'python3'." "#args: 1" "args: abc" -eempty run_init_run_python python3 -- abc

stage_dir stage
expect_exec -oh3 "This is 'python3'." "#args: 0" "args:" -eempty run_init_run_python python3 my_prog

stage_dir stage
expect_exec -oh3 "This is 'python3'." "#args: 1" "args: abc" -eempty run_init_run_python python3 my_prog -- abc

stage_dir stage
expect_exec -oh3 "This is 'python'." "#args: 0" "args:" -eempty run_init_run_python python

stage_dir stage
expect_exec -oh3 "This is 'python'." "#args: 1" "args: abc" -eempty run_init_run_python python -- abc

stage_dir stage
expect_exec -oh3 "This is 'python'." "#args: 0" "args:" -eempty run_init_run_python python my_prog

stage_dir stage
expect_exec -oh3 "This is 'python'." "#args: 1" "args: abc" -eempty run_init_run_python python my_prog -- abc

stage_dir stage
expect_exec -oh3 "This is 'python3'." "#args: 0" "args:" -eempty run_init_run_python python python3

stage_dir stage
expect_exec -oh3 "This is 'python3'." "#args: 1" "args: abc" -eempty run_init_run_python python python3 -- abc

stage_dir stage
expect_exec -oh3 "This is 'python3'." "#args: 0" "args:" -eempty run_init_run_python python python3 my_prog

stage_dir stage
expect_exec -oh3 "This is 'python3'." "#args: 1" "args: abc" -eempty run_init_run_python python python3 my_prog -- abc

export PYTHON=my_prog

stage_dir stage
expect_exec -oempty -eh "Error: Python command 'my_prog' set by environment variable 'PYTHON' does not exist." -r 2 run_init_run_python

stage_dir stage
expect_exec -oempty -eh "Error: Python command 'my_prog' set by environment variable 'PYTHON' does not exist." -r 2 run_init_run_python -- abc

stage_dir stage
expect_exec -oh3 "This is 'my_prog'." "#args: 0" "args:" -eempty run_init_run_python my_prog

stage_dir stage
expect_exec -oh3 "This is 'my_prog'." "#args: 1" "args: abc" -eempty run_init_run_python my_prog -- abc

stage_dir stage
expect_exec -oempty -eh "Error: Python command 'my_prog' set by environment variable 'PYTHON' does not exist." -r 2 run_init_run_python python3

stage_dir stage
expect_exec -oempty -eh "Error: Python command 'my_prog' set by environment variable 'PYTHON' does not exist." -r 2 run_init_run_python python3 -- abc

stage_dir stage
expect_exec -oh3 "This is 'my_prog'." "#args: 0" "args:" -eempty run_init_run_python python3 my_prog

stage_dir stage
expect_exec -oh3 "This is 'my_prog'." "#args: 1" "args: abc" -eempty run_init_run_python python3 my_prog -- abc

stage_dir stage
expect_exec -oempty -eh "Error: Python command 'my_prog' set by environment variable 'PYTHON' does not exist." -r 2 run_init_run_python python

stage_dir stage
expect_exec -oempty -eh "Error: Python command 'my_prog' set by environment variable 'PYTHON' does not exist." -r 2 run_init_run_python python -- abc

stage_dir stage
expect_exec -oh3 "This is 'my_prog'." "#args: 0" "args:" -eempty run_init_run_python python my_prog

stage_dir stage
expect_exec -oh3 "This is 'my_prog'." "#args: 1" "args: abc" -eempty run_init_run_python python my_prog -- abc

stage_dir stage
expect_exec -oempty -eh "Error: Python command 'my_prog' set by environment variable 'PYTHON' does not exist." -r 2 run_init_run_python python python3

stage_dir stage
expect_exec -oempty -eh "Error: Python command 'my_prog' set by environment variable 'PYTHON' does not exist." -r 2 run_init_run_python python python3 -- abc

stage_dir stage
expect_exec -oh3 "This is 'my_prog'." "#args: 0" "args:" -eempty run_init_run_python python python3 my_prog

stage_dir stage
expect_exec -oh3 "This is 'my_prog'." "#args: 1" "args: abc" -eempty run_init_run_python python python3 my_prog -- abc
