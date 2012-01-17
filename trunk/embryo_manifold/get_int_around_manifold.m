function [int_found,fraction_found] = get_int_around_manifold(img_stack,manifold,extract_params,im_params)
%GET_INT_AROUND_MANIFOLD Returns the intensity found within within +/- n
% levels around the manifold seeded by embryo myosin intensity (presumptive
% apical surface).
%
% SYNOPSIS: int_found = 
%	 	get_int_around_manifold(img_stack,manifold,extract_params,im_params)
% get_int_around_manifold(img_stack,manifold,nZ,n_levels,interp);
%
% INPUT: img_stack - image stack whose intensity is of interest
%        manifold - the smoothened index locations of the myosin manifold
%				 extract_params.n_levels - number of levels (on each side) from in
%																	 the manifold to include in the final
%																	 data
%				 extract_params.interp - 'on'/'off' Turn interpolation between
%																 manifold indicies on
%				 extract_params.interp_alpha - should be 0.5
%
% OUTPUT: int_found - intensity found within +/- n_levels of the manifold
%					fraction_found - total fraction of image intensity included in
%													 the manifold
%
% xies@mit.edu Jan 2012.

n_levels = extract_params.n_levels;
interp = extract_params.interp;
alpha = extract_params.interp_alpha;
Z = im_params.Z;

[X,Y] = size(manifold);
int_found = zeros(X,Y,2*n_levels + 1); % Intensity broken down by layers
total_int = zeros(X,Y);
layers_around = -n_levels:n_levels;
layers_around = permute(layers_around,[2 3 1]);
layers_around = layers_around(ones(1,X),ones(1,Y),:);
manifold = manifold(:,:,ones(1,numel(-n_levels:n_levels)));

if strcmpi(interp,'on')

  manifold_layers = manifold + layers_around;
	% Anything higher than Z is sent to Z
	manifold_layers(manifold_layers > Z) = Z;
	% Anything lower than 1 is sent to 1
	manifold_layers(manifold_layers < 1) = 1;

	% Only operate on meaningful
	pixels_to_avg = manifold_layers >= 1 & manifold_layers <= Z;
	manifold_layers = manifold_layers(pixels_to_avg);
	manifold_floor = floor(manifold_layers);
	manifold_ceil = ceil(manifold_layers);
	% Interpolation (1-a)*floor + a*ceil
	int_found = (1-alpha)*img_stack(:,:,manifold_floor) + alpha*img_stack(:,:,manifold_ceil);

else

	manifold_layers = round(manifold + layers_around);
	manifold_layers(manifold_lyaers > Z) = Z;
	manifold_layers(manifold_layers < 1) = 1;
	%pixels_mask = manifold >= 1 & manifold <= Z;
	int_found = img_stack(:,:,manifold_layers);

end

if nargout > 1
	fraction_found = sum(int_found(:))/sum(img_stack(:));
end

end




function Mstuff=get_stuff_around_manifold(stuff,mfold,nz,mf,interp)

xdim=size(mfold,1);
ydim=size(mfold,2);

Mstuff=zeros(xdim,ydim,2*mf+1);  %return stuff on each of 2n+1 layers
tot_Mstuff=zeros(xdim,ydim);    %total stuff captured around 2n+1 layers of manifold

k=0;
for m=-mf:mf %from layer -mf to layer +mf
    k=k+1;
    depth=mfold+m;
    depth(depth>nz)=nz;
    depth(depth<1)=1;
    if(interp==1) %make weighted average if depth(x,y) not integer
        for i=1:xdim
            for j=1:ydim
                if (depth(i,j)>=1 && depth(i,j)<=nz)
                    indf=floor(depth(i,j));
                    indc=ceil(depth(i,j));
                    alpha=mod(depth(i,j),1);
                    Mstuff(i,j,k)=(1-alpha)*stuff(i,j,indf)+alpha*stuff(i,j,indc);
                    tot_Mstuff(i,j)=tot_Mstuff(i,j)+Mstuff(i,j,k);
                end
            end
        end
    else %round depth(x,y) to next integer
        depth=round(mfold+m);
        depth(depth>nz)=nz;
        depth(depth<1)=1;
        for i=1:xdim
            for j=1:ydim
                if (depth(i,j)>=1 && depth(i,j)<=nz)
                    Mstuff(i,j,k)=stuff(i,j,depth(i,j));
                    tot_Mstuff(i,j)=tot_Mstuff(i,j)+Mstuff(i,j,k);
                end
            end
        end
        
    end
end
%
s for m=1:k  %fractional content in each layer
%     Mstuff(:,:,m)=Mstuff(:,:,m)./tot_Mstuff(:,:);
% end

%fraction of total stuff captured in +-layers
totstuff=sum(stuff(:,:,:),3);

%figure(6); clf; imagesc(tot_Mstuff./totstuff,[0,1]);colorbar;
sum(tot_Mstuff(:))/sum(totstuff(:));


end
