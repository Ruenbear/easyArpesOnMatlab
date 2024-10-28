classdef SliceManager < handle
    % modify 对初始图像进行一系列处理
    %    ---->  通过on打开相应的处理方法，
    %           set设置相应参数
    %           off关闭相应方法
    %           offAll关闭全部方法
    %
    % fix 对图像的亮度、对比度进行调整
    %    ---->  通过setGT来调整Gain\Thd参数
    %
    % show/showeq 将图像展示在ax坐标系中

    properties
        osl %一份原始数据
        sl %一份显示数据

        ax %显示坐标系
        clrmap = 37;%坐标系的colormap



    end
    methods
        function obj = SliceManager(sl,ax)
            obj.osl = sl;
            obj.sl = sl;
            obj.ax = ax;
        end
        function changeSlice(obj,sl)
            obj.osl = sl;
            obj.sl = sl;
        end

        function ig = show(obj)
            ac = obj.ax.Children;
            %删除其他Image对象
            for j = 1:length(ac)
                if isa(ac(j),'matlab.graphics.primitive.Image')
                    delete(ac(j));
                end
            end
            xr = [obj.sl.xxl(1),obj.sl.xxl(end)];
            yr = [obj.sl.yyl(1),obj.sl.yyl(end)];
            ig = image(obj.ax,obj.sl.mat2);
            obj.ax.YDir = 'normal';
            ig.XData = xr;
            ig.YData = yr;
            obj.ax.XLim = xr;
            obj.ax.YLim = yr;
            colormap(obj.ax,slanCM(obj.clrmap));
            ac = obj.ax.Children;
            %将Image对象置于底部
            for j = 1:length(ac)
                if isa(ac(j),'matlab.graphics.primitive.Image')
                    break;
                end
            end
            obj.ax.Children = popj(ac,j,1);
        end

        function ig = showeq(obj)
            %坐标轴等比例展示
            ig = obj.show;
            obj.ax.DataAspectRatio = [1,1,1];
            %ig.CDataMapping = 'Scaled';
        end

        %按照proc对sl进行处理,每次修改proc后需要执行
        function modify(obj)
            obj.sl = obj.osl;%初始化
            ps = obj.proc_status;
            pn = fieldnames(ps);
            for j = 1:length(pn)
                nm = pn{j};
                if ps.(nm)
                    eval(['ff=@obj.',nm,';']);
                    ff();
                    %ff(pp.(nm));
                end
            end
        end

        function on(obj,fname)
            obj.proc_status.(fname) = true;
        end
        function set(obj,fname,para)
            obj.proc_para.(fname) = para;
        end
        function off(obj,fname)
            obj.proc_status.(fname) = false;
        end
        function offAll(obj)
            fn = fieldnames(obj.proc_status);
            for j = 1:length(fn)
                obj.off(fn{j});
            end
        end

        function fix(obj)
            %对modify的结果进行亮度、对比度调整
            obj.sl.mat2 = (obj.sl.mat2-obj.gainthd(2)*256)*obj.gainthd(1);
        end
        function setGT(obj,gt)
            obj.gainthd(1) = gt{1};
            obj.gainthd(2) = gt{2};
        end

    end


    properties (Access = private)
    %fieldname的顺序决定了图像处理的顺序
        proc_status = struct( ...
            'smooth',false, ...
            'm2dev',false, ...
            'normalize',false);

        proc_para = struct( ...
            'smooth',{{'Vertical',10}}, ...
            'm2dev',{{'Vertical',50}}, ...
            'normalize',{{'Both'}});

        gainthd = [1,0];
    end

    %保存modify过程中的函数
    %需要函数名与proc中的fieldname一一对应
    methods (Access = private)
        function smooth(obj)
            direct = obj.proc_para.smooth{1};
            order = obj.proc_para.smooth{2};
            img = obj.sl.mat2;
            if strcmp(direct,'Parallel')
                img = img';
            end
            sm = size(img);
            for j = 1:sm(2)
                img(:,j) = smoothdata(img(:,j),'gaussian',order);
            end
            if strcmp(direct,'Parallel')
                img = img';
            end
            obj.sl.mat2 = img;
        end

        function normalize(obj)
            %归一化
            temp = obj.proc_para.normalize;
            mode = temp{1};
            if strcmp(mode,'Both')
                M = max(obj.sl.mat2);
                temp = 0.6*mean(M)+0.4*max(M);
                obj.sl.mat2 = obj.sl.mat2/temp*256;
            end
            if strcmp(mode,'Vertical')
                obj.sl.mat2 = obj.pNormal(obj.sl.mat2,1,[10,100])*256;
            end
            if strcmp(mode,'Parallel')
                obj.sl.mat2 = obj.pNormal(obj.sl.mat2,2,[10,100])*256;
            end
        end

        function m2dev(obj)
            %负二阶微分
            temp = obj.proc_para.m2dev;
            direct = temp{1};
            del = temp{2};
            img = obj.sl.mat2;
            if strcmp(direct,'Parallel')
                img = img';
            end
            sm = size(img);
            for i = 1:sm(2)
                img(:,i) = m2dev(img(:,i),del);
            end
            MM = mean(max(img));
            mm = mean(min(img));
            img = (img-mm)/(MM-mm);
            if strcmp(direct,'Parallel')
                img = img';
            end
            obj.sl.mat2 = img;
        end
    end

    methods (Static)
        function r = lowhigh(img,thd)
            %记最大值、最小值为MM、mm
            %指定thd为两个百分比组成的二维行向量
            %将[thd1*mm,thd2*MM]重新映射到[mm,MM]区间
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
            r = img*(MM-mm)+mm;
        end

        function img = pNormal(img,direct,thd)
            if nargin == 2
                thd = [0,100];
            end
            if nargin == 1
                direct = 1;
                thd = [0,100];
            end
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
        end
        function seu = singleNormalize(myarr,thd)
            myarr = error2edge(myarr,thd);
            mm = min(myarr);
            MM = max(myarr);
            seu = (myarr - mm)/(MM-mm);
        end
    end
end