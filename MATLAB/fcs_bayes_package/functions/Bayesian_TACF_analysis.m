function [results_indiv results_mean] = Bayesian_TACF_analysis(t,TACF, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% main M-file to run Bayesian FCS on input precomputed TACF curves %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This m-file accepts precomputed TACF curves
% and apply bayesian regression and model selection
% output results (parameter estimates, uncertainty, model probability) for
% each model.
% Jun He @ lcbb.mit, Mar 20,2011.

%%%%%%% Input list ::
% % t : array of lag time
% % TACF :  multiple "TACF" curves
% % format of "t": 1D matix (1xT), "T" is maximum lag time.
% % format of "TACF": 2D matrix (nxT)
% % first dimension "n" is number of TACF curves
% example TACFs are with different noise level,(large number higher noise level) larger cell index corresponds to  higher noise level

%%%%%%%  options input list ::
% % varargin: input fiting options
% % 
% % varargin{1}: noise options
% % 'resid' (noise estimated from fitting residuals)
% % 'raw' (estimated from raw curves)
noise_opt = 'resid'; % default
% % 
% % varargin{2}: model options
% % '2D' (fit 2D models)
% % '3D' (fit 3D models)
% % '3D_Trip' (fit triplet blinking state)
model_opt = '3D';  % default
% % 
% % varargin{3}: fitting options
% % 'nw'(using un-weighted fitting); 
% % 'w' (using weighted fitting)
fit_opt = 'nw'; % default

%%%%%%% Output list :: 
% % results_indiv = (data structure: results of analyzing individual curves)
% %  
% %         b1comp: [nx3 double] (parameter estimates of 1 component model,n is dimension of parameters)
% %         b2comp: [nx5 double]
% %         b3comp: [nx7 double]
% %         b4comp: [nx9 double]
% %      bstd1comp: [nx3 double] (parameter uncertainty of 1 component model)
% %      bstd2comp: [nx5 double]
% %      bstd3comp: [nx7 double]
% %      bstd4comp: [nx9 double]
% %     logML1comp: [nx1 double] (log of marginal likelihood of 1 component model)
% %     logML2comp: [nx1 double]
% %     logML3comp: [nx1 double]
% %     logML4comp: [nx1 double]
% %        PM1comp: [nx1 double] (model probability of 1 component model)
% %        PM2comp: [nx1 double]
% %        PM3comp: [nx1 double]
% %        PM4comp: [nx1 double]
% % 
% % 
% % results_mean = (data structure: results of analyzing mean curves)
% % 
% %         b1comp: [1x3 double] (parameter estimates of 1 component model)
% %         b2comp: [1x5 double]
% %         b3comp: [1x7 double]
% %         b4comp: [1x9 double]
% %      bstd1comp: [1x3 double] (parameter uncertainty of 1 component model)
% %      bstd2comp: [1x5 double]
% %      bstd3comp: [1x7 double]
% %      bstd4comp: [1x9 double]
% %     logML1comp: [1x1 double] (log of marginal likelihood of 1 component model)
% %     logML2comp: [1x1 double]
% %     logML3comp: [1x1 double]
% %     logML4comp: [1x1 double]
% %        PM1comp: [1x1 double] (model probability of 1 component model)
% %        PM2comp: [1x1 double]
% %        PM3comp: [1x1 double]
% %        PM4comp: [1x1 double]






if ~isempty(varargin)
    if numel(varargin)==1
        noise_opt = varargin{1};
    elseif numel(varargin)==2
        noise_opt = varargin{1};
        model_opt = varargin{2}; 
    elseif numel(varargin)>=3
        noise_opt = varargin{1};
        model_opt = varargin{2}; 
        fit_opt = varargin{3};
    end
end

addpath('..\functions')
%% %%%%%%%%%%%%%%% fit individual curves%%%%%%%%%%%% 

corrFCS_mean = mean(squeeze(TACF));
corrFCS_std = std(squeeze(TACF));

for i = 1 : size(TACF,1) % get residuals from three component model, and estimate std of noise
    corrFCS_fit = TACF(i,:);
    a  =  fit_FCS_TACF(t,corrFCS_fit,'D2d3comp');
    resid(i,:) = corrFCS_fit - diff3popu(a, t);
end

if strcmp(noise_opt,'raw') % two ways to estimate standard devation 
    err = corrFCS_std ;
elseif strcmp(noise_opt,'resid')
    err = std(resid);
end

for i = 1 : size(TACF,1)
    t_fit = t;
    corrFCS_fit = TACF(i,:);
    
    if strcmp(model_opt,'2D')
        [a_1pop std_beta1 logML1pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D2d1comp', err, fit_opt);
        [a_2pop std_beta2 logML2pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D2d2comp', err, fit_opt);
        [a_3pop std_beta3 logML3pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D2d3comp', err, fit_opt);
        [a_4pop std_beta4 logML4pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D2d4comp', err, fit_opt);
    elseif strcmp(model_opt,'3D')
        [a_1pop std_beta1 logML1pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d1comp', err, fit_opt);
        [a_2pop std_beta2 logML2pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d2comp', err, fit_opt);
        [a_3pop std_beta3 logML3pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d3comp', err, fit_opt);
        [a_4pop std_beta4 logML4pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d4comp', err, fit_opt);
    elseif strcmp(model_opt,'3D_Trip')
        [a_1pop std_beta1 logML1pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d1compTrip', err, fit_opt);
        [a_2pop std_beta2 logML2pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d2compTrip', err, fit_opt);
        [a_3pop std_beta3 logML3pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d3compTrip', err, fit_opt);
        [a_4pop std_beta4 logML4pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d4compTrip', err, fit_opt);
    end
    PM_D1comp = exp(logML1pop-logML2pop);
    PM_D2comp = exp(logML2pop-logML2pop);
    PM_D3comp = exp(logML3pop-logML2pop);
    PM_D4comp = exp(logML4pop-logML2pop);
    P_total = PM_D1comp  + PM_D2comp +  PM_D3comp + PM_D4comp;
    PM_D1comp = PM_D1comp/P_total;
    PM_D2comp = PM_D2comp/P_total;
    PM_D3comp = PM_D3comp/P_total;
    PM_D4comp = PM_D4comp/P_total;
    
    results_indiv.b1comp(i,:) = a_1pop;
    results_indiv.b2comp(i,:) = a_2pop;
    results_indiv.b3comp(i,:) = a_3pop;
    results_indiv.b4comp(i,:) = a_4pop;
    
    results_indiv.bstd1comp(i,:) = std_beta1;
    results_indiv.bstd2comp(i,:) = std_beta2;
    results_indiv.bstd3comp(i,:) = std_beta3;
    results_indiv.bstd4comp(i,:) = std_beta4;
    
    results_indiv.logML1comp(i,1) = logML1pop;
    results_indiv.logML2comp(i,1) = logML2pop;
    results_indiv.logML3comp(i,1) = logML3pop;
    results_indiv.logML4comp(i,1) = logML4pop;
    
    results_indiv.PM1comp(i,1) = PM_D1comp;
    results_indiv.PM2comp(i,1) = PM_D2comp;
    results_indiv.PM3comp(i,1) = PM_D3comp;
    results_indiv.PM4comp(i,1) = PM_D4comp;
end

%% %%%%%%%%%%%%%%% fit mean curves%%%%%%%%%%%% 

corrFCS_fit = corrFCS_mean;
    
if strcmp(model_opt,'2D')
    [a_1pop std_beta1 logML1pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D2d1comp', err, fit_opt);
    [a_2pop std_beta2 logML2pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D2d2comp', err, fit_opt);
    [a_3pop std_beta3 logML3pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D2d3comp', err, fit_opt);
    [a_4pop std_beta4 logML4pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D2d4comp', err, fit_opt);
elseif strcmp(model_opt,'3D')
    [a_1pop std_beta1 logML1pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d1comp', err, fit_opt);
    [a_2pop std_beta2 logML2pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d2comp', err, fit_opt);
    [a_3pop std_beta3 logML3pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d3comp', err, fit_opt);
    [a_4pop std_beta4 logML4pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d4comp', err, fit_opt);
elseif strcmp(model_opt,'3D_Trip')
    [a_1pop std_beta1 logML1pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d1compTrip', err, fit_opt);
    [a_2pop std_beta2 logML2pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d2compTrip', err, fit_opt);
    [a_3pop std_beta3 logML3pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d3compTrip', err, fit_opt);
    [a_4pop std_beta4 logML4pop] = fit_FCS_TACF(t_fit,corrFCS_fit,'D3d4compTrip', err, fit_opt);
end
PM_D1comp = exp(logML1pop-logML2pop);
PM_D2comp = exp(logML2pop-logML2pop);
PM_D3comp = exp(logML3pop-logML2pop);
PM_D4comp = exp(logML4pop-logML2pop);
P_total = PM_D1comp  + PM_D2comp +  PM_D3comp + PM_D4comp;
PM_D1comp = PM_D1comp/P_total;
PM_D2comp = PM_D2comp/P_total;
PM_D3comp = PM_D3comp/P_total;
PM_D4comp = PM_D4comp/P_total;

results_mean.b1comp = a_1pop;
results_mean.b2comp = a_2pop;
results_mean.b3comp = a_3pop;
results_mean.b4comp = a_4pop;

results_mean.bstd1comp = std_beta1;
results_mean.bstd2comp = std_beta2;
results_mean.bstd3comp = std_beta3;
results_mean.bstd4comp = std_beta4;

results_mean.logML1comp = logML1pop;
results_mean.logML2comp = logML2pop;
results_mean.logML3comp = logML3pop;
results_mean.logML4comp = logML4pop;

results_mean.PM1comp = PM_D1comp;
results_mean.PM2comp = PM_D2comp;
results_mean.PM3comp = PM_D3comp;
results_mean.PM4comp = PM_D4comp;
    
    