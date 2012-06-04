% L1 Piece wise continuous autoregressive

cellID = 31;
area_sm = areas(:,cellID);
nonan_area = interp_and_truncate_nan(area_sm);
nonan_area(nonan_area == 0) = [];
acf = nanxcorr(nonan_area',nonan_area',20);

D_trunc = D(1:numel(nonan_area),1:numel(nonan_area));
gamma_ub = norm((D_trunc*D_trunc')\D_trunc*nonan_area',Inf);
gamma_lb = 2*nanstd(nonan_area);
[x,E,s] = l1pwc(nonan_area,gamma_ub,acf(1));
plot(nonan_area,'r-'),hold on,plot(x),plot(-diff(x),'g-')

if s
    E
    plot(nonan_area,'r-'),hold on,plot(x),plot(-diff(x),'g-');
else
    display('Failed.');beep;
end

%%

myosin_sm = myosins(:,cellID);
nonan_myosin = interp_and_truncate_nan(myosin_sm);
acf = nanxcorr(nonan_myosin',nonan_myosin',1);

D_trunc = D(1:numel(nonan_myosin),1:numel(nonan_myosin));
gamma_ub = norm((D_trunc*D_trunc')\D_trunc*nonan_myosin',Inf);
gamma_lb = 2*nanstd(nonan_area);
[x,E,s] = l1pwc(nonan_myosin,gamma_ub+gamma_lb/2,acf(1));
plot(nonan_myosin,'r-'),hold on,plot(x),plot(-diff(x),'g-')

%%
signal = nan(num_frames,num_cells);

for i = 1:num_cells
    area_sm = areas(:,i);
    if numel(area_sm(~isnan(area_sm))) > 2
        nonan_area = interp_and_truncate_nan(area_sm);
        first_idx = find(nonan_area ~= 0,1);
        nonan_area(nonan_area == 0) = [];
        acf = nanxcorr(nonan_area',nonan_area',1);
        
        D_trunc = D(1:numel(nonan_area),1:numel(nonan_area));
        gamma_ub = norm((D_trunc*D_trunc')\D_trunc*nonan_area',Inf);
        gamma_lb = 2*nanstd(nonan_area);
        [x,E,s] = l1pwc(nonan_area,gamma_lb,acf(1));
        plot(nonan_area,'r-'),hold on,plot(x),plot(-diff(x),'g-')
        
        if s
            signal(first_idx:first_idx + numel(nonan_area) -1,i)= x;
            plot(nonan_area,'r-'),hold on,plot(x),plot(-diff(x),'g-');
        else
            display('Failed.');beep;
        end
    end
    
end
