 function [ col_index, row_index] = Target_Location(u,YDim)
    
    u(1,:) = 0;
    u(:,1)=0;
    u(end,:)=0;
    u(:,end)=0;
    [C, I] = max(u(:));
    col_index = ceil(I/YDim);
    row_index = I-((col_index-1)*(YDim));
end