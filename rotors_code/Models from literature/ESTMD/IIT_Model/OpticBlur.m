function opticOut=OpticBlur(Input, pixels_per_degree)
   [m,n]=size(Input);
    sigma_deg = 1.4/2.35; 
    sigma_pixel = sigma_deg*pixels_per_degree;                                  %sigma = (sigma in degrees (0.59))*pixels_per_degree
    kernel_size = 2*(ceil(sigma_pixel));

    H = fspecial('gaussian',kernel_size,sigma_pixel);  %gaussian filter kernel
    G1 = ones(m+12,n+12);
    G1(7:(end-6), 7:(end-6)) = Input;

    G1(6, 7:(end-6)) = G1(7, 7:(end-6));
    G1(5, 7:(end-6)) = G1(8, 7:(end-6));
    G1(4, 7:(end-6)) = G1(9, 7:(end-6));
    G1(3, 7:(end-6)) = G1(10, 7:(end-6));
    G1(2, 7:(end-6)) = G1(11, 7:(end-6));
    G1(1, 7:(end-6)) = G1(12, 7:(end-6));

    G1((end-5), 7:(end-6)) = G1((end-6), 7:(end-6));
    G1((end-4), 7:(end-6)) = G1((end-7), 7:(end-6));
    G1((end-3), 7:(end-6)) = G1((end-8), 7:(end-6));
    G1((end-2), 7:(end-6)) = G1((end-9), 7:(end-6));
    G1((end-1), 7:(end-6)) = G1((end-10), 7:(end-6));
    G1((end), 7:(end-6)) = G1((end-11), 7:(end-6));

    G1(:, 6) = G1(:, 7);
    G1(:, 5) = G1(:, 8);
    G1(:, 4) = G1(:, 9);
    G1(:, 3) = G1(:, 10);
    G1(:, 2) = G1(:, 11);
    G1(:, 1) = G1(:, 12);

    G1(:, end-5) = G1(:, end-6);
    G1(:, end-4) = G1(:, end-7);
    G1(:, end-3) = G1(:, end-8);
    G1(:, end-2) = G1(:, end-9);
    G1(:, end-1) = G1(:, end-10);
    G1(:, end) = G1(:, end-11);

    G2 = conv2(G1,H,'same');                                                      %convolution with gaussian filter kernel
    opticOut = G2(7:(end-6), 7:(end-6));
end