function [dataGreenChannel,nFrames,groundTruth] = bgMotion
BG=imread('noise.jpg');
x_coord=[10:3:400];
y_coord=150*ones(1,length(x_coord));
BG=imresize(BG, [240,2000]);
x_reduced=x_coord;
a=ceil((length(x_coord)*1/2));
for IN=1:length(x_coord)
    background = BG(:, 1:320, :);
    if IN > a+1
        x_reduced(IN) = x_reduced(IN-1)+1;
        background = BG(:, 2*(IN-a+1):319+2*(IN-a+1),:);
    end
    Frame = insertShape(background,'FilledCircle',[x_reduced(IN) y_coord(IN) 10],'Color', 'red','Opacity',1);
%      Frame = insertShape(Frame,'FilledCircle',[x_2(IN) y_2(IN) 10],'Color', 'red','Opacity',1);
    dataGreenChannel(:,:,IN)=Frame(:,:,2);
end  
nFrames=length(x_reduced);
groundTruth(1,:)=x_reduced;
groundTruth(2,:)=y_coord;