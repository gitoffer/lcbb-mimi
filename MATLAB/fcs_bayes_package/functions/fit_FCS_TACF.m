function [a std_beta logML ML ] = fit_FCS_TACF(time,corr,model,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% M-file to run Bayesian analysis on single input TACF curves %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % This m-file accepts TACF data
% % and apply bayesian regression and model selection
% % output results (parameter estimates, uncertainty, model probability) for
% % each model.
% % Jun He @ lcbb.mit, Mar 12,2011.

%%%%%%% Input list ::
% % time (1d array): input lag time points
% % corr (1d array): input TACF data points at corresponding time points
% % model (string) : model name with
%%%%%%% Model Label List ::
% %     D2d1comp      : diffuion 2D 1 component
% %     D2d2comp
% %     D2d3comp
% %     D2d4comp
% %     D3d1comp      : diffuion 3D 1 component
% %     D3d2comp
% %     D3d3comp
% %     D3d4comp
% %     D3d1compTrip  : diffuion 3D 1 component with triplet state
% %     D3d2compTrip
% %     D3d3compTrip
% %     D3d4compTrip 
% % varargin: optional input of std of noise terms (1d array, same dimension as time and corr)
%%%%%%% Output list ::
% % a : parameter estimates
% % std_beta : parameter uncertainty (std)
% % logML : log of marginal likelihood
% % ML: marginal likelihood


    
    boxsize = 200; % flat prior box size
    s=4.5;  % aspect ratio of PSF: wz/wx
    opt = 'nw'; % 'w' weighted, 'nw' non-weighted
    if ~isempty(varargin) & numel(varargin) ==2
        opt = varargin{2};
    end

%%%%%% set initial condition for the model of choice
    if strcmp(model,'D2d1comp')
        a0 = zeros(1,3);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        a0(3) = max([min(corr) 0]);
        f = @diff1popu ;
    elseif strcmp(model,'D2d2comp')
        a0 = zeros(1,5);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        a0(3) =  min(corr);
        [a, residual,J,COVB] = nlinfit(time,corr,@diff1popu ,[a0(1),a0(2),(max(corr) - min(corr))/2]);
        a0(1) = abs(a(1)/2);
        a0(2) = abs(a0(2))*5;
        a0(3) = (max(corr) - min(corr))/2;
        a0(4) = a0(2)/25;
        a0(5) = max([min(corr) 0]);
        f = @diff2popu;
    elseif strcmp(model,'D2d3comp')
        a0 = zeros(1,7);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        a0(3) =  min(corr);
        [a, residual,J,COVB] = nlinfit(time,corr,@diff1popu ,[a0(1),a0(2),(max(corr) - min(corr))/2]);
        a0(1) = abs(a(1)/3);
        a0(4) = a0(2)*2;
        a0(6) = a0(2)/2;
        a0(3) = a0(1);
        a0(5) = a0(1);
        a0(7) = max([min(corr) 0]);
        f = @diff3popu;
    elseif strcmp(model,'D2d4comp')
        a0 = zeros(1,9);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        a0(3) =  min(corr);
        [a, residual,J,COVB] = nlinfit(time,corr,@diff1popu ,[a0(1),a0(2),(max(corr) - min(corr))/2]);
        a0(1) = abs(a(1)/4);
        a0(4) = a0(2)*2;
        a0(6) = a0(2)/2;
        a0(8) = a0(2)/10;
        a0(3) = a0(1);
        a0(5) = a0(1);
        a0(7) = a0(1);
        a0(9) = max([min(corr) 0]);
        f = @diff4popu;
    elseif strcmp(model,'D3d1comp')
        a0 = zeros(1,3);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        a0(3) = max([min(corr) 0]);
        f = @(a,t)diffusion_3Ds(a,t,s);
    elseif strcmp(model,'D3d2comp')
        a0 = zeros(1,5);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        [a, residual,J,COVB] = nlinfit(time,corr,@diff1popu ,[a0(1),a0(2),(max(corr) - min(corr))/2]);
        a0(1) = abs(a(1)/2);
        a0(2) = a(2); 
        a0(2) = abs(a0(2))*2;
        a0(3) = (max(corr) - min(corr))/2;
        a0(4) = a0(2)/2;
        a0(5) = max([min(corr) 0]);
        f = @(a,t)diffusion_3Ds_2popu(a,t,s);
    elseif strcmp(model,'D3d3comp')
        a0 = zeros(1,7);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        a0(7) =  min(corr);
        [a, residual,J,COVB] = nlinfit(time,corr,@diff1popu ,[a0(1),a0(2),(max(corr) - min(corr))/2]);
        a0(1) = abs(a(1)/3);
        a0(2) = a(2); 
        a0(3) = a0(1);
        a0(4) = a0(2)*2;
        a0(5) = a0(1);
        a0(6) = a0(2)/2;
        a0(7) = max([min(corr) 0]);
        f = @(a,t)diffusion_3Ds_3popu(a,t,s); 
    elseif strcmp(model,'D3d4comp')
        a0 = zeros(1,9);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        a0(7) =  min(corr);
        [a, residual,J,COVB] = nlinfit(time,corr,@diff1popu ,[a0(1),a0(2),(max(corr) - min(corr))/2]);
        a0(1) = abs(a(1)/4);    
        a0(2) = a(2); 
        a0(3) = a0(1);
        a0(4) = a0(2)*2;
        a0(5) = a0(1);
        a0(6) = a0(2)/2;
        a0(7) = a0(1);
        a0(8) = a0(2)*10;
        a0(9) = max([min(corr) 0]);
        f = @(a,t)diffusion_3Ds_4popu(a,t,s);
    elseif strcmp(model,'D3d1compTrip')
        a0 = zeros(1,5);
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        a0(3) = max([min(corr) 0]);
        a0(4) = 0.98;
        a0(5) = 5e-5;
        f = @(a,t)diffusion_3Ds_trip(a,t,s);
    elseif strcmp(model,'D3d2compTrip')
        a0(1) = (max(corr) - min(corr));
        a0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
         f = @(a,t)diffusion_3Ds(a,t,s);
        [a, residual,J,COVB] = nlinfit(time,corr,f,[a0(1),a0(2),(max(corr) - min(corr))/2]);
        a0(1) = abs(a(1)/2);
        a0(2) = abs(a0(2));
        a0(3) = (max(corr) - min(corr))/2;
        a0(4) = 10* a0(2);
        a0(5) = max([min(corr) 0]);
        a0(6) = 0.98;
        a0(7) = 5e-5;
        f = @(a,t)diffusion_3Ds_2popu_trip(a,t,s);
    elseif strcmp(model,'D3d3compTrip')
        a0 = zeros(1,9);
        n_bin = 10.^floor(log10(numel(time))) ; % Syuan-ming's method
        [nh,xout]= hist(corr,n_bin);
        [nh_s ind] = sort(nh, 'descend') ;
        a0(1) = xout(ind(2));
        a0(7) = max([min(corr) 0]);
        [dd t_ind] = min(abs(corr-((a0(1)-a0(3))/2+ a0(3)))) ;
        a0(2) = time(t_ind) ;
        a0(3) = a0(1)/3;
        a0(4) = a0(2)*5;
        a0(5) = a0(1)/3;
        a0(6) = a0(2)/5;
        a0(8) = 0.98;
        a0(9) = 5e-5;
        a0(1) = a0(1)/3;
        f = @(a,t)diffusion_3Ds_3popu_trip(a,t,s);
    elseif strcmp(model,'D3d4compTrip')
        a0 = zeros(1,11);
        n_bin = 10.^floor(log10(numel(time))) ; % Syuan-ming's method
        [nh,xout]= hist(corr,n_bin);
        [nh_s ind] = sort(nh, 'descend') ;
        a0(1) = xout(ind(2));
        a0(9) = max([min(corr) 0]);
        [dd t_ind] = min(abs(corr-((a0(1)-a0(3))/2+ a0(3)))) ;
        a0(2) = time(t_ind) ;
        a0(3) = a0(1)/3;
        a0(4) = a0(2)*5;
        a0(5) = a0(1)/3;
        a0(6) = a0(2)/5;
        a0(7) = a0(1)/3;
        a0(8) = a0(2)/20;
        a0(10) = 0.98;
        a0(11) = 5e-5;
        a0(1) = a0(1)/3;
        f = @(a,t)diffusion_3Ds_4popu_trip(a,t,s);
    end
    
%%%%%%% estimate variance of noise %%%%%%%%%%%%
    if isempty(varargin)
        b0 = zeros(1,4); % if without outside supplied variance, can be estimated from 1 model (can be changed by user)
        b0(1) = (max(corr) - min(corr));
        b0(2) = time(find(ismember(abs((max(corr) - min(corr))/2 - corr),min(min(abs((max(corr) - min(corr))/2 - corr)))),1,'first'));
        b0(4) = max([min(corr) 0]);
        b0(3) = sqrt(abs( (time(ceil(numel(time)/2))^2-time(1)^2)/ (log(corr(ceil(numel(time)/2)))-log(corr(1))) ));
        [b, resid] = nlinfit(time,corr,@diffusion_flow,b0);
        sigma_sq = sum(resid.^2)/(numel(resid)-4); 
        w = 1/sigma_sq.*ones(size(time));
    else
        w = 1./ varargin{1}.^2;
    end
    %%%%%%%%%%%%%%%%%%

%%%%%%% compute model probabilitiy %%%%%%%%%%%%   
%     [ a, residual,J,COVB] = nlinfit(time,corr,f,a0); % a pre-fit
    if strcmp(opt, 'w')
        [a, residual,J,COVB,mse] = nlinfitw (time,corr,f,a0,w); %[bFitw,rw,Jw,COVBw,msew]
    elseif strcmp(opt, 'nw')
        [a, residual,J,COVB] = nlinfit(time,corr,f,a0);
%         [a, residual,J,COVB] = good_fit(time,corr,f,a0);
        w = ones(size(time))*(1/mean(1./w));
    end
    std_beta = sqrt((diag(COVB)))';
    logML = 0.5*numel(a0)*log(2*pi)+ 0.5*log(abs(det(COVB))) - 0.5*( sum(residual.^2.*w));

%         logML = logML - log(prod(std_beta)*(2*boxsize)^numel(a));
    
    if any(isnan(COVB)) | any(isinf(COVB))
        logML = -inf;
    else
        if det(COVB)<0
            logML =-inf;
        else
        logML = logML - log(abs(det((COVB)))*(2*boxsize)^numel(a));
        end
    end
    
    if any(isinf(std_beta )) || isnan(logML)
        logML = -inf;
    end
    ML = exp(logML);
    

