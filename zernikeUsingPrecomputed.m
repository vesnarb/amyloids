function Z = zernikeUsingPrecomputed(Rads, p, deg)

% assume that the image is of the same size as the Rads where built!

Z = zeros(1, size(Rads, 3));
cnt = nnz(Rads(:, :, 1));

for m = 0:deg
    for n = m:2:deg
        if mod(n, 2) == 0 
            pos = n*(n+2)/4 + m/2 + 1;
        else
            pos = (n+1)*(n+1)/4 + (m+1)/2;
        end
        Product = p .* Rads(:, :, pos);
        Z(pos) = sum(Product(:));
        Z(pos) = (n+1) * Z(pos) / cnt;  % normalize the amplitude of moments - from discretizing formula
    end
end

end
