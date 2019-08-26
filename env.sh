#!/bin/bash

echo "TPM2TOOLS_TCTI_NAME=abrmd:bus_name=com.intel.tss2.Tabrmd" > /etc/environment
export TPM2TOOLS_TCTI_NAME=device
export TPM2TOOLS_DEVICE_FILE=/dev/tpmrm0


