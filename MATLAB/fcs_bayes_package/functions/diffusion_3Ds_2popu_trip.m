    
function F = diffusion_3Ds_2popu_trip(a,t,s)

% Used by the curve fitter to calculate values for the diffusion equation

    F = a(5) + (a(1)./(1 + t./a(2))./sqrt(1 + t./a(2)/s^2) + a(3)./(1 + t./a(4))./sqrt(1 + t./a(4)/s^2) ).* (1 + a(6)./(1-a(6)).*exp(-t./a(7))); 
