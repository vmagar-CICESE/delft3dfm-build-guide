# Delft3D-FM Build Process

This document outlines the complete build process for Delft3D-FM using GNU compilers.



## Prerequisites

Before starting the build:
1. [Set up the Intel OneAPI environment](intel_oneapi_setup.md)
2. [Build NetCDF with Intel Fortran compatibility](netcdf_build.md)
3. Ensure all environment variables are properly set


## System Dependencies

The following packages are required for building Delft3D-FM:

```bash
sudo apt-get install -y build-essential m4 wget curl
sudo apt-get install -y libhdf5-serial-dev hdf5-tools
sudo apt-get install -y libcurl4-openssl-dev zlib1g-dev
sudo apt-get install -y uuid-dev  # Required for WAQ component
sudo apt-get install -y libopenmpi-dev  # MPI development libraries
sudo apt-get install -y libblas-dev liblapack-dev  # BLAS and LAPACK
sudo apt-get install -y libexpat1-dev  # XML parsing library
```

## PETSc Installation

Delft3D-FM requires PETSc for parallel solvers. For installation instructions, see:
https://petsc.org/release/install/

Our configuration assumes PETSc is installed in `/usr/local/petsc`.

## Configuration

### Option 1: Direct Configuration (Full Command)

This approach shows all compiler flags explicitly:

```bash
cd /mnt/c/Users/vanes/Documents/DelftFM/delft3dfm-9180/src

FC=mpiifort F77=mpiifort MPIFC=mpiifort CC=gcc CXX=g++ MPICXX=mpicxx \
PETSc_CFLAGS="-I/usr/local/petsc/include" \
PETSc_LIBS="-L/usr/local/petsc/lib -lpetsc" \
PETSC_DIR=/usr/local/petsc \
FCFLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include" \
FFLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include" \
F90FLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include" \
LDFLAGS="-L$HOME/intel-netcdf/lib" \
./configure --prefix=$(pwd) --with-netcdf=$HOME/intel-netcdf \
--with-mpi --with-metis=/usr --with-petsc=/usr/local/petsc \
--with-blas-lib=-lblas --with-lapack-lib=-llapack
```

### Option 2: Using Environment Script (Recommended)

This approach uses the provided environment setup script:

# Source the environment setup script
source scripts/fix_compiler_flags.sh

## PETSc Installation

Delft3D-FM requires PETSc for parallel solvers. For installation instructions, see:
https://petsc.org/release/install/

Our configuration assumes PETSc is installed in `/usr/local/petsc`.


# Run configure
./configure --prefix=$(pwd) --with-netcdf=$HOME/intel-netcdf \
  --with-mpi --with-metis=/usr --with-petsc=/usr/local/petsc \
  --with-blas-lib=-lblas --with-lapack-lib=-llapack

The fix_compiler_flags.sh script sets all necessary compiler flags and environment variables, making the configuration process cleaner and more maintainable.


## Build Process

Initial Build Attempt
cd /path/to/delft3dfm/src
make ds-install



## Incremental Build Process

When encountering compiler flag issues:

1. Navigate to the problematic directory indicated in the error message
2. Fix the Makefile by replacing Intel/GNU flags with GNU/Intel equivalents
3. Return to the main source directory
4. Continue with `make ds-install`

The build will resume from where it left off without rebuilding already completed components.


## Verifying Successful Build

After the build completes successfully:

1. Check that executables are created in the `bin` directory:
   ```bash
   ls -la bin/



## Compiler Notes

Although we configure with Intel Fortran compilers, many Makefiles contain hardcoded Intel flags that need conversion when using GNU compilers for certain components. The conversion table is included in `fix_compiler_flags.sh`.

## Troubleshooting

For common issues and their solutions, see the [Issues and Solutions](issues_and_solutions.md) document.