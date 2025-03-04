function [M_recover, M, N, iter] = MLR_APG(R_Omega, U, V, lambda1, lambda2, maxiter, tol, LL)
if(max(max(R_Omega))+min(min(R_Omega))~=0)
    disp("Error: Lack of normalization. ----PRLtrain.m");
end
R_Omega = R_Omega*LL;
B = (V'*LL)';
%% Step1: Initialization
[n, m2] = size(R_Omega);
r_a = size(U, 2);
r_b = size(V, 2);
M = zeros(n, m2);
N = zeros(r_a, r_b);
Z = zeros(r_a, r_b);

%% Step2: Iteration
i = 1;
stop1 = 1;
b = 0;
matr = M + U * N * B';

while(stop1 > tol )
    matr_1 = matr;
    % update M
    E = R_Omega - U * N * B';
    M_1 = fsvt(E, lambda1);
    
    % update N
    L_p = sqrt(norm(U'*U, 'fro')*norm(B'*B, 'fro'));
    
    F = Z - 1/L_p*(U'*(M_1 + U * Z * B' - R_Omega)*B);
    N_1 = fL1(F, lambda2);
    b_1 = (1+sqrt(1+4*b*b))/2;
    Z_1 = N + (b-1)/b_1*(N_1-N);
    
    
    matr = M_1 + U * N_1 * B';
    stop1 = norm(matr - matr_1, 'fro') / norm(matr_1, 'fro');
    M = M_1;
    N = N_1;
    i=i+1;
    b = b_1;
    Z = Z_1;
    
    if i < maxiter
        iter = i - 1;
    else
        iter = maxiter;
        break
    end
end

%% Step3: The completed matrix
M_recover = U * N * B' + M;
M_recover = M_recover*pinv(LL);
end
