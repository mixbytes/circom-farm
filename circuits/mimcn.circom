pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/mimc.circom";

template MiMCN(N) {
    signal input a;
    signal output out;

    component mimc[N];

    var k = 1;
    mimc[0] = MiMC7(91); // amount of rounds
    mimc[0].x_in <== a;
    mimc[0].k <== k;
    
    var j;
    for (j=1; j<N; j++) {
        mimc[j] = MiMC7(91);
        mimc[j].x_in <== mimc[j-1].out;
        mimc[j].k <== k;
    }
    
    out <== mimc[j-1].out;
}

component main = MiMCN(512);
