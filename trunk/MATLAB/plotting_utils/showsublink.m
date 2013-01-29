function showsublink(varargin)
%SHOWSUB Subplots with arbitrary graphic methods (e.g. pcolor, plot, mesh,
%imagesc, etc.) Will link axis by default.
%
% The input order is: @graphing_method, {arguments}, title, options
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

index = 0;
h = zeros(1,N);

for i = 1:4:nargin
    %total count of figures
    index = index + 1;
    plot_method = varargin{i};
    data = varargin{i+1};
    fig_title = varargin{i+2};
    gca_opt = varargin{i+3};
    % set subplot indices
    h(index) = subplot(num_rows,num_columns,ceil(i/4));
    % evaluate plotting method
    feval(plot_method,data{:});
    % evalutate options (e.g. axis equal)
    eval(gca_opt);
    % put title on figure
    title(fig_title);
end

linkaxes(h);

end