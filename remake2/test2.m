clear;clc;
%mp = Mapping('CS0680059.zip');
mpm = MappingManager('CS0680059.zip');
cf = CutFrame(mpm);

%图片处理方法和参数 1-e，2-x，3-y
cf.fcn_names{2} = {'normalize','m2dev'};
cf.fcn_paras{2} = {{'Vertical',10},{'Vertical',100}};
cf.fcn_names{3} = {'normalize','m2dev'};
cf.fcn_paras{3} = {{'Vertical',10},{'Vertical',100}};

%刷新图像
cf.reE;
cf.reX;
cf.reY;


cf.getECutLine;

%%
clc
cf.sle_m.modify;
cf.sle_m.show;


%%
clc
sle = mpm.getE;
slx = mpm.getX;
sly = mpm.getY;

ax = axes;
sle_m = SliceManager(sle,ax);

clc
sle_m.on('m2dev');
sle_m.set('m2dev',{'Parallel',100});

%sle_m.proc_para.normalize = {};
%sle_m.proc_status.m2dev = true;
%sle_m.proc_para.m2dev = {'Parallel',50};
sle_m.modify;
%sle_m.setGT({100,0});
%sle_m.fix;


s = sle_m.showeq;
colorbar(ax);




