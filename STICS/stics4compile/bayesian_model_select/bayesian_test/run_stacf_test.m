%%
N = 100;
for i = 1:10
    
    lsq_opt = optimset('Jacobian','off','Display','off');
    
    G000 = 10^(i-5);
    G_inf = 0;
    D = .5;
    psf = 1;
    params = [G000 G_inf D .1 -.2 .1 .1 psf];
    constants = [psf .1 .1];
    xdata = [30 30 1 9];
    f = 'mixed_model';
    noise_level = G000/10;
    
    G_th = feval(f,params,xdata,constants);
%     G_th = G_th(:,:,2:end);
    
        [X,Y] = meshgrid(-14:1:15,-14:1:15);
        figure(201)
        mesh(X,Y,G_th(:,:,1));
        axis equal
        xlabel('\eta')
        ylabel('\xi')
        zlabel('G(\eta,\xi,\tau)')
        title(['STICS Correlation function for ' f ' at \tau = 0']);
        display(['The real model is ' f ' and noise level set at ' num2str(noise_level)])
    
    o = SticsOptions(.1,.1,32,32,32,32,32,32,10,1,1,1,1);
    models = {
        'mixed_model', ...
        'diffusion_model', ...
        'flow_model', ...
        'noise_model' ...
        };
    photobleaching = 0;
    weighted_fit = 1;
    psf_size = .4;
    bayes_o = BayesOptions(models,photobleaching,weighted_fit,psf_size,100);
    
    tic
    output_array(i,:) = stacf_test(G_th,N,noise_level,xdata,lsq_opt,o,bayes_o);
    toc
end

%% Visualize the outcome
figure;
xaxis = 10*((1:10)-5);
hold on;
plot(xaxis,[output_array(:,1).model_probability],'g-');
plot(xaxis,[output_array(:,2).model_probability],'r-')
plot(xaxis,[output_array(:,3).model_probability],'b-')
plot(xaxis,[output_array(:,4).model_probability],'k-')
legend('Mixed','diffusion','flow','noise')