% =========================================================================
% Description����Ʊ�������Ҫ�����ָ�˹�˲�:����[m,n] = size(img);
%              �ٵ�shape='v'ʱ��filter2(img,w,'valid')Ч��һ��,
%                ���ͼ��Ϊdouble���ͣ���СΪ[m-window+1,n-window+1];
%              �ڵ�shape='r'ʱ��imfilter(img,w,'replicate')Ч��һ��,
%                ���ͼ��Ϊuint8���ͣ���СΪ[m,n]
% Author��     Susie Chang
% Date��       17/12/27
% =========================================================================
function [o_img] = Guafilter2d(img,sigma,n,shape)
[hei, wid]=size(img);
%��˹�˲���
w = zeros(n,n);
N = floor(n/2);
for i=1:n  
    for j=1:n  
        fenzi=double((i-N-1)^2+(j-N-1)^2);  
        w(i,j)=exp(-fenzi/(2*sigma*sigma))/(2*pi*sigma);  
    end  
end
w=w/sum(w(:));
if shape=='v'
    %������  
    x1=double(img);
    x2 = x1;
    %���
    for i=n:hei-n+1
        for j=n:wid-n+1
            c = x1(i:i+(n-1),j:j+(n-1)).*w; 
            s = sum(sum(c));
            x2(i+(n-1)/2,j+(n-1)/2)=s;
        end
    end
    o_img = x2(n:hei-n+1,n:wid-n+1);
elseif shape=='r'
    %������
    hei_ext = hei + 2*(n - 1);
    wid_ext = wid + 2*(n - 1);
    img_ext = zeros(hei_ext,wid_ext);
    img_ext = extend_boundary(img,n-1);
    x1=double(img_ext);
    x2 = x1;
    %���
    for i=1:hei_ext-n+1
        for j=1:wid_ext-n+1
            c = x1(i:i+(n-1),j:j+(n-1)).*w; 
            s = sum(sum(c));
            x2(i+(n-1)/2,j+(n-1)/2)=s;
        end
    end
    o_img = x2(n:hei+n-1,n:wid+n-1);
    o_img = uint8(o_img);
else
    error('wrong input param');
end
end