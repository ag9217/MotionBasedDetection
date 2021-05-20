function Grid=FacilitationGrid(Col_index,Row_index, Image, sig, Gain)
       

    [m,n]=size(Image);

    O1=ones(m,5);
    O2=ones(m,10);
    O3=ones(m,mod((n-5),10));

    I=round(n/10);

    Matrix1=[];
    Matrix2=[];
    Matrix3=[];
    Matrix4=[];

    for j=0:10:I*10;
        z=exp(-(Col_index-j).^2/(2*sig^2));
        if j==0
            C=O1*z;
        elseif j==I*10
            C=O3*z;
        else
            C=O2*z;
        end
        Matrix1=[Matrix1 C];
    end

   O1=ones(m,10);
   O2=ones(m,mod(n,10));

   I=round((n-5)/10);
   for j=5:10:(I*10+5);
        z=exp(-(Col_index-j).^2/(2*sig^2));
        if j==I*10+5
            C=O2*z;
        else
            C=O1*z;
        end
        Matrix2=[Matrix2 C];
   end
   O1=ones(5,n);
   O2=ones(10,n);
   O3=ones(mod((m-5),10),n);
   I=round(m/10); 

   for j=0:10:I*10;
        z=exp(-(Row_index-j).^2/(2*sig^2));
        if j==0
            C=O1*z;
        elseif j==I*10
            C=O3*z;
        else
            C=O2*z;
        end
        Matrix3=[Matrix3; C];
   end

   O1=ones(10, n);
   O2=ones(mod(m,10), n);

   I=round((m-5)/10);
   for j=5:10:(I*10+5);
        z=exp(-(Row_index-j).^2/(2*sig^2));
        if j==I*10+5
            C=O2*z;
        else
            C=O1*z;
        end
        Matrix4=[Matrix4; C];
   end

   Grid=Gain*(Matrix1+Matrix2).*(Matrix3+Matrix4);
end