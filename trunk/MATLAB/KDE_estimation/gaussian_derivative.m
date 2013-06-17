function y = gaussian_derivative(h,data,xi)
%GAUSSIAN_DERIVATIVE

A = 1/sqrt(2*pi*h);

y = zeros(size(xi));
for i = 1:numel(data)
    y = y - (xi - data(i)).*A.*exp(-(xi - data(i)).^2/(2*h^2))/h^2;
end

end
