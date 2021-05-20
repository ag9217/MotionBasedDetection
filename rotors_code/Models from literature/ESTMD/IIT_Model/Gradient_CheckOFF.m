function Tau=Gradient_CheckOFF(Difference)
     [R,C]=size(Difference);
     for i=1:R
        for j=1:C
            if Difference(i,j)>0
                Tau(i,j)=3;
            else
                Tau(i,j)=70;
            end
        end
     end
  end