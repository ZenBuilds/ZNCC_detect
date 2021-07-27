clear ;
close all;
addpath(genpath(pwd));
imgSeqColor= loadImg('test sequence\14'); 
r = 5;
[h, w, ~, n] = size(imgSeqColor);
g = zeros(h, w, n);
eq = g;
for i = 1:3
    g(:,:,i) = rgb2gray(imgSeqColor(:,:,:,i));
end
for i = 1:3
    eq(:,:,i) = histeq(g(:,:,i));
end

for i = 1:3
    eq(:,:,i) = medfilt2(eq(:,:,i), [4 4]);
%     imwrite(eq(:,:,i), "./test/eq"+i+".jpg");
end

base = 2;
l = 3;
% fun_sub = @(block_struct) sum(block_struct.data) / power(2*3+1, 2);
% tmp = zeros(10,10);
motion_bitmap = zeros(h, w, 3);
% for i = 1:3
%    if i ~= 2
%        motion_bitmap(:,:,i) = bg_difference(eq(:,:,i), eq(:,:,base), l, thres);
%    end
% end

for i = 1:3
    motion_bitmap(:,:,i) = bg_difference(g(:,:,i), g(:,:,base), l, 0.002);
%     imwrite(motion_bitmap(:,:,i), "./test/motion_bit"+i+".jpg");
    figure, imshow(motion_bitmap(:,:,i));
end

mtbs = g;

deghost = imgSeqColor;
for i = 1:3 
        mtbs(:, :, i) =  MTB(g(:, :, i));
%         imwrite(mtbs(:,:,i), "./test/mtbs"+i+".jpg");
end

m2 = zeros(h, w, n);
m = ones(h, w, n);
for i = 1:3
    if i ~= 2
        m2(:, :, i) = xor(mtbs(:, :, i), mtbs(:, :, base));
        m(:, :, i) = motion_bitmap(:, :, i) | m2(:, :, i);
%         imwrite(m(:,:,i), "./test/m"+i+".jpg");
        temp = imhistmatch(imgSeqColor(:,:,:,base),...
                imgSeqColor(:,:,:,i),'method', 'polynomial');
        temp(temp<0) = 0;
        temp(temp>1) = 1;
        deghost(:, :, :, i) = imgSeqColor(:, :, :, i) .* repmat(m(:, :, i), [1 1 3])+...
            temp .* repmat(1-m(:, :, i), [1 1 3]);
    end
    if i == 2
        deghost(:, :, :, i) = imgSeqColor(:, :, :, i);
    end
%     imwrite(deghost(:,:,i), "./test/deghost"+i+".jpg");
end
fi = fastExpoFuse(deghost, r);
imshow(fi);


