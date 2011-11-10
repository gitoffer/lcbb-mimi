function o = merge_ops(varargin)
% Purpose: simplify processing of optional function parameters, in cases
% where default values are available.
% Input:
%   optional set, default set of (key,value) pairs
%   default set is always a struct
%   optional set is either a struct or a list of key, value pairs
% Output:
%   A struct containing all the (key,values) from the optional set,
%   with any (key,values) present in the default set but not in the option
%   set added in.
%
%
% Used to process optional input struct passed to a function, applying
% o_default wherever necessary
%
% Example:
%   function y = f(x, varargin)
%       o_default = struct('k', 1);
%       o = merge_ops(varargin, o_default);
%       y = o.k*x
%   end
%
% Kirill Titievsky
%

o_default = varargin{end};

% FIXME: This can be done much safer
if isstruct(varargin{1})
    o = varargin{1};
else
    % if o is a list of key value pairs, we need to convert it
    if iscell(varargin{1})
        % this is the case of varargin here is a varargin of the calling
        % function passed in directly
        varargin = [varargin{1}, varargin{2:end}];
    end

    % now try to treate varargin is a flat list of (key, values)s
    try
        o = struct(varargin{1:end-1});
    catch
        o = struct();
        warning('', 'No optional arguments found. Using defaults.');
    end
    
end

keys = fieldnames(o_default);
% if the supplied o does not define a given parameter key-value pair,
% Take them from the default
%
for ikey = 1:length(keys)
    key = keys{ikey};
    if ~isfield(o, key)
        o.(key) = o_default.(key);
    end
end

end