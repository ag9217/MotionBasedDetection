function y = RTC_Spatial_Filtering(Channel)

    H = [-1, -1, -1, -1, -1; -1, 0, 0, 0, -1; -1, 0, 2, 0, -1; -1, 0, 0, 0, -1; -1, -1, -1, -1, -1];
    n=size(Channel,1);
    m=size(Channel,2);
    G1 = ones(n+4,m+4);
    G1(3:(end-2), 3:(end-2)) = Channel;
    G1(2, 3:(end-2)) = G1(3, 3:(end-2));
    G1(1, 3:(end-2)) = G1(4, 3:(end-2));
    G1((end-1), 3:(end-2)) = G1((end-2), 3:(end-2));
    G1(end, 3:(end-2)) = G1((end-3), 3:(end-2));
    G1(:, 2) = G1(:, 3);
    G1(:, 1) = G1(:, 4);
    G1(:, end-1) = G1(:, end-2);
    G1(:, end) = G1(:, end-3);                                                 %convolution with gaussian filter kernel

    G3 = conv2(G1, H,'same');
    y = G3(3:(end-2), 3:(end-2));
end