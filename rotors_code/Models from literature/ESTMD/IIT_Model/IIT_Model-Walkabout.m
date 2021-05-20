clc
clear all
%  Bagheri Z.B., Wiederman S.D., Cazzolato B.S., Grainger S., O'Carroll
%  D.C. (2017) "Performance of an Insect-Inspired Target Tracker in Natural Conditions"
%  
%
%  This MATLAB code implements an insect-inspired target tracking (IIT) model. 

%  It is free for research use. If you find it useful, please acknowledge the paper
%  above with a reference.

%  This function takes care of setting up parameters, loading video
%  information and computing precisions. 

%%%%%%%%%%% path to the videos %%%%%%%%%%%%
%choose background and motion path
%Background: road, blank, noise
%Motion Path: horizontal, vertical, sinosoid
[dataGreenChannel,nFrames]=createMotion('road','sinosoid');
load('groundtruth.mat')
groundtruth=data;
%%%%%%%%%%% Path to the code %%%%%%%%%%%%%%%
codeDirectory=['D:\OneDrive - Imperial College London\IRP\AutoCar\IIT_Model'];
cd(codeDirectory)

%%%%%%%%%%% Set the Parameters %%%%%%%%%%%%

%Center of the target in the first frame
X_C=(groundtruth(1,1)+groundtruth(1,3)/2);   
Y_C=groundtruth(1,2)+groundtruth(1,4)/2;  

%Image size
image_size_m = size(dataGreenChannel,1) ;                         %number of rows
image_size_n = size(dataGreenChannel,2);                         %number of columns
Prompt1='Please enter the horizontal field of view (degrees): ';
degrees_in_image =input(Prompt1); % Facilitation time constant
if isempty(degrees_in_image )
    degrees_in_image = 50;                    %field of view horizontally

end
pixels_per_degree = image_size_n/degrees_in_image;                          %pixels_per_degree = #horiz. pixels in output / horizontal degrees (97.84)
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

%Initial target location in the subsampled image
initialCol=ceil(X_C/pixel2PR);
initialRow=ceil(Y_C/pixel2PR);

%Facilitation parameters
Facilitation_sigma=5/2.35482;
Ts = 0.05; %Sampling time
Prompt='Please enter the w parameter in Equation 10 to set the facilitation time constant: ';
wb =input(Prompt); % Facilitation time constant
if isempty(wb)
    wb=0.05;
end
    
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
for i=1:nFrames+Delay
   if i>=2
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
   
   tic;
   tStart = tic;
   opticOut=OpticBlur(Input, pixels_per_degree);
   tBlur = toc(tStart);
   SubSampledGreen=Subsample(opticOut, pixel2PR);%Resize picture to eye size
   %SubSampledGreen=Subsample(Input, pixel2PR);
   PR_Output=PhotoReceptor(SubSampledGreen, XDim, YDim);
   LMC_Output=LMC(PR_Output, XDim,YDim);
   RTC_Output=RTC(LMC_Output, Ts);
   ESTMD_OUT=ESTMD(RTC_Output, Facilitation_Matrix, Facilitation_Mode, start, Threshold); 
   [Direction_Horizontal,Direction_Vertical]=Direction(ESTMD_OUT,  RC_wb, Ts,XDim, YDim);
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
%     Grid=FacilitationGrid(col_index,row_index, ESTMD_OUT, Facilitation_sigma, FacilitationGain);
%     Facilitation_Matrix=FacilitationMatrix(Grid, col_index, default, Ts, wb);
   tFrame=toc;
   [rs1,~]=size(Grid);
   [rs2,~]=size(Input);
   resizeVal=rs2/rs1;
   if i>Delay
       TargetLocationRow(i-Delay)=row_index;
       TargetLocationCol(i-Delay)=col_index;
       FM=insertShape(dataGreenChannel(:,:,i-Delay),'FilledCircle',[col_index*resizeVal row_index*resizeVal 5],'Color', 'red','Opacity',1);
       %imshow(frame)
       FM=imresize(FM, [480 640]);
       EO=imresize(ESTMD_OUT, [240 320]);
       imshow(FM)
   end
   framePTime(i)=tFrame;
   blurPTime(i)=tBlur;
end

%imshow(FM)
directory1=['D:\OneDrive - Imperial College London\IRP\AutoCar\IIT_Model\results'];
mkdir(directory1)
cd(directory1)


save('TargetLocationRow','TargetLocationRow')
save('TargetLocationCol','TargetLocationCol')
save('framePTime','framePTime')
save('blurPTime', 'blurPTime')
clear functions

   
