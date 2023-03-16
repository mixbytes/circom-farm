pragma circom 2.0.0;

template Multiplier2 (N) {
    signal input a;  
    signal input b;  
    
    signal output c;    // (1) I will prove, that my private inputs "a" and "b" generated such public "c"

    signal d[N];
    signal e[N];
    
    var i = 1;
    d[0] <-- 1;
    e[0] <-- 1;
    while (i < N) {     // (4) and amount of of this intermediate signals == N
        // (3) where each new signal d[i], e[i] "accumulates" previous multiplication of "a" and "b" 
        d[i] <== a * d[i-1];
        e[i] <== b * e[i-1];
        i++;        
    }
    
    c <-- d[i-1] * e[i-1]; 
    c === d[i-1] * e[i-1];  // (2) that equals the multiplication of the "last" signals in d[] and e[] (d[i-1], e[i-1])
}

component main = Multiplier2(32);
