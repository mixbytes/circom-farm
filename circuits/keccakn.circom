
pragma circom 2.0.0;

include "vocdoni-keccak/keccak.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

template KeccakN(N) {
    signal input a;
    signal keccak_in[25*64];
    signal keccak_out[25*64];
    signal output out;

    component toNBits = Num2Bits(25*64);
    component fromNBits = Bits2Num(25*64);
    
    // need to build N keccak circuits to perform N-times hashing
    component keccak[N];

    toNBits.in <== a;
    
    var i;
    keccak[0] = Keccakf();
    for (i=0; i<25*64; i++) {
        keccak[0].in[i] <== toNBits.out[i];
    }
    
    var j;
    for (j=1; j<N; j++) {
        keccak[j] = Keccakf();
        for (i=0; i<25*64; i++) {
            keccak[j].in[i] <== keccak[j-1].out[i];
        }
    }
    
    for (i=0; i<25*64; i++) {
        fromNBits.in[i] <== keccak[j-1].out[i];
    }
    out <== fromNBits.out;
}

component main = KeccakN(1);
