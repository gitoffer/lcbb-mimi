function showsub(varargin)
%SHOWSUB Subplots
%
% SYNOPSIS:
% showsub(@imshow,{image,[]},'Title 1','colorbar',...);
%
% xies@mit Jan 2012

if mod(nargin,4) ~= 0, error('Input in the format {@plot_method,data,title,gca_opt...}'); end

% number of figures
N = nargin/4;

num_columns = 2;
num_rows = ceil(N/num_columns);

% xaxis_title = 'Distance (\mum)';
% yaxis_title = 'SCF';

index = 0;
for i = 1:4:nargin
    index = index + 1;
    plot_method = varargin{i};
    data = varargin{i+1};
    fig_title = varargin{i+2};
    gca_opt = varargin{i+3};
    subplot(num_rows,num_columns,ceil(i/4));
    feval(plot_method,data{:});
    eval(gca_opt);
    title(fig_title);
%     xlabel(xaxis_title);
%     ylabel(yaxis_title);
end
