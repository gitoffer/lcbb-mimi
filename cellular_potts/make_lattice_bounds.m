function bounded_lattice = make_lattice_bounds(lattice,method,size)

switch method
    case 'zero'
        bounded_lattice = padarray(lattice,[size size],0);
    otherwise
        error('Unsupported boundary condition.');
end
