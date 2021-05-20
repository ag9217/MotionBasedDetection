function [Dist]=getError(groundTruth,colData,rowData)
size(groundTruth)
size(rowData)
Dist=(groundTruth(:,1)-colData).^2+(groundTruth(:,2)-rowData).^2;
for i=1:length(colData)
    Dist(i)=sqrt((groundTruth(i,1)-colData(i))^2+(groundTruth(i,2)-rowData(i))^2);
    if Dist(i)<10
        Dist(i)=0   ;
    else
        Dist(i)=Dist(i)-10;
    end
end