function [region]=regionDetection(col_index,row_index,ESTMD_OUT)
%a,b,c,d: up, down, left and right of region boundary
a=row_index;
b=row_index;
c=col_index;
d=col_index;
while ESTMD_OUT(a,col_index)>0.2
    if a == 35
        break
    end
    a=a+1;
end
while ESTMD_OUT(b,col_index)>0.2
    if b == 1
        break
    end
    b=b-1;
end
while ESTMD_OUT(row_index,c)>0.2
    if c == 46
        break
    end
    c=c+1;
end
while ESTMD_OUT(row_index,d)>0.2
    if d == 1
        break
    end
    d=d-1;
end

region=[a,b,c,d];
    