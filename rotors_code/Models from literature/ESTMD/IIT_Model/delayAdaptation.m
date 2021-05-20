function [col_index, row_index] = delayAdaptation(ci,ri,Direction_Horizontal,Direction_Vertical)

if abs(Direction_Horizontal)>0.2
    col_index=ci+5;
else
    col_index=ci;
end
if abs(Direction_Vertical)>0.2
    row_index=ri+10*Direction_Vertical;
else 
    row_index=ri;
end
