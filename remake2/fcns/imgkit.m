classdef imgkit
%图像工具包
methods(Static)

%图像统一归一化
function CUT = normal(CUT)
    img = CUT.cut;
    mm = min(min(img));
    MM = max(max(img));
    immg = (img-mm)/(MM-mm);
    %immg(immg>1) = 1;
    CUT.cut = immg;
end

%图像强度调整
function CUT = modi(CUT,thd)
    %记最大值、最小值为MM、mm
    %指定thd为两个百分比组成的二维行向量
    %将[thd1*mm,thd2*MM]重新映射到[mm,MM]区间
    try
        img = CUT.cut;
    catch
        img = CUT;
    end
    MM = max(max(img));
    mm = min(min(img));
    img = (img-mm)/(MM-mm);
    %先计算区间宽度
    wd = thd(2) - thd(1);
    %数据点向下平移
    img = (img - thd(1))/wd;
    %排除越界
    img(img<0)=0;
    img(img>1)=1;
    img = img*(MM-mm)+mm;
    try
        CUT.cut = img;
    catch
        CUT = img;
    end
%    img = imgTools.normal(img);
end

function OUT = subarea(CUT,xrange,yrange)
    cut = CUT.cut;
    sm = size(cut);
    xxl = CUT.xxl;
    yyl = CUT.yyl;
    xxl = linspace(xxl(1),xxl(end),sm(2));
    yyl = linspace(yyl(1),yyl(end),sm(1));
    x1 = val2ind(xxl,xrange(1));
    x2 = val2ind(xxl,xrange(2));
    y1 = val2ind(yyl,yrange(1));
    y2 = val2ind(yyl,yrange(2)); 
    disp(x2);
    OUT.cut = cut(y1:y2,x1:x2);
    OUT.xxl = xxl(x1:x2);
    OUT.yyl = yyl(y1:y2);
end




function CUT = pNormal(CUT,direct,thd)
if nargin == 2
    thd = [0,100];
end
if nargin == 1
    direct = 1;
    thd = [0,100];
end
img = CUT.cut;
if direct == 2
    img = img';
end
sm = size(img);
for i = 1:sm(2)
    img(:,i) = imgkit.singleNormalize(img(:,i),thd);
end
if direct == 2
    img = img';
end
CUT.cut = img;
end

function seu = singleNormalize(myarr,thd)
myarr = error2edge(myarr,thd);
mm = min(myarr);
MM = max(myarr);
seu = (myarr - mm)/(MM-mm);
end


function CUT = smooth(CUT,direct,order)
    %direct = 1,2 - (v,p)
    img = CUT.cut;
    if direct == 2
        img = img';
    end
    sm = size(img);
    for j = 1:sm(2)
        img(:,j) = smoothdata(img(:,j),'gaussian',order);
    end
    if direct == 2
        img = img';
    end
    CUT.cut = img;
end

function CUT = dev(CUT,direct,del)
    %direct 1,2 - (v,p)
    img = CUT.cut;
    if direct == 2
        img = img';
    end
    
    sm = size(img);
    for i = 1:sm(2)
        img(:,i) = m2dev(img(:,i),del);
    end
    MM = mean(max(img));
    mm = mean(min(img));
    img = (img-mm)/(MM-mm);
       
    if direct == 2
        img = img';
    end
    CUT.cut = img;

end

function CUT = mult(CUT,gain)
    CUT.cut = CUT.cut*gain;
end

function CUT = laplace(CUT,h)
    CUT.cut = -del2(CUT.cut,h);
    CUT = imgkit.normal(CUT);
end





end



end