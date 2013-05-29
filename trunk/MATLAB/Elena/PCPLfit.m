function [r, toi] = PCPLfit( data,tn, tf )
%PCPLFIT or piecewise linear piecewise constant takes the average myosin
%intensity and iterates over a time range such that it returns a constant
%fit before the time of inflection and a linear fit outside of the time of
%inflection. It returns then, the fit with the lowest R2 . Used in
%combination with R2CALC . 

R = Inf;
r2s = zeros(1, tf - tn );
resnorms = zeros(1, tf - tn);
for toi = tn:tf
    [r2,resnorm,p] = r2Calc( toi, data) ;
    r2s(toi) = r2;
    resnorms(toi) = resnorm;
%     if r2 < R
%         R = r2;
%         tact = toi;
%         params = p;
%     
%     end
r = r2 + resnorms ;
end

toi = tn:tf;