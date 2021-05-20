from scipy import signal
import numpy as np
import matplotlib.pyplot as plt
import cv2
import math

def opticBlur(sig, pixelPerDegree):
    sigma_deg = 1.4/2.35
    sigma_pixel = sigma_deg*pixelPerDegree
    kernel_size = 2*(int(sigma_pixel))
    opticblur = cv2.GaussianBlur(sig, (kernel_size+1, kernel_size+1), sigma_pixel)
    return opticblur


def downsampling(sig, XDim, YDim):
    sig = cv2.resize(sig, (XDim, YDim))
    sig = sig[:, :, 2]
    # sig = cv2.cvtColor(sig, cv2.COLOR_BGR2GRAY)
    return sig


def photoReceptor(sig, XDim, YDim):
    sig = sig / 255
    b = np.array([0, 0.0001, -0.0011, 0.0052, -0.0170, 0.0439, -0.0574, 0.1789, -0.1524])
    a = np.array([1.0000, -4.3331, 8.6847, -10.7116, 9.0004, -5.3058, 2.1448, -0.5418, 0.0651])
    try:
        photoReceptor.buffer
    except AttributeError:
        photoReceptor.buffer = None
    if photoReceptor.buffer is None:
        photoReceptor.buffer = np.zeros([YDim, XDim, len(b)])
    Output, photoReceptor.buffer = IIRFilter(b, a, sig, photoReceptor.buffer)
    return Output


def IIRFilter(b, a, sig, dbuffer):
    for k in range(len(b)-1):
        dbuffer[:, :, k] = dbuffer[:, :, k+1]

    dbuffer[:, :, -1] = 0
    for k in range(len(b)):
        dbuffer[:, :, k] = dbuffer[:, :, k] + sig*b[k]

    for k in range(len(b) - 1):
        dbuffer[:, :, k+1] = dbuffer[:, :, k+1] - dbuffer[:, :, 0]*a[k+1]

    filtered_data = dbuffer[:, :, 0]
    return filtered_data, dbuffer


def LMC(prOut, XDim, YDim):
    H = np.array([[-1/9, -1/9, -1/9], [-1/9, 8/9, -1/9], [-1/9, -1/9, -1/9]])
    G1 = np.ones([YDim+2, XDim+2])
    G1[1:-1, 1:-1] = prOut
    G1[0, 1:-1] = G1[1, 1:-1]
    G1[-1, 1:-1] = G1[-2, 1:-1]
    G1[:, 0] = G1[:, 1]
    G1[:, -1] = G1[:, -2]

    G2 = signal.convolve2d(G1, H, 'same')
    lmcoutput = G2[1:-1, 1:-1]
    return lmcoutput


def preProcessing(sig, XDim, YDim, pixelPerDegree):
    sigma_deg = 1.4 / 2.35
    sigma_pixel = sigma_deg * pixelPerDegree
    kernel_size = 2 * (int(sigma_pixel))
    opticblur = cv2.GaussianBlur(sig, (kernel_size+1, kernel_size+1), sigma_pixel)
    subsample = cv2.resize(opticblur, (XDim, YDim))
    subsample = subsample[:, :, 1]
    pr = subsample / 255
    b = np.array([0, 0.0001, -0.0011, 0.0052, -0.0170, 0.0439, -0.0574, 0.1789, -0.1524])
    a = np.array([1.0000, -4.3331, 8.6847, -10.7116, 9.0004, -5.3058, 2.1448, -0.5418, 0.0651])
    try:
        photoReceptor.buffer
    except AttributeError:
        photoReceptor.buffer = None
    if photoReceptor.buffer is None:
        photoReceptor.buffer = np.zeros([YDim, XDim, len(b)])
    pr, photoReceptor.buffer = IIRFilter(b, a, pr, photoReceptor.buffer)
    H = np.array([[-1 / 9, -1 / 9, -1 / 9], [-1 / 9, 8 / 9, -1 / 9], [-1 / 9, -1 / 9, -1 / 9]])
    G1 = np.ones([YDim + 2, XDim + 2])
    G1[1:-1, 1:-1] = pr
    G1[0, 1:-1] = G1[1, 1:-1]
    G1[-1, 1:-1] = G1[-2, 1:-1]
    G1[:, 0] = G1[:, 1]
    G1[:, -1] = G1[:, -2]

    G2 = signal.convolve2d(G1, H, 'same')
    lmcoutput = G2[1:-1, 1:-1]
    return lmcoutput


def RTC(lmcOut, ts):
    ON_Channel = lmcOut > 0
    ON_Channel = ON_Channel*1
    ON_Channel = np.multiply(ON_Channel, lmcOut)
    OFF_Channel = lmcOut < 0
    OFF_Channel = OFF_Channel*1
    OFF_Channel = -(np.multiply(OFF_Channel, lmcOut))
    try:
        RTC.onDelay
    except AttributeError:
        RTC.onDelay = None
    if RTC.onDelay is None:
        RTC.onDelay = np.zeros_like(ON_Channel)
    try:
        RTC.offDelay
    except AttributeError:
        RTC.offDelay = None
    if RTC.offDelay is None:
        RTC.offDelay = np.zeros_like(OFF_Channel)
    ON_Difference = np.subtract(ON_Channel, RTC.onDelay)
    OFF_Difference = np.subtract(OFF_Channel, RTC.offDelay)
    RTC.onDelay = ON_Channel
    RTC.offDelay = OFF_Channel
    tauOn = GradientCheck(ON_Difference)
    ON_Filter1 = Filter1(ON_Channel, tauOn)
    try:
        RTC.onDelayFiltered
    except AttributeError:
        RTC.onDelayFiltered = None
    if RTC.onDelayFiltered is None:
        RTC.onDelayFiltered = np.zeros_like(ON_Channel)
    ON_Filter2 = Filter2(RTC.onDelayFiltered, tauOn)
    ON_Filtered = np.add(ON_Filter1, ON_Filter2)
    Subtracted_ON_Channel = np.subtract(ON_Channel, RTC.onDelayFiltered)
    RTC.onDelayFiltered = ON_Filtered

    tauOff = GradientCheck(OFF_Difference)
    OFF_Filter1 = Filter1(OFF_Channel, tauOff)
    try:
        RTC.offDelayFiltered
    except AttributeError:
        RTC.offDelayFiltered = None
    if RTC.offDelayFiltered is None:
        RTC.offDelayFiltered = np.zeros_like(OFF_Channel)
    OFF_Filter2 = Filter2(RTC.offDelayFiltered, tauOff)
    OFF_Filtered = np.add(OFF_Filter1, OFF_Filter2)
    Subtracted_OFF_Channel = np.subtract(OFF_Channel, RTC.offDelayFiltered)
    RTC.offDelayFiltered = OFF_Filtered

    ON_Channel_Dead = Subtracted_ON_Channel > 0             # Another deadzone
    ON_Channel_Dead = ON_Channel_Dead*1
    ON_Channel_Dead = np.multiply(ON_Channel_Dead, Subtracted_ON_Channel)
    OFF_Channel_Dead = Subtracted_OFF_Channel > 0  # Another deadzone
    OFF_Channel_Dead = OFF_Channel_Dead * 1
    OFF_Channel_Dead = np.multiply(OFF_Channel_Dead, Subtracted_OFF_Channel)
    ON_Spatial_Filtered = spatialFilter(ON_Channel_Dead)
    OFF_Spatial_Filtered = spatialFilter(OFF_Channel_Dead)

    ON_Spatial_Dead2 = ON_Spatial_Filtered > 0  # Another deadzone
    ON_Spatial_Dead2 = ON_Spatial_Dead2 * 1
    ON_Spatial_Dead2 = np.multiply(ON_Spatial_Dead2, ON_Spatial_Filtered)
    OFF_Spatial_Dead2 = OFF_Spatial_Filtered > 0  # Another deadzone
    OFF_Spatial_Dead2 = OFF_Spatial_Dead2 * 1
    OFF_Spatial_Dead2 = np.multiply(OFF_Spatial_Dead2, OFF_Spatial_Filtered)
    m, n = ON_Spatial_Dead2.shape
    bArray = np.array([1 / (1 + 2 * 1.25 / ts), 1 / (1 + 2 * 1.25 / ts)])
    aArray = np.array([1, (1 - 2 * 1.25 / ts) / (1 + 2 * 1.25 / ts)])
    try:
        RTC.onBuffer
    except AttributeError:
        RTC.onBuffer = None
    if RTC.onBuffer is None:
        RTC.onBuffer = np.zeros([m, n, len(bArray)])
    ON_Delayed_Output, RTC.onBuffer = IIRFilter(bArray, aArray, ON_Spatial_Dead2, RTC.onBuffer)

    try:
        RTC.offBuffer
    except AttributeError:
        RTC.offBuffer = None
    if RTC.offBuffer is None:
        RTC.offBuffer = np.zeros([m, n, len(bArray)])
    OFF_Delayed_Output, RTC.offBuffer = IIRFilter(bArray, aArray, OFF_Spatial_Dead2, RTC.offBuffer)

    correlateOnOff = np.multiply(ON_Spatial_Dead2, OFF_Delayed_Output)
    correlateOffOn = np.multiply(OFF_Spatial_Dead2, ON_Delayed_Output)
    RTC_Output = np.add(correlateOffOn, correlateOnOff)
    return RTC_Output


def GradientCheck(diff):
    m, n = diff.shape
    tau = np.zeros_like(diff)
    for x_coord in range(m):
        for y_coord in range(n):
            if diff[x_coord, y_coord] > 0:
                tau[x_coord, y_coord] = 3
            else:
                tau[x_coord, y_coord] = 70
    return tau


def Filter1(u, tau):
    ts = 0.05
    para = 1-np.exp(-(np.divide(ts, tau)))
    filteredOn = np.multiply(para, u)
    return filteredOn


def Filter2(u, tau):
    ts = 0.05
    para = np.exp(-(np.divide(ts, tau)))
    filteredu = np.multiply(para, u)
    return filteredu


def spatialFilter(channel):
    H = [[-1, -1, -1, -1, -1, -1, -1],
         [-1, 1, 0, 0, 0, 0, -1],
         [-1, 0, 1, 1, 1, 0, -1],
         [-1, 0, 1, 2, 1, 0, -1],
         [-1, 0, 1, 1, 1, 0, -1],
         [-1, 0, 0, 0, 0, 0, -1],
         [-1, -1, -1, -1, -1, -1, -1]]
    n, m = channel.shape
    G1 = np.ones([n+4, m+4])
    G1[2:-2, 2:-2] = channel
    G1[1, 2:-2] = G1[2, 2:-2]
    G1[0, 2:-2] = G1[3, 2:-2]
    G1[-2, 2:-2] = G1[-3, 2:-2]
    G1[-1, 2:-2] = G1[-4, 2:-2]
    G1[:, 1] = G1[:, 2]
    G1[:, 0] = G1[:, 3]
    G1[:, -2] = G1[:, -3]
    G1[:, -1] = G1[:, -4]

    G3 = signal.convolve2d(G1, H, 'same')
    filteredChannel = G3[2:-2, 2:-2]
    return filteredChannel


def motionDetector(rtc, facMat, start, Threshold):
    # if not start == 0:
    #     rtc = np.multiply(rtc*6, facMat)
    # else:
    #     rtc = rtc*6
    # rtc = rtc * 6
    rtc2 = rtc - Threshold
    rtcDead = rtc2 > 0
    rtcDead = rtcDead*1
    rtcDead = np.multiply(rtcDead, rtc2)
    # ESTMD_OUT = np.tanh(rtcDead)
    ESTMD_OUT =rtcDead
    return ESTMD_OUT


def direction(ESTMD_OUT, wb, ts, XDim, YDim):
    bArray = [ts*wb/(ts*wb+2), ts*wb/(ts*wb+2)]
    aArray = [1, (ts*wb-2)/(ts*wb+2)]
    try:
        direction.mdBuffer
    except AttributeError:
        direction.mdBuffer = None
    if direction.mdBuffer is None:
        direction.mdBuffer = np.zeros([YDim, XDim, len(bArray)])
    delayEstmd, direction.mdBuffer = IIRFilter(bArray, aArray, ESTMD_OUT, direction.mdBuffer)
    left, right, up, down = reichardtCorrelator(delayEstmd, ESTMD_OUT)
    direct1 = np.subtract(down, up)
    direct2 = np.subtract(right, left)
    directVertical = np.max(direct1) + np.min(direct1)
    directHorizontal = np.max(direct2) + np.min(direct2)
    return directVertical, directHorizontal


def direction2(ESTMD_OUT, wb, ts, XDim, YDim):
    bArray = [ts*wb/(ts*wb+2), ts*wb/(ts*wb+2)]
    aArray = [1, (ts*wb-2)/(ts*wb+2)]
    try:
        direction2.mdBuffer
    except AttributeError:
        direction2.mdBuffer = None
    if direction2.mdBuffer is None:
        direction2.mdBuffer = np.zeros([YDim, XDim, len(bArray)])
    delayEstmd, direction2.mdBuffer = IIRFilter(bArray, aArray, ESTMD_OUT, direction2.mdBuffer)
    left, right, up, down = reichardtCorrelator(delayEstmd, ESTMD_OUT)
    direct1 = np.subtract(down, up)
    direct2 = np.subtract(right, left)
    directVertical = np.max(direct1) + np.min(direct1)
    directHorizontal = np.max(direct2) + np.min(direct2)
    return directVertical, directHorizontal


def reichardtCorrelator(delayEstmd, original):
    rows, columns = original.shape
    left_org = original[:, :-1]
    right_org = original[:, 1:]
    left_lp = delayEstmd[:, 1:]
    right_lp = delayEstmd[:, :-1]
    right_big = np.multiply(right_org, right_lp)
    right = right_big[:, 1:-1]
    left_big = np.multiply(left_org, left_lp)
    left = left_big[:, 1:-1]

    up_org = original[:-1, :]
    down_org = original[1:, :]
    up_lp = delayEstmd[:-1, :]
    down_lp = delayEstmd[1:, :]
    up_big = np.multiply(up_org, up_lp)
    up = up_big[1:-1, :]
    down_big = np.multiply(down_org, down_lp)
    down = down_big[1:-1, :]
    return left, right, up, down


def location(ESTMD_OUT):
    row_index = np.argmax(np.max(ESTMD_OUT, axis=1))
    col_index = np.argmax(np.max(ESTMD_OUT, axis=0))
    return row_index, col_index


def velocityVector(col, row, horizontal, vertical, test):
    if test == 1:
        if horizontal > 0.1:
            col_2 = col + 3
        elif horizontal < -0.1:
            col_2 = col - 3
        else:
            col_2 = col
        if vertical > 0.1:
            row_2 = row + 3
        elif vertical < -0.1:
            row_2 = row - 3
        else:
            row_2 = row
    else:
        col_2 = col
        row_2 = row
    return col_2, row_2


def facilitationGrid(col_index, row_index, signal, sigma, gain):
    m, n = signal.shape
    o1 = np.ones([m, 5])
    o2 = np.ones([m, 10])
    o3 = np.ones([m, (n-5) % 10])
    I = round(n/10)
    matrix1 = []
    matrix2 = []
    matrix3 = []
    matrix4 = []
    for j in range(0, I*10+10, 10):
        z = -np.power(col_index - j, 2)/np.power(2*sigma, 2)
        z = np.exp(z)
        if j == 0:
            C = o1*z
        elif j == I*10:
            C = o3*z
        else:
            C = o2*z
        if matrix1 == []:
            matrix1 = C
        else:
            matrix1 = np.concatenate((matrix1, C), axis=1)
    o1 = np.ones([m, 10])
    o2 = np.ones([m, n % 10])
    I = round((n-5)/10)
    for j in range(5, I*10+15, 10):
        z = -np.power(col_index - j, 2) / np.power(2 * sigma, 2)
        z = np.exp(z)
        if j == I*10+5:
            C = o2*z
        else:
            C = o1*z
        if matrix2 == []:
            matrix2 = C
        else:
            matrix2 = np.concatenate((matrix2, C), axis=1)
    o1 = np.ones([5, n])
    o2 = np.ones([10, n])
    o3 = np.ones([(m-5)%10, n])
    I = round(m/10)
    for j in range(0, I*10+10, 10):
        z = -np.power(col_index - j, 2) / np.power(2 * sigma, 2)
        z = np.exp(z)
        if j == 0:
            C = o1*z
        elif j == I*10:
            C = o3*z
        else:
            C = o2*z
        if matrix3 == []:
            matrix3 = C
        else:
            matrix3 = np.concatenate((matrix3, C), axis=0)
    o1 = np.ones([10, n])
    o2 = np.ones([m%10, n])
    I = round((m-5)/10)
    for j in range(5, I*10+15, 10):
        z = -np.power(col_index - j, 2) / np.power(2 * sigma, 2)
        z = np.exp(z)
        if j == I*10+5:
            C = o2*z
        else:
            C = o1*z
        if matrix4 == []:
            matrix4 = C
        else:
            matrix4 = np.concatenate((matrix4, C), axis=0)

    Grid = gain*(np.multiply(np.add(matrix1, matrix2), np.add(matrix3, matrix4)))
    return Grid


def facilitationMatrix(grid, col_index, default, ts, w):
    m, n = grid.shape
    try:
        facilitationMatrix.delayGrid
    except AttributeError:
        facilitationMatrix.delayGrid = None
    if facilitationMatrix.delayGrid is None:
        facilitationMatrix.delayGrid = np.zeros([m, n])
    if col_index == 1:
        G1 = facilitationMatrix.delayGrid
    else:
        G1 = grid

    G2 = np.add(G1, np.ones_like(grid))
    if default == 0:
        fac = np.ones_like(G2)
    else:
        fac = G2

    bArray = [ts * w / (ts * w + 2), ts * w / (ts * w + 2)]
    aArray = [1, (ts * w - 2) / (ts * w + 2)]
    try:
        facilitationMatrix.Buffer
    except AttributeError:
        facilitationMatrix.Buffer = None
    if facilitationMatrix.Buffer is None:
        facilitationMatrix.Buffer = np.zeros([m, n, len(bArray)])

    facilitation, facilitationMatrix.Buffer = IIRFilter(bArray, aArray, fac, facilitationMatrix.Buffer)
    facilitationMatrix.delayGrid = G1
    return facilitation


def facilitationMatrix2(grid, col_index, default, ts, w):
    m, n = grid.shape
    try:
        facilitationMatrix2.delayGrid
    except AttributeError:
        facilitationMatrix2.delayGrid = None
    if facilitationMatrix2.delayGrid is None:
        facilitationMatrix2.delayGrid = np.zeros([m, n])
    if col_index == 1:
        G1 = facilitationMatrix2.delayGrid
    else:
        G1 = grid

    G2 = np.add(G1, np.ones_like(grid))
    if default == 0:
        fac = np.ones_like(G2)
    else:
        fac = G2

    bArray = [ts * w / (ts * w + 2), ts * w / (ts * w + 2)]
    aArray = [1, (ts * w - 2) / (ts * w + 2)]
    try:
        facilitationMatrix2.Buffer
    except AttributeError:
        facilitationMatrix2.Buffer = None
    if facilitationMatrix2.Buffer is None:
        facilitationMatrix2.Buffer = np.zeros([m, n, len(bArray)])

    facilitation, facilitationMatrix2.Buffer = IIRFilter(bArray, aArray, fac, facilitationMatrix2.Buffer)
    facilitationMatrix2.delayGrid = G1
    return facilitation


def regionDetector(col, row, estmd):
    a = row
    b = row
    c = col
    d = col
    while estmd[a, col] > 0.2:
        if a == 34:
            break
        a += 1
    while estmd[b, col] > 0.2:
        if b == 0:
            break
        b -= 1
    while estmd[row, c] > 0.2:
        if c == 45:
            break
        c += 1
    while estmd[row, d] > 0.2:
        if d == 0:
            break
        d -= 1
    region = [a, b, c, d]
    return region


def regionProcessing(rtc, region):
    m,n = rtc.shape
    rtcForward = np.zeros_like(rtc)
    rtcReverse = np.zeros_like(rtc)
    for x in range(m):
        for y in range(n):
            if region[0]+1 > x > region[1]-1 and region[2]+1 > y > region[3]-1:
                rtcForward[x, y] = 10 * rtc[x, y]
            else:
                rtcForward[x, y] = 0.2*rtc[x, y]
    for x in range(m):
        for y in range(n):
            if region[0] + 1 > x > region[1] - 1 and region[2] + 1 > y > region[3] - 1:
                rtcReverse[x, y] = 0 * rtc[x, y]
            else:
                rtcReverse[x, y] = rtc[x, y]

    if region[0] == 0:
        rtcReverse == rtc
        rtcForward == rtc

    return rtcForward, rtcReverse

#


def direction_finder(new_coord, old_coord):
    if new_coord[0] != 0 and old_coord[0] != 0:
        x_direct = new_coord[0] - old_coord[0]
        y_direct = new_coord[1] - old_coord[1]
        if x_direct == 0:
            x_direct = 0.01
        current_direction = np.degrees(np.arctan([y_direct/x_direct]))
        current_magnitude = math.sqrt(x_direct**2 + y_direct**2)
    else:
        current_direction = 0
        current_magnitude = 0
    return current_direction, current_magnitude




# def directionRegulator(old_direct, new_direct):
#     object_direction = 0.5*old_direct + 0.5*new_direct


# def direction_regulator(new_direction, old_direction)
#     if new_direction[0]!=0 and old_direction[0]!=0:
#         new_cartesian =
