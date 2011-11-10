classdef SticsOptions
    properties
        um_per_px;
        sec_per_frame;
        dt;
        wt;
        dx;
        dy;
        wx;
        wy;
        corrTimeLim;
        dimensions;
        crop;
        ch;
        bayes;
    end
    methods
        function obj = SticsOptions(upp,spf,dt,wt,dx,dy,wx,wy,ctl,dim,crop,ch,b)
            obj.um_per_px = upp;
            obj.sec_per_frame = spf;
            obj.dt = dt;
            obj.wt = wt;
            obj.dx = dx;
            obj.dy = dy;
            obj.wx = wx;
            obj.wy = wy;
            obj.corrTimeLim = ctl;
            obj.dimensions = dim;
            obj.crop = crop;
            obj.ch = ch;
            obj.bayes = b;
        end
    end
end