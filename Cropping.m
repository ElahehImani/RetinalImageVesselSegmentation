function [mask,image]=Cropping(image,thresh)
    % [mask,image]=Cropping(image,thresh) delete the useless pixels from
    % retinal image and create the retinal mask
    mask=image(:,:,2)>thresh;
    se=strel('disk',3);
    mask=imerode(mask,se);
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