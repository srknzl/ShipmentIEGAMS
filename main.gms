sets
j   customers  / 1 * 56/
k   truck type /1 * 2/
parameters

v(j) demand of customer j in terms of volume
/
$include ./demand-volume.txt
/

w(j) demand of customer j in terms of weight
/
$include ./demand-weight.txt
/

c(j,k) cost of sending good to customer j with truck type k
/
$include ./direct-shipment-cost.txt
/
q(k)   capacity of truck type k
/ 1 = 18, 2 = 33 /

a(j,j) if customer j1 and j2 can be visited together
$include  ./clusterability.txt
u(j)   unit cost of sending good to customer j indirectly
$include ./trans_cost.txt

binary variable i(j) 1 if customer j receives indirectly. ;
binary variable b(j,j,k) b(jj'k)=1  if customer j j' are visited together with truck type k and cost of j is less than j'
positive variable Z total cost;

equations
cost           definition of total cost
sameCustomer(j1,j1,k) equation to make bjjk = 0
costOrder(j1,j2,k) equation to make costs ordered according to bjj'k
atMostThree(j1,k) equation to state a truck can work for three customers at most and if a customer has taken the goods indirectly the goods cannot have it directly
clusterabilityConst(j1,j2,k) equation to limit direct shipment according to clusterabiliy matrix
directIndirectImpicationOne(j1,j2,k) equation to state if direct it cannot be indirect
directIndirectImpicationTwo(j1,j2,k) equation to state if direct it cannot be indirect
;

cost..
Z =
sum(j1,u(j1)*i(j1)*v(j1))
+sum((j1,j2,j3,k),(b(j3,j2,k)*b(j2,j1,k)*(c(j3,k)+250*k)))
+sum((j2,j3,k),(b(j3,j2,k)*(1-sum(j1,b(j2,j1,k)*(1-sum(j1,b(j1,j3,k)))*(1-sum(j1,(b(j1,j3,k)*b(j1,j2,k))))*(c(j3,k)+125*k))))
+sum((j1,j2,k),((1-b(j1,j2,k))*(1-i(j1))*c(j1,k)));
sameCustomer(j1,j1,k).. b(j1,j1,k) =e= 0;
costOrder(j1,j2,k).. c(j2,k)*b(j1,j2,k) =l= c(j1,k);
atMostThree(j1,k).. sum(j2,b(j1,j2,k)+b(j2,j1,k)) =l= 2*(1-i(j1));
clusterabilityConst(j1,j2,k).. a(j1,j2) =g= b(j1,j2,k);
directIndirectImpicationOne(j1,j2,k).. 1-b(j1,j2,k) =g= i(j1);
directIndirectImpicationTwo(j1,j2,k).. 1-b(j1,j2,k) =g= i(j2);

model shipmentModel / all /;

option mip=baron;
*option nlp=conopt;

solve shipmentModel using mip minimizing Z;
