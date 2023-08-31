function [I_thres]=add_threshold(I_noise,thres)
% This function accepts a user defined threshold to the image to make a
% binary image
% input:I_noise,thres
% output:I_thres
I_thres=I_noise;

for i=1:size(I_noise,1)
    for j=1:size(I_noise,2)
        if I_noise(i,j)>=thres
            I_thres(i,j)=1;%I_noise(i,j);
        else
            I_thres(i,j)=0;
        end
    end
end
end