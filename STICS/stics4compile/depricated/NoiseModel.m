classdef NoiseModel < BayesModels
%NOISEMODEL Subclass of BayesModels
% Use for displaying. Parses model parameters into physically meaningful fields
    properties
        floor
    end
    methods
        function obj = NoiseModel(p,log_l,model_p)
            if nargin == 0
                p = NaN;
                log_l = NaN;
                model_p = NaN;
            end
            if nargin == 2
                model_p = NaN;
            end
            obj = obj@BayesModels('noise_model',p,log_l,model_p);
            p = obj.parameters;
            obj.floor = p;
        end
        function new_obj = get_physical_parameters(obj)
            new_obj = obj;
            if isnan(obj.D) && ~any(isnan(obj.parameters))
                p = obj.parameters;
                new_obj.floor = p(1);
            end
        end
        function bar = estimate_initial_params(foo,corr,~,~,~)
            flat = @(x) x(:);
            G_inf = mean(flat(corr));
            
            b0(1) = G_inf;
            
            bar{1} = b0;
            bar{2} = -Inf;
            bar{3} = Inf;
            
        end
        function model = bayes(obj)
            model = BayesModels('noise_model',obj.parameters,obj,obj.log_likelihood,model_probability);
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
            s = sprintf('%s %.5f \t \n',...
                'Noise floor = ', obj.floor);
            disp(s);
        end
    end
end
