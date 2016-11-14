
param n, integer, >= 1;
set I:=1..n;
param W, integer, >= 1;
param w{i in I};
param v{i in I};

#variables
var x{i in I}, binary;

#criterion
maximize total: sum{i in I} v[i]*x[i];

s.t. weight: sum{i in I} w[i]*x[i] <= W;

solve;

printf "Max income: %d\n", total;
printf {i in I: x[i]}: "Item %d\n", i;

data;

param n := 20;

param W := 30;

param : w v :=
1     3 3
2     2 5
3     7 1
4     5 8
5     4 7
6     7 6
7     3 4
8     2 10
9     7 4
10    5 10
11    4 7
12    7 6
13    3 2
14    2 5
15    7 7
16    5 2
17    4 2
18    7 9
19    3 3
20    6 4
;


end;