function v = take_derivative(x,window)

% Approximate derivative with windowing symmetrically around x
% returns vector the same length as x

l = length(x);
v = zeros(l,1);
padded = padarray(x,floor(window/2),'replicate');

for i = 1:l
    if padded(i) == NaN || padded(i+window) == NaN
        v(i) = NaN;
        continue
    else
        v(i) = (padded(i+window)-padded(i))/window;
    end
end