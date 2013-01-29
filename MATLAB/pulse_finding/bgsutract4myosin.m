function signal_nobg = bgsutract4myosin(signal,method,params)
%BGSUBTRACT4MYOSIN Given a signal, fit a function to it that approximates
% the background of the signal, and subtracts the background.
% Uses LSQCURVEFIT.
%
% INPUT: signal - the signal to be fitted
%        method - 'linear' linear background
%                 'gaussian' a wide Gaussian background
%        params - the domain of the signal
% OUTPUT: signal_nobg
%
% xies@mit.edu. Feb 2012.

% domain of signal
x = params{1};

% turn off display
opt = optimset('display','off');
switch method
    case 'linear'
        p = polyfit(x,signal,2);
        bg = polyval(p,x);
    case 'gaussian'
        % find extrema as the best first guess
        [height,max] = extrema(signal);
        guess = [height(1) max(1) 2];
        p = lsqcurvefit(@lsq_gauss1d,guess,x,signal,[-Inf 30],[Inf Inf],opt);
        % evaluate the fitted gaussian
        bg = lsq_gauss1d(p,x);
    otherwise
        error('Unsupported method')
end

signal_nobg = signal-bg;

end