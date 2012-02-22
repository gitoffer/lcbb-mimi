%% Calculate cross correlations between constriction rate and myosin

% Enter first and last time point
n1=1; %First time point
n2=50; %Last time point

dt=5.63/60; % enter time step in number of seconds

dtmatrix=[n1:n2]*dt; % time matrix for plotting figures

% enter data as area and myo and crop to desired time range
area=area_raw(:,n1:n2); 
myo=myo_raw(:,n1:n2);

[nc,nt]=size(area); % determine number of cells (nc) and number of time points (nt) 


% Smooth data

areasm=smooth2a(area,0,1); 
myosm=smooth2a(myo,0,1);

figure(1)
subplot(2,2,1)
imagesc(area); colorbar;
subplot(2,2,2)
imagesc(areasm);colorbar;
subplot(2,2,3)
imagesc(myo);colorbar;
subplot(2,2,4)
imagesc(myosm);colorbar;

% calculating constriction rates

cr = zeros(nc,nt);
mr = zeros(nc,nt);

dt_cr = 1;
nt0_cr = 2;
nt_cr = nt;
for i=1:nc
    for j=nt0_cr:nt_cr-dt_cr
        cr(i,j) = -(areasm(i,j+dt_cr)-areasm(i,j-dt_cr))/(2*dt_cr*dt);
        mr(i,j) =  (myosm(i,j+dt_cr)-myosm(i,j-dt_cr))/(2*dt_cr*dt);
%         cr(i,j) = -(ar(i,mint(j+dt_cr,nt_cr))-ar(i,max(j-dt_cr,nt0_cr)))/(2*dt_cr*ddt/60);
%         mr(i,j) = (myo_meant(i,mint(j+dt_cr,nt_cr))-myo_meant(i,max(j-dt_cr,nt0_cr)));
    end
end

figure(2)
subplot(2,2,1)
plot(dtmatrix,areasm(1,:),'Color','Red','Linewidth',2);
hold on;
plot(dtmatrix,cr(1,:),'Color','Blue','Linewidth',2);
hold off;

subplot(2,2,2)
plot(dtmatrix,areasm(10,:),'Color','Red','Linewidth',2);
hold on;
plot(dtmatrix,cr(10,:),'Color','Blue','Linewidth',2);
hold off;

subplot(2,2,3)
plot(dtmatrix,myosm(20,:),'Color','Red','Linewidth',2);
hold on;
plot(dtmatrix,mr(20,:),'Color','Blue','Linewidth',2);
hold off;

subplot(2,2,4)
plot(dtmatrix,myosm(30,:),'Color','Red','Linewidth',2);
hold on;
plot(dtmatrix,mr(30,:),'Color','Blue','Linewidth',2);
hold off;


%% Code to Calculate time-resolved Cross-Correlation between two signals

ntl=1; %starting time point at zero
ntr=nt; %ending time point at final end point
ntshift=20; %shift for correlations
corr=zeros(nc,2*ntshift+1); %defining size of matrix

% % If to NaN can use corrcoef
% for j=1:nc
%     for i=-ntshift:ntshift
%         crosscorr=corrcoef(cr(j,max(ntl,ntl+i):min(ntr,ntr+i)),mr(j,max(ntl,ntl-i):min(ntr,ntr-i)))
%         corr(j,i+ntshift+1)=crosscorr(1,2);
%     end
% end

% If data has NaN can use nancov to calculate correlation
for j=1:nc
    for i=-ntshift:ntshift
        matrix=[cr(j,max(ntl,ntl+i):min(ntr,ntr+i));mr(j,max(ntl,ntl-i):min(ntr,ntr-i))];
        matrix=matrix';
        covmatrix=nancov(matrix);
        
        crosscorr=zeros(2,2);
        variance=diag(covmatrix);
%         keyboard
        for p=1:2
            for q=1:2
            crosscorr(p,q)=covmatrix(p,q)/(sqrt(variance(p)*variance(q)));
            end
        end
    corr(j,i+ntshift+1)=crosscorr(1,2);
        
    end
end

figure(3)
imagesc([-ntshift ntshift],[0 nc],corr)
colorbar


figure(4)
avgcorr=nanmean(corr(:,:));
stdcorr=nanstd(corr);
% plot(avgcorr);
errorbar(-ntshift:ntshift,avgcorr,stdcorr);
% axis([-ntshift ntshift -1 1]);