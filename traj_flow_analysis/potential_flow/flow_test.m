flat = @(x) x(:);
nbins = 25;
zA = 0;

Ws = cell(1,5);
[Ws{1},x,y] = power_law(1,pi/4,1,-10:1:10);
Ws{2} = source_sink_swirl(1i,zA,-10:1:10);
Ws{3} = source_sink_swirl(1,zA+1,-10:1:10);
Ws{4} = source_sink_swirl(-1,0,-10:1:10);
Ws{5} = doublet(1,0);
name = {'uniform','swirl','source','sink','doublet'};

for i = 1:5

    W = Ws{i};
    [Vx,Vy] = velocity_from_potential(W);

    figure(1);
    g((i-1)*3+1) = subplot(5,3,(i-1)*3+1);
    contourf(x,y,imag(W)),axis equal;axis tight;
    title(['Streamline function for ' name{i} ' flow'])
    
    h((i-1)*3+2) = subplot(5,3,(i-1)*3+2);
    quiver(x,y,Vx,Vy,0,'Linewidth',1), axis tight square;
    title([name{i} ' vector field'])
    V = cat(3,Vx,Vy);
    V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
    centroids = grid2list(x(:),y(:));
    
    [Cvv,R] = spatial_correlation_function(V,centroids,nbins,'off','off');
    k((i-1)*3+3) = subplot(5,3,(i-1)*3+3);
    plot(R,Cvv), axis tight square;
    title('Spatial correlation function')
    xlabel('Distance of separation (R)')
    ylabel('SCF')
end
linkaxes(h)
linkaxes(g)
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


%%

flat = @(x) x(:);
num_var = 10;
nbins = 25;
Cvv = zeros(num_var,nbins);
for i = 1:num_var
    zA = [-5+5i 5i 5+5i,...
        -5 0 5,...
        -5-5i -5i 5-5i ];
    
    [W0,x,y] = power_law(1,pi/4,1,-10:1:10);
    W1 = source_sink_swirl((i-1)*3i+1i,zA,-10:1:10);
    W2 = source_sink_swirl((i-1)*3,zA+1,-10:1:10);
    W3 = source_sink_swirl(i*-5,0,-10:1:10);
    W4 = doublet(1*i,0);
    W5 = vortex(10,1*i,-1+1i,-10:1:10);
    
    W = W4;
    [Vx,Vy] = velocity_from_potential(W);
    if any(i == [1,5,10])
        switch i, case 1, n = 1; str = '0'; case 5, n = 2; str = 'pi/6'; case 10, n = 3; str = 'pi/3'; end
        figure(2)
        g(n) = subplot(1,3,n);
        contourf(x,y,imag(W)),axis equal;axis tight;
        title(['Streamline function for ' str 'angle of attack'])
        figure(3)
        h(n) = subplot(1,3,n);
        quiver(x,y,Vx,Vy,0,'Linewidth',1), axis tight square;
        title([str ' angle of attack (of uniform field).'])
        %         figure(2)
        %         pcolor(x,y,imag(W))
    end
    
    V = cat(3,Vx,Vy);
    V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
    centroids = grid2list(x(:),y(:));
    [Cvv(i,:),R] = spatial_correlation_function(V,centroids,nbins,'off','off');
end

linkaxes(h)
linkaxes(g)
figure;
[foo,bar] = meshgrid(R,1:num_var);
pcolor(foo,bar,Cvv); colorbar

xlabel('Distance (R)')
ylabel('Angle of attack (radians)')
title('Global normalization')

%%


%%
flat = @(x) x(:);
nbins = 50;

x = -20:1:20;
zA = [-10+10i 10i 10+10i,...
    -10 0 10,...
    -10-10i -10i 10-10i ];
% zA = 0

[W0,X,Y] = power_law(1,pi/4,1,x);
W1 = source_sink_swirl(10,zA,x);
W2 = doublet(1,zA,pi/2,x);

W = W0 + W1;
contourf(X,Y,imag(W),-50:1:50),axis equal;
[Vx,Vy] = velocity_from_potential(W);
figure,quiver(X,Y,Vx,Vy,0,'linewidth',1),axis equal

V = cat(3,Vx,Vy);
V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
centroids = grid2list(X(:),Y(:));
[Cvv,R] = spatial_correlation_function(V,centroids,nbins);
figure,plot(R,Cvv);
hold on, plot(R,0*ones(1,nbins),'r-');