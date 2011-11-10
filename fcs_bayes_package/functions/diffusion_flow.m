function F = diffusion_flow(a,data);

% Used by the curve fitter to calculate values for the diffusion equation

    F = a(4)+(a(1) .* (a(2)./(a(2) + abs(data)))).*exp(-(abs(data)./a(3)).^2);  
