function diff_img = bg_difference(target_img, base_img, l, di)
[h, w] = size(target_img);
tmp_img = zeros(h, w);
    for i = 1:h
       for j = 1:w
           if i - l < 1; up = 1;        else; up = i - l;end
           if i + l > h; bottom = h;    else; bottom = i + l;end
           if j - l < 1; left = 1;      else; left = j - l;end
           if j + l > w; right = w;     else; right = j + l;end
           
%          Formula
           tmp_img(i, j) = sum(sum(...
               abs((target_img(up:bottom, left:right) - base_img(up:bottom, left:right)))))/...
               power(numel(target_img(up:bottom, left:right)), 2);
       end
    end
    di = get_grey_value(tmp_img, 0.95);
    diff_img = zeros(h, w);
    diff_img(tmp_img >= di) = 1;
% diff_img = tmp_img;
end