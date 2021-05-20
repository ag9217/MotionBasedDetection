dataMat = [];
data = [];
speedMat = [1:10];
speedMat = (speedMat.*speedMat).*0.05;
speedMat = speedMat';
% for pixel = 3:15
%     [variance, N] = varPixelNframe(pixel);
%     dataMat = [dataMat; 320/pixel, variance, N];
% end
omega=[0.05, 1, 10];

for w = 1:3
    for speed = 1:10
        wb = omega(w);
        variance = varSpeedNframe(wb, speed);
        dataMat = [dataMat;variance];
    end
    data(:, w) = dataMat;
    dataMat = [];
end
plot(speedMat, data(:, 1))
% hold on
% 
% yyaxis left
% plot(dataMat(:,1),dataMat(:,2));
% title('Resolution on width, variance of position and N frame')
% xlabel('Resolution')
% ylabel('Position Variance')
% 
% yyaxis right
% plot(dataMat(:,1),dataMat(:,3));
% ylabel('Number of Frame till detection')