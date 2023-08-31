% This RUN script runs the added QA functions sequentially with some
% parameter pre-defined in the config file. Finally, the result is updated
% in an Excel with the name of the institution. If the Excel does not
% previously exist in the directory, then it will create one. If centre has
% multiple scanners, then it will add one-by-one to worksheet by asking
% user to load each one's localiser directory (This part has NOT been
% tested due to no centre I visited has multiple scanners).
%
% There are three general phases:
%   1.Pre-setting.
%   2.QA tests.
%   3.Result reporting.
% Search word "phase" to find the location of each phase.
%
% The original script follows all 7 tests for localiser, T1 & T2 images.
% Users are encouraged to modify the code for their own needs in the 2nd
% phase. However, because the Excel reporting is written based on the full
% QA test, if user intends to delete any test (e.g. PSG), then either the
% scripts & functions used in the 3rd phase need to be modified or user can
% predefine the unwanted test result variables (e.g. TEST_6_S7=0).
%
% The script & functions has been tested with the previously acquired
% images from 2 Skyra, 1 Prisma & 1 GE scanners.
%
% Function have been added to accurately measure phantom AP direction
% diameter in case of losing liquid. This is achieved by attaching objects
% like Vitamin E pill to the anterior edge of the phantom at slice 1,5,7 &
% 11. This function has been preliminarily tested before but NO extensive
% testing has been performed due to lack of time.
%
% This is the final version of OSAQA-ACR code for now. Because I have to
% concentrte on TEAP training, very limited effort will be put into this
% project.
% 
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v1 (17/05/13)
%          v2 (13/10/13)(search for v2)
%          v3 (30/04/14)
%          v4 (01/04/2017)
% History: v1
%          v2 changed the output Excel format to single row
%             changed PIU to % before saving, to be consistent to Michael
%             save the Excel sheet in localiser folder
%             add instruction to high contrast test message box
%          v3 major change: -create a log file store results info
%                           -check if an output exists, so don't repeat
%                            the same measurement if 1st time went wrong
%          v4 final modification: -add config file to simplify code.
%                                 -save result into structure.
%                                 -tidy up code.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.
% SSZZ

%=====================pre-setting phase start=====================
%1.read config file
fid=fopen('config_para.txt');
while ~feof(fid)%until end of file
    tline=strtrim(fgetl(fid));%trim start & end spaces
    eval(tline);
end
%2.pre-define dir&file name
switch test_choice
    case 'Demo'
        if ~exist('dir_name_loc','var')
            dir_name_loc=pwd;%for testing only
            dir_name_loc=[dir_name_loc '\test_images\loc\'];
        else
            disp('You have specified Localiser directory.');
        end
        if ~exist('dir_name_T1','var')
            dir_name_T1=pwd;
            dir_name_T1=[dir_name_T1 '\test_images\T1\'];
        else
            disp('You have specified T1 directory.');
        end
        if ~exist('dir_name_T2','var')
            dir_name_T2=pwd;
            dir_name_T2=[dir_name_T2 '\test_images\T2\'];
        else
            disp('You have specified T2 directory.');
        end
    case 'MySite'
        if ~exist('dir_name_loc','var')||isequal(dir_name_loc,0)
            dir_name_loc=uigetdir('C:\','Select Localiser Directory');
            dir_name_loc=[dir_name_loc '\'];
        else
            disp('You have specified Localiser directory.');
        end
        if ~exist('dir_name_T1','var')||isequal(dir_name_T1,0)
            dir_name_T1=uigetdir('C:\','Select T1 Image Directory');
            dir_name_T1=[dir_name_T1 '\'];
        else
            disp('You have specified T1 directory.');
        end
        if ~exist('dir_name_T2','var')||isequal(dir_name_T2,0)
            dir_name_T2=uigetdir('C:\','Select T2 Image Directory');
            dir_name_T2=[dir_name_T2 '\'];
        else
            disp('You have specified T2 directory.');
        end
end
[file_name_loc]=fun_ACR_FindSlice('loc',dir_name_loc);
[file_name_S1_T1,file_name_S5_T1,file_name_S7_T1,file_name_S8_T1,...
    file_name_S9_T1,file_name_S10_T1,file_name_S11_T1]=...
    fun_ACR_FindSlice('T1',dir_name_T1);
[file_name_S1_T2,file_name_S5_T2,file_name_S7_T2,file_name_S8_T2,...
    file_name_S9_T2,file_name_S10_T2,file_name_S11_T2]=...
    fun_ACR_FindSlice('T2',dir_name_T2);
%2.load relevant DCM tag from localiser img
[institution_name,manuf_name,manuf_model_name,station_name,QA_date]=...
    fun_ACR_GetScannerInfo(dir_name_loc);
%4.user's personal contrast
if myContrast==0
    myContrast=fun_TestContrast(300,0.001,0.05,0.001);
end
%5.define pass/fail handle
if ~exist('pf_hdl','var')||isempty(pf_hdl)
    pf_hdl=zeros(1,19);
end
%6.define result saving path
dummy=0;
for i=size(dir_name_loc,2)-1:-1:1
    if strcmp(dir_name_loc(1,i),'\')==1
        dummy=i;
        break;
    end
end
save_path=dir_name_loc(1,1:dummy);
%=====================pre-setting phase end=====================
%=====================QA tests phase start=====================
%T1 QA test
%7.TEST 1-GEOMETRIC DISTORTION
%7.1.localiser
tic;
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_loc');
end
if sum(imhere)>0
    disp('You have done the Test 1 on localiser.');
else
    disp('It''s the 1st time you run Test 1 on localiser.');
    [TEST_1_loc,pf_hdl(1,1)]=fun_ACR_1_loc...
        (dir_name_loc,file_name_loc,visual,imag_check,save_path);
end
close all;
t_loc=toc;
%7.2.S1
tic;
dummy=0;
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_S1_hori');
end
if sum(imhere)>0
    disp('You have done the Test 1 on S1 T1 image.');
else
    disp('It''s the 1st time you run Test 1 on S1 T1 image.');
    [TEST_1_S1_hori,TEST_1_S1_vert,mu_S1,dummy(1,1:2)]=fun_ACR_1_S1...
        (dir_name_T1,file_name_S1_T1,visual,imag_check,'T1',save_path,pill_choice_S1,pill_r);
end
close all;
%7.3.S5
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_S5_hori');
end
if sum(imhere)>0
    disp('You have done the Test 1 on S5 T1 image.');
else
    disp('It''s the 1st time you run Test 1 on S5 T1 image.');
    [TEST_1_S5_hori,TEST_1_S5_vert,TEST_1_S5_ng,TEST_1_S5_pg,dummy(1,3:6)]...
        =fun_ACR_1_S5(dir_name_T1,file_name_S5_T1,visual,imag_check,...
        'T1',save_path,pill_choice_S5,pill_r);
    if sum(dummy)==6
        pf_hdl(1,2)=1;
    else
        pf_hdl(1,2)=0;
    end
end
close all;
%8.TEST 2-HIGH CONTRAST SPATIAL RESOLUTION
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_2_S1');
end
if sum(imhere)>0
    disp('You have done the Test 2 on S1 T1 image.');
else
    disp('It''s the 1st time you run Test 2 on S1 T1 image.');
    [TEST_2_S1,pf_hdl(1,4:5)]=fun_ACR_2_S1...
        (dir_name_T1,file_name_S1_T1,visual,HCSR_choice,imag_check,myContrast,pill_choice_S1,pill_r);
end
%9.TEST 3-SLICE THICKNESS ACCURACY
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_3_S1');
end
if sum(imhere)>0
    disp('You have done the Test 3 on S1 T1 image.');
else
    disp('It''s the 1st time you run Test 3 on S1 T1 image.');
    mu_S1=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T1 file_name_S1_T1]),...
        0.1,visual);%delete this if run fun_ACR_1_S1 before.
    [TEST_3_S1,pf_hdl(1,8)]=fun_ACR_3_S1...
        (dir_name_T1,file_name_S1_T1,mu_S1,imag_check,pill_choice_S1,pill_r);
end
%10.TEST 4-SLICE POSITION ACCURACY
%10.1.S1
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_4_S1');
end
if sum(imhere)>0
    disp('You have done the Test 4 on S1 T1 image.');
else
    disp('It''s the 1st time you run Test 4 on S1 T1 image.');
    mu_S1=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T1 file_name_S1_T1]),...
        0.1,visual);%delete this if run fun_ACR_1_S1 before.
    [TEST_4_S1,pf_hdl(1,10)]=fun_ACR_4_S1S11...
        ('S1',dir_name_T1,file_name_S1_T1,visual,mu_S1,imag_check,pill_choice_S1,pill_choice_S11,pill_r);
end
%10.2.S11
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_4_S11');
end
if sum(imhere)>0
    disp('You have done the Test 4 on S11 T1 image.');
else
    disp('It''s the 1st time you run Test 4 on S11 T1 image.');
    mu_S11=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T1 file_name_S11_T1]),...
        0.1,visual);
    [TEST_4_S11,pf_hdl(1,11)]=fun_ACR_4_S1S11...
        ('S11',dir_name_T1,file_name_S11_T1,visual,mu_S11,imag_check,pill_choice_S1,pill_choice_S11,pill_r);
end
%11.TEST 5-IMAGE INTENSITY UNIFORMITY
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_5_S7');
end
if sum(imhere)>0
    disp('You have done the Test 5 on S7 T1 image.');
else
    disp('It''s the 1st time you run Test 5 on S7 T1 image.');
    [TEST_5_S7,mu_S7,pf_hdl(1,14)]=fun_ACR_5_S7...
        (dir_name_T1,file_name_S7_T1,visual,imag_check,PIU_choice,'',pill_choice_S7,pill_r);
end
%12.TEST 6-PERCENTAGE SIGNAL GHOSTING
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_6_S7');
end
if sum(imhere)>0
    disp('You have done the Test 6 on S7 T1 image.');
else
    disp('It''s the 1st time you run Test 6 on S7 T1 image.');
    mu_S7=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T1 file_name_S7_T1]),...
        0.1,visual);%delete this if run fun_ACR_5_S7 before.
    [TEST_6_S7,pf_hdl(1,16)]=fun_ACR_6_S7...
        (dir_name_T1,file_name_S7_T1,visual,mu_S7,imag_check,'T1',save_path,pill_choice_S7,pill_r);
end
close all;
%13.TEST 7-LOW CONTRAST OBJECT DETECTABILITY
%13.1.S11
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S11');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S11 T1 image.');
else
    disp('It''s the 1st time you run Test 7 on S11 T1 image.');
    [TEST_7_S11,I_spk_S11]=fun_ACR_7_S8S9S10S11...
        (dir_name_T1,file_name_S11_T1,11,visual,LCOD_choice,imag_check);
end
%13.2.S10
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S10');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S10 T1 image.');
else
    disp('It''s the 1st time you run Test 7 on S10 T1 image.');
    [TEST_7_S10,I_spk_S10]=fun_ACR_7_S8S9S10S11...
        (dir_name_T1,file_name_S10_T1,10,visual,LCOD_choice,imag_check);
end
%13.3.S9
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S9');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S9 T1 image.');
else
    disp('It''s the 1st time you run Test 7 on S9 T1 image.');
    [TEST_7_S9,I_spk_S9]=fun_ACR_7_S8S9S10S11...
        (dir_name_T1,file_name_S9_T1,9,visual,LCOD_choice,imag_check);
end
%13.4.S8
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S8');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S8 T1 image.');
else
    disp('It''s the 1st time you run Test 7 on S8 T1 image.');
    [TEST_7_S8,I_spk_S8]=fun_ACR_7_S8S9S10S11...
        (dir_name_T1,file_name_S8_T1,8,visual,LCOD_choice,imag_check);
end
if sum([TEST_7_S11,TEST_7_S10,TEST_7_S9,TEST_7_S8])>=37
    pf_hdl(1,18)=1;
else
    pf_hdl(1,18)=0;
end
t_T1=toc;
%T1 QA test
%14.TEST 1-GEOMETRIC DISTORTION
%14.1.S1
tic;
dummy=0;
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_S1_hori_T2');
end
if sum(imhere)>0
    disp('You have done the Test 1 on S1 T2 image.');
else
    disp('It''s the 1st time you run Test 1 on S1 T2 image.');
    [TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,mu_S1_T2,dummy(1,1:2)]=fun_ACR_1_S1...
        (dir_name_T2,file_name_S1_T2,visual,imag_check,'T2',save_path,pill_choice_S1,pill_r);
end
close all;
%14.2.S5
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_S5_hori_T2');
end
if sum(imhere)>0
    disp('You have done the Test 1 on S5 T2 image.');
else
    disp('It''s the 1st time you run Test 1 on S5 T2 image.');
    [TEST_1_S5_hori_T2,TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2,dummy(1,3:6)]...
        =fun_ACR_1_S5(dir_name_T2,file_name_S5_T2,visual,imag_check,...
        'T2',save_path,pill_choice_S5,pill_r);
    if sum(dummy)==6
        pf_hdl(1,3)=1;
    else
        pf_hdl(1,3)=0;
    end
end
close all;
%15.TEST 2-HIGH CONTRAST SPATIAL RESOLUTION
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_2_S1_T2');
end
if sum(imhere)>0
    disp('You have done the Test 2 on S1 T2 image.');
else
    disp('It''s the 1st time you run Test 2 on S1 T2 image.');
    [TEST_2_S1_T2,pf_hdl(1,6:7)]=fun_ACR_2_S1...
        (dir_name_T2,file_name_S1_T2,visual,HCSR_choice,imag_check,myContrast,pill_choice_S1,pill_r);
end
%16.TEST 3-SLICE THICKNESS ACCURACY
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_3_S1_T2');
end
if sum(imhere)>0
    disp('You have done the Test 3 on S1 T2 image.');
else
    disp('It''s the 1st time you run Test 3 on S1 T2 image.');
    mu_S1_T2=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T2 file_name_S1_T2]),...
        0.1,visual);%delete this if run fun_ACR_1_S1 before.
    [TEST_3_S1_T2,pf_hdl(1,9)]=fun_ACR_3_S1...
        (dir_name_T2,file_name_S1_T2,mu_S1_T2,imag_check,pill_choice_S1,pill_r);
end
%17.TEST 4-SLICE POSITION ACCURACY
%17.1.S1
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_4_S1_T2');
end
if sum(imhere)>0
    disp('You have done the Test 4 on S1 T2 image.');
else
    disp('It''s the 1st time you run Test 4 on S1 T2 image.');
    mu_S1_T2=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T2 file_name_S1_T2]),...
        0.1,visual);%delete this if run fun_ACR_1_S1 before.
    [TEST_4_S1_T2,pf_hdl(1,12)]=fun_ACR_4_S1S11...
        ('S1',dir_name_T2,file_name_S1_T2,visual,mu_S1_T2,imag_check,pill_choice_S1,pill_choice_S11,pill_r);
end
%17.2.S11
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_4_S11_T2');
end
if sum(imhere)>0
    disp('You have done the Test 4 on S11 T2 image.');
else
    disp('It''s the 1st time you run Test 4 on S11 T2 image.');
    mu_S11_T2=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T2 file_name_S11_T2]),...
        0.1,visual);
    [TEST_4_S11_T2,pf_hdl(1,13)]=fun_ACR_4_S1S11...
        ('S11',dir_name_T2,file_name_S11_T2,visual,mu_S11_T2,imag_check,pill_choice_S1,pill_choice_S11,pill_r);
end
%18.TEST 5-IMAGE INTENSITY UNIFORMITY
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_5_S7_T2');
end
if sum(imhere)>0
    disp('You have done the Test 5 on S7 T2 image.');
else
    disp('It''s the 1st time you run Test 5 on S7 T2 image.');
    [TEST_5_S7_T2,mu_S7_T2,pf_hdl(1,15)]=fun_ACR_5_S7...
        (dir_name_T2,file_name_S7_T2,visual,imag_check,PIU_choice,'',pill_choice_S7,pill_r);
end
%19.TEST 6-PERCENTAGE SIGNAL GHOSTING
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_6_S7_T2');
end
if sum(imhere)>0
    disp('You have done the Test 6 on S7 T2 image.');
else
    disp('It''s the 1st time you run Test 6 on S7 T2 image.');
    mu_S7_T2=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T2 file_name_S7_T2]),...
        0.1,visual);%delete this if run fun_ACR_5_S7 before.
    [TEST_6_S7_T2,pf_hdl(1,17)]=fun_ACR_6_S7...
        (dir_name_T2,file_name_S7_T2,visual,mu_S7_T2,imag_check,'T1',save_path,pill_choice_S7,pill_r);
end
close all;
%20.TEST 7-LOW CONTRAST OBJECT DETECTABILITY
%20.1.S11
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S11_T2');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S11 T2 image.');
else
    disp('It''s the 1st time you run Test 7 on S11 T2 image.');
    [TEST_7_S11_T2,I_spk_S11_T2]=fun_ACR_7_S8S9S10S11...
        (dir_name_T2,file_name_S11_T2,11,visual,LCOD_choice,imag_check);
end
%20.2.S10
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S10_T2');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S10 T2 image.');
else
    disp('It''s the 1st time you run Test 7 on S10 T2 image.');
    [TEST_7_S10_T2,I_spk_S10_T2]=fun_ACR_7_S8S9S10S11...
        (dir_name_T2,file_name_S10_T2,10,visual,LCOD_choice,imag_check);
end
%20.3.S9
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S9_T2');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S9 T2 image.');
else
    disp('It''s the 1st time you run Test 7 on S9 T2 image.');
    [TEST_7_S9_T2,I_spk_S9_T2]=fun_ACR_7_S8S9S10S11...
        (dir_name_T2,file_name_S9_T2,9,visual,LCOD_choice,imag_check);
end
%20.4.S8
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S8_T2');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S8 T2 image.');
else
    disp('It''s the 1st time you run Test 7 on S8 T2 image.');
    [TEST_7_S8_T2,I_spk_S8_T2]=fun_ACR_7_S8S9S10S11...
        (dir_name_T2,file_name_S8_T2,8,visual,LCOD_choice,imag_check);
end
if sum([TEST_7_S11_T2,TEST_7_S10_T2,TEST_7_S9_T2,TEST_7_S8_T2])>=37
    pf_hdl(1,19)=1;
else
    pf_hdl(1,19)=0;
end
t_T2=toc;
%=====================QA tests phase end=====================
%=====================Result reporting phase start=====================
%22.write results into Excel file
tic;
disp('Finished test and writing result into Excel');
res={'',TEST_1_loc,TEST_1_S1_hori,TEST_1_S1_vert,TEST_1_S5_hori,...
    TEST_1_S5_vert,TEST_1_S5_ng,TEST_1_S5_pg,...
    TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,TEST_1_S5_hori_T2,...
    TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2,...
    TEST_2_S1(1,1),TEST_2_S1(2,1),TEST_2_S1_T2(1,1),TEST_2_S1_T2(2,1)...
    TEST_3_S1,TEST_3_S1_T2,TEST_4_S1,TEST_4_S11,TEST_4_S1_T2,TEST_4_S11_T2,...
    TEST_5_S7*100,TEST_5_S7_T2*100,TEST_6_S7,TEST_6_S7_T2,...
    TEST_7_S11,TEST_7_S10,TEST_7_S9,TEST_7_S8,...
    TEST_7_S11_T2,TEST_7_S10_T2,TEST_7_S9_T2,TEST_7_S8_T2};
fun_ACR_GenExcel...
    (res,institution_name,manuf_name,manuf_model_name,station_name,...
    QA_date,scanner_num);
current_dir=pwd;
fun_ACR_CentralFreq([dir_name_loc file_name_loc],...
    [current_dir '\Central_Frequency.xlsx']);
t_log=toc;
%23.create log.txt
fun_ACR_SaveLog(save_path,pf_hdl,TEST_1_loc,TEST_1_S1_hori,...
    TEST_1_S1_vert,TEST_1_S5_hori,TEST_1_S5_vert,TEST_1_S5_ng,...
    TEST_1_S5_pg,TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,TEST_1_S5_hori_T2,...
    TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2,TEST_2_S1,...
    TEST_2_S1_T2,TEST_3_S1,TEST_3_S1_T2,TEST_4_S1,TEST_4_S11,TEST_4_S1_T2,...
    TEST_4_S11_T2,TEST_5_S7,TEST_5_S7_T2,TEST_6_S7,TEST_6_S7_T2,TEST_7_S11,...
    TEST_7_S10,TEST_7_S9,TEST_7_S8,TEST_7_S11_T2,TEST_7_S10_T2,...
    TEST_7_S9_T2,TEST_7_S8_T2,t_loc,t_T1,t_T2,t_log);
disp('A Log file has been created under following path:');
disp([save_path 'log.txt']);
msgbox('QA done. Excel has been updated.');
%=====================Result reporting phase start=====================