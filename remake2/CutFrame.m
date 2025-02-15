classdef CutFrame <handle
    %构建cutline网络
    properties
        xAxes
        yAxes
        eAxes
        pesAxes

        map_m
        
        slx_m
        sly_m
        sle_m
        
        pes_curve

        fcn_names
        fcn_paras

    end
    
    methods (Access = public)
        function obj = CutFrame(map_m,axList)
                if nargin == 1
                    obj.getAxes;
                end
                obj.map_m = map_m;               
                obj.sle_m = SliceManager(obj.map_m.getE,obj.eAxes);
                obj.slx_m = SliceManager(obj.map_m.getX,obj.xAxes);
                obj.sly_m = SliceManager(obj.map_m.getY,obj.yAxes);
        end

        function getAxes(obj)
            figure;
            obj.xAxes = axes;
            figure;
            obj.yAxes = axes;
            figure;
            obj.eAxes = axes;
            figure;
            obj.pesAxes = axes;
        end
        

        %刷新坐标系，需要在每次修改Slice之后进行
        function reE(obj)
%             if ~isempty(obj.sle_m)
%                 delete(obj.sle_m)
%             end
            obj.sle_m.changeSlice(obj.map_m.getE);
            obj.modify(0);
%             obj.sle_m.on('normalize');
%             obj.sle_m.set('normalize',{'Vertical'});
%             obj.sle_m.modify;
            obj.sle_m.showeq;
        end
        function reX(obj)
            obj.slx_m.changeSlice(obj.map_m.getX);
            %obj.slx_m.normalize('Both');
            obj.modify(1);
            obj.slx_m.show;
        end

        function reY(obj)
            obj.sly_m.changeSlice(obj.map_m.getY);
            %obj.sly_m.normalize('Both');
            obj.modify(2);
            obj.sly_m.show;
        end

        function getECutLine(obj)
            hold(obj.eAxes,"on");
            cutLinePro(obj.eAxes,@obj.doX,@obj.doY,obj.map_m.val_arr(2:3));
        end

        function modify(obj,exy)
            fname = obj.fcn_names{exy+1};
            para = obj.fcn_paras{exy+1};
            switch exy 
                case 0
                    hd = obj.sle_m;
                case 1
                    hd = obj.slx_m;
                case 2
                    hd = obj.sly_m;
            end
            hd.offAll;
            for j = 1:length(fname)
                hd.on(fname{j});
                hd.set(fname{j},para{j});
            end
            hd.modify;
        end


    end

    methods (Access = private)
        function doE(obj,val)
            obj.map_m.val_arr(1) = val;
            obj.reE;
        end
        function doX(obj,val)
            obj.map_m.val_arr(2) = val;
            obj.reX;
        end
        function doY(obj,val)
            obj.map_m.val_arr(3) = val;
            obj.reY;
        end
    end
end