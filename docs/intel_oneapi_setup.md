# Intel OneAPI Environment Setup for Delft3D-FM

## Prerequisites

Before building or running Delft3D-FM, you must source the Intel OneAPI environment:

```bash
# Source the Intel OneAPI base environment
source /opt/intel/oneapi/setvars.sh

# Alternatively, you can source specific components if needed:
# source /opt/intel/oneapi/compiler/2025.1/env/vars.sh
# source /opt/intel/oneapi/mpi/2021.15/env/vars.sh
```

## When to Source Intel OneAPI

- **During build process**: Required for successful compilation, particularly for Fortran components
- **Before running Delft3D-FM**: Ensures runtime libraries are available
- **For each new terminal session**: Environment variables aren't persistent between sessions


## Verifying Intel Compilers

After sourcing the environment, verify the compilers are available:
```bash
# Check Intel Fortran compiler
mpiifort --version

# Check Intel C compiler
mpiicc --version
```

## Include Download Information

- **Download URL**: [Intel oneAPI Toolkits](https://www.intel.com/content/www/us/en/developer/tools/oneapi/toolkits.html)

### Required Components
- Intel oneAPI Base Toolkit
- Intel oneAPI HPC Toolkit (for Fortran compiler)


## Installation commands for Ubuntu/Debian:

```bash
# Download and add Intel repository key
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

# Add Intel repository
echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

# Update and install Intel components
sudo apt update
sudo apt install intel-oneapi-compiler-fortran intel-oneapi-mpi intel-oneapi-mpi-devel
```