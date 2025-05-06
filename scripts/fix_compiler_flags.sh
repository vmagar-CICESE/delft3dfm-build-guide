#!/bin/bash
# Global compiler flag fixes for Delft3D-FM compilation
# This script addresses common compatibility issues when building Delft3D-FM

# ---------- HELP MESSAGE ----------
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $(basename $0) [--fix-makefiles /path/to/directory]"
  echo "Options:"
  echo "  --fix-makefiles DIR  Automatically fix Intel compiler flags in Makefiles"
  echo "  --help, -h          Show this help message"
  exit 0
fi

# ---------- SOURCE INTEL ONEAPI ENVIRONMENT ----------
# Uncomment if needed to ensure Intel compilers are available
source /opt/intel/oneapi/setvars.sh

# Check if Intel compilers are available
command -v mpiifort >/dev/null 2>&1 || { 
  echo >&2 "Intel MPI Fortran compiler not found. Please source Intel OneAPI environment."
  echo >&2 "Try: source /opt/intel/oneapi/setvars.sh"
  exit 1
}

# ---------- COMPILER SELECTION ----------
# Use Intel Fortran with GNU C/C++
export FC=mpiifort
export F77=mpiifort
export MPIFC=mpiifort
export CC=gcc
export CXX=g++
export MPICXX=mpicxx

# ---------- COMPILER FLAGS ----------
# Base compilation flags
export FFLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include"
export FCFLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include"
export F90FLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include"
export CFLAGS="-fcommon -O2"
export LDFLAGS="-L$HOME/intel-netcdf/lib"

# ---------- PETSC CONFIGURATION ----------
export PETSc_CFLAGS="-I/usr/local/petsc/include"
export PETSc_LIBS="-L/usr/local/petsc/lib -lpetsc"
export PETSC_DIR=/usr/local/petsc

# ---------- NETCDF ENVIRONMENT SETUP ----------
export NETCDF_HOME=$HOME/intel-netcdf
export LD_LIBRARY_PATH=$NETCDF_HOME/lib:$LD_LIBRARY_PATH
export PATH=$NETCDF_HOME/bin:$PATH
export NETCDF_FORTRAN_HOME=$NETCDF_HOME

# ---------- GNU FORTRAN FLAG FIXES FOR MAKEFILES ----------
echo "Applied compiler settings for Delft3D-FM"
echo "  FC: $FC"
echo "  FFLAGS: $FFLAGS"
echo "  FCFLAGS: $FCFLAGS"
echo "  NETCDF_HOME: $NETCDF_HOME"
echo ""
echo "NOTE: For Makefile fixes with GNU Fortran compilers, use these conversions:"
echo "  Intel flag         →  GNU equivalent"
echo "  ---------------------------------"
echo "  -qopenmp          →  -fopenmp"
echo "  -132              →  -ffixed-line-length-132"
echo "  -recursive        →  -frecursive"
echo "  -reentrancy*      →  (remove)"
echo "  -traceback        →  (remove)"
echo "  -r8               →  -fdefault-real-8"


# ---------- AUTOMATIC MAKEFILE FIXING ----------
# This would let you run:
# ./fix_compiler_flags.sh --fix-makefiles /mnt/c/Users/vanes/Documents/DelftFM/delft3dfm-9180/src


if [ "$1" = "--fix-makefiles" ] && [ -n "$2" ]; then
  echo "Applying fixes to Makefiles in $2..."
  find "$2" -name "Makefile" -exec sed -i 's/-qopenmp/-fopenmp/g' {} \;
  find "$2" -name "Makefile" -exec sed -i 's/-132/-ffixed-line-length-132/g' {} \;
  find "$2" -name "Makefile" -exec sed -i 's/-recursive/-frecursive/g' {} \;
  find "$2" -name "Makefile" -exec sed -i 's/-reentrancy threaded//g' {} \;
  find "$2" -name "Makefile" -exec sed -i 's/-traceback//g' {} \;
  find "$2" -name "Makefile" -exec sed -i 's/-r8/-fdefault-real-8/g' {} \;
  echo "Done fixing Makefiles!"
fi


# ---------- END OF SCRIPT ----------
# Note: This script is intended for use on systems with Intel compilers and GNU C/C++ compilers.