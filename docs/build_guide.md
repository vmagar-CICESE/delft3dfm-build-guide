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

```bash
# Source the environment setup script
source scripts/fix_compiler_flags.sh

# Run configure with simpler parameters since environment is pre-configured
./configure --prefix=$(pwd) --with-netcdf=$HOME/intel-netcdf \
  --with-mpi --with-metis=/usr --with-petsc=/usr/local/petsc \
  --with-blas-lib=-lblas --with-lapack-lib=-llapack
```



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

### NetCDF Library Linking Issues in WAQ component
When building the WAQ components, you may see errors like:
```bash
undefined reference to `netcdf_mp_nf90_inquire_attribute_'
```

This indicates the NetCDF Fortran library isn't being linked properly. Fix by adding explicit NetCDF libraries to LDFLAGS: 
```bash
LDFLAGS="-L/root/intel-netcdf/lib -lnetcdff -lnetcdf"
```
The -lnetcdff flag is critical for linking Fortran NetCDF interfaces.

We can clean and rebuild the WAQ component:
```bash
make -C engines_gpl/waq clean
make -C engines_gpl/waq
```

Or clean and rebuild with the explicit NetCDF library flags:

```bash
# Clean the WAQ component
make -C engines_gpl/waq clean

# Rebuild with explicit NetCDF library flags
FC=mpiifort F77=mpiifort MPIFC=mpiifort CC=gcc CXX=g++ MPICXX=mpicxx \
PETSc_CFLAGS="-I/usr/local/petsc/include" \
PETSc_LIBS="-L/usr/local/petsc/lib -lpetsc" \
PETSC_DIR=/usr/local/petsc \
FCFLAGS="-fPIC -O1 -qopenmp -I/root/intel-netcdf/include" \
FFLAGS="-fPIC -O1 -qopenmp -I/root/intel-netcdf/include" \
F90FLAGS="-fPIC -O1 -qopenmp -I/root/intel-netcdf/include" \
LDFLAGS="-L/root/intel-netcdf/lib -lnetcdff -lnetcdf" \
make ds-install
```

## Verifying Successful Build

After the build completes successfully:

1. Check that executables are created in the `bin` directory:
   ```bash
   ls -la bin/

### Environment Consistency

When building specific components separately, you must maintain the same environment variables that were used during configure:

```bash
# When building dflowfm separately
FC=mpiifort F77=mpiifort MPIFC=mpiifort \
FCFLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include" \
FFLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include" \
F90FLAGS="-fPIC -O1 -qopenmp -I$HOME/intel-netcdf/include" \
LDFLAGS="-L$HOME/intel-netcdf/lib" \
make ds-install -C engines_gpl/dflowfm
```

## Compiler Notes

Although we configure with Intel Fortran compilers, many Makefiles contain hardcoded Intel flags that need conversion when using GNU compilers for certain components. The conversion table is included in `fix_compiler_flags.sh`.

## Compiler Consistency Requirements

### Critical: Maintain Consistent Compiler Usage

For a successful build, the same Fortran compiler must be used consistently throughout the build process:

- If using Intel Fortran for the main components, all Fortran code must be compiled with Intel Fortran
- If using GNU Fortran, all Fortran code must be compiled with GNU Fortran
- **Mixing compilers will cause build failures with cryptic error messages**

### Common Compiler Mixing Errors

1. **Module incompatibility errors**:

f951: Fatal Error: Reading module '...' at line 1 column 2: Unexpected EOF


This indicates a Fortran module file compiled with one compiler being used with another.

2. **Linker symbol errors**:

undefined reference to _gfortran_st_write'    multiple definition of main'

This indicates object files compiled with GNU Fortran being linked with Intel Fortran runtime (or vice versa).

### Checking Compiler Configuration

Verify your MPI wrappers are using the correct compilers:

```bash
# Check which compiler mpif77 is using
mpif77 -show

# Check which compiler mpiifort is using
mpiifort -show
```


### Fixing Compiler Consistency

1. Configure Intel MPI to use Intel Fortran consistently:

```bash
source /opt/intel/oneapi/setvars.sh
export I_MPI_F77=ifort
export I_MPI_F90=ifort
```

2. Clean the problematic components:
```bash
make -C path/to/problem/component clean
```

3. For persistent issues, a complete rebuild may be necessary:
```bash
make distclean
# Then reconfigure with consistent settings
```

### External Library Dependencies - FLAP

The dfmoutput component requires the FLAP (Fortran command Line Arguments Parser) library:

```bash
# Build FLAP with FoBiS.py (install if needed: pip install FoBiS.py)
cd /path/to/src/third_party_open/FLAP
FoBiS.py build -mode static-intel

# The modules are created in static/mod/ directory
ls -la static/mod/
# Should show data_type_command_line_interface.mod and ir_precision.mod

# When building dfmoutput, add this include path:
export FCFLAGS="$FCFLAGS -I/path/to/src/third_party_open/FLAP/static/mod"
make -C tools_gpl/dfmoutput clean
make -C tools_gpl/dfmoutput
```
If you get errors like:

error #7002: Error in opening the compiled module file. Check INCLUDE paths. [IR_PRECISION]

This indicates the FLAP modules can't be found during compilation.


The build system expects FLAP modules in `third_party_open/FLAP/Test_Driver/mod` but the FoBiS.py build puts them in `third_party_open/FLAP/static/mod`.

To resolve this, either:
1. Create symbolic links:
   ```bash
   cd /path/to/src/third_party_open/FLAP
   mkdir -p Test_Driver/mod
   ln -sf $(pwd)/static/mod/ir_precision.mod Test_Driver/mod/
   ln -sf $(pwd)/static/mod/data_type_command_line_interface.mod Test_Driver/mod/
  ```
1. Or explicitly specify the path:
```bash
FCFLAGS="-I/path/to/src/third_party_open/FLAP/static/mod $FCFLAGS" make -C tools_gpl/dfmoutput
```


The symlink approach is often cleaner as it allows the build system to continue working with its expected paths.

### FLAP Interface Compatibility Issues

When building with Intel Fortran, dfmoutput may fail with:
```bash
error #6627: This is an actual argument keyword name, and not a dummy argument name. [VALNAME]
```
This occurs due to incompatibility between the FLAP API and Intel Fortran.

This occurs due to incompatibility between the FLAP API and Intel Fortran.

#### Using make -k to Continue Despite Errors

If symlinks and other approaches don't work, you can use:
```bash
make -k ds-install
```

This continues the build despite errors, which will skip dfmoutput while building everything else.

The resulting build will be functional for simulations, but will lack dfmoutput utilities for post-processing.


####  What's Missing Without dfmoutput
The dfmoutput component provides these utilities:

mapmerge: Combines map output files

extract: Extracts subsets of data from output files

convert: Converts between file formats

These functions can be performed with external tools like Python scripts using the netCDF4 library.


# Testing Your Build

To verify your build is fully functional:

```bash
# Set up the runtime library path
export LD_LIBRARY_PATH=/mnt/c/Users/vanes/Documents/DelftFM/delft3dfm-9180/src/lib:$LD_LIBRARY_PATH

# Run a simple test
cd /mnt/c/Users/vanes/Documents/DelftFM/delft3dfm-9180/src
bin/d_hydro --version
bin/dimr --version
```

## Troubleshooting

For common issues and their solutions, see the [Issues and Solutions](issues_and_solutions.md) document.