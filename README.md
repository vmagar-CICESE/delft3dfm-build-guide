# Delft3D-FM Compilation Guide

This repository documents the process of compiling [Delft3D Flexible Mesh](https://oss.deltares.nl/web/delft3dfm) on Linux systems, focusing on resolving common compilation issues.

## Environment

- OS: Ubuntu (WSL)
- Compilers: Intel Fortran (mpiifort) and GNU compilers
- NetCDF: Custom built with Intel Fortran compatibility

## Key Issues Addressed

- NetCDF Fortran module compatibility with Intel compilers
- Multiple definition errors in NEFIS library
- Intel vs GNU Fortran flag mismatches
- Fortran argument type mismatches (using -fallow-argument-mismatch)
