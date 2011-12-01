function V_msubt = meansubtract_vector_field(V)

N = size(V,1);
means = mean(V,1);
Means = zeros(size(V));

for i = 1:numel(means)
    Means(:,i) = means(i*ones(1,N));
end

V_msubt = V - Means;