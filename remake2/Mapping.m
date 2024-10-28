classdef Mapping
    %Mapping对象通过Slice方法导出Slice对象
    properties 
        mat3
        xxl
        yyl
        eel

        ini
    end
    methods (Access = public)
        function obj = Mapping(fname)
            addpath("fcns");
            temp = split(fname,'.');
            if strcmp(temp(end),'zip')
                %zip格式即原始数据,此时默认面内坐标为ang
                tempmap = loadDa30Zip2(fname);
                obj.mat3 = tempmap.map;
                obj.eel = tempmap.eel(:);
                obj.xxl = tempmap.angxl(:);
                obj.yyl = tempmap.angyl(:);
                obj.ini = tempmap.ini;
                %obj.kAngSwitch = 'ang';
            end  
        end
        function r = getE(obj,val,sum)
            ind = val2ind(obj.eel,val);
            r = obj.getSlice(0,ind,sum);
        end
        function r = getX(obj,val,sum)
            ind = val2ind(obj.xxl,val);
            r = obj.getSlice(1,ind,sum);
        end
        function r = getY(obj,val,sum)
            ind = val2ind(obj.yyl,val);
            r = obj.getSlice(2,ind,sum);
        end

        function r = getSlice(obj,direction,num,sum)
            sm = size(obj.mat3);
           
            enum = min(num+sum,sm(direction+1));
            switch direction %0-width,1-height,2-depth
                case 0
                    temp = mean(obj.mat3(num:enum,:,:),1);
                    slice = reshape(temp,sm(2),sm(3));
                    slice = slice'; %让kx落在x轴
                    r = Slice(slice,obj.xxl,obj.yyl);
                case 1
                    temp = mean(obj.mat3(:,num:enum,:),2);
                    slice = reshape(temp,sm(1),sm(3));
                    r = Slice(slice,obj.yyl,obj.eel);
                case 2
                    temp = mean(obj.mat3(:,:,num:enum),3);
                    slice = reshape(temp,sm(1),sm(2));
                    r = Slice(slice,obj.xxl,obj.eel);
            end
            

        end

    end

    methods (Access = private)

    end
end