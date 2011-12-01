function thresh_stuff=get_stuff_threshold_fn(raw,Lxx,Lyy,top,remove_spurious)

xdim = size(raw,1);
ydim = size(raw,2);
ext=2*max(xdim,ydim);
nz=size(raw,3);
Lx=nextpow2(Lxx);
Ly=nextpow2(Lyy);

%% remove spurious pixels
if remove_spurious==1
    rstuff=double(raw);
    for n=1:nz
        raw(:,:,n)=uint8(get_filtered_gauss(raw(:,:,n),ext,1,0));
    end
end

%% delete everything below "top" intensity percent in a volume element
nx=xdim/Lx;
ny=ydim/Ly;
thresh_stuff=zeros(xdim,ydim); %array containing local threshold values

%generate location dependent threshold
for i=1:nx
    for j=1:ny
        X(i)=(i-1)*Lx+1;
        Y(j)=(j-1)*Ly+1;

    v=raw(X(i):X(i)+Lx-2, Y(j):Y(j)+Ly-2, :);
        
    v=v(:);        
    [counts,intens]=hist(v,[1:4095]); %do histogram
    C=cumsum(counts);
    C=C/max(C(:)); 
    thresh_stuff(X(i):X(i)+Lx-1,Y(j):Y(j)+Ly-1)=find(C>1-(top/100),1,'first');
    end
end
   

   figure(5); clf; imagesc(thresh_stuff);
    %smoothen the thresholds
    thresh_stuff=get_filtered_gauss(thresh_stuff,ext,20,0);
    thresh_stuff=thresh_stuff(1:xdim,1:ydim);
   figure(6); clf; imagesc(thresh_stuff);
   