function [vline,pline] = cutLinePro(ax,vfun,pfun,ppos)

temp = ax;
while 1
    temp = temp.Parent;
    if isa(temp,'matlab.ui.Figure')
        fg = temp;
        break;
    end
end

xrange = ax.XLim;
yrange = ax.YLim;

%生成一条线
xx = mean(xrange)*[1,1];
yy = yrange;


vcolor1 = [166,186,204]/255;
vcolor2 = [82,111,132]/255;
vline = plot(ax,xx,yy,'linewidth',2, ...
    'ButtonDownFcn', @vlineBdf, ...
    'color',vcolor1);

if nargin == 3
    ppos = mean(yrange)*[1,1];
end
xx = xrange;
yy = ppos;
pcolor1 = [5,242,5]/255;
pcolor2 = [86,177,70]/255;
pline = plot(ax,xx,yy,'linewidth',2, ...
    'ButtonDownFcn', @plineBdf, ...
    'color',pcolor1);


%鼠标选定的曲线位置
mousePos = [];
    function vlineBdf(~,~)
        vline.Color = vcolor2;
        vline.LineWidth = 3;
        fg.WindowButtonMotionFcn=@vwbmfcn;
        fg.WindowButtonUpFcn=@vwbufcn;
    
        function vwbmfcn(~,~)
            mousePos = ax.CurrentPoint;
            %xdata = cutline.XData;
            xpos = mousePos(1,1);
            if (xpos<=xrange(2))&&(xpos>=xrange(1))
               vline.XData = xpos*[1,1];
               lxpos = xpos;
               vfun(lxpos)
            end
        end
    
        function vwbufcn(~,~)
            fg.WindowButtonMotionFcn='';
            fg.WindowButtonUpFcn='';
            vline.Color = vcolor1;
            vline.LineWidth = 2;
        end
    end
    


    function plineBdf(~,~)
        pline.Color = pcolor2;
        pline.LineWidth = 3;
        fg.WindowButtonMotionFcn=@pwbmfcn;
        fg.WindowButtonUpFcn=@pwbufcn;
    
        function pwbmfcn(~,~)
            mousePos = ax.CurrentPoint;
            %xdata = cutline.XData;
            ypos = mousePos(1,2);
            if (ypos<=yrange(2))&&(ypos>=yrange(1))
               pline.YData = ypos*[1,1];
               lypos = ypos;
               pfun(lypos)
            end
        end
    
        function pwbufcn(~,~)
            fg.WindowButtonMotionFcn='';
            fg.WindowButtonUpFcn='';
            pline.Color = pcolor1;
            pline.LineWidth = 2;
        end
    end





end

