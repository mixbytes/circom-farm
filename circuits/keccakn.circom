
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

    toNBits.in <== a;
    component keccak = Keccakf();
    var i;
    for (i=0; i<25*64; i++) {
        keccak.in[i] <== toNBits.out[i];
    }
    for (i=0; i<25*64; i++) {
        fromNBits.in[i] <== keccak.out[i];
    }
    out <== fromNBits.out;
}

component main = KeccakN(10);
