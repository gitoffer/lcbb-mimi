%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% main M-file to run Bayesian FCS on input precomputed TACF curves %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This m-file accepts precomputed TACF curves
% and apply bayesian regression and model selection
% output results (parameter estimates, uncertainty, model probability) for
% each model.
% Jun He @ lcbb.mit, Mar 25,2011.

addpath('.\functions')
load('.\data\TACF_examp_13.mat') % load data
% input data: multiple "TACF" curves, with corresponding "t"
% format of "t": 1D matix (1xT), "T" is maximum lag time.
% format of "TACF": 2D matrix (nxT)
% first dimension "n" is number of TACF curves
% TACFs are with different noise level,(large number higher noise level) 
% larger cell index corresponds to lower noise level


%% fit with default otions
%%%%%%%%%%%%%%%%% % fiting options: 
% 1st argument after 'TACF': noise options
% 'resid' (noise estimated from fitting residuals)
% 'raw' (estimated from raw curves)

% 2nd argument after 'TACF': model options
% '2D' (fit 2D models)
% '3D' (fit 3D models)
% '3D_Trip' (fit triplet blinking state)

% 3nd argument after 'TACF':fitting options
% 'nw'(using un-weighted fitting); 
% 'w' (using weighted fitting)

[results_indiv results_mean] = Bayesian_TACF_analysis(t,TACF) % fit with default options: 'resid','3D','nw'

%% fit with specified otions
[results_indiv results_mean] = Bayesian_TACF_analysis(t,TACF,'raw','2D','w')

%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % about funciton: Bayesian_TACF_analysis                           %%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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





