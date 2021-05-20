function LMC_Output=LMC(PR_Output, XDim,YDim)
    H = [-1/9,-1/9, -1/9; -1/9, 8/9, -1/9; -1/9,-1/9, -1/9];
    G1 = ones(YDim+2, XDim+2);                                                 
    G1(2:(end-1), 2:(end-1)) = PR_Output;
    G1(1, 2:(end-1)) = G1(2, 2:(end-1));        
    G1(end, 2:(end-1)) = G1((end-1), 2:(end-1));
    G1(:, 1) = G1(:, 2);
    G1(:, end) = G1(:, end-1);

    G2 = conv2(G1, H, 'same');           %convolution with gaussian filter kernel
    LMC_Output = G2(2:(end-1), 2:(end-1));
end