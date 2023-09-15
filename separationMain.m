function []=main()
% separate using shearlet and starlet
close all
clc
s=256;
path='.\DRIVE\training\images\';
outpath='..\separation results\contourlet-shearlet-DRIVE-500\train\';
num=64;
for i=1 : num
    nimg=double(imread([path,'img (',num2str(i),').tif']));
    [mask,nimg]=Mask(nimg);
    nimg=nimg(:,:,2);
    mask=imresize(mask,[256,256]);
    [x,y]=meshgrid(1:size(mask,2),1:size(mask,1));
    mask=mask.*((y-128).^2+(x-128).^2<128^2);
    nimg=imresize(nimg,[s,s]);
    nimg=nimg.*mask;
    nimg=preprocess(nimg);
    % function in the Shearlab package ---------------------------
    shear=shearing_filters_Myer([40 40 40 40],[3 3 3 3],s);
    % ------------------------------------------------------------
    [C P] = separate(nimg,8,20,3,3,[.1 .5 .5 1],0,shear);
    data{i}.point=P;
    data{i}.curve=C;
    data{i}.mask=mask;
    imwrite(mat2gray(P),[outpath,'lesion',num2str(i),'.png']);
    imwrite(mat2gray(C),[outpath,'vessel',num2str(i),'.png']);
    disp(i)
end
save([outpath,'normal1-100'],'data')
end

function [mask,image]=Mask(image)
thresh=3;
mask=image(:,:,2)>thresh;
se=strel('disk',15);
mask=imopen(mask,se);
se=strel('disk',15);
mask=imclose(mask,se);

[row,col]=find(mask);
r1=min(row);
r2=max(row);
c1=min(col);
c2=max(col);
mask=mask(r1(1):r2(1),c1(1):c2(1));
image=image(r1(1):r2(1),c1(1):c2(1),:);
end