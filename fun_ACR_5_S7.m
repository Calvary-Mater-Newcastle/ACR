function [PIU,mu_S7,pf_hdl]=fun_ACR_5_S7...
    (dir_name,file_name,visual,imag_check,choice,choice_strength,pill_choice,pill_r)
% This function is used to find the image intensty uniformity on S7.
%
% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of S5
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose.
%   imag_check: if check the current image is the correct image
%   choice: manual=1 or automatic=0
%   choice_strength: field strength string, '1.5T' or '3T'
%   pill_choice: S7 with/without attached pill (1=with, 0=without)
%   pill_r: pill radius in mm (num)
% Output:
%   PIU: percentage intensity uniformity
%   I_low: low boundary used to fit distribution to histogram
%   I_high: high boundary used to fit distribution to histogram
%   mu_S7: water mean intensity on S7, will be used in ghosting test
%   pf_hdl: pass/fail handle
% Usage: 
%   PIU=fun_ACR_5_S7()
%   PIU=fun_ACR_5_S7('dir_str','file_str',1or0)
% HW: (search for HW)
%   use 3 std to mask image initially to ensure 99% water is masked
%   the centre of circular ROI in phantom is 10 pixels below the phantom
%       centre, this avoid to include wedge in case of 205cm2 area
%   if the ROI of water is too big, the ROI will include region outside
%       phantom. in this case, user has one more chance to choose a ROI
%       with smaller area. If problem still exists, script will choose 200
%       cm2 ROI for user
%   when preparing to select 1cm2 region for minimum mean intensity, the
%       image is masked starting from mu-2*std and increments by 0.2*std
%       (these 2 HW in the same for loop)
%   when preparing to select 1cm2 region for maximum mean intensity, the
%       image is masked starting from mu+3*std and incremented by 0.2*std
%       (these 2 HW in the same for loop)
%   phantom wall thickness=6 mm

% Naughty Boy: (search for NAUGHTY BOY)

% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (16/04/13,17/04/13)
%          v.2  16/05/13)(search for v2)
%          v.3 (22/08/13)(search for v3)
%          v.4 (11/01/14)(search for v4)
%          v.5 (15/04/14)(search for v5)
%          v.6 (31/05/14)(search for v6)
%          v.7 (27/01/15)(search for v7)
%          v.8 (16/07/15)(search for v8)
%          v.9 (01/04/17)(search for v9)
% History: v.1
%          v.2: allow user to change the directory and file names depends
%               on where the image is stored. This can be changed at the
%               beginning of this file
%               also directory and file name strings are 2 new inputs of 
%               this function
%               add visualisation option
%          v.3 add option if to allow user to check the current image
%              output pass/fail handle
%              output water mean intensity for ghosting test usage
%          v.4 replace manual setup of intensity range for water peak
%              intensity calculation with automatic peak estimation;
%              use half of water intenstiy mean to mask image instead of 3
%              std
%          v.5 add auto uniformity calculation module. Create ROIs inside
%              the water ROI, the number of ROIs was maximised to sample
%              the high and low mean intensity within water ROI. The code
%              uses code recommended on
%              http://www.mathworks.com/matlabcentral/answers/24614-cricle-packed-with-circles
%              to generate maximised number of ROIs inside water ROI. Mod
%              has been added to that code to suit for usage here
%              add a popup window to ask user if do ROIs manually or
%              automatically
%          v.6 add if exists the 'MagneticFieldStrength' DICOM tag, auto
%              select field strength. Otherwise, user specifies strength
%          v.7 add 'choice_strength' variable to the function, so user can
%              specify the field strength if it is know, then user does not
%              have to click to choose the field strength
%          v.8 Add choice of with/without attached pill. This is mainly to
%              solve the missing liquid induced AP diameter mis-measurement
%              problem.
%          v.9 Add pill radius as input.
% Possible Improvement: 
%   Use the number of pixels that =1 on the logic image to determine the
%       rought area of the extreme ROI. This can reduce the manually visual
%       justification of user. Then create ROI around the region to get the
%       ROI of min/max intensity (11/06/13)
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if user has specified dir and file name and visualisation option
if ~exist('dir_name','var')||isempty(dir_name)%v2
    dir_name='test_images\';%UC:change this line if diff path
end
if ~exist('file_name','var')||isempty(file_name)%v2
    file_name='S7.dcm';%UC:change this line if diff file name
end
if ~exist('visual','var')||isempty(visual)%v2
    visual=0;
end
if ~exist('imag_check','var')||isempty(imag_check)%v5
    imag_check=0;
end
if ~exist('pill_choice','var')%v8
    pill_choice_trig = questdlg('Did you attached a pill marker to anterior phantom on S7?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');
    switch pill_choice_trig%Handle response
        case 'Yes'
            pill_choice=1;
        case 'No'
            pill_choice=0;
    end
end
%2.load and display image to let user check if it is S7
I=dicomread([dir_name file_name]);%v2
if imag_check==1%v3
    h=imtool(I,[]);
    choice = questdlg('Is this image the S7 image?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');%Construct a questdlg with two options
    switch choice%Handle response
        case 'Yes'
            path_name=[dir_name file_name];%v2
            %v4 comment out
%             imcontrast(h);%open contrast window
%             prompt = {'Lower Intensity:','Higher Intensity:'};
%             dlg_title = 'Water Intensity Range';
%             num_lines = 1;
%             def = {'1500','2900'};
%             answer = inputdlg(prompt,dlg_title,num_lines,def);
            close(h);%shut window
        case 'No'
            close(h);%shut window
            disp('Manually select localiser image.');%manual selection
            [f_n,p_n]=uigetfile([dir_name '*.dcm']);%v2
            path_name=fullfile(p_n,f_n);
            I=dicomread(path_name);
            h=imtool(I,[]);
            %v4 comment out
%             imcontrast(h);%open contrast window
%             prompt = {'Lower Intensity:','Higher Intensity:'};
%             dlg_title = 'Water Intensity Range';
%             num_lines = 1;
%             def = {'1500','2900'};
%             answer = inputdlg(prompt,dlg_title,num_lines,def);
            close(h);%shut window
    end
elseif imag_check==0
    path_name=[dir_name file_name];
    %v4 comment out
%     h=imtool(I,[]);
%     imcontrast(h);
%     prompt = {'Lower Intensity:','Higher Intensity:'};
%     dlg_title = 'Water Intensity Range';
%     num_lines = 1;
%     def = {'1500','2900'};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     close(h);%shut window
end
%3.use mean and std of water to mask image
%v4 comment out
% I_low=str2double(answer{1,1});%get the input
% I_high=str2double(answer{2,1});
% [mu,sigma]=fun_ACR_FindWaterMean...
%     (I,I_low,I_high,'rician',visual);%find water mean
mu=fun_ACR_FindWaterIntPeak(I,0.1,visual);
% I_bin=add_threshold(I,mu/2);%half water mean as threshold
% I_bin=add_threshold(I,mu-3*sigma);%HW:use 3 std so 99% water is masked
I_bin=add_threshold(I,mu/2);%v4
if visual==1%v2
    figure;
    imshow(I_bin,[]);
    title('Thresholded S7 Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded S7 image']);
end
%======================v8 start======================
% %4.find the centre of phantom
% [ind_row_low,ind_row_high]=fun_ACR_FindBndryFromBand(I_bin,'row');%extreme
% [ind_col_low,ind_col_high]=fun_ACR_FindBndryFromBand(I_bin,'col');%pts
% ind_centre=[round((ind_col_high-ind_col_low)/2+ind_col_low) ...
%     round((ind_row_high-ind_row_low)/2+ind_row_low)];%centre of phantom
%4.find the image pixel size
pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
if pxl_sz(1,1)~=pxl_sz(2,1)%TODO:use ellipse ROI if anisotropic
    h=errordlg(['Your image is not isotropic!'...
        'Please check pixel size. I continue from here though.']);
    uiwait(h);
end
%5.find the centre of phantom
[cen_pxl,~,phant_p_y,~,~,~]=...
    fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice,pill_r,6);%HWv9
ind_centre=round(cen_pxl');%col to row [x y], make consistent with old code
ind_centre=fliplr(ind_centre);%make consistent with old code
ind_col_high=phant_p_y;%make consistent with old code
%======================v8 end======================
%6.create circular ROI around phantom centre with user specified radius
%===================v5 start===================
% choice = questdlg('Manual or automatically create extreme ROIs for Test 5?', ...
%     'Choose Red or Blue Pill', ...
%     'Automatic','Manual','Automatic');%Construct a questdlg with two options
switch choice
    case 1%manual
        prompt={'What area of ROI do you want to create? (195-205):'};
        num_lines = 1;%user input area of ROI
        def={'195'};
        answer=inputdlg(prompt,'Blue/Red Pill?',num_lines,def);
        area_ROI_water=str2double(answer{1,1});
    case 0%auto
        area_ROI_water=200;
        disp('Since you selected the automatic process for Test 5,');
        disp('I have created an ROI with area of 200 cm2 for you.');
end
%===================v5 finish===================
radius_cm=sqrt(area_ROI_water/pi);
radius_mm=radius_cm*10;
radius_pxl=radius_mm/pxl_sz(1,1);%from this line, use ellipse ROI if image
theta=0:0.01:2*pi;               %is anisotropic (see test.m for working)
x=radius_pxl*cos(theta)+ind_centre(1,2);
y=radius_pxl*sin(theta)+ind_centre(1,1)+10;%HW:centre of ROI is 10 pxls%below phantom centre
if max(y)>ind_col_high%if user specified area too large, do it again
    h=msgbox(['I assume you selected an area > 205 cm2 by a lot. '...
        'The area is too big that it includes regions outside '...
        'ACR phantom. Please try another smaller area this time.']);
    uiwait(h);
    prompt={'What area of ROI do you want to create? (195-205):'};
    num_lines = 1;%user input area of ROI
    def={'195'};
    answer=inputdlg(prompt,'Blue/Red Pill?',num_lines,def);
    area_ROI_water=str2double(answer{1,1});
    radius_cm=sqrt(area_ROI_water/pi);
    radius_mm=radius_cm*10;
    radius_pxl=radius_mm/pxl_sz(1,1);
    theta=0:0.01:2*pi;
    x=radius_pxl*cos(theta)+ind_centre(1,2);
    y=radius_pxl*sin(theta)+ind_centre(1,1)+10;
    if max(y)>ind_col_high%if user specified area is still too large
        h=msgbox(['The area is still too big, man. I will choose '...
            '200 cm2 for you this time.']);
        uiwait(h);
        radius_cm=sqrt(200/pi);%HW:200cm2 if area still too big
        radius_mm=radius_cm*10;
        radius_pxl=radius_mm/pxl_sz(1,1);
        theta=0:0.01:2*pi;
        x=radius_pxl*cos(theta)+ind_centre(1,2);
        y=radius_pxl*sin(theta)+ind_centre(1,1)+10;
    end
end
BW=roipoly(I,x,y);
if visual==1%v2
    figure;
    imshow(BW,[]);
    title('Thresholded Water ROI Binary Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded water ROI binary image']);
end
I_ROI_water=fun_apply_mask(I,BW);
if visual==1%v2
    figure;
    imshow(I_ROI_water,[]);
    title('Thresholded Water ROI Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded water ROI image']);
end
I_ROI_water_sum=sum(I(BW));%this finds sum of water within mask
I_ROI_water_mean=I_ROI_water_sum/size(I(BW),1);%mean of water ROI
I_ROI_water_sigma=std(double(I(BW)));%std of water ROI
disp(['The mean intensity of ROI: ' num2str(I_ROI_water_mean) ...
    '. Record this value for percentage signal ghost calculation.']);
mu_S7=I_ROI_water_mean;
%===================v5 start===================
%7.ask user manual or auto create ROIs
switch choice%Handle response
    case 0%'Automatic'
%         figure;
%         imshow(I_ROI_water,[]);hold on;
        C_x=ind_centre(1,2);
        C_y=ind_centre(1,1)+10;%+10 to get ROI centre y cood
        R=radius_pxl;
        radius_cm_small=sqrt(1/pi);%1cm2 circle
        radius_mm_small=radius_cm_small*10;
        radius_pxl_small=...
        radius_mm_small/pxl_sz(1,1);%this can be reused for max mean intensity
        r=radius_pxl_small;
        [xcc ycc]=fun_circle([C_x C_y],r,1000); % center circle
%         plot(xcc,ycc,'-','linewidth',2,'color',0.5.*rand(1,3));
%         hold on;
        BW_small=roipoly(I,xcc,ycc);
        I_ROI_small=fun_apply_mask(I,BW_small);
        I_ROI_small_sum=sum(sum(I_ROI_small));%this finds sum of intensity within mask
        I_ROI_small_mean(1,1)=I_ROI_small_sum/size(find(I_ROI_small),1);%mean of min ROI
        numlapis=((2*R)-(R+r))/(2*r);
        if visual==1
            figure;
            imshow(I_ROI_water,[]);hold on;
            plot(xcc,ycc,'-','linewidth',2,'color',0.5.*rand(1,3));
            hold on;
        end
        cnt=2;
        for cnt1=1:numlapis
            lapis(cnt1)=cnt1*6;
            [xcoor ycoor]=fun_circle([C_x C_y],cnt1*2*r,lapis(cnt1)+1);
            for cnt2=1:lapis(cnt1)
                [xc yc] = fun_circle([xcoor(cnt2) ycoor(cnt2)],r,1000);
                BW_small=roipoly(I,xc,yc);
                I_ROI_small=fun_apply_mask(I,BW_small);
                I_ROI_small_sum=sum(sum(I_ROI_small));%this finds sum of intensity within mask
                I_ROI_small_mean(cnt,1)=I_ROI_small_sum/size(find(I_ROI_small),1);%mean of min ROI
                cnt=cnt+1;
                if visual==1
                    plot(xc,yc,'-','linewidth',2,'color',0.5.*rand(1,3));
                end
            end
        end
        PIU=1-(max(I_ROI_small_mean)-min(I_ROI_small_mean))/(max(I_ROI_small_mean)+min(I_ROI_small_mean));
    case 1%'Manual'
        
        %7.start mask from 2*std of ROI, display mask image for min intensity
        for i=1:0.2:2%HW:thres increments by 0.2
            I_bin_dummy_low=add_threshold...
                (I_ROI_water,...
                I_ROI_water_mean-(3-i)*I_ROI_water_sigma);%HW:decrease from 2 std
            h=imtool(I_bin_dummy_low,[]);
            choice=questdlg('Do you see a region of darkness?', ...
                'Welcome to the dark side','Yes','No','No');
            switch choice
                case 'Yes'
                    dummy_thres_low=I_ROI_water_mean-(3-i)*I_ROI_water_sigma;
                    fprintf('We stoped at -%3.1f STD.\n',3-i);
                    fprintf('Threshold is %3.1f.\n',dummy_thres_low);
                    close(h);
                    break;
                case 'No'
                    close(h);
                    continue;
            end
        end
        %7.mask the image with dark region mask
        I_bin_low=BW-I_bin_dummy_low;
        I_ROI_min_region=fun_apply_mask(I,I_bin_low);
        if visual==1%v2
            figure;
            imshow(I_ROI_min_region,[]);
            title('Thresholded Water Min Intensity Region Image');
        else
            disp(['You have turned off graph visualisation '...
                'to show the thresholded water min intensity region image']);
        end
        %8.user clicks a point in the low intensity region & create a 1cm2 ROI
        hh=figure;
        imshow(I_ROI_min_region,[]);
        h=impoint(gca,[]);
        pos_min=getPosition(h);%(col,row) coord of pt
        close(hh);
        radius_cm_small=sqrt(1/pi);%1cm2 circle
        radius_mm_small=radius_cm_small*10;
        radius_pxl_small=...
            radius_mm_small/pxl_sz(1,1);%this can be reused for max mean intensity
        x_min=radius_pxl_small*cos(theta)+pos_min(1,1);
        y_min=radius_pxl_small*sin(theta)+pos_min(1,2);
        BW_min=roipoly(I,x_min,y_min);
        I_ROI_min=fun_apply_mask(I,BW_min);
        if visual==1%v2
            figure;
            imshow(I_ROI_min,[]);
            title('Thresholded Water Min Intensity ROI Image');
        else
            disp(['You have turned off graph visualisation '...
                'to show the thresholded water min intensity ROI image']);
        end
        %9.find mean of minimum intensity ROI
        I_ROI_min_sum=sum(sum(I_ROI_min));%this finds sum of intensity within mask
        I_ROI_min_mean=I_ROI_min_sum/size(find(I_ROI_min),1);%mean of min ROI
        I_ROI_min_sigma=std(double(I(BW_min)));%std of min ROI
        %10.start mask from 2*std of ROI, display mask image for max intensity
        for i=1:0.2:3%HW:thres increments by 0.2
            I_bin_dummy_high=add_threshold...
                (I_ROI_water,...
                I_ROI_water_mean+(4-i)*I_ROI_water_sigma);%HW:decrease from 3 std
            h=imtool(I_bin_dummy_high,[]);
            choice=questdlg('Do you see a region of brightness?', ...
                'Welcome to the bright side','Yes','No','No');
            switch choice
                case 'Yes'
                    dummy_thres_high=I_ROI_water_mean-(4-i)*I_ROI_water_sigma;
                    fprintf('We stoped at +%3.1f STD.\n',4-i);
                    fprintf('Threshold is %3.1f.\n',dummy_thres_high);
                    close(h);
                    break;
                case 'No'
                    close(h);
                    continue;
            end
        end
        %11.mask the image with bright region mask
        I_ROI_max_region=fun_apply_mask(I,I_bin_dummy_high);
        if visual==1%v2
            figure;
            imshow(I_ROI_max_region,[]);
            title('Thresholded Water Max Intensity Region Image');
        else
            disp(['You have turned off graph visualisation '...
                'to show the thresholded water max intensity region image']);
        end
        %12.user clicks a point in the high intensity region & create a 1cm2 ROI
        hh=figure;
        imshow(I_ROI_max_region,[]);
        h=impoint(gca,[]);
        pos_max=getPosition(h);%(col,row) coord of pt
        close(hh);
        x_max=radius_pxl_small*cos(theta)+pos_max(1,1);
        y_max=radius_pxl_small*sin(theta)+pos_max(1,2);
        BW_max=roipoly(I,x_max,y_max);
        I_ROI_max=fun_apply_mask(I,BW_max);
        if visual==1%v2
            figure;
            imshow(I_ROI_max,[]);
            title('Thresholded Water Max Intensity ROI Image');
        else
            disp(['You have turned off graph visualisation '...
                'to show the thresholded water max intensity ROI image']);
        end
        %13.find mean of maximum intensity ROI
        I_ROI_max_sum=sum(sum(I_ROI_max));%this finds sum of intensity within mask
        I_ROI_max_mean=I_ROI_max_sum/size(find(I_ROI_max),1);%mean of min ROI
        I_ROI_max_sigma=std(double(I(BW_max)));%std of min ROI
        %14.display the 2 ROI on original image
        figure;
        imshow(I,[]);
        title('Three ROIs Automatically Contoured');
        hold on;
        plot(x_min,y_min,'b');
        hold on;
        plot(x_max,y_max,'r');
        hold on;
        plot(x,y,'k');
        hold off;
        %15.calculate PIU
        PIU=1-(I_ROI_max_mean-I_ROI_min_mean)/(I_ROI_max_mean+I_ROI_min_mean);
end
%===================v5 end===================
%===================v6 start===================
%15.check if pass the test
if isempty(choice_strength)%v7
    if isfield(dicominfo(path_name),'MagneticFieldStrength')
        dummy=dicominfo(path_name);
        choice_strength=dummy.MagneticFieldStrength;
        choice_strength=num2str(choice_strength);
        choice_strength=[choice_strength 'T'];
    else
%         choice_strength=questdlg('What scanner do you use?', ...
%             '','1.5T','3T','3T');
    fid=fopen('config_para.txt');
    while ~feof(fid)%until end of file
        tline=strtrim(fgetl(fid));%trim start & end spaces
        eval(tline);
    end
    choice_strength=BField_strength;
    end
end
%===================v6 end===================
switch choice_strength
    case '1.5T'
        if PIU>=0.875
            disp(['Congrats! Your scanner passed the PIU test. '...
                'Your scanner PIU is ' num2str(PIU*100,3) '%. '...
                '(>=87.5%)']);
            pf_hdl=1;
        else
            disp(['Your scanner''s PIU score is ' ...
                num2str(PIU*100,3) ...
                '%. The passing score for 1.5T is 87.5%.'...
                'Try manual measurement.']);
            pf_hdl=0;
        end
    case '3T'
        if PIU>=0.82
            disp(['Congrats! Your scanner passed the PIU test. '...
                'Your scanner PIU is ' num2str(PIU*100,3) '%. '...
                '(>=82%)']);
            pf_hdl=1;
        else
            disp(['Your scanner''s PIU score is ' ...
                num2str(PIU*100,3) ...
                '%. The passing score for 3T is 82%.'...
                'Try manual measurement.']);
            pf_hdl=0;
        end
end
end