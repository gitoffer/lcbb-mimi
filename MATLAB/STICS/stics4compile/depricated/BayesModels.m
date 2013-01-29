classdef BayesModels
% BayesModels Class for handling model probability data in Bayesian model fitting.
    properties
        Model;              % String of model function file name
        parameters;
        log_likelihood;     % Log-likelihood assigned by Bayes
        model_probability;  % Normalized model probability given data
    end
    
    methods
        
        function obj = BayesModels(model_name,p,ml,mp)
            % Class constructor. If model_probability is unspecified, will
            % put NaN. Will not error out if there are no arguments.
            if nargin > 0
                if nargin >= 3
                    obj.Model = model_name;
                    obj.parameters = p;
                    obj.log_likelihood = ml;
                    obj.model_probability = NaN;
                end
                if nargin == 4
                    obj.model_probability = mp;
                end
            end
        end
        
        function new_array = assign_probability(obj_array)
            % Assigns model_probability given an object array if all
            % log_likelihoods are set.
            new_array = obj_array;
            log_likelihoods = [obj_array.log_likelihood];
            N = length(log_likelihoods);
			if ~isrow(log_likelihoods)
				log_likelihoods = log_likelihoods';
			end
			
			% Construct a matrix of log-differences
			log_diffs = log_likelihoods(ones(1,N),:) - log_likelihoods(ones(1,N),:)';

            % Add up all the exponentiated differences
			probabilities = 1./sum(exp(log_diffs),2);
            
            % If there are NaN or Inf probabilities, set to 0
			probabilities(isnan(probabilities) | isinf(probabilities)) = 0;
            
            % Assign to array
            for i = 1:N
                new_array(i).model_probability = probabilities(i);
            end
        end
        
        function sorted_array = sort_models(array,dim)
            %SORT_MODELS Sort an BayesModel array of size NxMxnum_models
            %according to model probability along the third dimension'
            %
            % N,M - spatial placements of STICS calculations
            % num_models - number of competing models
            %
            % NOTE: Generalize to be able to sort along any supplied
            % dimension.
            
            array = squeeze(array);
            if ndims(array) ~= 3
                error('Unsupported dimension of BayesModels array.')
            end
            [N,M,num_models] = size(array);
            probabilities = reshape([array.model_probability],N*M,num_models);
                [~,I] = sort(probabilities,2,'descend');
            I = reshape(I,N,M,num_models);
            for i = 1:N
                for j = 1:M
                    sorted_array(i,j,:) = array(i,j,I(i,j,:));
                end
            end
        end
        
        function index = find_model_by_name(model_array,name)
            % Returns the index in a model array given the name of the model
            if nargin > 0
                N = numel(model_array);
                for i = 1:N
                    if strcmp(model_array(i).Model,name)
                        index = i;
                        return
                    else
                        continue
                    end
                end
                error('Model name not found');
            end
        end
        function obj = convert(bayes_array)
            
            [N,M,num_models] = size(array);
            
            
            p = bayes_model.parameters;
            ml = bayes_model.log_likelihood;
            mp = bayes_model.model_probability;
			if ischar(bayes_model.Model)
	            switch bayes_model.Model
    	            case 'convection_model'
        	            obj = ConvectionModel(p,ml,mp);
            	    case 'diffusion_model'
	                    obj = DiffusionModel(p,ml,mp);
    	            case 'mixed_model'
        	            obj = MixedModel(p,ml,mp);
            	    case 'noise_model'
	                    obj = NoiseModel(p,ml,mp);
    	            otherwise
        	            error('Model not regonized.');
                end
            else
                error('Invalid model name.')
			end
        end
        function disp(obj)
            flat = @(x) x(:);
            obj_flat = flat(obj);
            for i = 1:length(obj_flat)
                convert(obj_flat(i))
            end
        end
    end
end
