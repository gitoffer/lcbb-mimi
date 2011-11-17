function o = fit_model_calc_bayes(observed_data,observed_var,in,lsq_opt,stics_o,bayes_o)

VERBOSE = 0;
flat = @(x) x(:);

%FIT_MODEL_CALC_BAYES
% Uses LSQCURVEFIT to perform least-squares fitting of the form $y = f(x,b)
% where x is the independent variable and b the parameters of the model f.
%
% Then computes the log-likelihood of the data given the model via Laplace
% approximation, given the matrix of errors. Optionally, can perform
% weighted LSQ fitting.
%
% SYNOPSIS: out = fit_model_calc_bayes(
%            observed_data,observed_var,in,window,lsq_opt,stics_o,bayes_o)
%
% INPUT:    observed_data - data that you want to fit
%			observed_var  - variation in observed data
%           in    - structure of input information
%               in.Model - name of the function used by the model
%               in.xdata - x, independent variable
%               in.InitParams - initial parameters
%           lsq_opt - optimization options as set by Optimset
%           bayes_o - fitting options
% OUTPUT:   o - array of structs containing model information

% Parse input
model_name = in.Model; % Model to fit to data
b0 = in.InitParams; % Initial guess for paramters
lb = in.LowerBound; % Lowerbounds on paramters
ub = in.UpperBound; % Upperbounds
xdata = in.xdata;   % Matrix of lag-variable coordinate grid
constants = [bayes_o.psf_size stics_o.um_per_px stics_o.sec_per_frame]; % Imaging parameters
eval(['f = @' model_name ';']);

% Parse options
weighted_regression = bayes_o.weighted_fit; % Boolean, turns on/off weighted fitting
photobleaching = bayes_o.photobleaching;
window = bayes_o.prior_window;

% Data fitting

% LSQCUTVEFIT from optimization toolbox, does least-squares optimization on
% the residual of the data-fitting problem. The inline anonymous function
% is used to pass the fit_weights to the function

if weighted_regression
    try
        fit_weights = 1./observed_var;
%         observed_data = observed_data.*fit_weights;
        %         fw = @(x,xdata) fit_weights.*f(x,xdata,s);
        [b,~,residual,~,~,~,J] = lsqcurvefit(...
            @(x,xdata) f(x,xdata,constants).*fit_weights,...
            b0,xdata,observed_data.*fit_weights,lb,ub,lsq_opt);
    catch err
        if (strcmp(err.identifier,'optim:snls:InvalidUserFunction'))
            switch model_name
                case 'diffusion_model'
                    b = nan(1,3);
                case 'flow_model'
                    b = nan(1,4);
                case 'mixed_model'
                    b = nan(1,5);
                case 'noise_model'
                    b = nan(1,2);
            end
            o.model_name = model_name;
            o.params = b;
            o.log_likelihood = -Inf;
            o.model_probability = NaN;
            o.D = NaN;
            o.vx = NaN;
            o.vy = NaN;
            return
        else
            rethrow(err)
        end
    end
%     residual = reshape(residual,size(observed_data));
    residual = f(b,xdata,constants) - observed_data;
    resnorm = norm(flat(residual));
else % not weighted regression
    try
        [b,resnorm,residual,~,~,~,J] = lsqcurvefit(...
            @(x,xdata) f(x,xdata,constants),...
            b0,xdata,observed_data,lb,ub,lsq_opt);
    catch err
        if (strcmp(err.identifier, 'optim:snls:InvalidUserFunction'))
            switch model_name
                case 'diffusion_model'
                    b = nan(1,3);
                case 'flow_model'
                    b = nan(1,4);
                case 'mixed_model'
                    b = nan(1,5);
                case 'noise_model'
                    b = nan(1,2);
            end
            o.model_name = model_name;
            o.params = b;
            o.log_likelihood = -Inf;
            o.model_probability = NaN;
            o.D = NaN;
            o.vx = NaN;
            o.vy = NaN;
            return
        else
            rethrow(err)
        end
    end
    residual = reshape(residual,size(observed_data));
end

% p is the degrees of freedom
p = numel(b0);
% n is the number of independent data points
n = numel(residual);

% Covariance matrix of the parameters, given the Jacobian and residual
% <http://www.courses.rochester.edu/SASdocs/sashtml/stat/chap45/sect24.htm Reference>
mse = resnorm*n/(n-p);

% For weighted regression, need to correct the weighted statistics by the
% weight
if weighted_regression
    mse = sum(flat(residual.^2.*fit_weights))./sum(flat(fit_weights)).*n./(n-p);
end

if rcond(full(J'*J)) < 1e-8
    log_model_likelihood = -Inf;
    if VERBOSE > 1
        display('Covariance matrix is singular');
        display(['Assigning likelihooods to ' model_name ' as ' num2str(log_model_likelihood)])
    end
else
    
    covB = full(inv(J'*J));
    covB = covB*mse;
    sqrt_beta = sqrt(diag(covB));
    
    % Likelihood calculations
    
    % Check to see if Jacobian is invertible. If not, then we set log
    % likelihood to be infinite.
    
    
    % The marginal likelihood of the data given a set of parameters is:
    % $$ p(\vec{y}|\vec{\beta}) = \prod_{i+1}^n p(y_i|\vec{\beta}) =
    % \frac{1}{(2\pi)^(n/2)\prod\sigma_i}\exp\left\{-\sigma\frac{[y_i-f(x_i,\vec{\beta})]^2}{2\sigma_i}\right\}
    % $$
    % where $sigma_i$ is the error with respect to the parameters
    
    log_likelihood_data = - 0.5*sum(flat(residual.^2./observed_var));
    
    % The prior distribution of the parameters of the model is taken to be
    % uniform
    %    * Maybe later extend to other forms of the uniform - Jeffreys?
    
    log_prior_params = - log(prod(sqrt_beta)*(2*window)^p);
    
    % Laplace approximation (assumes we have unimodal distribution with respect
    % to the parameters)
    log_model_likelihood = (p/2)*log(2*pi) + ...
        (1/2)*log(abs(det(covB))) + ...
        log_likelihood_data + log_prior_params;
    
    if VERBOSE > 1
        display(['Log-likelihood of data is ' num2str(log_likelihood_data)]);
        display(['Log-likelihood of prior is ' num2str(log_prior_params)]);
        display(['Log of determinant of covariance matrix is ' num2str((1/2)*log(abs(det(covB))))])
        display(['Assigning likelihooods to ' model_name ' as ' num2str(log_model_likelihood)])
    end
end

o.model_name = model_name;
o.params = b;
o.log_likelihood = log_model_likelihood;
o.model_probability = NaN;
o.D = NaN;
o.vx = NaN;
o.vy = NaN;
% o = BayesModels(model_name,b,log_model_likelihood);

o
end
