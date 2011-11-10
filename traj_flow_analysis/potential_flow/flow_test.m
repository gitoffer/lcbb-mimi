
%%
num_var = 20;
for i = 1:num_var
    
    [W0,x,y] = power_law(1,pi/4,1,-10:1:10);
    W1 = source_sink_swirl(i*.1i,0,-10:1:10);
    W2 = source_sink_swirl(i*1,0,-10:1:10);
    W3 = source_sink_swirl(-1,1-5i,-10:1:10);
    W4 = doublet(.1*i,0);
    W5 = vortex(10,1*i,-1+1i,-10:1:10);
    
    W = W0 + W4;
    [Vx,Vy] = velocity_from_potential(W);
    if any(i == [1,20])
        switch i, case 1, n = 1; str = 'low'; case 20, n = 2; str = 'high'; end
        figure(3)
        h(n) = subplot(1,2,n);
        quiver(Vx,Vy,0), axis equal, axis tight
        title([str ' power.'])
        %         figure(2)
        %         pcolor(x,y,imag(W))
    end
    
    V = cat(3,Vx,Vy);
    V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
    centroids = grid2list(x(:),y(:));
    [Cvv(i,:),R] = spatial_correlation_function(V,centroids,30);
end

linkaxes(h)
figure
[foo,bar] = meshgrid(R,1:num_var);
pcolor(foo,bar,Cvv),colorbar
xlabel('Distance (R)')
ylabel('Power')

%%


%%
flat = @(x) x(:);

x = -20:1:20;
zA = [0];

[W0,X,Y] = power_law(1,pi/4,1,x);
W1 = source_sink_swirl(10i*i,zA);

W = W0 + W1;
contour(X,Y,imag(W)),axis equal;
[Vx,Vy] = velocity_from_potential(W);
figure,quiver(Vx,Vy,0),axis equal

V = cat(3,Vx,Vy);
V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
centroids = grid2list(X(:),Y(:));
[Cvv,R] = spatial_correlation_function(V,centroids,26);
figure,plot(R,Cvv);