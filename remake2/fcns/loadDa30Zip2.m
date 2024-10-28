function MAP = loadDa30Zip2(zipdir)
%将Da30的zip数据直接读取为标准化MAP结构体
%数据将被全局归一化.此处为粗归一
[map,ini] = loadDa30ZipOld(zipdir);
mm = mean(min(min(map)));
MM = mean(max(max(map)));
map = (map-mm)/(MM-mm);

MAP = ini2xxl(ini);
MAP.map = map;      
MAP.ini = ini;
end


function [MAP,INI] = loadDa30ZipOld(zipdir)
%解压指定ZIP，在当前文件夹建立指定子文件夹
%并调用函数读取该解压文件夹
%结束时删除该文件夹
tempdirname = '__tempzip__';
unzip(zipdir,tempdirname);
[MAP,INI] = loadDa30Folder(tempdirname);
rmdir(tempdirname,'s');
end

function [MAP,INI] = loadDa30Folder(fdir)
[bnm,inm] = findDa30(fdir);
INI = loadIni(inm);
MAP = loadFloatBin(bnm,INI.height, INI.width,INI.depth);
end

function myStruc = loadIni(ffname)
    iniCell = textIntoCell(ffname);
    lenIniCell = length(iniCell);
    for n = 2:lenIniCell
        tempStr = iniCell{n};
        tempCell = split(tempStr,"=");
        iniData.(tempCell{1}) = tempCell{2};
    end
    iniData.width = round(str2double(iniData.width));
    iniData.height = round(str2double(iniData.height));
    iniData.depth = round(str2double(iniData.depth));
    iniData.widthdelta = str2double(iniData.widthdelta);
    iniData.widthoffset = str2double(iniData.widthoffset);
    iniData.heightdelta = str2double(iniData.heightdelta);
    iniData.heightoffset = str2double(iniData.heightoffset);
    iniData.depthdelta = str2double(iniData.depthdelta);
    iniData.depthoffset = str2double(iniData.depthoffset);
    myStruc = iniData;
end


function AA = loadFloatBin(ffname,height,width,depth)

fileID = fopen(ffname);
A = fread(fileID,[width depth*height],'float');
fclose(fileID);
AA = zeros(width,height,depth);
for n = 1:depth
    AA(:,:,n) = A(1:width,height*(n-1)+1:height*(n));
    %im = image(A/10000);
end

end


function textCell = textIntoCell(ffname)

fid=fopen(ffname);       %首先打开文本文件coordinate.txt
temp = {};
mc = 1;
while ~feof(fid)    % while循环表示文件指针没到达末尾，则继续
    % 每次读取一行, str是字符串格式
    str = fgetl(fid);     
    temp{mc} = str;
    mc = mc + 1;
end
fclose(fid);
textCell = temp;

end


function [bnm,inm] = findDa30(ddir)
%在DA30-MAPPING文件夹中寻找
%二进制文件与配置信息的文件名
%假设他们一定以'Spectrum_'开头
tt = strcat(ddir,'\Spectrum*');
res = dir(tt);
fldr = res(1).folder;
fldr = strcat(fldr,'\');

for j = 1:2
    tn = res(j).name;
    temp = split(tn,'.');
    if strcmp(temp{end},'bin')
        bnm = tn;
    end
    if strcmp(temp{end},'BIN')
        bnm = tn;
    end
    if strcmp(temp{end},'INI')
        inm = tn;
    end
    if strcmp(temp{end},'ini')
        inm = tn;
    end
end

bnm = strcat(fldr,bnm);
inm = strcat(fldr,inm);


end



function OUT = ini2xxl(INI)
    eel = delta2xxl(INI.width,INI.widthoffset,INI.widthdelta);
    axl = delta2xxl(INI.height,INI.heightoffset,INI.heightdelta);
    ayl = delta2xxl(INI.depth,INI.depthoffset,INI.depthdelta);
    Ekin = mean(eel);
    OUT.angxl = axl;
    OUT.angyl = ayl;
    OUT.kxl = ang2k(axl,Ekin);
    OUT.kyl = ang2k(ayl,Ekin);
    OUT.eel = eel;
end

function xxl = delta2xxl(num,offset,delta)
    xxl = linspace(offset,offset+num*delta,num);
end


function kp = ang2k(xxl,Ekin)
    xxl = xxl/180*pi;
    kp = 0.512*sqrt(Ekin)*sin(xxl);
end
