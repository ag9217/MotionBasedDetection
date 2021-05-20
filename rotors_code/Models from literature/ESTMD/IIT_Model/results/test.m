input=ones(10,10)
region=[5,3,6,2];
for x=1:10
    for y=1:10
        if x>region(1)+1 || x<region(2)-1 
            if y>region(3)+1 || y<region(4)-1
               input(x,y)=0.1*input(x,y);
            else
                input(x,y)=input(x,y);
            end
        else
            input(x,y)=input(x,y);
        end
    end
end
imshow(input)
