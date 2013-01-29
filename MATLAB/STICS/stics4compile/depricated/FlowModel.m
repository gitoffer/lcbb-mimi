classdef FlowModel < BayesModels
    properties
        vx
        vy
    end
    methods
        function obj = ConvectionModel(p,log_l,model_p)
            if nargin == 0
                p = [NaN NaN NaN NaN];
                log_l = NaN;
                model_p = NaN;
            end
            if nargin == 2
                model_p = NaN;
            end
            obj = obj@BayesModels('flow_model',p,log_l,model_p);
            p = obj.parameters;
            obj.vx = p(4);
            obj.vy = p(3);
        end
        function new_obj = get_physical_parameters(obj)
            new_obj = obj;
            if isnan(obj.vx) && ~any(isnan(obj.parameters))
                p = obj.parameters;
                new_obj.vx = p(4);
                new_obj.vy = p(3);
            end
        end
        function bar = estimate_initial_params(foo,corr,input,stics_o,pb)
            
            flat = @(x) x(:);
            G000 = max(flat(corr)) - min(flat(corr));
            G_inf = min(flat(corr));
            xdata = input.xdata;
            
            xf = xdata(1);
            x = (1:xf)*stics_o.um_per_px;
            yf = xdata(2);
            y = (1:yf)*stics_o.um_per_px;
            t0 = xdata(3); tf = xdata(4);
            t = (t0:tf)*(stics_o.sec_per_frame);
            t = t';
            
            b0 = zeros(1,4);
            b0(1) = G000;
            b0(2) = G_inf;
            
            %vx
            [~,i] = max(max(corr(:,:,1),[],2));
            [~,j] = max(max(corr(:,:,2),[],2));
            b0(3) = (x(i)-x(j))/(t(2)-t(1));
            %vy
            [~,i] = max(max(corr(:,:,1),[],1));
            [~,j] = max(max(corr(:,:,2),[],1));
            b0(4) = (y(i)-y(j))/(1);
            lb = [0 -Inf -Inf -Inf];
            ub = [Inf Inf Inf Inf];
            
            if pb
                lambda = G000 - max(flat(corr(:,:,2)));
                b0(end+1) = lambda;
            end
            bar{1} = b0;
            bar{2} = lb;
            bar{3} = ub;
            
        end
        function model = bayes(obj)
            model = BayesModels('flow_model',obj.parameters,obj,obj.log_likelihood,model_probability);
        end
        function display(obj)
            % Overrides default display(...)
            if length(obj) ~= 1
                for i = 1:length(obj)
                    display(obj(i));
                end
            end
            s = sprintf('\n %s',...
                obj.Model);
            disp(s);
            s = sprintf('%s %.5f', ...
                'Model probability: ', obj.model_probability);
            disp(s);
            s = sprintf('%s',...
                'Parameters: ');
            disp(s);
            s = sprintf('%s %.5f \t %s %.5f \t \n',...
                'vx = ', obj.vx, 'vy = ', obj.vy);
            disp(s);
        end
    end
end
