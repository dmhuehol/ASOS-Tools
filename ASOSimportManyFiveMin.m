%%ASOSimportManyFiveMin
    %Function to import ASOS five-minute data into MATLAB as a structure
    %from a list of filenames. Outputs up to two master structures--one with
    %only the most useful variables, and one with all variables supplied by
    %ASOS--which in turn contain other structures referring to data from different stations as
    %subfields. Multiple months are concatenated into the subfields, not split
    %off as their own structures.
    %
    %General form:
    %   [usefulStruct,ASOSstruct] = ASOSimportManyFiveMin(filelist,stations)
    %
    %Outputs:
    %usefulMasterStruct: structure containing entries for year, month, day, hour,
    %   minute, variable wind, wind direction, wind speed, wind character,
    %   wind character speed, minimum variable direction, maximum variable
    %   direction, present weather, temperature, dewpoint, altimeter setting,
    %   relative humidity, visibility, sky condition, and station ID. (Times are
    %   recorded in UTC.)
    %ASOSmasterStruct: structure containing all possible ASOS entries--all
    %   entries from above, plus an extra station ID, record length,
    %   day/month/year, local HH:MM:SS, observation frequency, another station ID, Zulu
    %   time, observation type, slash field (divider), unknown data field, another
    %   unknown data field, another unknown data field, magnetic wind,
    %   magnetic variable wind, and remarks.
    %
    %Inputs:
    %filelist: cell array list of names referring to ASOS five minute data files.
    %stations: cell array list of all station codes that have files in the file list.
    %
    %To download an ASOS data file from the NCDC FTP server
    %using MATLAB, see ASOSdownloadFiveMin. To download an ASOS data file
    %by hand, go to:
    %   ftp://ftp.ncdc.noaa.gov/pub/data/asos-fivemin/
    %(link active as of 6/07/2018)
    %
    %If you are attempting to import only a single month from a single site,
    %use ASOSimportFiveMin instead.
    %
    %When a regular expression is used, the raw expression formatted for
    %troubleshooting on regexr.com can be found commented out in the line
    %before the expression variable is defined.
    %
    %
    %Links to useful ASOS documentation can be found in the
    %EnvAn-WN-Phase-2 repository readme on github user page @dmhuehol.
    %
    %Version date: 5/3/2019
    %Last major revision: 6/11/2018
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
for all = 1:length(diffStations) %Splits different stations into different fields of the master structure
    %% Raw data
    surfaceObsRawByMonth = cell(1,length(diffStations(all).files)); %Preallocation
    for sameStation = 1:length(diffStations(all).files)
        surfaceObsRawByMonth{sameStation} = fileread(diffStations(all).files{sameStation}); %Imports the files as character blocks; different months are placed into different cells
    end
    surfaceObsRaw = cat(2,surfaceObsRawByMonth{1:end}); %All input data for the given station is concatenated into a single character block
    %(\d{5}\w{4})\s([A-Z]{3})(\d{4})(\d{2})(\d{2})(\d{4})(\d{3})(\d{2}\/\d{2}\/\d{2})\s?(\d{2}:\d{2}:\d{2})\s?\s?(5-MIN)\s([A-Z]{4})\s(\d{6}Z)\s(AUTO){0,1}\s?((VRB){0,1}\d{0,5}[GQ]{0,1}\d{2,3}KT\s?){0,1}(\d{3}V\d{3}\s?){0,1}(M?\d{1,2}SM|M?\d{1}\s\d{1}\/\d{1,2}SM|M?\d{1}\/\d{1}SM|\d{1}\s?\d{1}\/\d{1}SM|\s?(R\d{2})?\/P?\d{4}V?P?\d{0,4}FT){0,2}\s?(-?\+?(VC)?(MI|PR|BC|DR|BL|SH|TS|FZ)?(DZ|RA|SN|SG|IC|PE|PL|GR|GS|UP)?(BR|FG|FU|VA|DU|SA|HZ|PY)?(PO|SQ|FC|SS)?\s?){0,4}(([A-Z]{3}\d{3}(CB)?|CLR|VV\d{3})\s?){0,5}\s?(M?\d{0,3}|M)?(\/?)(M?\d{0,3}|M)?\s?(A\d{4}|M)?\s?(-?\d{1,4}|M)\s?(100|M|\d{2})?\s?(-?\d{1,4}|M)?\s?(M)?\s?((VRB)?\d{0,3}\/\d{0,2}[GQ]?\d{0,3}|\s?\/M)?\s?(\d{3}V\d{3}|\M|\/M)?\s?(RMK.*)?
    trueExp = '(?<StationID>\d{5}\w{4})\s(?<ExtraID>[A-Z]{3})(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})(?<Time>\d{4})(?<RecordLength>\d{3})(?<DayMonthYear>\d{2}\/\d{2}\/\d{2})\s?(?<HHMMSS>\d{2}:\d{2}:\d{2})\s?\s?(?<ObservationFrequency>5-MIN)\s(?<FurtherID>[A-Z]{4})\s(?<ZuluTime>\d{6}Z)\s(?<ObservationType>AUTO){0,1}\s?(?<Wind>(VRB){0,1}\d{0,5}[GQ]{0,1}\d{2,3}KT\s?){0,1}(?<VariableWind>\d{3}V\d{3}\s?){0,1}(?<Visibility>M?\d{1,2}SM|M?\d{1}\s\d{1}\/\d{1,2}SM|M?\d{1}\/\d{1}SM|\d{1}\s?\d{1}\/\d{1}SM|\s?(R\d{2})?\/P?\d{4}V?P?\d{0,4}FT){0,2}\s?(?<PresentWeather>-?\+?(VC)?(MI|PR|BC|DR|BL|SH|TS|FZ)?(DZ|RA|SN|SG|IC|PE|PL|GR|GS|UP)?(BR|FG|FU|VA|DU|SA|HZ|PY)?(PO|SQ|FC|SS)?\s?){0,4}(?<SkyCondition>([A-Z]{3}\d{3}(CB)?|CLR|VV\d{3})\s?){0,5}\s?(?<Temperature>M?\d{0,3}|M)?(?<Slash>\/?)(?<Dewpoint>M?\d{0,3}|M)?\s?(?<Altimeter>A\d{4}|M)?\s?(?<UnknownOne>-?\d{1,4}|M)\s?(?<RelativeHumidity>100|M|\d{2})?\s?(?<UnknownTwo>-?\d{1,4}|M)?\s?(?<UnknownThree>M)?\s?(?<MagneticWind>(VRB)?\d{0,3}\/\d{0,2}[GQ]?\d{0,3}|\s?\/M)?\s?(?<MagneticVariableWind>\d{3}V\d{3}|\M|\/M)?\s?(?<Remarks>RMK.*)?'; %Blood, sweat, and tears
    ASOSstruct = regexp(surfaceObsRaw,trueExp,'names','dotexceptnewline'); %Read raw data using the regular expression defined above
    %'names' designates structure fields based on the bracketed parts of each token
    %'dotexceptnewline' causes each line to be read as a new field in the structure
    %Every data file will have a handful of cursed entries that won't work with
    %this expression for whatever reason, but it will usually miss less than 10 entries per month of data.
    
    %% Datatype conversions
    usefulStruct = struct([]); %Preallocate a blank structure
    %((VRB)){0,1}(\d{2})(\d{0,3})([GQ]{0})(\d{0,3})(KT)
    windExp = '(?<Variable>(VRB){0,1})(?<WindDirection>\d{2})(?<WindSpeed>\d{0,3})(?<WindCharacter>[GQ]{0,1})(?<WindCharacterSpeed>\d{0,3})(KT)'; %Expression for wind data
    %(\d{3})(V)(\d{3})\s?
    variableWindExp = '(?<MinimumWindDirection>\d{3})(V)(?<MaximumWindDirection>\d{3})\s?'; %Expression for variable wind group
    errorCount = 0;
    missingCount = 0;
    errorThreshold = length(ASOSstruct)*0.08; %Unacceptable threshold for errors (8% of data); don't mess with this unless you have a REALLY good reason
    for count = length(ASOSstruct):-1:1 %Backwards so the entire structure is built in the first step and is then merely filled with data as the loop progresses (saves time)
        try %Prevents a small number of errors from choking the function
            wind(count) = regexp(ASOSstruct(count).Wind,windExp,'names'); %Read wind data using the wind expression
            try %Split the variable wind group into minimum wind direction and maximum wind direction
                variableWind(count) = regexp(ASOSstruct(count).VariableWind,variableWindExp,'names');
            catch ME; %#ok %If the regular expression fails, there is no variable wind group
                variableWind(count).MinimumWindDirection = ''; %blank
                variableWind(count).MaximumWindDirection = ''; %blank
                continue %move on
            end
        catch ME; %#ok %If the regular expression fails, then wind data was not recorded for this time. Thus, we manually fill in the missing data the same way that missing data is usually filled in automatically
            wind(count).Variable = 'M'; %M for murder (actually for missing)
            wind(count).WindDirection = ''; %blank
            wind(count).WindSpeed = ''; %blank
            wind(count).WindCharacter = 'M'; %M for mono
            wind(count).WindCharacterSpeed = ''; %blank
            variableWind(count).MinimumWindDirection = ''; %blank
            variableWind(count).MaximumWindDirection = ''; %blank
            if strcmp(wind(count).Variable,'M')==1 %If the data is missing
                %disp(count) %Uncomment this line to see where errors are occurring
                missingCount = missingCount+1; %Increase the error count
            end
            continue %move on
        end
    end
    
    if missingCount>errorThreshold %If the error count is greater than the threshold
        percentError = missingCount/length(ASOSstruct)*100;
        stringError = num2str(percentError);
        disp(['WARNING: Wind data was not recorded for ' stringError '% of data entries!']); %warn the user
    else
        %do nothing
    end
    
    for count = length(ASOSstruct):-1:1
        usefulStruct(count).StationID = ASOSstruct(1).FurtherID;
        usefulStruct(count).Year = sscanf(ASOSstruct(count).Year,'%4f'); %sscanf is fastest way to convert from string to number
        usefulStruct(count).Month = sscanf(ASOSstruct(count).Month,'%f');
        usefulStruct(count).Day = sscanf(ASOSstruct(count).ZuluTime(1:2),'%2f'); %Z time is used as the default time in usefulStruct to make it easier to compare ASOS with other datasets
        if sscanf(ASOSstruct(count).Day,'%2f')==31 && sscanf(ASOSstruct(count).ZuluTime(1:2),'%2f')==1 %Fixes last day for 31-day months
            if sscanf(ASOSstruct(count).Month,'%2f')==12 %If said month is December
                usefulStruct(count).Year = usefulStruct(count).Year+1; %Increment the year
                usefulStruct(count).Month = 1; %and the month is January, not 13
            else
                usefulStruct(count).Month = usefulStruct(count).Month+1; %Otherwise, just increase the month by 1
            end
        %For all other last days, there are no year issues as December always has 31 days
        elseif sscanf(ASOSstruct(count).Day,'%2f')==30 && sscanf(ASOSstruct(count).ZuluTime(1:2),'%2f')==1 %Fixes last day for 30-day months
            usefulStruct(count).Month = usefulStruct(count).Month+1;
        elseif sscanf(ASOSstruct(count).Day,'%2f')==29 && sscanf(ASOSstruct(count).ZuluTime(1:2),'%2f')==1 %Fixes last day for leap year Februaries
            usefulStruct(count).Month = usefulStruct(count).Month+1;
        elseif sscanf(ASOSstruct(count).Day,'%2f')==28 && sscanf(ASOSstruct(count).ZuluTime(1:2),'%2f')==1 %Fixes last day for normal Februaries
            usefulStruct(count).Month = usefulStruct(count).Month+1;
        end
        usefulStruct(count).Hour = str2num(ASOSstruct(count).ZuluTime(3:4)); %#ok %str2double and sscanf both fail here, sometimes str2num is just more robust
        usefulStruct(count).Minute = str2num(ASOSstruct(count).ZuluTime(5:6)); %#ok %str2double and sscanf both fail here, sometimes str2num is just more robust
        usefulStruct(count).VariableWind = wind(count).Variable;
        usefulStruct(count).WindDirection = sscanf(wind(count).WindDirection,'%2f').*10;
        usefulStruct(count).WindSpeed = str2double(wind(count).WindSpeed); %sscanf fails here, str2double is used instead
        usefulStruct(count).WindCharacter = wind(count).WindCharacter;
        usefulStruct(count).WindCharacterSpeed = str2double(wind(count).WindCharacterSpeed); %sscanf fails here, str2double is used instead
        usefulStruct(count).MinimumVariableDir = sscanf(variableWind(count).MinimumWindDirection,'%3f');
        usefulStruct(count).MaximumVariableDir = sscanf(variableWind(count).MaximumWindDirection,'%3f');
        usefulStruct(count).PresentWeather = ASOSstruct(count).PresentWeather;
        try %This section converts negative readings in temperature and dewpoint from M-designated string negatives to actual numbers
            if isempty(ASOSstruct(count).Temperature)==1 %If temperature was missing
                usefulStruct(count).Temperature = NaN;
            elseif isempty(ASOSstruct(count).Dewpoint)==1 %If dewpoint is missing
                usefulStruct(count).Dewpoint = NaN;
            elseif strcmp(ASOSstruct(count).Temperature(1),'M')==1 && length(ASOSstruct(count).Temperature)>2 %If the temperature is negative
                ASOSstruct(count).Temperature(1) = []; %Delete the M
                ASOSstruct(count).Dewpoint(1) = []; %Delete the M in dewpoint as well (since Td<=T for all Td)
                usefulStruct(count).Temperature = str2double(ASOSstruct(count).Temperature)*-1; %Change string to double and make it negative (sscanf fails here)
                usefulStruct(count).Dewpoint = str2double(ASOSstruct(count).Dewpoint)*-1; %Change string to double and make it negative (sscanf fails here)
            elseif strcmp(ASOSstruct(count).Dewpoint(1),'M')==1 && length(ASOSstruct(count).Dewpoint)>2 %If dewpoint is negative but temperature was not
                ASOSstruct(count).Dewpoint(1) = []; %Delete the M
                usefulStruct(count).Temperature = str2double(ASOSstruct(count).Temperature); %Change string to double but leave sign alone (sscanf fails here)
                usefulStruct(count).Dewpoint = str2double(ASOSstruct(count).Dewpoint)*-1; %Change string to double and make it negative (sscanf fails here)
            else %If both temperature and dewpoint are positive
                usefulStruct(count).Temperature = str2double(ASOSstruct(count).Temperature); %Change string to double (sscanf fails here)
                usefulStruct(count).Dewpoint = str2double(ASOSstruct(count).Dewpoint); %Change string to double (sscanf fails here)
            end
        catch ME; %#ok
            %disp(count) %Uncomment this to see where any errors are occuring
            errorCount = errorCount+1; %Increase the error count
            if errorCount>errorThreshold %If error count exceeds maximum acceptable threshold
                msg = 'Error count exceeded maximum allowable value! Check dataset for compatibility with function.';
                error(msg); %Warn the user and stop the function
            else
                %do nothing
            end
            continue
        end
        if isempty(usefulStruct(count).Dewpoint)==1 %If dewpoint data is missing
            usefulStruct(count).Dewpoint = NaN;
        end
        usefulStruct(count).Altimeter = sscanf(ASOSstruct(count).Altimeter(2:end),'%4f')/100;
        if isempty(usefulStruct(count).Altimeter)==1 %If altimeter data is missing
            usefulStruct(count).Altimeter = NaN;
        end
        usefulStruct(count).RelativeHumidity = str2double(ASOSstruct(count).RelativeHumidity);
        usefulStruct(count).Visibility = ASOSstruct(count).Visibility; %No conversion
        usefulStruct(count).SkyCondition = ASOSstruct(count).SkyCondition; %No conversion
        usefulStruct(count).stationID = ASOSstruct(1).FurtherID;
    end
    
    %% Create output structures
    usefulMasterStruct.(stations{all}) = usefulStruct;
    ASOSmasterStruct.(stations{all}) = ASOSstruct;
    
    %Blank the variables that will be reused in the next loop, otherwise
    %data may be repeated in the output structures
    usefulStruct = struct([]); %#ok (complaining about the variable "not being used")
    ASOSstruct = struct([]); %#ok (complaining about the variable "not being used")
    wind = struct([]);
    variableWind = struct([]);
    
end

end
