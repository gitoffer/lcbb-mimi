function int_found = get_int_around_manifold(img_stack,manifold,nZ,n_levels,interp)
%GET_INT_AROUND_MANIFOLD Returns the intensity found within within +/- n
% levels around the manifold seeded by embryo myosin intensity (presumptive
% apical surface).
%
% SYNOPSIS: int_found =
% get_int_around_manifold(img_stack,manifold,nZ,n_levels,interp);
%
% INPUT: img_stack - image stack whose intensity is of interest
%        manifold -
%        nZ
%        n_levels - number of +/- levels to return
%        interp - (opt) 'on'/'off' to turn on interpolation between
%        confocal stacks when calculating intensity. (Default is on)

[X,Y] = size(manifold);
int_found = zeros(X,Y,2*n_levels + 1); % Intensity broken down by layers
% total_int = zeros(X,Y);

if ~exist('interp','var')
    interp = 'on';
end

mf_layers = -n_levels:n_levels;
if strcmpi(interp,'on')
    
else
    
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
% for m=1:k  %fractional content in each layer
%     Mstuff(:,:,m)=Mstuff(:,:,m)./tot_Mstuff(:,:);
% end

%fraction of total stuff captured in +-layers
totstuff=sum(stuff(:,:,:),3);

%figure(6); clf; imagesc(tot_Mstuff./totstuff,[0,1]);colorbar;
sum(tot_Mstuff(:))/sum(totstuff(:));


end