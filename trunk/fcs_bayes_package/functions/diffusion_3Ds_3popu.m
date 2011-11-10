    
function F = diffusion_3Ds_3popu(a,t,s);

% Used by the curve fitter to calculate values for the diffusion equation

    F = a(7) + a(1)./(1 + t./a(2))./sqrt(1 + t./a(2)/s^2) + a(3)./(1 + t./a(4))./sqrt(1 + t./a(4)/s^2) + a(5)./(1 + t./a(6))./sqrt(1 + t./a(6)/s^2); 
