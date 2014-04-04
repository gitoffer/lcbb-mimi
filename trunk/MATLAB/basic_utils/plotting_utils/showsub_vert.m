function showsub_vert(varargin)
%SHOWSUB_VERT Subplots with arbitrary graphic methods (e.g. pcolor, plot, mesh,
%imagesc, etc.) Will link axis by default.
%
% The input order is: @graphing_method, {arguments}, title, options
%
% SYNOPSIS:
% showsub(@imshow,{image,[]},'Title 1','colorbar',...,num_rows);
%
% xies@mit Jan 2012

if mod(nargin,4) ~= 1, error('Input in the format {@plot_method,data,title,gca_opt...}'); end

N = (nargin-1)/4;
num_rows = varargin{end};
num_columns = ceil(N/num_rows);

% xaxis_title = 'Distance (\mum)';
% yaxis_title = 'SCF';

for i = 1:4:nargin-1
    plot_method = varargin{i};
    data = varargin{i+1};
    fig_title = varargin{i+2};
    gca_opt = varargin{i+3};
    subplot(num_rows,num_columns,ceil(i/4))
    feval(plot_method,data{:});
    eval(gca_opt);
    title(fig_title);
%     xlabel(xaxis_title);
%     ylabel(yaxis_title);
end

end