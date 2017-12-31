function [o_img] = bicubic(img,o_h,o_w)
[M,N,c] = size(img);
if c == 1
    o_img = bicubic_single(img,o_h,o_w);
else
    o_img = zeros(o_h,o_w,c);
    for i = 1 : c
        o_img(:,:,i) = bicubic_single(img(:,:,i),o_h,o_w);
    end
end
    o_img = uint8(o_img);
end
