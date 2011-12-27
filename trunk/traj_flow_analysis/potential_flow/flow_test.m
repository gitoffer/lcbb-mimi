% MOCK-Embryo

flat = @(x) x(:);
x = (-200:8:200)*.16; % in microns
y = (1:8:400)*.16;
dR = 2; % in microns
Rmax = max(y) - min(y);

% Place sigularities
zA0 = [-500:25:500];
zA = [zA0 (rand(1,100)*400i-200i + rand(1,100)*1000)-500];
zA = zA0*.16;
Gamma0 = -15*ones(1,numel(zA0));
Gammas = [Gamma0 rand(1,100)*-15];
Gammas = Gamma0;

% Generate flow
[W,X,Y] = source_sink_swirl(Gammas,zA,x,y);
[Vx,Vy] = velocity_from_potential(W);
V = cat(3,Vx,Vy);
% get a list of velocities
V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
% V = normalize_vector_field(V);
[Vx,Vy] = list2grid(V,numel(y),numel(x));
% get a list of centroids
centroids = grid2list(X(:),Y(:));

% Generate SCFs
mean_subt = 'off';
opt = struct('local','off','mean_subt','off');
[C_gl,~] = spatial_correlation_function(V,centroids,dR,Rmax,opt);
opt = struct('local','on','mean_subt','off');
[C_loc,R] = spatial_correlation_function(V,centroids,dR,Rmax,opt);

figure
showsub_vert(...
    @contourf,{X,Y,real(W)},'Flow potential','axis equal tight',...
    @quiver,{X,Y,Vx,Vy,0,'linewidth',1},'Vector field','axis equal tight',...
    @plot,{R,C_loc,'r-',R,C_gl,'b-'},['Mean subtraction is ' mean_subt],'legend(''Local'',''Global'');'...
    );

%% Vary the number of bins

flat = @(x) x(:);
num_var = 25;
Cvv_gl = cell(1,num_var);
Cvv_loc = cell(1,num_var);
R = cell(1,num_var);
x = -200:8:200;
y = -80:8:80;

d = 50;
zA = [-200 -175 -150 -125 -100 -75 -50 -25 0 ...
    25 50 75 100 125 150 175 200];
% zA = [-60 -40 -20 0 20 40 60];
[W,X,Y] = source_sink_swirl(-10,zA,x,y);
[Vx,Vy] = velocity_from_potential(W);
V = cat(3,Vx,Vy);
V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
centroids = grid2list(X(:),Y(:));

hold all,colorset = varycolor(num_var);
set(gca,'colororder',colorset);
for i = 1:num_var
    dR = i;
    
    opt = struct('local','off','mean_subt','off');
    [Cvv_gl{i},~] = spatial_correlation_function(V,centroids,dR,75,opt);
    opt = struct('local','on','mean_subt','off');
    [Cvv_loc{i},R{i}] = spatial_correlation_function(V,centroids,dR,75,opt);
    plot(R{i},Cvv_loc{i});
end

%% Linear combination of simple flow fields

flat = @(x) x(:); num_var = 10;
x = (-100:8:100)*.16; % in microns
y = (-100:8:100)*.16;
dR = 2; % in microns
Rmax = max(y) - min(y);
nbins = numel(0:dR:Rmax);
C_gl = zeros(num_var,nbins); C_loc = C_gl;

% Generate different simple flow fields
zA = [0];
    
[W0,X,Y] = power_law(1,pi,1,x,y); % Uniform
W1 = source_sink_swirl(1i,zA,x,y); % Swirl
W2 = source_sink_swirl(-1,zA+1,x,y); % Sink
W3 = source_sink_swirl(1,0,x,y); % Source
W4 = doublet(1*i,0); % Doublet
W5 = vortex(1,1*i,-1+1i,x,y); % Vortex

plot_field = 1;
yaxis_label = 'swirl size';
for i = 1:num_var
    
    W = W0 + i*W1;
    [Vx,Vy] = velocity_from_potential(W);
    V = cat(3,Vx,Vy);
    V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
    centroids = grid2list(X(:),Y(:));
    
    % Get SCF
    opt = struct('local','off','mean_subt','on');
    [C_gl(i,:),~] = spatial_correlation_function(V,centroids,dR,Rmax,opt);
    opt = struct('local','on','mean_subt','on');
    [C_loc(i,:),R] = spatial_correlation_function(V,centroids,dR,Rmax,opt);

    % Plot underlying field (if turned on)
    if plot_field && any(i == [1,5,10])
        switch i, case 1, n = 1; str = 'low'; case 5, n = 2; str = 'medium'; case 10, n = 3; str = 'high'; end
        figure(1)
        g(n) = subplot(1,3,n);
        contourf(x,y,imag(W)),axis equal;axis tight;
        title(['Streamline function for ' str ' ' yaxis_label])
        figure(2)
        h(n) = subplot(1,3,n);
        quiver(x,y,Vx,Vy,0,'Linewidth',1), axis tight square;
        title(['Vector field for ' str ' ' yaxis_label])
    end
end
linkaxes(g); linkaxes(h);

% Plot SCFs
figure, subplot(1,2,1);
[foo,bar] = meshgrid(R,1:num_var);
pcolor(foo,bar,C_gl); colorbar, axis square
xlabel('Distance (R)'),title('Global normalization');

subplot(1,2,2);
pcolor(foo,bar,C_loc); colorbar, axis square
xlabel('Distance (R)'),title('Local normalization');

%% Plots normal/global SCF together
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

%% Plots simple flow fields
flat = @(x) x(:);
dR = 5;
Rmax = 100;
zA = 0;

x = -50:1:50;
y = -50:1:50;
Ws = cell(1,5);
[Ws{1},X,Y] = power_law(10,pi/4,1,x,y);
Ws{2} = source_sink_swirl(10i,zA,x,y);
Ws{3} = source_sink_swirl(10,zA+1,x,y);
Ws{4} = source_sink_swirl(-10,0,x,y);
Ws{5} = doublet(1,0,0,x,y);
name = {'uniform','swirl','source','sink','doublet'};

for i = 1:5
    opt_gl = struct('local','off','mean_subt','off');
    opt_loc = struct('local','off','mean_subt','off');
    
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
        [Cvv,R] = spatial_correlation_function(V,centroids,dR,Rmax,opt_gl);
        
        h((i-1)*4+3) = subplot(3,4,(i-1)*4+3);
        plot(R,Cvv), axis tight square;
        title('Spatial correlation function (global normalized)')
        xlabel('Distance of separation (R)')
        ylabel('SCF')
        
        [Cvv,R] = spatial_correlation_function(V,centroids,dR,Rmax,opt_loc);
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
        [Cvv,R] = spatial_correlation_function(V,centroids,dR,Rmax,opt_gl);
        
        g((i-4)*4+3) = subplot(2,4,(i-4)*4+3);
        plot(R,Cvv), axis tight square;
        title('Spatial correlation function (global normalized)')
        xlabel('Distance of separation (R)')
        ylabel('SCF')
        
        [Cvv,R] = spatial_correlation_function(V,centroids,dR,Rmax,opt_loc);
        g((i-1)*4+4) = subplot(2,4,(i-4)*4+4);
        plot(R,Cvv), axis tight square;
        title('Spatial correlation function (local normalized)')
        xlabel('Distance of separation (R)')
        ylabel('SCF')
        
    end
end