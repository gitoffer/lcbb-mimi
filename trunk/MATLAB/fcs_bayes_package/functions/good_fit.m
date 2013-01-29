function [beta resid  J COVB mse Hessian] = good_fit(x, y, model, beta0)
% use Newton method from 'lsqcurvefit'
    
    lb = [];
    ub = [];
    weights = ones(size(y));
    curvefitoptions = optimset('Display','off','MaxFunEvals',10000,'MaxIter',50000);
    
    [beta,resnorm,resid] = lsqcurvefit(model,beta0,x,y.*weights,lb,ub,curvefitoptions);
    
    yfit = model(beta ,x);
    nans = (isnan(y(:)) | isnan(yfit(:)));
    J = getjacobian(beta,10^-5,model,x,yfit,nans);
    
    mse = sum(resid.^2)/(numel(resid)-numel(beta)); 
    COVB = mse*(J'*J)^-1;
    std_beta = sqrt((diag(COVB))');
    Hessian = (J'*J);

function J = getjacobian(beta,fdiffstep,model,X,yfit,nans)
p = numel(beta);
delta = zeros(size(beta));
for k = 1:p
    if (beta(k) == 0)
        nb = sqrt(norm(beta));
        delta(k) = fdiffstep * (nb + (nb==0));
    else
        delta(k) = fdiffstep*beta(k);
    end
    yplus = model(beta+delta,X);
    dy = yplus(:) - yfit(:);
    dy(nans) = [];
    J(:,k) = dy/delta(k);
    delta(k) = 0;
end