function [o_img] =bicubic_single(img, o_h, o_w)
[i_h,i_w] = size(img);
x_ratio = double(i_h) / double(o_h);
y_ratio = double(i_w) / double(o_w);
for i = 1:o_h
    for j = 1:o_w
        tx = x_ratio*i;
        ty = y_ratio*j;
        x = floor(tx);
        y = floor(ty);
        dif_x = tx - x;
        dif_y = ty - y;
        %ÏµÊý
        Wx = [sw(1 + dif_x); sw(dif_x); sw(1 - dif_x); sw(2 - dif_x)];
        Wy = [sw(1 + dif_y), sw(dif_y), sw(1 - dif_y), sw(2 - dif_y)];     
        Px = x - 1 : 1 : x + 2;
        Px(Px < 1)=1; Px(Px > i_h)=i_h;
        Py = y - 1 : 1 : y + 2;
        Py(Py < 1)=1; Py(Py > i_w)=i_w;
        Pix = zeros(4,4);
        for r = 1:4
            for c = 1:4
                Pix(r,c) = img(Px(r),Py(c));
            end
        end
        Pix = double(Pix);
        o_img(i,j) = sum(sum(Pix.*(Wx*Wy)));
    end
end
o_img(o_img>255)=255;
o_img(o_img<0)=0;
o_img = uint8(o_img);
end

