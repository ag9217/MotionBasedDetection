function [Direction_Horizontal,Direction_Vertical]=Direction(ESTMD_OUT, RC_wb, Ts,XDim, YDim)
    b=[Ts*RC_wb/(Ts*RC_wb+2), Ts*RC_wb/(Ts*RC_wb+2)];
    a=[1, (Ts*RC_wb-2)/(Ts*RC_wb+2)];
    persistent ESTMDbuffer
    if isempty(ESTMDbuffer)
        ESTMDbuffer=zeros(YDim,XDim,length(b));
    end
    [ESTMD_Dlayed_Output,ESTMDbuffer]=IIRFilter(b,a,ESTMD_OUT,ESTMDbuffer);
    [Left, Right, Up, Down]= Reichardt_Correlator(ESTMD_Dlayed_Output, ESTMD_OUT);
    Direction1=Down-Up; %Moving down is positive and up is negative
    Direction2=Right-Left;%Moving Right is positive and left is negative
    Direction_Vertical = max(Direction1(:))+min(Direction1(:));
    Direction_Horizontal = max(Direction2(:))+min(Direction2(:));

end