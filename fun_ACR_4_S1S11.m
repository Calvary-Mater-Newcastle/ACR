function [l_diff,pf_hdl]=fun_ACR_4_S1S11...
    (choice,dir_name,file_name,visual,mu_S1,imag_check,pill_choice_S1,pill_choice_S11,pill_r)
% This function is used to find the slice position accuracy on S1 & S11. It
% also gives the phantom rotation angle on the transverse plane.
% +=clockwise rotation, -=anticlockwise rotation. When meansuring the wedge
% length, only relative length is measured (start measuring from 10 mm
% below phantom top edge). Because sometime the wedge is connected to the
% phantom edge and making wedge not being an island within phantom, this
% prevents using intensity profile to define the top edge of phantom
% vertically at each column. Because the difference between wedge length is
% used for the positioning accuracy, so the relative length is working. The
% final two lengths used for calculation was the mean of all lengths in
% each wedge
%
% Input:
%   choice: 'S1' or 'S11'
%   dir_name: directory path string where image is stored
%   file_name: file name of S5
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose.
%   mu_S1: mean water intensity got from S1 distortion test
%   imag_check: if check the current image is the correct image
%   pill_choice_S1: S1 with/without attached pill (1=with, 0=without)
%   pill_choice_S11: S11 with/without attached pill (1=with, 0=without)
%   pill_r: pill radius in mm (num)
% Output:
%   l_diff: length difference between 2 wedges
%   rotated_angle: phantom rotation angle on transverse plane (+=clockwise)
%   pf_hdl: pass/fail handle
% Usage: 
%   [l_diff,rot_ang]=fun_ACR_4_S1S11('S1orS11')
%   [l_diff,rot_ang]=fun_ACR_4_S1S11('S1orS11','dir_str','file_str',1or0)
% HW: (search for HW)
%   to get the width of wedge, sample at 10mm below top boundary of
%       phantom. this position is also used for measuring the relative
%       wedge length
%   phantom internal diameter is fixed to be 190mm as stated in spec doc
%   when looking for wedge length of every column, the vertical length of
%       ROI is fixed to 70mm in order to include wedge in any cases (NOT
%       USED)
%   when randomly select wedge length, ignore the boundary pixel in order
%       to avoid any unexpected length due to masking
%   outer bndry of wedge is the edge found, but inner bndry of wedge is 1
%       pixel away from the centre of 2 wedges. This is try to avoid
%       sampling the right wedge length inside left wedge and vice versa
%   phantom wall thickness=6 mm
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (05/04/13,14/04/13, 15/04/13)
%          v.2 (15/05/13)(search for v2)
%          v.3 (18/07/13)(search for v3)
%          v.4 (22/08/13)(search for v4)
%          v.5 (13/10/13)(search for v5)
%          v.6 (09/01/14)(search for v6)
%          v.7 (25/01/14)(search for v7)
%          v.8 (17/04/14)(search for v8)
%          v.9 (16/07/15)(search for v9)
%          v.10 (01/04/17)(search for v10)
% History: v.1
%          v.2 allow user to change the directory and file names depends 
%              on where the image is stored. This can be changed at the 
%              beginning of this file also directory and file name strings
%              are 2 new inputs of this function;
%              add visualisation option
%          v.3 solve the bug caused by zeros difference between 2 wedges,
%              previous alg use derivative of length to find the centre of
%              wedges, it gives error when there is no length difference.
%              The new alg first uses the width of wedges to find the
%              wedge centre and then store the wedge lengths into 2
%              vectors and then takes the best results for calculation
%          v.4 add option if to allow user to check the current image;
%              output pass/fail handle;
%              add input of water mean intensity got from S1 distortion
%              test;
%              deleted the user input mean water intensity step
%          v.5 don't do phantom rotation check to save time
%          v.6 assume no phantom rotation and use phantom center to
%              identify the center and boundaries of wedges
%          v.7 increase the search length to 44 mm to measure the wedge
%              length to overcome short measurement in case 512*512 matrix
%              size (even though it is not very commonly used);
%              add to compare all the length measurements to the mean, if
%              the difference is larger than std then it is a false
%              measurement and ignore
%          v.8 use the mean value of the true length measurement as the
%              result
%          v.9 Add choice of with/without attached pill. This is mainly to
%              solve the missing liquid induced AP diameter mis-measurement
%              problem.
%          v.10 Add pill radius as input.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if user has specified dir and file name and visualisation option
if ~exist('dir_name','var')||isempty(dir_name)%v2
    dir_name='test_images\';
end
if ~exist('visual','var')||isempty(visual)%v2
    visual=0;
end
if ~exist('imag_check','var')||isempty(imag_check)%v4
    imag_check=0;
end
%2.load and display image to let user check if it is S1 or S11
if strcmp(choice,'S1')
    if ~exist('file_name','var')||isempty(file_name)%v2
        file_name='S1.dcm';%UC:change this line if diff file name
    end
    I=dicomread([dir_name file_name]);%v2
    if imag_check==1%v4
        h=imtool(I,[]);
        choice_dlg = questdlg('Is this image the S1 image?', ...
            'Choose Red or Blue Pill', ...
            'Yes','No','Yes');%Construct a questdlg with two options
        switch choice_dlg%Handle response
            case 'Yes'
                path_name=[dir_name file_name];%v2
            case 'No'
                close(h);%shut window
                disp('Manually select localiser image.');%manual selection
                [f_n,p_n]=uigetfile([dir_name '*.dcm']);%v2
                path_name=fullfile(p_n,f_n);
                I=dicomread(path_name);
                h=imtool(I,[]);
        end
    elseif imag_check==0
        path_name=[dir_name file_name];
    end
    if ~exist('pill_choice_S1','var')%v9
        pill_choice = questdlg('Did you attached a pill marker to anterior phantom on S1?', ...
            'Choose Red or Blue Pill', ...
            'Yes','No','Yes');
        switch pill_choice%Handle response
            case 'Yes'
                pill_choice_S1=1;
            case 'No'
                pill_choice_S1=0;
        end
    end
elseif strcmp(choice,'S11')
    if ~exist('file_name','var')||isempty(file_name)%v2
        file_name='S11.dcm';%UC:change this line if diff file name
    end
    I=dicomread([dir_name file_name]);%v2
    if imag_check==1%v4
        h=imtool(I,[]);
        choice_dlg = questdlg('Is this image the S11 image?', ...
            'Choose Red or Blue Pill', ...
            'Yes','No','Yes');%Construct a questdlg with two options
        switch choice_dlg%Handle response
            case 'Yes'
                path_name=[dir_name file_name];%v2
            case 'No'
                close(h);%shut window
                disp('Manually select localiser image.');%manual selection
                [f_n,p_n]=uigetfile([dir_name '*.dcm']);%v2
                path_name=fullfile(p_n,f_n);
                I=dicomread(path_name);
                h=imtool(I,[]);
        end
    elseif imag_check==0
        path_name=[dir_name file_name];
    end
    if ~exist('pill_choice_S11','var')%v9
        pill_choice = questdlg('Did you attached a pill marker to anterior phantom on S11?', ...
            'Choose Red or Blue Pill', ...
            'Yes','No','Yes');
        switch pill_choice%Handle response
            case 'Yes'
                pill_choice_S11=1;
            case 'No'
                pill_choice_S11=0;
        end
    end
end
%3.read DICOM image & get pxl size
pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
%4.use water mean intensity to find phantom top bndry
water_mean=mu_S1;%v4
I_bin=add_threshold(I,water_mean/2);%mask image to get extreme pts
if visual==1%v2
    figure;
    imshow(I_bin,[]);
    title('Thresholded Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded image']);
end
%======================v9 start======================
% [ind_row_low,ind_row_high]=fun_ACR_FindBndryFromBand(I_bin,'row');%extreme
% [ind_col_low,ind_col_high]=fun_ACR_FindBndryFromBand(I_bin,'col');%pts
% ind_centre=[round((ind_col_high-ind_col_low)/2+ind_col_low) ...
%     round((ind_row_high-ind_row_low)/2+ind_row_low)];%phantom centre (y,x)
if strcmp(choice,'S1')
    [cen_pxl,phant_a_y,~,~,~,~]=...
        fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice_S1,pill_r,6);%HWv10
elseif strcmp(choice,'S11')
    [cen_pxl,phant_a_y,~,~,~,~]=...
        fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice_S11,pill_r,6);%HWv10
end
ind_centre=round(cen_pxl');%col to row [x y], make consistent with old code
ind_centre=fliplr(ind_centre);%make consistent with old code
ind_col_low=round(phant_a_y);%make consistent with old code
%======================v9 end======================
%5.go down by 10mm & sample the wedge left&right bndry
l_pxl=round(10/pxl_sz(1,1));%HW:look at 10mm below top bndry to get width
% [bndry_low,bndry_high]=fun_ACR_FindBndryBinaryRow...%can use this but
%     (I_bin,(ind_col_low+l_pxl));%result gives water bndry,need l+1&r-1
% sample_row=I_bin((ind_col_low+l_pxl),:);
% bndry_l=find(diff(1-sample_row),1)+1;   %left bndry of wedge
% bndry_r=find(diff(sample_row),1,'last');%right bndry of wedge
%++++++++++++++++++v6 start+++++++++++++++++++++++
sample_row=I_bin(ind_col_low+l_pxl,...
    ind_centre(1,2)-2*l_pxl:ind_centre(1,2)+2*l_pxl);
bndry_l=find(1-sample_row,1,'first')+ind_centre(1,2)-2*l_pxl-1;
bndry_r=find(1-sample_row,1,'last')+ind_centre(1,2)-2*l_pxl-1;
%++++++++++++++++++v6 finish+++++++++++++++++++++++
%++++++++++++++++++v5 start+++++++++++++++++++++++
% %6.find the centre of wedge to divide wedge into 2 parts
% wedge_centre=round((bndry_r-bndry_l)/2+bndry_l);
% %7.check wedge centre with phantom centre to determine positioning error
% phi_internal=190;%HW:phantom internal diameter is 190mm
% opp_side=abs(wedge_centre-ind_centre(1,2));
% adj_side=phi_internal/2;
% theta=atand(opp_side/adj_side);
% if wedge_centre>ind_centre(1,2)
%     h=msgbox(['The phantom was positioned with a clockwise rotation of '...
%         num2str(theta) ' degrees.']);
%     uiwait(h);
%     rotated_angle=theta;
% elseif wedge_centre<ind_centre(1,2)
%     h=msgbox(['The phantom was positioned with an anti-clockwise ' ...
%         'rotation of ' num2str(theta) ' degrees.']);
%     uiwait(h);
%     rotated_angle=-theta;
% elseif wedge_centre==ind_centre(1,2)
%     h=msgbox('Good job! There is no transverse positioning rotation.');
%     uiwait(h);
%     rotated_angle=theta;
% end
%++++++++++++++++++v5 finish+++++++++++++++++++++++
%++++++++++++++++++v3 start+++++++++++++++++++++++
%8.find bndry of each wedge
integertest=~mod((bndry_r-bndry_l)/2,1);
if integertest%if even rows
    bndry_1=(bndry_r-bndry_l)/2+bndry_l-1;%HW
    bndry_2=bndry_r-(bndry_r-bndry_l)/2+1;%HW
else%if odd rows
    bndry_1=floor((bndry_r-bndry_l)/2+bndry_l)-1;%HW
    bndry_2=round((bndry_r-bndry_l)/2+bndry_l)+1;%HW
end
l_wedge_bndry=[bndry_l bndry_1];
r_wedge_bndry=[bndry_2 bndry_r];
%9.find length inside each wedge and put into vectors
dummy1=zeros();
dummy2=zeros();
row_start=ind_col_low+l_pxl;
row_end=ind_col_low+round(44/pxl_sz(1,1));%v7
cnt_ind=1;
for j=l_wedge_bndry(1,1):l_wedge_bndry(1,2)
    cnt=1;
    for i=row_start:row_end
        if I_bin(i,j)<1
            cnt=cnt+1;
        else
            break;
        end
    end
    dummy1(1,cnt_ind)=cnt;
    cnt_ind=cnt_ind+1;
end
cnt_ind=1;
for j=r_wedge_bndry(1,1):r_wedge_bndry(1,2)
    cnt=1;
    for i=row_start:row_end
        if I_bin(i,j)<1
            cnt=cnt+1;
        else
            break;
        end
    end
    dummy2(1,cnt_ind)=cnt;
    cnt_ind=cnt_ind+1;
end
%++++++++++++v7 start++++++++++++
%10.search length result & delete the one outside std (false result)
dummy1_mu=mean(dummy1);
dummy1_std=std(dummy1);
dummy2_mu=mean(dummy2);
dummy2_std=std(dummy2);
dummy1_diff=abs(dummy1-dummy1_mu);
dummy2_diff=abs(dummy2-dummy2_mu);
dummy1_true=find(dummy1_diff<=dummy1_std);
dummy1=mean(dummy1(dummy1_true));%v8:take mean of true value as result
dummy2_true=find(dummy2_diff<=dummy2_std);
dummy2=mean(dummy2(dummy2_true));%v8:take mean of true value as result
%++++++++++++v7 end++++++++++++
%11.convert pxl to mm
dummy1=dummy1*pxl_sz(2,1);
dummy2=dummy2*pxl_sz(2,1);
%12.find the length difference using difference between mean lengths
length_l=mean(dummy1);
length_r=mean(dummy2);
l_diff=length_r-length_l;%use right minus left
%12.show result and create pass/fail handle
if l_diff<5||l_diff>-5
    disp(['Congrats! Your slice positioning test has passed. '...
        'Your result is ' num2str(l_diff) ' mm (<5 mm or >-5 mm). ']);
    disp(['If your result is better than 4 mm, you will have better '...
        'result in low contrast object detectibility test.']);
    pf_hdl=1;
else
    disp(['Your slice positioning accuracty result is '...
        num2str(l_diff) ' mm. It is > 5 mm. In case I was wrong, please'...
        ' check manually.']);
    pf_hdl=0;
end
%++++++++++++++++++v3 finish+++++++++++++++++++++++
%+++++++++++++++++++original code with bug++++++++++++++++++++++++
% %8.find all the vertical length in wedge
% % vert_l_pxl=round(70/pxl_sz(2,1));%HW:vert length fixed to 70mm (NOT USED)
% vert_l=zeros(1,(bndry_r-bndry_l+1));
% cnt=1;
% for i=bndry_l:bndry_r
%     dummy=find(diff(1-I_bin(:,i)),1,'first');
%     vert_low=dummy+1;%+1 TO GET WEDGE TOP BNDRY
%     dummy=find(diff(I_bin(:,i)));
%     vert_high=dummy(2,1);%WEDGE BOTTOM BNDRY
%     vert_l(1,cnt)=vert_high-vert_low+1;
%     cnt=cnt+1;
% end
% if visual==1%v2
%     figure;%plot length of wedge and derivative of length
%     subplot(2,1,1);
%     plot(vert_l);
%     title('Vertical Length Across Wedge');
%     subplot(2,1,2);
%     plot(diff(vert_l));
%     title('Rate of Vertical Length Change');
% else
%     disp(['You have turned off graph visualisation '...
%         'to show the wedge length plot']);
% end
% %9.find the max in the length vector derivative & that is the centre
% [~,ind_cen_loc]=max(diff(vert_l));%local index
% ind_cen_glo=bndry_l+ind_cen_loc-1;%global index across image
% %10.use the index of centre to pick up lenght on both sides randomly
% rand_num_1=rand(1);
% rand_num_2=rand(1);
% ind_length_l=floor...
%     ((ind_cen_glo-bndry_l-1)*rand_num_1);%HW:-1 pxl from bndry
% ind_length_r=ceil...
%     ((bndry_r-ind_cen_glo-1)*rand_num_2)+ind_cen_loc;%HW:-1 pxl from bndry
% length_l_pxl=vert_l(1,ind_length_l);
% length_r_pxl=vert_l(1,ind_length_r);
% %11.convert to mm
% length_l=length_l_pxl*pxl_sz(2,1);
% length_r=length_r_pxl*pxl_sz(2,1);
% %12.find the length difference
% l_diff=length_r-length_l;%use right minus left
% fprintf('The length difference is %4.2f mm.\n',l_diff);
% %13.manual measurement if something not right
% if l_diff<5
%     h=msgbox(['Congrats! This test has passed. '...
%         'The length difference is ' num2str(l_diff) ' mm. '...
%         '(<5 mm)']);
%     uiwait(h);
% else
%     disp(['Oops. It seems something is going wrong. '...
%         'Try doing manual measurement. ']);
%     disp(['If the test still does not pass, '...
%         'then the machine probably need some care from you.']);
%     disp('Performing manual measurement now:');
%     msgbox(['Now we are doing manual measurement. '...
%         'Record length you saw on screen and then '...
%         'calculate the length difference. ' ...
%         'DON''T FORGET TO PUT ''-'' SIGN IN FRONT '...
%         'IF LEFT LENGTH IS LONGER.']);
%     figure;
%     imshow(I_bin,[]);
%     h = imline(gca);
%     addNewPositionCallback(h,@(p) ...
%         title(['Real length: ' ...
%         num2str(sqrt(abs(p(1,1)-p(2,1))*abs(p(1,1)-p(2,1))+...
%         abs(p(1,2)-p(2,2))*abs(p(1,2)-p(2,2))))...
%         'mm']));%find & display length between 2 pts
% end
%+++++++++++++++++original code with bug++++++++++++++++++++++++++
end