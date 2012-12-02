function y = unique_nosort(vector)

if ~isvector(vector), vector = vector(:); end

[sorted_vec,sortID] = sort(vector);
try uv(sortID) = [1; diff(sorted_vec)] ~= 0;
catch
    uv(sortID) = [1, diff(sorted_vec)] ~= 0;
end

y = vector(uv);