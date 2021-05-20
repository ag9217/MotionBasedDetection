 function [ col_index, row_index] = Target_Location(u,YDim)
    
    u(1,:) = 0;
    u(:,1)=0;
    u(end,:)=0;
    u(:,end)=0;
%     [C, I] = max(u(:));
%     col_index = ceil(I/YDim)
%     row_index = I-((col_index-1)*(YDim))
     [row_index, col_index] = find(ismember(u, max(u(:))));
     row_index = row_index(1);
     col_index = col_index(1);
end