function grey_value = get_grey_value(grey_img, scale)

[h, w] = size(grey_img);
loc = h * w * scale;

steps = 0;
[counts, bin] = imhist(grey_img);
for j = 1:256
   steps = steps + counts(j);
   if steps >= loc
       loc = j;
       break;
   end
end
grey_value = bin(loc);

end