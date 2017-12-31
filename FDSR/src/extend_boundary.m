%==========================================================================
% Description:  由于matlab版本缺少工具箱，自行编写函数实现函数
%               wextend('2D','sym',X,len)功能用于边界延拓
% Author:       Susie Chang
% Date:         2017/12/30
%==========================================================================
function [ext_y] = extend_boundary(y,n)
[h,w] = size(y);
ext_y = zeros(h + 2*n, w + 2*n);
row_ext_y = zeros(h,w + 2*n);
row_left_y = y(1:h,1:n);
row_left_inv_y = fliplr(row_left_y);
row_right_y = y(1:h,w - n + 1:w);
row_right_inv_y = fliplr(row_right_y);
row_ext_y(1:h,1:n) = row_left_inv_y;
row_ext_y(1:h,w + n+1:w+2*n) = row_right_inv_y;
row_ext_y(1:h,n+1:w+n) = y(1:h,1:w);

col_up_y = row_ext_y(1:n,1:w + 2*n);
col_up_inv_y = flipud(col_up_y);
col_down_y = row_ext_y(h - n + 1:h,1:w+2*n);
col_down_inv_y = flipud(col_down_y);
ext_y(1:n,1:w + 2*n) = col_up_inv_y;
ext_y(h + n + 1:h + 2*n,1:w + 2*n) = col_down_inv_y;
ext_y(n+1:h+n,1:w+2*n) = row_ext_y;