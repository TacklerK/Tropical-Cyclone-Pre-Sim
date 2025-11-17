clc;
clear;
close all

%% 保存的excel
title = {'class_type', 'INTER_SID', 'tracknum', 'ALL_SID', ...
    'CN_SID', 'endcode', 'step_time', 'storm_name','gettime', ...
    'YMDH', 'intensity', 'LAT', 'LON', 'PRESS', 'WND','DGREE',...
    'SPEED','IFLANDFULL','SEASON','DIS2COAST','distance'};
%% 读
samplepath='E:\桌面\模拟路径处理\数据重建\LandDataPred.csv';
Infodata=readtable(samplepath);
alldata=table2cell(Infodata);
%%
Intervel=50;%间隔
Internum=1000/Intervel;%环的数量
CenLat=Infodata(:,12);
CenLon=Infodata(:,13);
%CenTime=num2str(Infodata(:,10));
PointNum=height(CenLat);
outdata=[];
for i=1:PointNum
    curdata=alldata(i,:);
    CurLat=table2array(CenLat(i,1));
    CurLon=table2array(CenLon(i,1));
    %0.1MSWEP分辨率范围
    msweplonlim=-180:0.1:179.9;
    msweplatlim=90:-0.1:-89.9;
    %将图像划分格网(MSWEP)
    [rglon,rglat]=meshgrid(msweplonlim,msweplatlim);
    [rdistRad,raz]=distance(rglat,rglon,CurLat,CurLon,6371.004);%两点间距离和方位角，单位km
    rdistRad=fix(rdistRad./Intervel)+1;%第n个环!!
    for j=1:Internum
        outdata=[outdata;[curdata,j*Intervel]];
    end
end
outcell = [title; outdata];
outfilename="E:\桌面\模拟路径处理\数据重建\LandDataAll.xlsx";
xlswrite(outfilename, outcell);








