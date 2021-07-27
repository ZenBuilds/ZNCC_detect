function mtb = MTB(grey_img)
% This is the function of computing the Median Threshold Bitmap(MTB) of a...
% grey image
    grey_value = get_grey_value(grey_img, 0.5);
    grey_img(grey_img < grey_value) = 0;
    grey_img(grey_img >= grey_value) = 1;
    mtb = grey_img;
end