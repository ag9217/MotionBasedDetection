function SpeedMap=SpeedCheck(ESTMD1, ESTMD2, ESTMD3, ESTMD4)
    Speed = ESTMD1;
    [m,n]=size(ESTMD1);
    Speedmap=Speed;
    for i = 1:m
        for j = 1:n
            if abs(ESTMD2(i,j) - Speed(i,j)) > Speed(i,j)*0.1
                Speed(i,j) = ESTMD2(i,j);
                Speedmap(i,j) = 2;
            end
        end
    end
    for i = 1:m
        for j = 1:n
            if abs(ESTMD3(i,j) - Speed(i,j)) > Speed(i,j)*0.1
                Speed(i,j) = ESTMD3(i,j);
                Speedmap(i,j) = 3;
            end
        end
    end
    for i = 1:m
        for j = 1:n
            if abs(ESTMD4(i,j) - Speed(i,j)) > Speed(i,j)*0.1
                Speed(i,j) = ESTMD4(i,j);
                Speedmap(i,j) = 4;
            end
        end
    end
    SpeedMap = Speedmap;
    