function Tau=Gradient_CheckOFF(Difference)
     [R,C]=size(Difference);
     for i=1:R
        for j=1:C
            if Difference(i,j)>0.01
                Tau(i,j)=0.25;
            else
                Tau(i,j)=5;
            end
        end
     end
  end