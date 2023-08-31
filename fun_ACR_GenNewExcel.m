function fun_ACR_GenNewExcel(single_scanner)
% This function generates new Excel file for a centre. The file name will
% be 'InstitutionName.xlsx'. User will be asked to select the localiser
% from each scanner. The program uses the DICOM info from localiser to
% create work sheet for each scanner.
% Each work sheet is expected to have following format:
% Manufacturer_ManufacturerModelName_StationName
% If the length of the character is more than 31, MS Excel worksheet can't
% handle. In that case, the work sheet format will be:
% ManufacturerModelName_StationName
% The Excel file will be saved at the same directory as the program.
%
% Input:
%   single_scanner: single or multiple scanners (bin: 1=single or 0=multiple)
% Output:
%   NA
% Usage: 
%   
% HW: (search for HW)
%   
% Naughty Boy: (search for NB)
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v1 (14/07/16)
%          v2 (16/09/16)(search for v2)
% History: v1
%          v2 Added binary trigger for single or multiple scanners.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.define Excel heading
heading={'','Localiser','Distortion (T1 S1)','','Distortion (T1 S5)','','','',...%v2
    'Distortion (T2 S1)','','Distortion (T2 S5)','','','',...
    'High Contrast','','High Contrast','','Slice Thickness','',...
    'Slice Position','','','','PIU','','PSG','',...
    'LCOD T1','','','','LCOD T2','','','';...%1st row
    'Date','Distortion','RL','AP','RL','AP','NG','PG','RL','AP','RL','AP','NG','PG',...
    'UL T1','RL T1','UL T2','RL T2','T1','T2',...
    'T1 S1','T1 S11','T2 S1','T2 S11','T1','T2','T1','T2',...
    'S11','S10','S9','S8','S11','S10','S9','S8'};
%2.create Excel file using while loop
more_scanner=1;
while more_scanner==1
    dir_name=uigetdir('C:\',...
        'Select localiser directory for one of your scanner.');
    dir_name=[dir_name '\'];
    [institution_name,manuf_name,manuf_model_name,station_name]=...
        fun_ACR_GetScannerInfo(dir_name);
    wrt_sheet=[manuf_name '_' manuf_model_name '_' station_name];
    xlswrite([institution_name '.xlsx'],heading,wrt_sheet);
    %====================v2 start====================
    if single_scanner==0%multiple scanners
        more_scanner_choice=questdlg('Do you have any other scanners at your centre?', ...
            'Red or Blue Pill', ...
            'Yes','No','Yes');
        switch more_scanner_choice%Handle response
            case 'Yes'
                continue;
            case 'No'
                more_scanner=0;
        end
    elseif single_scanner==1%single scanner
        more_scanner=0;
    end
    %====================v2 end====================
end
end