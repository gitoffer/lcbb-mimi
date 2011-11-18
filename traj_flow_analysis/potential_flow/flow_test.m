

%%

flat = @(x) x(:);
num_var = 10;
nbins = 25;
Cvv = zeros(num_var,nbins);
x = -10:1:10;
y = -50:1:50;

for i = 1:num_var
    zA = [0];
    
    [W0,X,Y] = power_law(1,pi,1,x,y);
    W1 = source_sink_swirl(5*i*1i,zA,x,y);
    W2 = source_sink_swirl((i-1)*3,zA+1,x,y);
    W3 = source_sink_swirl(i*-5,0,x,y);
    W4 = doublet(1*i,0);
    W5 = vortex(10,1*i,-1+1i,x,y);
    
    W = W0 + W1;
    [Vx,Vy] = velocity_from_potential(W);
    if any(i == [1,5,10])
        switch i, case 1, n = 1; str = 'low'; case 5, n = 2; str = 'medium'; case 10, n = 3; str = 'high'; end
        figure(2)
        g(n) = subplot(1,3,n);
        contourf(x,y,imag(W)),axis equal;axis tight;
        title(['Streamline function for ' str ' swirl size'])
        figure(3)
        h(n) = subplot(1,3,n);
        quiver(x,y,Vx,Vy,0,'Linewidth',1), axis tight square;
        title([str ' swirl size + uniform field.'])
        %         figure(2)
        %         pcolor(x,y,imag(W))
    end
    
    V = cat(3,Vx,Vy);
    V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
    centroids = grid2list(X(:),Y(:));
    [Cvv_gl(i,:),R] = spatial_correlation_function(V,centroids,nbins,'off','off');
    [Cvv_loc(i,:),R] = spatial_correlation_function(V,centroids,nbins,'on','off');
end

linkaxes(h)
linkaxes(g)
figure;
subplot(1,2,1)
[foo,bar] = meshgrid(R,1:num_var);
pcolor(foo,bar,Cvv_gl); colorbar,axis square

xlabel('Distance (R)')
ylabel('Swirl size')
title('Global normalization')

subplot(1,2,2)
[foo,bar] = meshgrid(R,1:num_var);
pcolor(foo,bar,Cvv_loc); colorbar,axis square

xlabel('Distance (R)')
ylabel('Swirl size')
title('Local normalization')

%%


%%
flat = @(x) x(:);
nbins = 50;

x = -50:1:50;
y = -10:1:10;
zA = [-70i, 70i];
gammas = [1000 1000];
% zA = 0

[W0,X,Y] = power_law(1,pi/4,1,x,y);
W1 = source_sink_swirl(gammas,zA,x,y);

W = W1;
figure,contourf(X,Y,imag(W)),axis equal;
[Vx,Vy] = velocity_from_potential(W);

V = cat(3,Vx,Vy);
V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));

[Vx,Vy] = list2grid(V,numel(y),numel(x));
figure,quiver(X,Y,Vx,Vy,0,'linewidth',1),axis equal

centroids = grid2list(X(:),Y(:));
[Cvv_gl,R] = spatial_correlation_function(V,centroids,nbins,'off','off');
figure,plot(R,Cvv_gl);
hold on, plot(R,0*ones(1,nbins),'r-');

[Cvv_loc,R] = spatial_correlation_function(V,centroids,nbins,'on','off');
hold on,plot(R,Cvv_loc,'g-');

%%
flat = @(x) x(:);
nbins = 25;
zA = 0;

x = -10:1:10;
y = -50:1:50;
Ws = cell(1,5);
[Ws{1},X,Y] = power_law(10,pi/4,1,x,y);
Ws{2} = source_sink_swirl(10i,zA,x,y);
Ws{3} = source_sink_swirl(10,zA+1,x,y);
Ws{4} = source_sink_swirl(-10,0,x,y);
Ws{5} = doublet(1,0,0,x,y);
name = {'uniform','swirl','source','sink','doublet'};

for i = 4:5
    
    if i <4
        W = Ws{i};
        [Vx,Vy] = velocity_from_potential(W);
        
        figure(1);
        h((i-1)*4+1) = subplot(3,4,(i-1)*4+1);
        contourf(x,y,imag(W)),axis equal;axis tight;
        title(['Streamline function for ' name{i} ' flow'])
        
        h((i-1)*4+2) = subplot(3,4,(i-1)*4+2);
        quiver(x,y,Vx,Vy,0,'Linewidth',1), axis equal;
        title([name{i} ' vector field'])
        V = cat(3,Vx,Vy);
        V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
        centroids = grid2list(X(:),Y(:));
        [Cvv,R] = spatial_correlation_function(V,centroids,nbins,'off','off');
        
        h((i-1)*4+3) = subplot(3,4,(i-1)*4+3);
        plot(R,Cvv), axis tight square;
        title('Spatial correlation function (global normalized)')
        xlabel('Distance of separation (R)')
        ylabel('SCF')
        
        [Cvv,R] = spatial_correlation_function(V,centroids,nbins,'on','off');
        h((i-1)*4+4) = subplot(3,4,(i-1)*4+4);
        plot(R,Cvv), axis tight square;
        title('Spatial correlation function (local normalized)')
        xlabel('Distance of separation (R)')
        ylabel('SCF')
        
    else
        W = Ws{i};
        [Vx,Vy] = velocity_from_potential(W);
        
        figure(2);
        g((i-4)*4+1) = subplot(2,4,(i-4)*4+1);
        contourf(x,y,imag(W)),axis equal;axis tight;
        title(['Streamline function for ' name{i} ' flow'])
        
        g((i-4)*4+2) = subplot(2,4,(i-4)*4+2);
        quiver(x,y,Vx,Vy,0,'Linewidth',1), axis equal;
        title([name{i} ' vector field'])
        V = cat(3,Vx,Vy);
        V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
        centroids = grid2list(X(:),Y(:));
        
        [Cvv,R] = spatial_correlation_function(V,centroids,nbins,'off','off');
        g((i-4)*4+3) = subplot(2,4,(i-4)*4+3);
        plot(R,Cvv), axis tight square;
        title('Spatial correlation function (global normalized)')
        xlabel('Distance of separation (R)')
        ylabel('SCF')
        
        [Cvv,R] = spatial_correlation_function(V,centroids,nbins,'on','off');
        g((i-1)*4+4) = subplot(2,4,(i-4)*4+4);
        plot(R,Cvv), axis tight square;
        title('Spatial correlation function (local normalized)')
        xlabel('Distance of separation (R)')
        ylabel('SCF')
        
    end
end
% 
% W = W0;
% [Vx,Vy] = velocity_from_potential(W);
% if any(i == [1,5,10])
%     switch i, case 1, n = 1; str = '0'; case 5, n = 2; str = 'pi/6'; case 10, n = 3; str = 'pi/3'; end
%     figure(2)
%     g(n) = subplot(1,3,n);
%     contourf(x,y,imag(W)),axis equal;axis tight;
%     title(['Streamline function for ' str 'angle of attack'])
%     figure(3)
%     h(n) = subplot(1,3,n);
%     quiver(x,y,Vx,Vy,0,'Linewidth',1), axis tight square;
%     title([str ' angle of attack (of uniform field).'])
% end
% 
% V = cat(3,Vx,Vy);
% V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
% centroids = grid2list(x(:),y(:));
% [Cvv,R] = spatial_correlation_function(V,centroids,nbins,'off','off');
