function h = plot_pdf(observations,nbins,varargin)

switch nargin
    case 0
        error('Need at least 1 input!');
    case 1
        nbins = 30;
end

if isvector(observations) && isrow(observations)
    observations = observations';
end

[counts,bins] = hist(observations,nbins);
prob_mass = sum(counts,1);
counts = counts./prob_mass(ones(1,nbins),:);
bar(bins,counts);

h = findobj(gca,'Type','patch');
if nargin > 2
    set(h,varargin{:});
end

% for i = 1:num_var
%     [counts] = hist(observations(:,i),edges);
%     counts = counts/nansum(counts);
%     hold on
%     bar(edges,counts);
%     
%     h = findobj(gca,'Type','patch');
%     
%     if nargin > 2
%         set(h,opts{i,:});
%     end
% end
% hold off

end
