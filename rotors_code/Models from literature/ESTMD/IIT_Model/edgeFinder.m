function [edgeCoord, edgeSize] = edgeFinder(origin, frame)

up = origin(2);
down = origin(2);
left = origin(1)+2;
right = origin(1)+2;
%find upper boundary
while frame(up, left)>=245
    left = left - 1;
    while frame(up, left) >= 245
        up = up - 1;
    end
end

while frame(down, right)>=245
    right = right + 1;
    while frame(down, right) >= 245
        down = down + 1;
    end
end

edgeSize = [down-up, right-left];
edgeCoord = [origin(1), up];

