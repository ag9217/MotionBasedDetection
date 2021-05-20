function Facilitation=FacilitationMatrix(Grid, Col_index,Default, Ts, wb)
    
    [m,n]=size(Grid);
    persistent Delayed_Grid
    if isempty(Delayed_Grid)
        Delayed_Grid=zeros(m,n);
    end

    if (Col_index==1)
        G1=Delayed_Grid;
    else
        G1=Grid;
    end

    G2=G1+ones(size(Grid));

    if Default==0
        Fac=ones(size(G2));
    else
        Fac=G2;
    end
    b=[Ts*wb/(Ts*wb+2), Ts*wb/(Ts*wb+2)]; 
    a=[1 , (Ts*wb-2)/(Ts*wb+2)];
    persistent Facilitationbuffer
    if isempty(Facilitationbuffer)
        Facilitationbuffer=zeros(m,n,length(b));
    end
    [Facilitation,Facilitationbuffer]=IIRFilter(b,a,Fac,Facilitationbuffer);
    Delayed_Grid=G1;

end