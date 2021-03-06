$inlinecom /* */

/* Turn off the listing of the input file */
$offlisting

/* Turn off the listing and cross-reference of the symbols used */
$offsymxref offsymlist

option
    limrow = 0,     /* equations listed per block */
    limcol = 0,     /* variables listed per block */
    solprint = off,     /* solver's solution output printed */
    sysout = off;    

Sets
t   truck type /small, large/
j   customers
/
$include customers.txt
/;

Alias(j, k, l)

Parameters
dv(j)    volume
/
$include demand-volume.txt
/

dw(j)   weight
/
$include demand-weight.txt
/

a(j, k)    clusterability
/
$include clusterability.txt
/

u(j)    cost of indirect shipment
/
$include trans_cost.txt
/;

scalar qs small truck volume / 18 /;
scalar qb large truck volume/ 33 /;

Table c(j, t) direct shipment cost
$include direct-shipment-cost.txt
;

Binary Variables
i(j)
d(j)
b(j)
s(j)
b1(j)
b2(j, k)
b3(j, k, l)
s1(j)
s2(j, k)
s3(j, k, l);

Free Variables
cb2(j, k)
cb3(j, k, l)
cs2(j, k)
cs3(j, k, l)
z;

Equations
direct_or_indirect(j)
large_or_small(j)
carry_small_once(j)
carry_big_once(j)
b2_together(j, k)
b3_together(j, k, l)
s2_together(j, k)
s3_together(j, k, l)
b1_capacity(j)
b2_capacity(j, k)
b3_capacity(j, k, l)
s1_capacity(j)
s2_capacity(j, k)
s3_capacity(j, k, l)
cb2_max1(j, k)
cb2_max2(j, k)
cb3_max1(j, k, l)
cb3_max2(j, k, l)
cb3_max3(j, k, l)
cs2_max1(j, k)
cs2_max2(j, k)
cs3_max1(j, k, l)
cs3_max2(j, k, l)
cs3_max3(j, k, l)
cost
;

direct_or_indirect(j) .. i(j) + d(j) =e= 1;
large_or_small(j) .. b(j) + s(j) =e= d(j);

carry_big_once(j) .. sum((k, l), (b3(k, l, j) + b3(l, j, k) + b3(j, k, l))) + sum(k, (b2(j, k) + b2(k, j))) + b1(j) =e= b(j);
carry_small_once(j) .. sum((k, l), (s3(k, l, j) + s3(l, j, k) + s3(j, k, l))) + sum(k, (s2(j, k) + s2(k, j))) + s1(j) =e= s(j);

b2_together(j, k) .. b2(j, k) =l= a(j, k);
b3_together(j, k, l) .. b3(j, k, l) =l= a(j, k) * a(k, l) * a(l, j);

s2_together(j, k) .. s2(j, k) =l= a(j, k);
s3_together(j, k, l) .. s3(j, k, l) =l= a(j, k) * a(k, l) * a(l, j);

b1_capacity(j) .. b1(j) * dv(j) =l= qb;
b2_capacity(j, k) .. b2(j, k) * (dv(j) + dv(k)) =l= qb;
b3_capacity(j, k, l) .. b3(j, k, l) * (dv(j) + dv(k) + dv(l)) =l= qb;

s1_capacity(j) .. s1(j) * dv(j) =l= qs;
s2_capacity(j, k) .. s2(j, k) * (dv(j) + dv(k)) =l= qs;
s3_capacity(j, k, l) .. s3(j, k, l) * (dv(j) + dv(k) + dv(l)) =l= qs;

cb2_max1(j, k) .. cb2(j, k) =g= c(j, "large") * b2(j, k);
cb2_max2(j, k) .. cb2(j, k) =g= c(k, "large") * b2(j, k);

cb3_max1(j, k, l) .. cb3(j, k, l) =g= c(j, "large") * b3(j, k, l);
cb3_max2(j, k, l) .. cb3(j, k, l) =g= c(k, "large") * b3(j, k, l);
cb3_max3(j, k, l) .. cb3(j, k, l) =g= c(l, "large") * b3(j, k, l);

cs2_max1(j, k) .. cs2(j, k) =g= c(j, "small") * s2(j, k);
cs2_max2(j, k) .. cs2(j, k) =g= c(k, "small") * s2(j, k);

cs3_max1(j, k, l) .. cs3(j, k, l) =g= c(j, "small") * s3(j, k, l);
cs3_max2(j, k, l) .. cs3(j, k, l) =g= c(k, "small") * s3(j, k, l);
cs3_max3(j, k, l) .. cs3(j, k, l) =g= c(l, "small") * s3(j, k, l);

cost .. z =e= sum(j, i(j) * dw(j) * u(j))
+ sum(j, b1(j) * c(j, "large"))
+ sum(j, s1(j) * c(j, "small"))
+ sum((j, k), cb2(j, k) + 250 * b2(j, k))
+ sum((j, k), cs2(j, k) + 125 * s2(j, k))
+ sum((j, k, l),  cb3(j, k, l) + 500 * b3(j, k, l))
+ sum((j, k, l), cs3(j, k, l) + 250 * s3(j, k, l));



model transport / all /;

solve transport using MIP minimizing z;


Display i.l, d.l, b.l, s.l, b1.l, b2.l, b3.l, s1.l, s2.l, s3.l;
