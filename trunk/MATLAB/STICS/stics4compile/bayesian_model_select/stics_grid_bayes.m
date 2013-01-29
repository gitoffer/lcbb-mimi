function B = stics_grid_bayes(imser,Xf,Yf,stics_opt,bayes_opt,varargin)
%STICS_GRID_Bayes Calculates STICS function and model probability at each point in the image series.
%
% SYNOPSIS: [B Xf Yf] = stics_grid_bayes(imser,Xf,Yf,stics_opt,bayes_opt,varargin);
%
% Computes the STICS funcion for every grid point in the subimage, with sizes wx, wy.
% Optional inputs: varargin{1}=fitting limit; varargin{2}= whether show stic func (on/off)
%
% Added: Bayesian model selection framework. Aug 2011. xies@mit

wx = stics_opt.wx;
wy = stics_opt.wy;
corrTimeLim = stics_opt.corrTimeLim;

maxFrame = size(imser,3);
if isempty(varargin)
    %     fitTimeLimit = corrTimeLim;
    showsurf = 'off';
elseif numel(varargin)==1
    %     fitTimeLimit = varargin{1};
    showsurf = 'off';
else
    %     fitTimeLimit = min(varargin{1},corrTimeLim);
    showsurf = varargin{2};
end

models = bayes_opt.model_list;

frame1 =imser(:,:,1);
[X,Y]=size(Xf);
m = numel(models);
[B(X,Y,m).model_name,...
    B(X,Y,m).params, ...
    B(X,Y,m).log_likelihood,...
    B(X,Y,m).model_probability,...
    B(X,Y,m).D,...
    B(X,Y,m).vx,...
    B(X,Y,m).vy]...
    = deal([],[],NaN,NaN,NaN,NaN,NaN);

for i = 1:size(Xf,1)
    for j = 1:size(Xf,2)
        sub_imser = imser(Yf(i,j)-floor((wy-1)/2):Yf(i,j)+floor(wy/2), Xf(i,j)-floor((wx-1)/2):Xf(i,j)+floor(wx/2),1:maxFrame);
        % crop out subimage with dimensions wx, wy, centered at grid point
        
        [STCorr,ST_std] = stics(sub_imser, corrTimeLim); % compute stic funciton and the std
        if strcmp(showsurf,'on')
            figure(30)
            frame1(Yf(i,j)-floor((wy-1)/2):Yf(i,j)+floor(wy/2), Xf(i,j)-floor((wx-1)/2):Xf(i,j)+floor(wx/2))...
                =frame1(Yf(i,j)-floor((wy-1)/2):Yf(i,j)+floor(wy/2), Xf(i,j)-floor((wx-1)/2):Xf(i,j)+floor(wx/2))-0.5*mean(imser(:));
            imshow(frame1,[]);
            hold on
            plot(Xf(i,j),Yf(i,j),'.')
            axis on; hold on;
            imsequence_color(STCorr);
        end
        B(i,j,:) = bayes_stics(STCorr,ST_std,stics_opt,bayes_opt);
    end
end

end