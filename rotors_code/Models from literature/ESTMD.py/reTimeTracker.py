from scipy import signal
import numpy as np
import math
import matplotlib.pyplot as plt
import cv2
import IIT as iit
import time


# Parameter initialization
image_size_m = 640
image_size_n = 480
degrees_in_image = 50
pixels_per_degree = image_size_n/degrees_in_image
pixel2PR = int(pixels_per_degree)
sigma_deg = 1.4/2.35
sigma_pixel = sigma_deg*pixels_per_degree
kernel_size = 2*(int(sigma_pixel))
ParameterResize = int(image_size_m/pixel2PR)
K1 = np.arange(1, image_size_n, pixel2PR)
K2 = np.arange(1, image_size_m, pixel2PR)
# YDim = len(K1)
# XDim = len(K2)
YDim = 35
XDim = 46
count = 1
Facilitation_Mode = 'off'
Facilitation_sigma = 5/2.35482
Ts = 1#0.0010 # Tune this (increase to something like 0.1)
wb = 0.1
RC_wb = 5
FacilitationGain = 25
Threshold = 0.01
Facilitation_Matrix1 = np.ones([YDim, XDim])
# Facilitation_Matrix2 = np.ones([YDim, XDim])    # Assign facilitation matrix as class?
Delay = 1

cap = cv2.VideoCapture("C:/Users/Armand/OneDrive - Imperial College London/Documents/University/4th year/Modules/Master project/training_videos/office_s/s_jpgs/image_%d.jpg", cv2.CAP_IMAGES)
region1 = [0, 0, 0, 0]
# region2 = [0, 0, 0, 0]
i = 0

assemblyMode = 'region'
oldCoord = []
old_magnitude = 0
# while(cap.isOpened()):
while cap.isOpened():

    if i >= 1:
        test = 1
        start = 1
    else:
        test = 0
        start = 0
    i = i+1
    ret, frame = cap.read()
    blurOut = iit.opticBlur(frame, pixels_per_degree)
    subsample = iit.downsampling(blurOut, XDim, YDim)
    pr_out = iit.photoReceptor(subsample, XDim, YDim)
    RTC_Output = iit.RTC(pr_out, Ts)
    RTC_1, rawRTC_2 = iit.regionProcessing(RTC_Output, region1)
    # RTC_2, leftOver = iit.regionProcessing(rawRTC_2, region2)
    ESTMD_1 = iit.motionDetector(RTC_Output, Facilitation_Matrix1, i, Threshold)
    # ESTMD_1 = iit.motionDetector(RTC_1, Facilitation_Matrix1, i, Threshold)
    # ESTMD_2 = iit.motionDetector(RTC_2, Facilitation_Matrix2, i, Threshold)
    DirectionVertical1, DirectionHorizontal1 = iit.direction(ESTMD_1, RC_wb, Ts, XDim, YDim)
    # DirectionVertical2, DirectionHorizontal2 = iit.direction2(ESTMD_2, RC_wb, Ts, XDim, YDim)
    row_1, col_1 = iit.location(ESTMD_1)
    # row_2, col_2 = iit.location(ESTMD_2)

    if i <= 1:
        default = 0
    col_12, row_12 = iit.velocityVector(col_1, row_1, DirectionHorizontal1, DirectionVertical1, test)
    # col_22, row_22 = iit.velocityVector(col_2, row_2, DirectionHorizontal2, DirectionVertical2, test)
    Grid1 = iit.facilitationGrid(col_12, row_12, ESTMD_1, Facilitation_sigma, FacilitationGain)
    # Grid2 = iit.facilitationGrid(col_22, row_22, ESTMD_2, Facilitation_sigma, FacilitationGain)
    Facilitation_Matrix1 = iit.facilitationMatrix(Grid1, col_12, default, Ts, wb)
    # Facilitation_Matrix2 = iit.facilitationMatrix2(Grid2, col_22, default, Ts, wb)
    # img = cv2.circle(frame, (col_1*7, row_1*7), 5, (255, 255, 255), -1)
    if i > 1:
        region1 = iit.regionDetector(col_1, row_1, ESTMD_1)
        # region2 = iit.regionDetector(col_2, row_2, ESTMD_2)
        row_1 = int((region1[0] + region1[1])/2)
        col_1 = int((region1[2] + region1[3])/2)
        targetCoord = [row_1, col_1]
    traceList =[]
    # plt.imshow(ESTMD_OUT, cmap='gray')
    # plt.show()

    estmd = np.multiply(ESTMD_1, 200)
    estmd = cv2.resize(estmd, (640, 480))
    estmd = np.array(estmd, dtype=np.uint8)
    sub = cv2.resize(subsample, (960, 720))
    frame = cv2.resize(frame, (960, 720))
    # trackOut.write(img)
    # frame = cv2.resize(frame, (1920, 1080))
    cv2.circle(frame, (col_1*21, row_1*21), 5, (0, 255, 0), -1)
    cv2.imshow('origin', frame)
    cv2.imshow('PhotoReceptor', sub)
    cv2.imshow('frame', estmd)

    path = 'C:/Users/Armand/OneDrive - Imperial College London/Documents/University/4th year/Modules/Master project/training_videos/office_s/s_estmd_jpgs/image_%d.jpg' % count
    #cv2.imwrite(path, estmd)
    # if DirectionVertical1 != 0:
        # currentDirection = np.degrees(np.arctan([DirectionHorizontal1/DirectionVertical1]))
        # if oldDirection != 0:
        #     objectDirection = iit.directionRegulator(oldDirection, currentDirection)
        #     oldDirection = objectDirection
        # else:
        #     oldDirection = currentDirection
        # print(currentDirection)

    # Direction Finder
    if i > 1:
        if oldCoord == []:
            oldCoord = targetCoord
        else:
            direction, magnitude = iit.direction_finder(targetCoord, oldCoord)
            oldCoord = targetCoord
            if old_magnitude == 0:
                old_magnitude = magnitude
            elif magnitude >= old_magnitude*10:
                traceList = []
            elif direction != 0:
                traceList.append(direction)
                ave_direction = sum(traceList)/len(traceList)
                # print(traceList)
            old_magnitude = magnitude
            print(direction)

    if i == 1:
        time.sleep(4)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

    count += 1
        

cap.release()
cv2.destroyAllWindows()
# trackOut.release()
# subsample = downsampling(Frame, XDim, YDim)q
# PR_Output = photoReceptor(subsample, XDim, YDim)
# LMC_Output = LMC(PR_Output, XDim, YDim)
# print(LMC_Output.shape)
#
#
