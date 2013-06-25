function F = diffusion_jun(a,data);

% Used by the curve fitter to calculate values for the diffusion equation

    F = a(3)+(a(1) .* (a(2)./(a(2) + abs(data))));  