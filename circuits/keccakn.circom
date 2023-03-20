
pragma circom 2.0.0;

include "vocdoni-keccak/keccak.circom";

template KeccakN(N) {
    signal input a[25*64];
    signal output out[25*64];
    component k = Keccakf();
    var i;
    for (i=0; i<25*64; i++) {
        k.in[i] <== a[i];
    }
    for (i=0; i<25*64; i++) {
        out[i] <== k.out[i];
    }
}

component main = KeccakN(10);
