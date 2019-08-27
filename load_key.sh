#!/bin/bash

set -e 

tpm2_createprimary -C o -c parent.ctx -G rsa2048:null:aes128cfb
tpm2_evictcontrol -c parent.ctx

tpm2_import -i private_key.key -r private_key.tss -u public_key.tss -Grsa -C parent.ctx
tpm2_load -C parent.ctx -u public_key.tss -r private_key.tss -c wzhpor.ctx
tpm2_evictcontrol -c wzhpor.ctx


