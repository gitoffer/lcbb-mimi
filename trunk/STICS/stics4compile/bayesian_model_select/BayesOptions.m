classdef BayesOptions
    properties
        model_list;
        photobleaching;
        weighted_fit;
        psf_size;
        prior_window;
    end
    methods
        function obj = BayesOptions(m_l,pb,w_f,s,w)
            obj.model_list = m_l;
            obj.photobleaching = pb;
            obj.weighted_fit = w_f;
            obj.psf_size = s;
            obj.prior_window = w;
        end
        function display(obj)
        % Overrides default display(...)    
            s = sprintf('\n %s %s \t', ...
                'Models to select from: ', obj.model_list{:});
            disp(s);
            s = sprintf('\n %s %.2f', 'PSF size (um): ', obj.psf_size);
            disp(s);
            s = sprintf('\n %s %d \n %s %d \n', ...
                'Fitting photobleaching: ', obj.photobleaching, ...
                'Weighted fitting according to standard error: ', obj.weighted_fit);
            disp(s);
        end
    end
end
