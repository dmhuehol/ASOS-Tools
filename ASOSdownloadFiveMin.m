%%ASOSdownloadFiveMin
    %Function to download five minute ASOS data from NCDC servers. Requires
    %an Internet connection.
    %
    %General form: ASOSdownloadFiveMin(emailAddress,station,year,month,downloadedFilePath)
    %Inputs:
    %emailAddress: The user's complete email address. This functions as a
    %password, and is required by the NCDC FTP server.
    %station: Four character station ID, such as KHWV for Brookhaven Airport,
    %or KISP for Islip.
    %year: Four-digit year
    %month: One or two-digit month. Use 'all' to download a full year.
    %downloadedFilePath: designate path to download to. Use pwd to download
    %to working directory. Type a 'folder name' to create a new folder named 'folder name'
    %in the working directory and download to it.
    %
    %Outputs:
    %None in the workspace (obviously, new files will be created at the
    %requested file path)
    %
    %Note: if function is failing for no apparent cause, it is likely an NCDC server problem.
    %Wait some time and try again, or try a different email address.
    %
    %Version Date: 3/18/2018
    %Last major revision: 3/18/2018
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    
function [] = ASOSdownloadFiveMin(emailAddress,station,year,month,downloadedFilePath)
if nargin~=5 %Needs all inputs to work properly
    msg = 'Improper number of inputs, check syntax!';
    error(msg);
end

% Check to see if whole year was requested
if strcmp(month,'all')==1
    allYear = 1;
else
    allYear = 0;
end

% For making paths, strings, and path strings
slash = '/'; %#ok
dash = '-';
obsType = '6401';
zeroChar = '0';
space = ' '; %#ok
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
if allYear == 1
    wholeYearMessageFirst = 'Current input will download all data from ';
    yearString = num2str(year);
    wholeYearMessageBegin = [wholeYearMessageFirst,yearString];
    wholeYearMessageEnd = '. Continue, Y/N?';
    wholeYearMessage = strcat(wholeYearMessageBegin,wholeYearMessageEnd);
    YN = input(wholeYearMessage);
    if strcmp(YN,'Y')==1 || strcmp(YN,'y')==1 || strcmp(YN,'Yes')==1 || strcmp(YN,'yes')==1
        %Do nothing
    elseif strcmp(YN,'N')==1 || strcmp(YN,'n')==1 || strcmp(YN,'No')==1 || strcmp(YN,'no')==1
        return %In this case the user has entered 'N'
    end
else %If a month was entered
    monthString = num2str(month);
    if numel(monthString)==1 %Check the number of digits in month
        monthString = strcat(zeroChar,monthString); %Add a leading zero if month is one-digit
    end
end

% Set up file paths
fiveMinPath = '/pub/data/asos-fivemin/'; %Path to five minute data on FTP server
yearPrefix = strcat(obsType,dash); %ASOS data is stored by year in folders with the prefix 6401-. For example, 2015 data is stored in the folder 6401-2015.
yearString = num2str(year); yearDirString = strcat(yearPrefix,yearString); %Creates the year directory string by concatenating the prefix and the input year
yearPath = strcat(fiveMinPath,yearDirString); %This is the path for the input year
if allYear==0
    obsFilename = [obsType zeroChar station yearString monthString fileExtension]; %If month is present, download the specific month file.
else
    obsFilename = [obsType zeroChar station yearString '*' fileExtension]; %If month is omitted, download the entire year.
end

ftpNCDC = ftp('ftp.ncdc.noaa.gov','anonymous',emailAddress); %Opens an FTP connection to the NCDC server
cd(ftpNCDC,fiveMinPath); %Changes folder to the ASOS five minute data
cd(ftpNCDC,yearPath); %Changes folder to the year path
mget(ftpNCDC,obsFilename,downloadedFilePath); %Downloads target file(s) to the specified file path
close(ftpNCDC) %Closes FTP connection

completeMessage = 'Download complete!';
disp(completeMessage);
end
    