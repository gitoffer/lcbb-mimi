function D = nan_stsd(v1,v2)
%NAN_STSD Short time-series (STS) distance with NaN handling.
%
% SYNOPSIS: D = nan_stsd(v1,v2);
%
% xies@mit.edu Dec 2012

D = sqrt(nansum( ...
    bsxfun(@minus,diff(v1),diff(v2,1,2)).^2,2 ...
    ));

end