BG=imread('road.jpg');
BG=imresize(BG, [240 320]);
scenario='sinosoid';
switch scenario
    case 'horizontal'
        x_coord=[10:(320-10)/200:320];
        y_coord=140*ones(length(x_coord));
    case 'vertical'
        y_coord=[20:(200-20)/200:200]; 
        x_coord=200*ones(length(y_coord));
    case 'sinosoid'
        x_coord=[20:(300-20)/200:300];
        y_coord=sin(x_coord/50)*50+90;
end
for IN=1:200
    Frame = insertShape(BG,'FilledRectangle',[x_coord(IN) y_coord(IN) 10 5],'Color', 'red','Opacity',0.7);
    dataGreenChannel(:,:,IN)=Frame(:,:,2);
end  
imshow(dataGreenChannel(:,:,20));