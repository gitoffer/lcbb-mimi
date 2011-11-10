classdef MixedModel < BayesModels
    properties
        D
        vx
        vy
    end
    methods
        function obj = MixedModel(p,log_l,model_p)
            if nargin == 0
                p = [NaN NaN NaN NaN NaN];
                log_l = NaN;
                model_p = NaN;
            end
            if nargin == 2
                model_p = NaN;
            end
            obj = obj@BayesModels('mixed_model',p,log_l,model_p);
            p = obj.parameters;
            obj.D = p(3);
            obj.vx = p(5);
            obj.vy = p(4);
        end
        function that = get_physical_parameters(this)
            that = this;
            if isnan(this.D) && ~any(isnan(this.parameters))
                p = this.parameters;
                that.D = p(3);
                that.vx = p(5);
                that.vy = p(4);
            end
        end
        function bar = estimate_initial_params(~,corr,input,stics_opt,pb)
            
            flat = @(x) x(:);
            G000 = max(flat(corr)) - min(flat(corr));
            G_inf = min(flat(corr));
            xdata = input.xdata;
            
            xf = xdata(1);
            x = (1:xf)*stics_opt.um_per_px;
            yf = xdata(2);
            y = (1:yf)*stics_opt.um_per_px;
            t0 = xdata(3);
            tf = xdata(4);
            t = (t0:tf)*stics_opt.sec_per_frame;
            t = t';
            
            b0 = zeros(1,5);
            b0(1) = G000;
            b0(2) = G_inf;
            %D
            b0(3) = (G000-max(flat(corr(:,:,2))))/(t(2)-t(1));
            %vx
            [~,i] = max(max(corr(:,:,1),[],2));
            [~,j] = max(max(corr(:,:,2),[],2));
            b0(3) = (x(i)-x(j))/(t(2)-t(1));
            %vy
            [~,i] = max(max(corr(:,:,1),[],1));
            [~,j] = max(max(corr(:,:,2),[],1));
            b0(4) = (y(i)-y(j))/(1);
            lb = [0 -Inf 0 -Inf -Inf];
            ub = [Inf Inf Inf Inf Inf];
            
            if pb
                lambda = G000 - max(flat(corr(:,:,2)));
                b0(end+1) = lambda;
            end
            bar{1} = b0;
            bar{2} = lb;
            bar{3} = ub;
            
        end
        function model = bayes(obj)
            model = BayesModels('mixed_model',obj.parameters,obj,obj.log_likelihood,model_probability);
        end
        function display(obj)
            % Overrides default display(...)
            s = sprintf('\n %s \t',...
                obj.Model);
            disp(s);
            s = sprintf('%s %.5f', ...
                'Model probability: ', obj.model_probability);
            disp(s);
            s = sprintf('%s',...
                'Parameters: ');
            disp(s);
            s = sprintf('%s %.5f \t',...
                'D = ', obj.D);
            disp(s);
            s = sprintf('%s %.5f \t %s %.5f \t',...
                'vx = ', obj.vx, 'vy = ', obj.vy);
            disp(s);
        end
    end
end
