function F = diffusion_jun3Ds(a,t,s);

% Used by the curve fitter to calculate values for the diffusion equation

    F = a(3) + a(1)./(1 + t./a(2))./sqrt(1 + t./a(2)/s^2); 
