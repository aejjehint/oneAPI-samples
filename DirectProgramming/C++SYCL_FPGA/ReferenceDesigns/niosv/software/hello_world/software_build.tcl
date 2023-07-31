#  Copyright (c) 2022 Intel Corporation
#  SPDX-License-Identifier: MIT

# Author:       whitepau
# Date:         2023-06-13

# Description:  This script will create and generate the application and BSPs in
#               the software directory, build the software, generate the memory
#               initialization file.  Ensure this script is in the software
#               directory under the Quartus project.  This script will *only*
#               build Nios V HAL programs. To use this script in your own
#               project change the variables below (hardware/software locations
#               and simulation settings)

# Usage:        Run "sh software_build.sh" from the Nios V command shell
#               (ensures Nios V environment is setup correctly first)

# Todo:
#  1)  Add additional BSP flags to control which memory is populated and other
#      settings
#  2)  Add -h argument to list out usage and other helpful info
#  3)  Create a simulation script that will copy hex file over, ld_debug,
#      etc.... (this can be a .tcl file that Questa can consume)

# Hardware locations:  change these to point at the Quartus and Platform
# Designer project files, if using relative paths base them from the /software
# directory
set QPF_FILE  "../../test_system.qpf"
set QSYS_FILE "../../pd_system.qsys"

# Software locations:  change these to point at the appropriate application,
# BSP, and source file directories
set APP_DIR       "./app"
set APP_BUILD_DIR "$APP_DIR/build"
set BSP_DIR       "./bsp"
set SRC_DIR       "./src"
set ELF_FILE      "hello_world.elf"

# Simulation settings:  change this to whatever the on-chip RAM is expecting to
# be initialized with

# must be hex!
set CODE_RAM_BASE  "0x0"

# must be hex!
set CODE_RAM_END   "0xFFFFF"

# set to the width (bits) of the on-chip RAM to be initialized
set CODE_RAM_WIDTH "32"
set HEX_SIM_FILE   "$APP_BUILD_DIR/code_data_ram_init.hex"

set SIM_DIR "../../simulation_files"

#*** DON'T TOUCH ANYTHING BELOW THIS LINE, EDIT THE VARIABLES ABOVE INSTEAD ***

# create BSP
set cmd "niosv-bsp --create --quartus-project=$QPF_FILE --qsys=$QSYS_FILE --type=hal $BSP_DIR/bsp_settings.bsp"
puts "Creating BSP:  $cmd"
eval "exec -ignorestderr"  $cmd

# generate BSP
set cmd "niosv-bsp --generate $BSP_DIR/bsp_settings.bsp"
puts "Generating BSP:  $cmd"
eval "exec -ignorestderr"  $cmd

# create application
set cmd "niosv-app --app-dir=$APP_DIR --bsp-dir=$BSP_DIR --srcs=$SRC_DIR --elf-name=$ELF_FILE"
puts "Creating Application:  $cmd"
eval "exec -ignorestderr"  $cmd

# run CMAKE on application
set cmd "cmake -B $APP_BUILD_DIR -S $APP_DIR -G \"Unix Makefiles\""
puts "CMake on Application:  $cmd"
eval "exec -ignorestderr"  $cmd

# run make on application
set cmd "make -C $APP_BUILD_DIR"
puts "Compiling Application:  $cmd"
eval "exec -ignorestderr"  $cmd

# generate a hex file pointed to by script variable HEX_SIM_FILE in the
# application build directory
set cmd "elf2hex --input $APP_BUILD_DIR/$ELF_FILE --width $CODE_RAM_WIDTH --base $CODE_RAM_BASE --end $CODE_RAM_END $HEX_SIM_FILE"
puts "Generating Memory Initialization File:  $cmd"
eval "exec -ignorestderr"  $cmd

# copy the .hex file to the simulation directory
set cmd "file copy -force $HEX_SIM_FILE $SIM_DIR"
puts "Copying .hex file to simulation directory: $cmd"
eval $cmd

puts "Finished. Now run questasim to simulate your design"
