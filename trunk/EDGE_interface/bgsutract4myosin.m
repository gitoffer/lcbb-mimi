function signal_nobg = bgsutract4myosin(signal,method,params)

x = params{1};

switch method
    case 'linear'
        p = polyfit(x,signal,2);
        bg = polyval(p,x);
    case 'gaussian'
        [height,max] = extrema(signal);
        guess = [height(1) max(1) 2];
        p = lsqcurvefit(@lsq_gauss1d,guess,x,signal);
        bg = lsq_gauss1d(p,x);
    otherwise
        error('Unsupported method')
end

signal_nobg = signal-bg;