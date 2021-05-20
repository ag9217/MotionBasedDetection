function RTC_Output=revFocus(RTC_Output,region)
if region(1)==1
    return
end
for x=1:35
    for y=1:46
        if region(1)+3 >=x && region(2)-3<=x && region(3)+3 >=y && region(4)-3<=y
                RTC_Output(x,y)=0.3*RTC_Output(x,y);
        else
                RTC_Output(x,y)=RTC_Output(x,y);
        end
    end
end