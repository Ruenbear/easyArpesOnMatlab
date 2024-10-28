classdef MappingManager < handle
    % 调控Mapping的Cut位置
    % 整体的归一化、去线性本底、二阶微分等
    % 3D-Cube的生成

    % setE/setX/setY 来修改三个方向slice的位置
    % getE/getX/getY 获取三个方向的slice
    %
    properties (Access = public)
        omap
        map
        
        val_arr
        sum_arr = [1,1,1];

    end
    methods (Access = public)
        function obj = MappingManager(map,val)
            if isa(map,"char")||isa(map,"string")
                obj.map = Mapping(map);
                disp(111)
            else
                obj.map = map;
            end
            if nargin == 1
                obj.val_arr = [mean(obj.map.eel),mean(obj.map.xxl),mean(obj.map.yyl)];
            else
                obj.val_arr = val; %初始化切片位置
            end
            
            obj.normalize;
            obj.omap = obj.map;
        end

        function r = getE(obj)
            r = obj.map.getE(obj.val_arr(1),obj.sum_arr(1));
        end
        function r = getX(obj)
            r = obj.map.getX(obj.val_arr(2),obj.sum_arr(2));
        end
        function r = getY(obj)
            r = obj.map.getY(obj.val_arr(3),obj.sum_arr(3));
        end

        function setE(obj,val)
            obj.val_arr(1) = val;
        end
        function setX(obj,val)
            obj.val_arr(2) = val;
        end
        function setY(obj,val)
            obj.val_arr(3) = val;
        end

        function normalize(obj)
            M = max(max(obj.map.mat3));
            temp1 = 0.6*mean(M)+0.4*max(M);
            m = min(min(obj.map.mat3));
            temp2 = 0.6*mean(m)+0.4*min(m);
            obj.map.mat3 = (obj.map.mat3-temp2)/(temp1-temp2)*256;     
        end

    end
end