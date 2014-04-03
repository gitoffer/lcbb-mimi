function im = wavelet_synthesize(coeff,As)

im = As + sum(coeff,3);