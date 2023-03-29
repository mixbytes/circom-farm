pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/pedersen.circom";

template PedersenN(N) {
    signal input a;
    signal output out;

    component pedersen[N];

    pedersen[0] = Pedersen(1); // amount of rounds
    pedersen[0].in[0] <== a;
    
    var j;
    for (j=1; j<N; j++) {
        pedersen[j] = Pedersen(1);
        pedersen[j].in[0] <== pedersen[j-1].out[0];
    }
    
    out <== pedersen[j-1].out[0];
}

component main = PedersenN(256);
