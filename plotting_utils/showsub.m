function showsub(varargin)

if mod(nargin,4) ~= 0, error('Input in the format {@plot_method,data,title,gca_opt...}'); end

N = (nargin-1)/4;
num_columns = 3;
num_rows = ceil(N/3);

xaxis_title = 'Distance (\mum)';
yaxis_title = 'SCF';

for i = 1:4:nargin
    plot_method = varargin{i};
    data = varargin{i+1};
    fig_title = varargin{i+2};
    gca_opt = varargin{i+3};
    subplot(num_rows,num_columns,ceil(i/3))
    feval(plot_method,data{:});
    eval(gca_opt);
    title(fig_title);
    xlabel(xaxis_title);
    ylabel(yaxis_title);
end