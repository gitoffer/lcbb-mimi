function showsub(varargin)

if mod(nargin,4) ~= 0, error('Input in the format {@plot_method,data,title,gca_opt...}'); end

N = nargin/4;
num_columns = 2;
num_rows = ceil(N/num_columns);

% xaxis_title = 'Distance (\mum)';
% yaxis_title = 'SCF';

for i = 1:4:nargin
    plot_method = varargin{i};
    data = varargin{i+1};
    fig_title = varargin{i+2};
    gca_opt = varargin{i+3};
    subplot(num_columns,num_rows,ceil(i/4))
    feval(plot_method,data{:});
    h(i) = gca;
    eval(gca_opt);
    title(fig_title);
%     xlabel(xaxis_title);
%     ylabel(yaxis_title);
end
linkaxes(h)