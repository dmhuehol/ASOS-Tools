%%ASOSdownloadFiveMin
    %Function to download five minute ASOS data from NCDC servers. Requires
    %an Internet connection.
    %
    %General form: ASOSdownloadFiveMin(emailAddress,station,year,month,downloadedFilePath)
    %
    %Inputs:
    %emailAddress: The user's complete email address. This is required by
    %the NCDC FTP server.
    %station: Four character station ID or cell array of station IDs
    %year: Four-digit year or array of years
    %month: One or two-digit month or array of months. Use 'all' to download a full year.
    %downloadedFilePath: designate path to download to. Type a 'folder
    %name' to create and download to a new folder named 'folder name' in
    %the working directory.
    %
    %Outputs:
    %downloadedFilenames: 3D cell array of filenames created by the new
    %files. D1=year, D2=station, D3=month
    %
    %Note: if function is failing for no apparent cause, it is likely an NCDC server problem.
    %Wait some time and try again, or try a different email address.
    %
    %Version Date: 2/23/2020
    %Last major revision: 2/23/2020
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    
function [downloadedFilenames] = ASOSdownloadFiveMin(emailAddress,station,year,month,downloadedFilePath)
% Check inputs
if nargin~=5
    msg = 'Improper number of inputs, check syntax!';
    error(msg);
end
if ischar(station)==1
    station = {station};
end

% Check to see if whole year was requested
if strcmp(month,'all')==1
    allMonths = 1;
    month = 1:12;
else
    allMonths = 0;
end

% For making paths, strings, and path strings
slash = '/'; %#ok
dash = '-';
obsType = '6401';
zeroChar = '0';
space = '\n';
Y = 'Y'; %#ok
y = 'y'; %#ok
yes = 'yes'; %#ok
Yes = 'yes'; %#ok
N = 'N'; %#ok
n = 'n'; %#ok
no = 'no'; %#ok
No = 'no'; %#ok
fileExtension = '.dat';

% If year of data is requested, double-check with the user
if allMonths==1
    wholeYearMessageFirst = 'Download all data from ';
    yearString = num2str(year);
    wholeYearMessageBegin = [wholeYearMessageFirst,yearString];
    wholeYearMessageEnd = '? [Y/N]';
    wholeYearMessage = strcat(wholeYearMessageBegin,wholeYearMessageEnd,space);
    YN = input(wholeYearMessage);
    if strcmp(YN,'Y')==1 || strcmp(YN,'y')==1 || strcmp(YN,'Yes')==1 || strcmp(YN,'yes')==1
        %Do nothing
    elseif strcmp(YN,'N')==1 || strcmp(YN,'n')==1 || strcmp(YN,'No')==1 || strcmp(YN,'no')==1
        disp('Cancelled')
        return %In this case the user has entered 'N'
    end
end

for m_c = length(month):-1:1
    monthString{m_c} = num2str(month(m_c));
    if numel(monthString{m_c})==1 %Check the number of digits in month
        monthString{m_c} = strcat(zeroChar,monthString{m_c}); %Add a leading zero if month is one-digit
    end
end
for y_c = length(year):-1:1
    yearString{y_c} = num2str(year(y_c));
end

% Set up file paths
fiveMinPath = '/pub/data/asos-fivemin/'; %Path to five minute data on FTP server
for y_c = length(year):-1:1
    yearPrefix{y_c} = strcat(obsType,dash); %ASOS data is stored by year in folders with the prefix 6401-. For example, 2015 data is stored in the folder 6401-2015.
    %yearString = num2str(year);
    yearDirString{y_c} = strcat(yearPrefix{y_c},yearString{y_c}); %Creates the year directory string by concatenating the prefix and the input year
    yearPath{y_c} = strcat(fiveMinPath,yearDirString{y_c}); %This is the path for the input year
    for st_c = length(station):-1:1
        for m_c = length(month):-1:1
            obsFilename{y_c,st_c,m_c} = [obsType zeroChar station{st_c} yearString{y_c} monthString{m_c} fileExtension]; %If month is present, download the specific month file.
        end
    end
end
ftpNCDC = ftp('ftp.ncdc.noaa.gov','anonymous',emailAddress); %Opens an FTP connection to the NCDC server
cd(ftpNCDC,fiveMinPath); %Changes folder to the ASOS five minute data
for y_c = length(year):-1:1
    cd(ftpNCDC,yearPath{y_c}); %Changes folder to the year path
    for st_c = length(station):-1:1
        for m_c = length(month):-1:1
            try
                mget(ftpNCDC,obsFilename{y_c,st_c,m_c},downloadedFilePath); %Downloads target file(s) to the specified file path
            catch
                disp([obsFilename{y_c,st_c,m_c} ' could not be located on server! Skipped and continuing.'])
                continue
            end
            downloadedFilenames{y_c,st_c,m_c} = strcat(downloadedFilePath,obsFilename{y_c,st_c,m_c});
        end
    end
end
close(ftpNCDC) %Closes FTP connection

completeMessage = 'Download complete!';
disp(completeMessage);
end
    