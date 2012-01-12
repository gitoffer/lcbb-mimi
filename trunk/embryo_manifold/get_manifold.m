function manifold = get_manifold(myosin_thresh,manifold_params,im_params)
%GET_MANIFOLD Generates a smooth manifold (indices) from a thresholded myosin stack.
%
% SYNOPSIS: manifold = get_manifold(thresholded_myosin,m_params,im_params);
%
% INPUT: thresholded_myosin - (locally) thresholded myosin stacks
%		 manifold_params.smoothing - Gaussian size for smothing
%		 manifold_params.avg_slice - slice cutoff during index averaging
%	     manifold_params.display - 'on'/'off'
% 		 im_params.Z - slices in Z
% OUTPUT: manifold (2D numeric array)
%
% xies@mit Jan 2011. Modified from Adam martin.


% Sort myosin-intensity along z and return the ranked index.
[myosin_sorted, intensity_index] = sort(myosin_thresh,3,'descend');
% Project in Z total myosin intensity.
myosin_thresh = sum(myosin_sorted,3);
% Divide sorted myosin by total intensity... This yields relative contribution fro each slice
myosin_sorted = myosin_sorted./myosin_tresh(:,:,ones(1,im_params.Z));
mysoin_sorted(isnan(myosin_sorted)) = 0;

% Get weighted-average...
index = sum(myosin_sorted(:,:,1:manifold_params.avg_slice).*intensity_index(:,:,1:manifold_params.avg_slice));
if strcmpi(manifold.params.display, 'on')
	figure(21); clf; imagesc(index,[0,nz]);colorbar;
	title('Discrete myosin indices');
end

%% Remove outliers in z-depth, testing against average z-depth values in AP axis.
% Assumption: There should be no strong 'uneven-ness' in AP axis.
%if pr_params.mem_mask
%	index_weighted = myosin_index.*mem_mask;
%end
%%
%Remove strong deviations compared to 
%typical depth values in a-p direction, assuming no strong depth varyation in posterior anterior
%direction. Consider measurements within a dn thick slice in a-p direction
%indq=indq.*MembMask;       % remove membrane contribution from depth data
%dn=16;                     % thickness of slice in A-P direction
%for n=1:dn:ydim            % remove leftovers of membrane which typically deviate strongly from structure myosin
%    A=indq(:,n:n+dn-1);    %use this line if AP-axis vertically
%    A=indq(n:n+dn-1,:);    %use this line if AP-axis horiz
%    [r,c,v]=find(A);
%    m=mean(v); s=std(v);
%    A(A>(m+s))=0;          %this must be adjusted if embryo is tilted
%   indq(:,n:n+dn-1)=A;    %change this line if AP-acis vertically
%    indq(n:n+dn-1,:)=A;    %use this line if ap axis horizontally
%end
%clear A;
%figure(30); clf; imagesc(indq,[0,nz]); colorbar;

%% Making the smooth manifold

% Make a 'mask' of where the myosin is
myosin_mask = double(index > 0);
% Smooth/blur the index (which is discrete) by a Gaussian filter
index_sm = gaussian_filter(index,pr_params.support,manifold_params.smoothing,'off','off');
% Smooth/blur the mask by the same kernel
myosin_mask_sm = gaussian_filter(myosin_mask,pr_params.support,manifold_params.smoothing,'off','off');
% Divide the smoothed index by the mask, to 'normalize' the index
index_sm(index_sm > 0) = index_sm(myosin_mask > 0)./myosin_sm(myosin_sm > 0);
manifold =index_sm;

if strcmpi(manifold_params.display, 'on')
	figure(40); clf; imagesc(manifold,[0,Z]); colorbar;
	title('Final smooth manifold');
end

end
