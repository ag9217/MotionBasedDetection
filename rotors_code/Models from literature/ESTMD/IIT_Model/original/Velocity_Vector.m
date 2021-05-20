function [default, col_index2,row_index2] = Velocity_Vector(test, col_index1, row_index1,direction1,direction2, XDim)
    
if (direction1 > 0 && ( col_index1 > (XDim / 2) + 3))
    rotation = 1;
 elseif (direction1 < 0 &&  col_index1 < (XDim / 2) - 3)
    rotation = 2;
else
    rotation = 0;
end


    if ((col_index1 == 1) || (col_index1 == 91))&& test==1 
        flag1 = 1;
    else
        flag1 = 0;
    end

    if((row_index1==1)||(row_index1==37))&& test==1
        flag2=1;
    else
        flag2=0;
    end
    if flag1~=1 

        if (rotation==0)        %1 - moving right, 2 - moving left, 0 - not moving
            if direction1>0.1 
                col_index2 = col_index1+3;
            elseif direction1<-0.1 
                col_index2 = col_index1-3;
            else 
                col_index2 = col_index1;
            end           

        elseif rotation == 1 
            col_index2 = (XDim / 2) + 3;

        else
            col_index2 = (XDim / 2) - 3;     
        end
    else
        col_index2 = 1;

    end
    if flag2~=1
        if direction2>0.1 
            row_index2=row_index1+3;        
        elseif direction2<-0.1 
            row_index2=row_index1-3;
        else
            row_index2=row_index1;
        end
    else
        row_index2=1;
    end
    if flag1==1&& flag2==1
        default=0;
    else
        default=1;
    end
    %in rotation it clarifies that the pursuere should rotate left or right or
    %stay silent. But direction shows if the target moving left or right.
    %whenever the target is moving left or right but it's in the correct place
    %in terms of pursuing strategy, the rotation will be zero.
    %if col_index1=1 or 59 then default is 0 and cal_index2=1
end