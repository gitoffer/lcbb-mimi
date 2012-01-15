%% Make STICS output square
% [signal,X,Y] = stics_square(stics_img,Xf,Yf);
signal = stics_img;
X = Xf; Y = Yf;

dR = 10;
Rmax = max(Y(:));
[N,M,~] = size(signal{1});

%% SCF along x
options = struct('time_avg','off','local','off','mean_subt','on');

index = 0;
for i = 1:16:numel(signal)
    index = index + 1;
    subplot(4,4,index);
    C_gl = zeros(N,24);
    for j = 1:N
        this_vector{1} = signal{i}(j,:,:);
        [C_gl(j,:),R] = get_scf4stics(this_vector,X(j,:),Y(j,:),dR,Rmax,stics_opt,options);
    end
    [foo,bar] = meshgrid(R,(Y(:,1))*stics_opt.um_per_px);
    pcolor(foo,bar,C_gl),colorbar;
    xlabel('Distance (\mum)')
    ylabel('Distance from midline (\mum)')
    title(['C(R) at t = ' num2str(i)]);

end

%% SCF along y

options = struct('time_avg','off','local','off','mean_subt','on');

index = 0;
for i = 1:16:numel(signal)
    index = index + 1;
    subplot(4,4,index);
    C_gl = zeros(24,M);
    for j = 1:M
        this_vector{1} = signal{i}(:,j,:);
        [C_gl(:,j),R] = get_scf4stics(this_vector,X(:,j),Y(:,j),dR,Rmax,stics_opt,options);
    end
    [foo,bar] = meshgrid(X(1,:)*stics_opt.um_per_px,R);
    pcolor(foo,bar,C_gl),colorbar;
    ylabel('Distance (\mum)')
    xlabel('Distance along x (\mum)')
    title(['C(R) at t = ' num2str(i)]);

end
