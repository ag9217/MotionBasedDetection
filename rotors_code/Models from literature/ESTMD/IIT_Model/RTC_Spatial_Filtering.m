function y = RTC_Spatial_Filtering(Channel)
%     H = [-1, -1, -1, -1, -1; -1, -1, -1, -1, -1; -1, -1, 2, -1, -1; -1, -1, -1, -1, -1; -1, -1, -1, -1, -1];
%     H = [-1, -1, -1, -1, -1; -1, 0, 0, 0, -1; -1, 0, 2, 0, -1; -1, 0, 0, 0, -1; -1, -1, -1, -1, -1];
%     H = [-1, -1, -1, -1, -1, -1, -1; 
%         -1, -1, -1, -1, -1, -1, -1; 
%         -1,  -1, 2,  2,  2, -1, -1; 
%         -1,  -1, 2,  2,  2, -1, -1;
%         -1,  -1, 2,  2,  2, -1, -1; 
%         -1, -1, -1, -1, -1, -1, -1; 
%         -1,  -1, -1,  -1,  -1, -1, -1];
%     H = [-1, -1, -1, -1, -1, -1, -1; 
%         -1, 0, 0, 0, 0, 0, -1; 
%         -1,  0, 2,  2,  2, 0, -1; 
%         -1,  0, 2,  2,  2, 0, -1;
%         -1,  0, 2,  2,  2, 0, -1; 
%         -1, 0, 0, 0, 0, 0, -1; 
%         -1,  -1, -1,  -1,  -1, -1, -1];
%     H = [-1,-1,-1;-1,2,-1;-1,-1,-1];
% H = [-1, -1, -1, -1, -1, -1, -1; 
%             -1,  1,  0,  0, 0,  0, -1; 
%             -1,  0,  1,  1, 1,  0, -1; 
%             -1,  0,  1,  2, 1,  0, -1; 
%             -1,  0,  1,  1, 1,  0, -1; 
%             -1,  0,  0,  0, 0,  0, -1; 
%             -1, -1, -1, -1, -1, -1, -1]; 
%      H = [-1, -1, -1, -1, -1; 
%             -1,  0,  0, 0,  -1; 
%             -1,  0,  2, 0,  -1; 
%             -1,  0,  2, 0,  -1; 
%             -1,  0,  2, 0,  -1; 
%             -1,  0,  2, 0,  -1; 
%             -1,  0,  2, 0,  -1; 
%             -1,  0,  2, 0,  -1; 
%             -1,  0,  0, 0,  -1;
%             -1, -1, -1, -1, -1]; 
%         H = H';
    Heights = 18;
    Width = 18;
    H = ones(Heights,Width)*2;
    H(1,:)=-1;
    H(Heights,:)=-1;
    H(:,1)=-1;
    H(:,Width)=-1;
    H(2,2:Width-1)=0;
    H(Heights-1,2:Width-1)=0;
    H(2:Heights-1,2)=0;
    H(2:Heights-1,Width-1)=0;
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