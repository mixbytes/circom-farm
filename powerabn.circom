pragma circom 2.0.0;

template Multiplier2 (N) {
    signal input a;  
    signal input b;  
    
    // (1) Proving, that my inputs "a" and "b" generated such an output "c"
    signal output c;

    signal d[N + 1];
    signal e[N + 1];
    
    var i = 1;
    d[0] <-- 1;
    e[0] <-- 1;
    
    // (4) and amount of of this intermediate signals == N
    while (i <= N) {
        
        // (3) where each new signal d[i], e[i] "accumulates" previous multiplication of "a" and "b" 
        d[i] <== a * d[i-1];
        e[i] <== b * e[i-1];
        i++;        
    }
    
    c <-- d[i-1] * e[i-1]; 
    // (2) that equals the multiplication of the "last" signals in d[] and e[] (d[i-1], e[i-1])
    c === d[i-1] * e[i-1];
}

component main = Multiplier2(32);
