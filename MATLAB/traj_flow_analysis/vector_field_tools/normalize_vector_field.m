function V_norm = normalize_vector_field(V)

N = size(V,1);

norms = sqrt(sum(V.^2,2));
norms = norms(:,[1 1]);

V_norm = V./norms;