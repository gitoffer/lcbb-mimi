function varargout = pcolor_coherence(vector,window_range,direction)
flat = @(x) x(:);

% stics_dots = zeros([length(vector),length(window_range)]);
avg_coherence = zeros([length(vector),window_range]);
% std_coherence = zeros([length(vector),length(window_range)]);
sigma = zeros(length(vector),1);
mu = zeros(length(vector),1);


if strcmpi(direction,'t')
    for i = 1:window_range
        stics_dots = getDotsTemporal(vector,i);
        for j = 1:length(vector)
            [sigma(j),mu(j)] = normfit(flat(stics_dots(:,:,j)));
        end
        avg_coherence(:,i) = sigma;
    end
    
else
    for i = 1:window_range
        stics_dots = getDots4Stics(vector,i,direction);
        for j = 1:length(vector)
            [sigma(j),mu(j)] = normfit(flat(stics_dots(:,:,j)));
        end
        i
        avg_coherence(:,i) = sigma;
    end
    
end

pcolor(avg_coherence)
title(['Average coherence in ' direction]);
xlabel('Window size')
ylabel('Time');
caxis([.5 1]);
colorbar;


if nargout > 0
    varargout{1} = avg_coherence;
end

end