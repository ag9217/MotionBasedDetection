function ESTMD_OUT=ESTMD(RTC_OUT, Facilitation_Matrix, Facilitation_Mode, start, Threshold)
    if strcmp(Facilitation_Mode, 'on') && start~=0
        RTC_OUT=(RTC_OUT*6).*Facilitation_Matrix;
    else
        RTC_OUT=(RTC_OUT*6);
    end
    RTC_OUT2=RTC_OUT-Threshold;%0.1 is the threshold value
    RTC_Out_Dead= RTC_OUT2>0; %you can change the threshold value here
    RTC_Out_Dead=RTC_Out_Dead.* RTC_OUT2;
        % Soft saturation
    ESTMD_OUT=tanh(RTC_Out_Dead);
end