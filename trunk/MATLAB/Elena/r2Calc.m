function [ r2, resnorm, params ] = r2Calc( toi , data)
%R2CALC TAKES THE DATA SET AND CALCULATES THE R2 VALUES

% Crops the frames of constant regression
constantreg = data(1:toi, :);
mean = nanmean(nanmean(constantreg(:)));
dataSize = size(data);
% The variance is the residual-squared
xi = 1:toi;
%nonan_idxi = ~isnan(mean_ivals); 
var1 = nanvar(nanvar(constantreg(:)));

%l = length(mean_ivals(nonan_idxi));
%iresiduals = mean_ivals(nonan_idxi) - ones(l,1)*mean;
%r2 = sum(iresiduals.^2);

%r2 = nanvar(constantreg(:));

% Polynomial fit
params = polyGen(data, toi);

% for i = toi:dataSize(1)
%     if ~isnan(nanmean(data(i,:),2))
%         resnorm = resnorm + (nanmean(data(i,:),2) - polyval(p,i))^2;
%     end
% end

x = toi:dataSize(1);
mean_vals = nanmean(data(x,:),2);
nonan_idx = ~isnan(mean_vals);
residuals = mean_vals(nonan_idx)' - polyval(params,x(nonan_idx));
resnorm = sum(residuals.^2);

% plot( ...
%     1:toi,nanmean(nanmean(data(1:toi,:)))*ones(1,toi), ...
%     x(nonan_idx),polyval(params,x(nonan_idx)) ...
% );
% hold on
% plot(nanmean(data,2),'r-');
keyboard

end 


