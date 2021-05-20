function [variance, N] = varPixelNframe(pixel)
%  Bagheri Z.B., Wiederman S.D., Cazzolato B.S., Grainger S., O'Carroll
%  D.C. (2017) "Performance of an Insect-Inspired Target Tracker in Natural Conditions"
%  
%
%  This MATLAB code implements an insect-inspired target tracking (IIT) model. 

%  It is free for research use. If you find it useful, please acknowledge the paper
%  above with a reference.

%  This function takes care of setting up parameters, loading video
%  information and computing precisions.
clear('PhotoReceptor')
clear('RTC')
clear('Direction')
clear('FacilitationMatrix')
clear('FacilitationGrid')
%%%%%%%%%%% path to the videos %%%%%%%%%%%%
%choose background and motion path
%Background: road, blank, noise
%Motion Path: horizontal, vertical, sinosoid
[dataGreenChannel,nFrames,groundTruth]=createMotion('noise','sinosoid');
%%%%%%%%%%% Path to the code %%%%%%%%%%%%%%%
codeDirectory=['D:\OneDrive - Imperial College London\IRP\AutoCar\IIT_Model'];
cd(codeDirectory)

%%%%%%%%%%% Set the Parameters %%%%%%%%%%%%
image_size_m = size(dataGreenChannel,1) ;                         %number of rows
image_size_n = size(dataGreenChannel,2); 
pixels_per_degree = pixel;                          %pixels_per_degree = #horiz. pixels in output / horizontal degrees (97.84)
pixel2PR = ceil(pixels_per_degree);                                         %ratio of pixels to photoreceptors in the bio-mimetic model (1 deg spatial sampling...                                                                
sigma_deg = 1.4/2.35; 
sigma_pixel = sigma_deg*pixels_per_degree;                                  %sigma = (sigma in degrees (0.59))*pixels_per_degree
kernel_size = 2*(ceil(sigma_pixel));
ParameterResize=ceil(image_size_m/pixel2PR);
K1=1:pixel2PR:image_size_m;
K2=1:pixel2PR:image_size_n;
YDim=length(K1);
XDim=length(K2);
Facilitation_Mode='on';

initialCol=1;
initialRow=1;
Facilitation_sigma=5/2.35482;
Ts = 0.05; %Sampling time
wb=0.05;   
FacilitationGain =25; %root of facilitation kernel gain
RC_wb = 5; 
parameter.RC_fac_wb = 1;
Threshold = 0.01;
Facilitation_Matrix=ones(YDim, XDim);
TargetLocationRow=zeros(nFrames,1);
TargetLocationCol=zeros(nFrames,1);
framePTime=zeros(nFrames,1);
blurPTime=zeros(nFrames,1);
Delay=1; % allowing the facilitation to build up in the target region for 200 ms prior to the start of the experiment. 
%%
colData=[];
rowData=[];
HoriArray = [];
VerArray = [];
GTruth =[];
for i=1:nFrames+Delay
   if i>=Delay+1
       test=1;
       start=1;
   else
       test=0;
       start=0;
   end  
   if i>Delay
        Input=dataGreenChannel(:,:,i-Delay);
        Input=double(Input);
        
   else
       Input=ones(image_size_m,image_size_n);
   end
   opticOut=OpticBlur(Input, pixels_per_degree);
   SubSampledGreen=Subsample(opticOut, pixel2PR);%Resize picture to eye size
   
   %SubSampledGreen=Subsample(Input, pixel2PR);
   PR_Output=PhotoReceptor(SubSampledGreen, XDim, YDim);
   LMC_Output=LMC(PR_Output, XDim,YDim);
   RTC_Output=RTC(LMC_Output, Ts);
   %RTC_Output=motionRTC(LMC_Output, Ts);
   %RTC_Output=regionFocus(RTC_Output,region);
   ESTMD_OUT=ESTMD(RTC_Output, Facilitation_Matrix, Facilitation_Mode, start, Threshold); 
   [Direction_Horizontal,Direction_Vertical]=Direction(ESTMD_OUT,  RC_wb, Ts,XDim, YDim);
   HoriArray = [HoriArray, Direction_Horizontal];
   VerArray = [VerArray, Direction_Vertical];
   Direction_Horizontal = mean(HoriArray);
   Direction_Vertical = mean(VerArray);
   [ col_index, row_index] = Target_Location(ESTMD_OUT, YDim);
   [default, col_index2,row_index2] = Velocity_Vector(test, col_index, row_index,Direction_Horizontal,Direction_Vertical, XDim);
   if i<=Delay
       default=1;
   end
       
   if i<Delay+1
       col_index2=initialCol;
       row_index2=initialRow;
   end
   Grid=FacilitationGrid(col_index2,row_index2, ESTMD_OUT, Facilitation_sigma, FacilitationGain);
   Facilitation_Matrix=FacilitationMatrix(Grid, col_index2, default, Ts, wb);
   [rs1,~]=size(Grid);
   [rs2,~]=size(Input);
   resizeVal=rs2/rs1;
   if col_index2 ~= 1
        colData=[colData, col_index*resizeVal];
        rowData=[rowData, row_index*resizeVal];
        GTruth = [GTruth, groundTruth(:,i-Delay)];
   else
        N = i-Delay;
   end
%    if i>Delay
%        FM=insertShape(dataGreenChannel(:,:,i-Delay),'FilledCircle',[col_index*resizeVal row_index*resizeVal 5],'Color', 'red','Opacity',1);
%        FM=imresize(FM, [480 640]);
%        imshow(FM)
%    end
end
[Dist]=getError(GTruth',colData',rowData');
variance = var(Dist,0); 

