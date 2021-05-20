function [left, right, Up, Down] = Reichardt_Correlator(delayed, original)

    [rows ,columns] = size(original);

    left_orig = original(1:rows, 1:(columns-1));
    right_orig = original(1:rows, 2:columns);

    left_LP = delayed(1:rows, 2:columns);
    right_LP = delayed(1:rows, 1:(columns-1));

    right_big = right_orig.*right_LP;
    right = right_big(:, 2:(columns-1));

    left_big = left_orig.*left_LP;
    left = left_big(:, 2:(columns-1));

    Up_orig = original(1:(rows-1), 1:columns);
    Down_orig = original(2:rows, 1:columns);

    Up_LP = delayed(1:(rows-1), 1:columns);
    Down_LP = delayed(2:rows, 1:columns);

    Up_big = Up_orig.*Up_LP;
    Up = Up_big(2:(rows-1),:);

    Down_big = Down_orig.*Down_LP;
    Down = Down_big(2:(rows-1),:);
end