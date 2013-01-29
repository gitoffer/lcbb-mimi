% Load DNA copy-number data
clear all;
y = load('dnagwas.txt');
N = length(y);
L = 10;
x = zeros(N,L);

% Iterated median filter
name{1} = 'Iterated medians';
x(:,1) = pwc_medfiltit(y,15);

% Classical K-means with K=5
name{2} = 'Classical K-means';
x(:,2) = pwc_cluster(y,5,0,0,0);

% Soft K-means with Gaussian kernel and K=3
name{3} = 'Soft K-means';
x(:,3) = pwc_cluster(y,3,1,80.0,1);

% Likelihood mean-shift with hard kernel
name{4} = 'Likelihood mean-shift';
x(:,4) = pwc_cluster(y,[],0,0.1,1);

% Soft mean-shift with Gaussian kernel
name{5} = 'Soft mean-shift';
x(:,5) = pwc_cluster(y,[],1,800.0,0);

% Total variation denoising
name{6} = 'Total variation denoising';
x(:,6) = pwc_tvdip(y,1.0);

% Robust total variation denoising
name{7} = 'Robust TVD';
x(:,7) = pwc_tvdrobust(y,10.0);

% Jump penalization
name{8} = 'Jump penalty';
x(:,8) = pwc_jumppenalty(y,1,1.0);

% Robust jump penalization
name{9} = 'Robust jump penalty';
x(:,9) = pwc_jumppenalty(y,0,1.0);

% Bilateral filter with Gaussian kernel
name{10} = 'Bilateral filter';
x(:,10) = pwc_bilateral(y,1,200.0,5);

% Plots
close all;
figure;
c = [0.6 0.6 0.6];
R = ceil(sqrt(L));
C = ceil(L/R);

for i = 1:L
    subplot(R,C,i);
    hold on;
    plot(y,'Color',c);
    plot(x(:,i),'b-');
    box on;
    axis tight;
    title(char(name{i}));
end
