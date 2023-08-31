function [ind_low,ind_high]=fun_ACR_FindWaterBndryBinary_RestCoord...
    (I_bin,choice)
% This function search row-by-row or col-by-col on a binary image contains
% water phantom. It looks for the y-coordinants of two horizontal boundary
% pts and looks for the x-coordinants of two vertical boundary pts.
%
% Input:
%   I_bin
%   choice ('row' or 'col')
% Output:
%   ind_low
%   ind_high
% HW: (search for HW)
%    
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (28/03/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.if user forgot input choice, one more chance to do it
if ~exist('choice','var')||isempty(choice)%check right choice input
    errordlg('Need to choose ''row'' or ''col'' for choice');
    choice=input('What is your choice, row or col?\n','s');
end
%2.either row or col summation
if strcmp(choice,'row')
    scouty=0;%sum 1st non-zero col
    mark=[0 0];%last element in 1st non-zero col from left
    for j=1:size(I_bin,2)
        for i=1:size(I_bin,1)
            if I_bin(i,j)>0%accum non-zero element from bottom
                scouty=scouty+j;
                mark=[i j];
            end
        end
        if scouty>0%stop accum from next line
            break;
        end
    end
    scouty=scouty/mark(1,2);%find number of non-zero element
    ind_low=floor(mark(1,1)-scouty/2+1);
    scouty=0;%sum 1st non-zero col
    mark=[0 0];%last element in 1st non-zero col from right
    for j=1:size(I_bin,2)
        for i=1:size(I_bin,1)
            if I_bin(i,size(I_bin,2)-j)>0%accum non-zero element from right
                scouty=scouty+j;
                mark=[i j];
            end
        end
        if scouty>0%stop accum from next line
            break;
        end
    end
    scouty=scouty/mark(1,2);%find number of non-zero element
    ind_high=floor(mark(1,1)-scouty/2+1);
elseif strcmp(choice,'col')
    scouty=0;%sum 1st non-zero row
    mark=[0 0];%last element in 1st non-zero row from top
    for i=1:size(I_bin,1)
        for j=1:size(I_bin,2)
            if I_bin(i,j)>0%accum non-zero element
                scouty=scouty+i;
                mark=[i j];
            end
        end
        if scouty>0%stop accum from next line
            break;
        end
    end
    scouty=scouty/mark(1,1);%find number of non-zero element
    ind_low=floor(mark(1,2)-scouty/2+1);
    scouty=0;%sum 1st non-zero row
    mark=[0 0];%last element in 1st non-zero row from bottom
    for i=1:size(I_bin,1)
        for j=1:size(I_bin,2)
            if I_bin(size(I_bin,1)-i,j)>0%accum non-0 elemnt from bottom
                scouty=scouty+i;
                mark=[i j];
            end
        end
        if scouty>0%stop accum from next line
            break;
        end
    end
    scouty=scouty/mark(1,1);%find number of non-zero element
    ind_high=floor(mark(1,2)-scouty/2+1);
end
end