%%ASOSimportManyFiveMin
    %Function to import ASOS five-minute data into MATLAB as a structure
    %from a list of filenames. Outputs up to two master structures--one with
    %only the most useful variables, and one with all variables supplied by
    %ASOS--which in turn contain other structures referring to data from different stations as
    %substructures. Multiple months are concatenated into the substructures.
    %
    %General form:
    %   [usefulCompositeStruct,fullCompositeStruct] = ASOSimportManyFiveMin(filelist,stations)
    %
    %Outputs:
    %usefulStruct: structure containing substructures for each
    %   station. Each substructure contains the most useful data
    %   for that station: station ID, year, month, day, hour, minute,
    %   datetime, variable wind, wind direction, wind speed, wind
    %   character, wind character speed, minimum variable direction,
    %   maximum variable direction, present weather code, temperature,
    %   dewpoint, altimeter, relative humidity, visibility, sky condition.
    %   (Times are recorded in UTC.)
    %ASOSstruct: structure containing substructures for each station. Each
    %   substructure contains all possible ASOS entries--all from above,
    %   plus extra ID, record length, day/month/year, HH:MM:SS, observation
    %   frequency, another station ID, Zulu time, observation type, slash
    %   field (divider), unknown data field, another unknown data field,
    %   another unknown data field, magnetic wind, magnetic variable wind,
    %   and remarks.
    %
    %Inputs:
    %filelist: cell array list of names referring to ASOS five minute data files.
    %stations: cell array list of all station codes that have files in the
    %   file list. This MUST be input as a cell array even if there is only
    %   one station.
    %
    %To download an ASOS data file from the NCDC FTP server
    %using MATLAB, see ASOSdownloadFiveMin. To download an ASOS data file
    %by hand, go to:
    %   ftp://ftp.ncdc.noaa.gov/pub/data/asos-fivemin/
    %(link active as of 5/27/2020)
    %
    %If you are attempting to import only a single month from a single site,
    %use ASOSimportFiveMin instead.
    %
    %When a regular expression is used, the raw expression formatted for
    %troubleshooting on regexr.com can be found commented out in the line
    %before the expression variable is defined.
    %
    %
    %Version date: 5/27/2020
    %Last major revision: 5/27/2020
    %Written by: Daniel Hueholt
    %Undergraduate Research Assistant at Environment Analytics
    %North Carolina State University
    %
    %See also ASOSdownloadFiveMin, ASOSimportFiveMin
    %

function [usefulMasterStruct,ASOSmasterStruct] = ASOSimportManyFiveMin(filelist,stations)

%% Identify files to import
diffStations = struct([]);
for stCheck = 1:length(stations)
    st = strfind(filelist,stations{stCheck}); %Find all files corresponding to a given station
    logStations = logical(~cellfun('isempty',st));
    diffStations(stCheck).files = filelist(logStations==1); %Each structure entry contains the files for a given station
end

%% Import data
for cSt = 1:length(diffStations) %Splits different stations into different fields of the master structure
    noOvrwrt = 1;
    sortedActiveFiles = sort(diffStations(cSt).files);
    for cDiffSt = 1:length(sortedActiveFiles)
        disp(['Current file: ' sortedActiveFiles{cDiffSt}])
        % Unfortunately, since ASOSimportFiveMin only reads individual
        % files there isn't an immediately obvious way around using a loop
        % to feed the importer these files one at a time.
        % 
        [usefulStruct{noOvrwrt},ASOSstruct{noOvrwrt}] = ASOSimportFiveMin(sortedActiveFiles{cDiffSt}); %#ok preallocation actually slows this down
        noOvrwrt = noOvrwrt+1;
    end
        
    
    %% Create output structures
    usefulMasterStruct.(stations{cSt}) = cell2mat(usefulStruct);
    ASOSmasterStruct.(stations{cSt}) = cell2mat(ASOSstruct);
    
    %Blank the variables that will be reused in the next loop, otherwise
    %data may be repeated in the output structures
    usefulStruct = struct([]);
    ASOSstruct = struct([]);
    
end

end
