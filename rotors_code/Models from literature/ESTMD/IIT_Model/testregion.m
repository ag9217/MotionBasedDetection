input=ones(20,20);
region=[7,4,6,2];
for x=1:20
    for y=1:20
        if region(1)+2 >=x && region(2)+2<=x && region(3)+2 >=y && region(4)+2<=y
                input(x,y)=input(x,y);
        else
                input(x,y)=0.1*input(x,y);
        end
    end
end
imshow(input)
