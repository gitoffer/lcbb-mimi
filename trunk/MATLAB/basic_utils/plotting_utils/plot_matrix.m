function varargout = plot_matrix(X,Y,palette,legends)

[num_points,num_plot] = size(Y);

if size(X) ~= size(Y)
    if ~isvector(X)
        error('Input X must be a vector or the same size as Y');
    else
        if num_plot ~= numel(X)
            if iscolumn(X)
                X = X(:,ones(1,size(Y,2)));
            else
                X = X(ones(1,size(Y,1)),:)';
            end
        end
    end
end

figure(501);
for i = 1:num_plot
    plot(X(:,i),Y(:,i),'color',palette(i,:));
    hold on
end
hold off

if nargin > 3
    legend(legends);
end

h = gca;

if nargout > 0
    varargout{1} = h;
end
