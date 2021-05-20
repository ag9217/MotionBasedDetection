L=1;
video_path=['D:\OneDrive - Imperial College London\IRP\AutoCar\IIT_Model\STNS1\'];
img_files = dir([video_path '*.jpg']);
addpath(video_path)
img_files(1).name
frame=imread(img_files(1).name)