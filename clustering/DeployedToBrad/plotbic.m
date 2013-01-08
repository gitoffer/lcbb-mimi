function plotbic(bics,varname)
% Plot the values of the BIC for model-based clustering
%
%   PLOTBIC(BICS,VARNAME)
%   This takes the results of MBCLUST and plots the values
%   of the BIC for the various models.
%   
%   You can plot the variable name in the title via the optional 
%   argument VARNAME.

%   Model-based Clustering Toolbox, January 2003
%   Revised June 2004 to add all 9 models.

% Set up the symbols for plotting.
symbs = {'o','x','+','*','s','d','p','h','v'};
cmap = [.26 .72 .73;
    .12 .25 .09;
    .83 .63 .09;
    .23 .73 1;
    .88 0.55 .42;
    .55 .22 .79;
    .73 .23 .56;
    1 .97 .78;
    .55 .7 .51];    

% Now plot the results of the BIC
warning off
[m,nc] = size(bics);
hold on
for i = 1:m
	ind = find(bics(i,:) == 0);
	% set them to Nan so they won't plot
	bics(ind) = 0/0;
    plot(1:nc,bics(i,:),symbs{i})
end
for i = 1:m
    line('xdata',1:nc,'ydata',bics(i,:),'color',cmap(i,:))
end
axs = axis;
axis([0 nc + 1 axs(3) axs(4)])
set(gca,'XTick',0:(nc + 1))
xlabel('Number of clusters')
ylabel('BIC')

[maxbic,maxi] = max(bics(:));
[mi,mj] = ind2sub(size(bics),maxi);

if nargin==1
    title(['Model ' int2str(mi) ', ' int2str(mj) ' clusters is optimal.' ])
else
    title([varname, ': Model ' int2str(mi) ', ' int2str(mj) ' clusters is optimal.' ])
end
warning on

legend({'1: \Sigma_k = \lambda I',...
        '2: \Sigma_k = \lambda_k I',...
        '3: \Sigma_k = \lambda B',...
        '4: \Sigma_k = \lambda B_k',...
        '5: \Sigma_k = \lambda_k B_k',...
        '6: \Sigma_k = \lambda DAD''',...
        '7: \Sigma_k = \lambda D_k A D_k''',...
        '8: \Sigma_k = \lambda D_k A_k D_k''',...
        '9: \Sigma_k = \Sigma_k'},0)

