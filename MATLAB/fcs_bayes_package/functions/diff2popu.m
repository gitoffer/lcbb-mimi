function F = diff2popu(a,t)

% Used by the curve fitter to calculate values for the diffusion equation

    F = a(5) + a(1)./(1 + t./a(2)) + a(3)./(1 + t./a(4)); 