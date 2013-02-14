% estimate_embryo_curvature

r = 50; % 3.5
h = 10;  % 0.7

%%

alpha = atan2(h,r);
s = h/asin(alpha);
gamma = pi/2-alpha;

R = s/(2*cos(gamma));

theta = asin(r/R);

theta_deg = rad2deg(theta);
curvature = 1/R;

display(['Transit angle (deg): ' num2str(theta_deg)]);
display(['Embryo curvature (a.u.): ' num2str(curvature)]);

%% Error as a function of angle

% Transverse length error:
thetas = linspace(0,theta,10);
delta_thetas = diff(thetas);
lengths = diff(thetas*R);

l_hats = (R-h)*(tan(thetas(1:end-1)+delta_thetas) - ...
    tan(thetas(1:end-1)));

thetas_deg = rad2deg(thetas);
figure,
plot(thetas_deg(2:end),abs(l_hats-lengths)./lengths);
xlabel('Degrees away from midline');
ylabel('Fraction error in arc length estimation');
