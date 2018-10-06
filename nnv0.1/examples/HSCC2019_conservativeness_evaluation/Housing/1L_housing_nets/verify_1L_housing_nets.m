load 1L_housing_nets.mat;

W1 = nnetwork.W{1, 1};
b1 = nnetwork.b{1, 1};

W2 = nnetwork.W{1, 2};
b2 = nnetwork.b{1, 2};

L1 = Layer(W1, b1, 'ReLU');
L2 = Layer(W2, b2, 'Linear');

F = FFNN([L1, L2]);


lb = nnetwork.min';
ub = nnetwork.max';

% Input set
% x[i] = 0, i = 1:10
% lb(i) <= x[i] <= ub(i), i=11, 12

n = length(lb);

Ae = eye(n);
Ae(n-1:n, :) = [];
be = zeros(n-2, 1);

A1 = zeros(2, n);
A1(1, n) = 1;
A1(2, n) = -1;

A2 = zeros(2, n);
A2(1, n-1) = 1;
A2(2, n-1) = -1;

A = vertcat(A1, A2);
b = vertcat(ub(n), -lb(n), ub(n-1), -lb(n-1));

% Input Set
I = Polyhedron('A', A, 'b', b, 'Ae', Ae, 'be', be);

% exact range analysis
[R1, t1] = F.reach(I, 'exact', 4, []); % exact scheme
R11 = Reduction.hypercubeHull(R1);
R11.outerApprox;
range1 = [R11.Internal.lb, R11.Internal.ub];
save F_1L_exact.mat F;


% lazy-approximate range analysis
[R2, t2] = F.reach(I, 'approx', 4, []); % lazy-approximate scheme
R2.outerApprox;
range2 = [R2.Internal.lb R2.Internal.ub];
save F_1L_approx.mat F;



% lazy-approximate + input partition method for range analysis
I1 = Partition.partition_box(I, 2); % lazy-approximate scheme + input partition
[R3, t3] = F.reach(I1, 'approx', 4, []); % lazy-approximate scheme
R31 = Reduction.hypercubeHull(R3);
R31.outerApprox;
range3 = [R31.Internal.lb R31.Internal.ub];
save F_1L_approx_partition.mat F;

% mixing scheme for output range analysis
[R4, t4] = F.reach(I, 'mix', 4, 17);
R41 = Reduction.hypercubeHull(R4);
R41.outerApprox;
range4 = [R41.Internal.lb, R41.Internal.ub];
save F_1L_mixing.mat F;


% compute conservativeness
CSV1 = 0;
CSV2 = (abs(range2(1) - range1(1)) + abs(range2(2) - range1(2))) / (range1(2) - range1(1));
CSV3 = (abs(range3(1) - range1(1)) + abs(range3(2) - range1(2))) / (range1(2) - range1(1));
CSV4 = (abs(range4(1) - range1(1)) + abs(range4(2) - range1(2))) / (range1(2) - range1(1));



