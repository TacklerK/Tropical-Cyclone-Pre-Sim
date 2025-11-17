clc;
clear;
close all

%读取地形数据
dem=geotiffread("E:\桌面\模拟路径处理\陆地\地形数据\DEM005du.tif");
slope=geotiffread("E:\桌面\模拟路径处理\陆地\地形数据\slope005du.tif");
aspet=geotiffread("E:\桌面\模拟路径处理\陆地\地形数据\aspect005du.tif");
%读取样本数据
sample=readtable("E:\桌面\模拟路径处理\数据重建\Sample.csv");
lon=sample.LON;
lat=sample.LAT;
MoveDgree=sample.DGREE;
disnum=sample.distance/50;
pointnum=length(lon);
%划分格网
lonlim=-180:0.05:179.95;
latlim=90:-0.05:-89.95;
[glon,glat]=meshgrid(lonlim,latlim);
%遍历文件
DEM=nan(pointnum,8);
SLOPE=nan(pointnum,8);
ASPECT=nan(pointnum,8);
for i=1:pointnum
    [i,pointnum]
    curlon=lon(i);
    curlat=lat(i);
    curmove=MoveDgree(i);
    m=disnum(i);
    [dis,az]=distance(glat,glon,curlat,curlon,6371.004);
    %计算环带数和角度数
    disrad=fix(dis./50)+1;
    az=az-curmove;%计算格网相对于移动方向的角度
    kk=find(az<0);
    az(kk)=az(kk)+360;
    azRad=fix(az./45)+1;
    %赋值
    for n=1:8
        loc=find(azRad==n&disrad==m);
        DEM(i,n)=mean(dem(loc),"omitnan");
        SLOPE(i,n)=mean(slope(loc),"omitnan");
        ASPECT(i,n)=mean(aspet(loc),"omitnan");
    end
end
sample=addvars(sample,DEM,SLOPE,ASPECT,'Before','Rain1');
writetable(sample, 'E:\桌面\模拟路径处理\数据重建\Sample(terr).csv');












