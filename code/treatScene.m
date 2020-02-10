function [img, img2] = treatScene(img, img2, mean_lumi,mean_contr,cut_img_x, video)

%normalise average luminance and contrast of the scene
x = img(:);
x2 = img2(:);
lumi_img = mean([x;x2]);
cont_img = std([x;x2]);
img = (img-lumi_img)/cont_img;
img2 = (img2-lumi_img)/cont_img;

img = mean_lumi+img*mean_contr;
img2 = mean_lumi+img2*mean_contr;

% cut images for enlarging the distance between the two faces
%  We will project for a 1920 x 1080 resolution. On a screen like the
% one in the lab, the distance between faces is 7.8 for male and
% 8.3 for female cuples, with a mean angle of around 7.45.

% cut images on the x axis to take out the external arms of the
% chair
img = img(:,cut_img_x:end);
img2 = img2(:,1:(end-cut_img_x+1));

% calculate how much I have to cut the y axis if I project the x
% part of the scene on the x axis

prop_change = (video.x/2)/size(img,2);
newY = size(img,1)* prop_change;
cut_img_y = round(newY - video.y,0);

img = img(1:end-cut_img_y,:);
img2 = img2(1:end-cut_img_y,:);

end