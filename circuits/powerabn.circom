pragma circom 2.0.0;

template PowerABN(N) {
    signal input a;  
    signal input b;  
    
    signal output c;

    signal d[N + 1];
    signal e[N + 1];
    
    var i = 1;
    d[0] <== 1;
    e[0] <== 1;
    
    while (i <= N) {
        d[i] <== a * d[i-1];
        e[i] <== b * e[i-1];
        i++;        
    }
    
    c <== d[i-1] * e[i-1]; 
}

component main = PowerABN(32);
