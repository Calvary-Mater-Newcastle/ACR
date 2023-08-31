function fun_ACR_GenExcel...
    (res,institution_name,manuf_name,manuf_model_name,station_name,...
    QA_date,scanner_num)
% This function reads the historical Excel sheet and adds the new result to
% the sheet for long term scanner performance documentation and analysis.
% Each work sheet is expected to have following format:
% Manufacturer_ManufacturerModelName_StationName
% If the length of the character is more than 31, MS Excel worksheet can't
% handle. In that case, the work sheet format will be:
% ManufacturerModelName_StationName
% The Excel file is expected to be at the same directory as the program.
% The name of the Excel is 'InstitutionName.xlsx'.
%
% Input:
%   res: result (1-by-n vec)
%   institution_name: institution name (str)
%   manuf_name: manufacturer name (str)
%   manuf_model_name: manufacturer model name (str)
%   station_name: station name (str)
%   QA_date: QA date (str,YYYYMMDD)
%   scanner_num: single or multiple scanners (bin: 1=single or 0=multiple)
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
%          v2 A logic bug found: during check Excel existence, if any file
%             is not in the same name as the scanner DICOM tag then it will
%             perform new Excel generation. Somehow, it does not over-write
%             the previous data in Excel, maybe due to how I wrote the
%             generation function. The new code uses binary vector to find
%             the existence of the correct Excel. If exists update,
%             otherwise generate new.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.find Excel in current directory
dir_name=pwd;
dir_name=[dir_name '\'];
file_names=dir([dir_name '*.xlsx']);
%===============v2 start===============
dummy=zeros(length(file_names),1);
if ~isempty(file_names)%if has Excel files
    for i=1:length(file_names)
        file_name=file_names(i).name;
        if strcmp(file_name(1:end-5),institution_name)%create binary vec
            dummy(i,1)=1;
        else
            dummy(i,1)=0;
        end
    end
    if sum(dummy)==1%if exist target Excel
        file_ind=find(dummy);
        file_name=file_names(file_ind).name;
    elseif sum(dummy)==0%if not exist target Excel
        disp('Historical Excel file not found. Now I''ll create one.');
        fun_ACR_GenNewExcel(scanner_num);
        file_name=[institution_name '.xlsx'];
    end
else%no Excel files
    disp('No Excel file found. Now I''ll create one.');
    fun_ACR_GenNewExcel(scanner_num);
    file_name=[institution_name '.xlsx'];
end
% if ~isempty(file_names)%if has Excel files
%     for i=1:length(file_names)
%         file_name=file_names(i).name;
%         if strcmp(file_name(1:end-5),institution_name)
%             break;
%         else
%             disp('Historical Excel file not found. Now I''ll create one.');
%             fun_ACR_GenNewExcel();
%             file_name=[institution_name '.xlsx'];
%         end
%     end
% else%no Excel files
%     disp('No Excel file found. Now I''ll create one.');
%     fun_ACR_GenNewExcel();
%     file_name=[institution_name '.xlsx'];
% end
%===============v2 end===============
%2.read Excel
wrt_sheet=[manuf_name '_' manuf_model_name '_' station_name];
if length(wrt_sheet)>31
    wrt_sheet=[manuf_model_name '_' station_name];
end
[~,~,raw]=xlsread([dir_name file_name],wrt_sheet);
%2.define the new row index
new_row_ind=size(raw,1)+1;
%3.define range to write new result
wrt_range=['a' num2str(new_row_ind) ':' 'aj' num2str(new_row_ind)];%this line defines Excel col range
%4.add new date
res{1,1}=QA_date;
% %5.add new result
% new_raw(1,2:34)=result;
%6.save new Excel to dir
xlswrite([dir_name file_name],res,wrt_sheet,wrt_range);
disp('The historical report has been updated under following path: ');
disp([dir_name file_name]);
end