# tpm2-openvpn


@rpofuk/tpm2-asn-packer@1.0.1 p 6781050a0103 12  test/prv.key test/pub.key out.key


6781050a0103 = 

OID_loadableKey 2.23.133.10.1.3 


OID_loadableKey 2.23.133.10.1.3 


rwbi401000@rwbi401000:~/.tpm2$ npx @rpofuk/tpm2-asn-packer p 81800001 private_key.tss public_key.tss out.key
npx: installed 48 in 5.492s
Preparing outpuot
Packing hex asn 1
[ 48,
  [ [ 6, '6781050a0103' ],
    [ 160, [Array] ],
    [ 2, '81800001' ],
    [ 4,
      '<!-- HEX -->' ],
    [ 4,
      '<!-- HEX -->' ] ] ]
Generating pem file
Writing to ouput
Successfully written pen file



rwbi401000@rwbi401000:~/.tpm2$ openssl asn1parse -in  out.key 
    0:d=0  hl=4 l= 564 cons: SEQUENCE          
    4:d=1  hl=2 l=   6 prim: OBJECT            :2.23.133.10.1.3
   12:d=1  hl=2 l=   3 cons: cont [ 0 ]        
   14:d=2  hl=2 l=   1 prim: BOOLEAN           :1
   17:d=1  hl=2 l=   5 prim: INTEGER           :81800001
   24:d=1  hl=4 l= 280 prim: OCTET STRING      [HEX DUMP]: <!-- HEX -->
  308:d=1  hl=4 l= 256 prim: OCTET STRING      [HEX DUMP]: <!-- HEX -->
