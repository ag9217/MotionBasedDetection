function [dataGreenChannel,nFrames,groundTruth] = sizeMotion(background,scenario,speed)
%generate background and motion scenario
switch background
    case 'blank'
        BG=imread('blank.jpg');
    case 'road'
        BG=imread('road.jpg');
    case 'noise'
        BG=imread('noise.jpg');   
    case 'city'
        BG=imread('city.jpg'); 
    case 'largeroad'
        BG=imread('largeroad.jpg');
    case 'gray'
        BG=imread('gray.jpg');
end
BG=imresize(BG, [500 1200]);
%[m,n]=size(BG);
switch scenario
    case 'horizontal'
         x_coord=[10:speed:300];
        y_coord=35*ones(1,length(x_coord));
        x1_coord=[10:speed*2:300];
        y1_coord=95*ones(1,length(x1_coord));
        x2_coord=[10:speed*4:300];
        y2_coord=155*ones(1,length(x2_coord));
        x3_coord=[10:speed*8:300];
        y3_coord=215*ones(1,length(x3_coord));
    case 'vertical'
        y_coord=[20:(200-20)/200:200]; 
        x_coord=200*ones(1,length(y_coord));
    case 'sinosoid'
        x_coord=[20:(300-20)/200:300];
        y_coord=sin(x_coord/50)*50+100;
    case 'lock'
        x_coord=160*ones(1,200);
        y_coord=200*ones(1,length(x_coord));
end
%Multi motion
% x_2=160*ones(1,200);
% y_2=80*ones(1,length(x_coord));
%Generate green channel picture with moving point

for IN=1:length(x3_coord)
     Frame = insertShape(BG,'FilledCircle',[x_coord(IN) y_coord(IN) 20],'Color', 'red','Opacity',1);
     Frame = insertShape(Frame,'FilledCircle',[x1_coord(IN) y1_coord(IN) 20],'Color', 'red','Opacity',1);
     Frame = insertShape(Frame,'FilledCircle',[x2_coord(IN) y2_coord(IN) 20],'Color', 'red','Opacity',1);
     Frame = insertShape(Frame,'FilledCircle',[x3_coord(IN) y3_coord(IN) 20],'Color', 'red','Opacity',1);
%      Frame = insertShape(Frame,'FilledRectangle',[x2_coord(IN) y2_coord(IN) 10, 10],'Color', 'red','Opacity',1);
%      Frame = insertShape(Frame,'FilledRectangle',[x3_coord(IN) y3_coord(IN) 10, 10],'Color', 'red','Opacity',1);

%    motionBG = BG(:, IN*3:(IN*3+320), :);
%    Frame = insertShape(motionBG,'FilledCircle',[x_coord(IN) y_coord(IN) 10],'Color', 'red','Opacity',1);
%      Frame = insertShape(Frame,'FilledCircle',[x_2(IN) y_2(IN) 10],'Color', 'red','Opacity',1);
    dataGreenChannel(:,:,IN)=Frame(:,:,2);
end  
nFrames=length(x3_coord);
groundTruth(1,:)=x1_coord;
groundTruth(2,:)=y1_coord;