function [my_contrast]=fun_TestContrast(sig_water,cont_s,cont_f,cont_i)
% This function creates image of several high contrast horizontal and
% vertical lines with different contrasts. Each line consists of 2 high
% signal and 2 low signal single pixel dots. The high signal is fixed to
% the water signal user inputed. The low signal increases from the 0 to
% water signal in an increment so that the contrast between high/low
% signals increased 1%.
% 
% Input:
%   sig_water: water signal input by user
%   cont_s: starting contrast value
%   cont_f: finishing contrast value
%   cont_i: contrast increment
% Output:
%   my_contrast: user's best contrast
% Usage: 
%   myContrast=fun_TestContrast(300,0.001,0.05,0.001);
% HW: (search for HW)
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1
%          v.2 (27/03/13)(15/05/13)(search for v2)
% History: v.1 (25/02/14)(01/03/14)
%          v.2 
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.create the low contrast vector based on user defined high contrast
dummy(1,:)=cont_s:cont_i:cont_f;%contrast increment
for j=1:size(dummy,2)
    dummy(2,j)=(sig_water*(1-dummy(1,j)))/(1+dummy(1,j));%low signal
end
dummy=flipdim(dummy,2);%start with high contrast
%2.create grey scale image with specific contrast
Img_sub=ones(4,4)*sig_water;
a=size(dummy,2);
Img=ones(6,4*a+(a+1))*sig_water;%calc col of Img
cnt=2;
for k=1:size(dummy,2)
    Img_sub(1,1:2:3)=dummy(2,k);
    Img_sub(2:2:4,4)=dummy(2,k);
    Img(2:5,cnt:cnt+3)=Img_sub;
    Img(6,cnt)=dummy(1,k)*100;%embed contrast value (%) to lower left corner
    cnt=cnt+5;
end
%3.display image
h=imtool(Img,[],'InitialMagnification',400);
%4.user input best user's visual contrast
uiwait(h);
prompt={'My best contrast: e.g.0.3 (in %)'};
dlg_title='Input';
num_lines=1;
def={'0.3'};
answer=inputdlg(prompt,dlg_title,num_lines,def);
my_contrast=str2num(answer{1,1})/100;%convert percentage to demical
end