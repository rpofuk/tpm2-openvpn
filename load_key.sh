#!/bin/bash

set -e


tpm2_clear
echo "### Creating primary"
tpm2_createprimary  -C o -c parent.ctx -G rsa2048:null:aes128cfb
echo "### Done primary"


echo "### Persisting primary"
tpm2_evictcontrol -c parent.ctx > primary.log
echo "### Done persist"
HANDLE=$(cat primary.log | grep "persistent-handle" | awk '{printf $2}')
cat primary.log
echo "HANDLE ${HANDLE##*x}"


tpm2_import  -i $1 -r private_key.tss -u public_key.tss -Grsa -C parent.ctx
tpm2_load  -C parent.ctx -u public_key.tss -r private_key.tss -c wzhpor.ctx
tpm2_evictcontrol -c wzhpor.ctx

npx @rpofuk/tpm2-asn-packer p ${HANDLE##*x} private_key.tss public_key.tss out.key

