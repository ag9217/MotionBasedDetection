function PR_Output=PhotoReceptor(Green, XDim, YDim)
    Green2=Green/255;
    %Lognormal filter parameters
    b_LogNormal=[0    0.0001   -0.0011    0.0052   -0.0170    0.0439   -0.0574    0.1789   -0.1524];
    a=[ 1.0000   -4.3331    8.6847  -10.7116    9.0004   -5.3058    2.1448   -0.5418    0.0651];
    persistent dbuffer1
    if isempty(dbuffer1)
       dbuffer1=zeros(YDim,XDim,length(b_LogNormal));
    end
    %filter the data with a LogNormal Filter which has the same
    %properties as PhotoReceptors
    [PR_Output,dbuffer1]=IIRFilter(b_LogNormal,a,Green2,dbuffer1);
 end