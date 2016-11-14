param numFacilities, integer, >=0;
param numCustomers, integer, >= 0;
set Customers:=0..numCustomers-1;
set Facilities:=0..numFacilities-1;

param costs{i in Facilities};
param capacities{i in Facilities};
param facilityXs{i in Facilities};
param facilityYs{i in Facilities};

param demands{i in Customers};
param customerXs{i in Customers};
param customerYs{i in Customers};

var x{i in Facilities}, binary;
var y{i in Customers, j in Facilities}, binary;

minimize total: (sum{i in Facilities} costs[i]*x[i]) + sum{i in Customers,j in Facilities} (y[i,j] * sqrt((facilityXs[j] - customerXs[i])^2 + (facilityYs[j] - customerYs[i])^2));

s.t. caps {i in Facilities}: sum{j in Customers} (y[j,i]*demands[j]) <= (x[i] * capacities[i]);
#s.t. cont: sum{c in Customers, f in Facilities} y[c,f] = numCustomers;
s.t. cont2{i in Customers}: sum{j in Facilities} y[i,j] = 1;
solve;

printf: "%f\n", total;
for {i in Facilities: x[i] == 1} {
 printf '%d', i;
 for {j in Customers: y[j,i] == 1} {
 	printf ' %d', j;
 }
 printf '\n';
}