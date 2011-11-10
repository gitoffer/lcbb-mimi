%%
N = 10;
for i = 1:10
    
    lsq_opt = optimset('Jacobian','off','Display','off');
    
    d = 1*i;
    psf = 1;
    params = [1 0 d 1 1];
    constants = [psf .1 .1];
    xdata = [30 30 1 9];
    f = 'mixed_model';
    noise_level = 1;
    
    G_th = feval(f,params,xdata,constants);
%     G_th = G_th(:,:,2:end);
    
    %     [X,Y] = meshgrid(-10:1:10,-10:1:10);
    %     figure(201)
    %     mesh(X,Y,G_th(:,:,1));
    %     axis equal
    %     xlabel('\eta')
    %     ylabel('\xi')
    %     zlabel('G(\eta,\xi,\tau)')
    %     title(['STICS Correlation function for ' f ' at \tau = 0']);
    %     display(['The real model is ' f ' and noise level set at ' num2str(noise_level)])
    %
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
hold on;
plot([output_array(:,1).model_probability],'g-');
plot([output_array(:,2).model_probability],'r-')
plot([output_array(:,3).model_probability],'b-')
plot([output_array(:,4).model_probability],'k-')