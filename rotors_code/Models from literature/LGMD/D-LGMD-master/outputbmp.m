FilePath = 'C:\Users\Armand\Desktop\images\';

for i=1:136
    I = imread(strcat(FilePath, num2str(i), '.jpg'));
    imwrite(I,strcat(num2str(i),'.bmp'));
end