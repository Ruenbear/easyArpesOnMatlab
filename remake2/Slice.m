classdef Slice
%
    properties (Access = public)
        mat2
        xxl
        yyl
    end
    
    methods (Access = public)
        function obj = Slice(cut,xl,yl)
            if nargin == 1
                %直接读取文件
                disp(cut);
            else
                %从mapping中生成
                obj.mat2 = cut;
                obj.xxl = xl;
                obj.yyl = yl;
            end
        end

    end
end

