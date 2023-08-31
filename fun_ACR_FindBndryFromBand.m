function [ind_low,ind_high]=fun_ACR_FindBndryFromBand...
    (I_bin,choice,band_per)
% This function based on user specification, sum up either a band of rows
% or columns of a binary image to find the row or column boundary (edge) of
% water phantom. Row->hori bndry, col->vert bndry.
%
% Input:
%   I_bin
%   choice ('row' or 'col')
%   band_per (lower and upper percentage of image) (optional)
% Output:
%   ind_low
%   ind_high
%
% HW: (search for HW)
%    
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (27/03/13)
%          v.2 (10/01/14)(search for v2)
%          v.3 (26/03/14)(search for v3)
% History: v.1
%          v.2: add threshold on searching phantom bndry, this aims to
%               solve the bright intenisty noise effect on bndry
%               determination
%          v.3 the threshold added in v2 solved the bright intensity
%              outside the phantom (sometimes observed), but it sometimes
%              affects the accuracy of diameter measurements, especially
%              when gas appears on top of phantom. New method uses 0 as
%              threshold.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.default percentage = 30%-60% of image
if ~exist('band_per','var')||isempty(band_per)
    band_per=[0.3 0.6];
end
%2.if user forgot input choice, one more chance to do it
if ~exist('choice','var')||isempty(choice)%check right choice input
    errordlg('Need to choose ''row'' or ''col'' for choice');
    choice=input('What is your choice, row or col?\n','s');
end
%3.either row or col summation
if strcmp(choice,'row')
    row_band=zeros(1,size(I_bin,2));
    for i=round(band_per(1,1)*size(I_bin,1)):...
            round(band_per(1,2)*size(I_bin,1))
        row_band=row_band+double(I_bin(i,:));
    end
%     ind_low=find(row_band>5,1);%v2
%     ind_high=find(row_band>5,1,'last');%v2
    ind_low=find(row_band>0,1);%v3
    ind_high=find(row_band>0,1,'last');%v3
elseif strcmp(choice,'col')
    col_band=zeros(size(I_bin,1),1);
    for i=round(band_per(1,1)*size(I_bin,2)):...
            round(band_per(1,2)*size(I_bin,2))
        col_band=col_band+double(I_bin(:,i));
    end
%     ind_low=find(col_band>5,1);%v2
%     ind_high=find(col_band>5,1,'last');%v2
    ind_low=find(col_band>0,1);%v3
    ind_high=find(col_band>0,1,'last');%v3
end
end