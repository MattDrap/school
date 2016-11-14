param n, integer, >= 3;
set V:=1..n;
set E, within V cross V;
param c{(i,j) in E};

#variables
var x{(i,j) in E}, binary;
var y{(i,j) in E}, integer, >= 0;

#criterion
minimize total: sum{(i,j) in E} c[i,j]*x[i,j];

s.t. enter {i in V}: sum{(i,j) in E} x[i,j] = 1;
s.t. leave {j in V}: sum{(i,j) in E} x[i,j] = 1;
s.t. items {(i, j) in E}: y[i,j] <= (n-1)*x[i,j];
s.t. cont {i in 2..n}: sum{(j,i) in E} y[j,i] - 1 = sum{(i,k) in E} y[i,k];
s.t. first: sum{(j, 1) in E} y[j, 1] + (n-1) = sum{(1, k) in E} y[1, k];

solve;

printf "tour length: %d\n", total;
printf {(i,j) in E: x[i,j]}: "from %d to %d\n", i, j;

data;

param n := 5;

param : E : c :=
1 2 2
1 3 3
1 4 12 
1 5 5
2 1 2 
2 3 4 
2 4 8
2 5 7
3 1 3
3 2 4
3 4 3
3 5 3
4 1 12 
4 2 8
4 3 3
4 5 10
5 1 5
5 2 7
5 3 3
5 4 10
;
end;