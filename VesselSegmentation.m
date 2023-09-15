function []=main()
    clc
    clear all
    close all
    image_path='..\DRIVE\training\images\';
    vessel_path='..\separation results\contourlet-shearlet-DRIVE-500\train\';
    out_path='..\vessel_segmentation\drive\';
    Imgs = dir([image_path '/' ['*.','tif']]);
    for i=1 : length(Imgs)
        img=imread([image_path,Imgs(i).name]);
        [mask,img]=Cropping(img,20);
        img = imadjust(img,[0.2 .7],[]);
        img=imresize(img,[512,512]);
        mask=imresize(mask,[512,512]);
        if(exist([vessel_path,'vessel',Imgs(i).name]))
            vessel_img=imread([vessel_path,'vessel',Imgs(i).name]);
            [vessel_map,vessel_thin]=create_vessel_map(vessel_img,.2,mask);
            img=mat2gray(img);
            img(:,:,1)=img(:,:,1).*(~vessel_thin);
            img(:,:,2)=img(:,:,2).*(~vessel_thin);
            img(:,:,3)=img(:,:,3).*(~vessel_thin)+img(:,:,3).*(vessel_thin);
            imwrite(img,[out_path,Imgs(i).name]);
            disp(i)
        end
    end
end
%-----------------------------------------------
function [v,bw_thin]=create_vessel_map(img,T,mask)
    img=mat2gray(img);
    [a,b]=hist(img(mask(:)),min(img(mask(:))):.04:max(img(mask(:))));
    a=a./sum(a);
    g(1)=0;
    for i=2 : length(a)
        g(i)=g(i-1)+a(i);
    end
    [c,d]=find(g<=T);
    th=b(d(end));
    v=img<=th;
    remove=.1;
    fill=.01;
    scale = nnz(mask) / 100;
    scale=1000;
    v = clean_segmented_image(v, scale*remove, scale*fill);
    se=strel('disk',5);
    mask=imerode(mask,se);
    v=v.*mask;
    bw_thin = bwmorph(v, 'thin', Inf);
end