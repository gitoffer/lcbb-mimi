function [parameters,residual,likelihood] = peak_mixture_likelihood(y,x,max_peak,lb,ub,bg)
%ITERATIVE_GAUSSIAN_FIT Uses LSQCURVEFIT to fit multiple Gaussians to a 1D
% signal. Will use F-test to penalize for over-fitting. If BG is turned on,
% will fit an exponential background.
%
% params = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub,BG)
% [p,resnorm] = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub,BG)
% [p,resnorm,J] = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub,BG)
%
% See also: LSQCURVEFIT, LSQ_GAUSS1D
%
% xies@mit. Feb 2012.

% if numel(x) ~= numel(y)
%     error('The input vector and the input curve should have the same dimensions');
% end

if ~exist('bg','var'), bg = 'off'; end

if strcmpi(bg,'on')
    background = 1;
else
    background = 0;
end

parameters = NaN;
residual = NaN;
guess = [];
most_likely = -Inf;
likelihood = -Inf(1,max_peak+1);
LB = [];
UB = [];

for i = 0:max_peak
    
    [guess,LB,UB] = construct_parameter_vector('exp',guess,residual,x,y,LB,UB);
    
    [p,resnorm,r,exitFlag,~,~,J] = ...
        lsqcurvefit(@(p,x) synthesize_gaussians_withbg(p,x,@lsq_exponential,3,i), ...
        guess,x,y,LB,UB);
%     [p,r,J,covB,resnorm] = ...
%         nlinfit(x,y,@(p,x) synthesize_gaussians_withbg(p,x,@lsq_exponential,3,i), ...
%         guess);
    
    [~,R] = qr(J,0);
    Rinv = inv(R);
%     covB = inv(J'*J);
    covB = Rinv*Rinv';
    
    likelihood(i+1) = ...
        log(factorial(i)) ...
        + i*log(4*pi) ...
        - log(det(covB))/2 ...
        - resnorm/2 ...
        - i*log(sum(y)*(ub-lb));
    
    if likelihood(i+1) > most_likely
        parameters = p;
        residual = r;
        most_likely = likelihood(i+1);
    end
    
end

likelihood

end
%%%

function [params,lb,ub] = construct_parameter_vector(bg_name,prev_guess,residual,x,y,lb,ub)

if isempty(prev_guess)

    switch bg_name
        case 'exp' % [A,lambda,c]
            params(1:3) = [mean(y),100,mean(y)];
            lb = [0 0 0];
            ub = [sum(y) mean(y) max(y)];
        case 'lin_rect' % [m,b,c]
            params(1:3) = [(max(y)-min(y))/(x(end)-x(1)),y(1),mean(y)];
            lb = [0 -inf 0];
            ub = [inf inf max(y)];
    end
else
    
    [height,maxI] = extrema(residual);
    params = [prev_guess,height(1),maxI(1),20];
    
    lb = [lb 0 x(1) lb(end)];
    
    ub = [ub sum(y) x(end) ub(end)];
end

% for i = 1:num_gauss
%     params(i:i+2) = [
% end

end

% % Suppress display
% opt = optimset('Display','off');
% 
% % Initial guess
% [height,max] = extrema(y);
% % [A center width]
% guess = [height(1);x(max(1));x(3)-x(1)];
% 
% % Initialize
% if background
%     significant = 1;
%     resnorm_old = sum(y.^2);
%     guess_bg = [1;0;100]; % [A, offset, lambda]
%     
%     n_peaks = 0;
%     % Negative
%     LB = cat(2,[0;0;lb(3)],lb); % lower bounds for ALL params
%     UB = cat(2,[nanmax(y);nanmax(y);ub(3)],ub); % upper bounds for ALL params
%     guess = cat(2,guess_bg,guess); % concatenate bg and peak guesses
% 
% else
%     significant = 1;
%     resnorm_old = sum(y.^2);
%     n_peaks = 0; LB = lb; UB = ub;
% end
% 
% % While significant by F-test, fit 1 more gaussian
% while significant
%     
%     if background
%         [p,resnorm,residual,~,~,~,J] = ...
%             lsqcurvefit(@synthesize_gaussians_withbg,guess,x,y,LB,UB,opt);
%     else
%         [p,resnorm,residual,~,~,~,J] = ...
%             lsqcurvefit(@synthesize_gaussians,guess,x,y,LB,UB,opt);
%     end
% 
% %     [p,residual,J,covB,resnorm] = nlinfit(x,y,@synthesize_gaussians_withbg,guess);
%     
%     n_peaks = n_peaks + 1;
%     
%     F = ((resnorm_old-resnorm)/3) ...
%         /(resnorm/(T-n_peaks*3-1+3));
%     %     F = (resnorm/(T-n_peaks*3))/(resnorm_old/(T-n_peaks*3-3))
%     Fcrit = finv(1-alpha,3,T-n_peaks*3-1+3);
%     %     P = fcdf(F,T-n_peaks*3-3,T-n_peaks*3)
%     
%     if F >= Fcrit
%         %     if P < alpha
%         % Collect the "significant" parameters
%         parameters = p;
%         Jacob = J;
%         
%         % Updapte the statistics
%         significant = 1;
%         resnorm_old = resnorm;
%         
%         % Update the constraints
%         LB = cat(2,LB,lb);
%         UB = cat(2,UB,ub);
%         
%         % Guess the new n+1 peak parameters from the residuals
%         [height,max] = extrema(-residual);
%         if numel(height) > 0
%             % update guess with current params and next guess
%             guess = cat(2,p,[height(1);x(max(1));x(3)-x(1)]);
%         else
%             significant = 0;
%             break
%         end
%         
%     else
%         significant = 0;
%     end
%     
% end

% % Final test against background-only model
% 
% guess_bg = [1;x(1);30];
% p_bg = lsqcurvefit(@lsq_exponential,guess_bg,x,y,[0 -inf 0],[inf inf inf],opt);
% residuals = lsq_exponential(p_bg,x) - y;
% resnorm_bg = sum(residuals.^2);
% % F-Test
% F_bg = ((resnorm_bg-resnorm)/(3*n_peaks)) ...
%     /(resnorm/(T-n_peaks*3 -1 +3));
% Fcrit = finv(1-alpha,3*n_peaks,T-n_peaks*3-1+3);
% if F_bg < Fcrit
%     parameters = p_bg;
%     Jacob = [];
% end
% 
% if nargout > 1, varargout{1} = residuals; end
% if nargout > 2, varargout{2} = Jacob;
% if ~exist('parameters','var'), parameters = []; end
% 
% end
