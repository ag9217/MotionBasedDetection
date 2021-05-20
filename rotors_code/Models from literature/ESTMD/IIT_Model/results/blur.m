BG=imread('road.jpg');

BG=imresize(BG, [120, 160]);
BG = insertShape(BG,'FilledCircle',[35 80 6],'Color', 'red','Opacity',1);
BG = insertShape(BG,'FilledCircle',[70 80 5],'Color', 'red','Opacity',1);
BG=imresize(BG, [240, 320]);
BG_left=BG(1:240, 1:107, :);
BG_left=imresize(BG_left, [12,5]);
BG_right=BG(1:240, 213:320, :);
BG_right=imresize(BG_right, [12,5]);
BG_left=imresize(BG_left, [240, 107]);
BG_right=imresize(BG_right, [240, 107]);
BG(:,1:107,:)=BG_left;
BG(:,214:320,:)=BG_right;
imshow(BG)