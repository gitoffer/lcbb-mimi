function constriction_rate = calculate_constriction_rate(measurement,p,visualize)
%CALCULATE_CONSTRICTION_RATE Calculates constriction rate from
%median-filtered data of cell area as a function of time.
%
% SYNOPSIS: constriction_rate = calculate_constriction_rate(measurement,p,visualize)
%
% INPUT: measurements - array of EDGE measurements
%        p - parameters of calculation:
%            .t0 - initial time to be analyzed
%            .tf - final frame
%            .sec_per_frame - time resolution of imaging
%            .dt - step size of finite-difference
%            .filt_w - median filter window size (one wing)
%        visualize - 'on'/'off' (Default off)
%
% xies@mit.edu 10/2011

cell_area = extract_msmt_data(measurement,'area');
[T,Z,N] = size(cell_area);

if N > 1 && Z > 1, error('Too many cells/slices!'); end

if ~exist('p','var'),p.m = 1;end
if ~exist('visualize','var'),visualize = 'off';end

% Set values to default if not supplied.
if ~isfield(p,'t0'),t0 = 1;else t0 = p.t0; end
if ~isfield(p,'tf'),tf = T;else tf = p.tf; end
if ~isfield(p,'sec_per_frame')
    sec_per_frame = 1;
else
    sec_per_frame = p.sec_per_frame;
end
if ~isfield(p,'dt'),dt = 1;else dt = p.dt; end
if ~isfield(p,'filt_w'),filt_w = 1;else filt_w = p.filt_w; end

% Extract area data of desired range
cell_area = squeeze(cell_area(t0:tf,:,:));

% Use median-filter of window size FILT_W
cell_area = full(smooth2a(cell_area,filt_w,0));

% Finite difference approximation of area derivative
constriction_rate = -(cell_area(1+dt:end,:,:) - cell_area(1:end-dt,:,:))./(2*dt);

if strcmpi(visualize,'on')
    figure(10000)
    plot((t0:tf)*sec_per_frame,cell_area);
    figure(10001)
    plot((t0+.5:tf-.5)*sec_per_frame,constriction_rate);
end