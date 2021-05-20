function [Filtered_Data, dbuffer]=IIRFilter(b,a,Signal,dbuffer)
    for k=1:(length(b)-1)
        dbuffer(:,:,k)=dbuffer(:,:,k+1);
    end
    dbuffer(:,:,length(b))=zeros(size(dbuffer(:,:,length(b))));
    for k=1:length(b)
        dbuffer(:,:,k)=dbuffer(:,:,k)+Signal*b(k);
    end
    for k=1:(length(b)-1)
        dbuffer(:,:,k+1)=dbuffer(:,:,k+1)-dbuffer(:,:,1)*a(k+1);
    end
    Filtered_Data=dbuffer(:,:,1);
end