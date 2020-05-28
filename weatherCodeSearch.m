%%weatherCodeSearch
    %Function to find dates and times that an input weather code occurred
    %in an ASOS data structure.
    %
    %General form: [dates,exactTimes,exactDatenums] = weatherCodeSearch(weatherCode,ASOS)
    %
    %Outputs:
    %dates: all dates where the input code was observed
    %exactTimes: the exact MATLAB datetimes where the input code was observed
    %   in DD-MMM-YYYY HH:mm:SS format (note seconds are placeholder zeros)
    %exactDatenums: same as exactTimes, but as MATLAB datenums (note that
    %seconds are placeholder zeros)
    %
    %Inputs:
    %weatherCode: an ASOS weather code string
    %   Precip codes: 'RA' = rain, 'SN' = snow, 'PL' = sleet, 'FZRA' =
    %   freezing rain, 'FZDZ' = freezing drizzle, 'DZ' = drizzle
    %   Obscuration codes: 'BR' = mist, 'FG' = fog, 'FU' = smoke, 'HZ' =
    %   haze
    %   Character codes: 'SQ' = squall
    %ASOS: an ASOS 5-minute data structure.
    %
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version Date: 5/27/2020
    %Last Major Revision: 5/27/2020
    %

function [dates,exactTimes,exactDatenums] = weatherCodeSearch(weatherCode,ASOS)
presentWeather = {ASOS.PresentWeather};

weather = strfind(presentWeather,weatherCode);
noWeather = cellfun('isempty',weather); %'isempty' is faster than @isempty
weather(noWeather) = {0}; %Insert 0 into all empty cells, otherwise conversion to double removes blank entries
weather = cell2mat(weather); %Convert to double
logicalWeather = logical(weather); %Logically index on ~0
%All logical 1 elements now correspond to where the weather code is detected
validInd = logicalWeather==1;

%Useful command window message if no weather codes were found
if isempty(nonzeros(validInd))==1
    dates = []; exactTimes = []; exactDatenums = []; %Null outputs
    msg = 'No instances of this weather code could be located.';
    disp(msg)
    return %End the function
end

%Extract times
validYear = [ASOS(validInd).Year]';
validMonth = [ASOS(validInd).Month]';
validDay = [ASOS(validInd).Day]';
validHour = [ASOS(validInd).Hour]';
validMinute = [ASOS(validInd).Minute]';
fakeSecond = zeros(length(validMinute),1); %Assume all seconds are zero entries

validDates = datenum(validYear,validMonth,validDay);
validDates = unique(validDates);
dates = datestr(validDates); %Output unique days where code occurred
exactDatenums = datenum(validYear,validMonth,validDay,validHour,validMinute,fakeSecond); %Output every datenum where the code occurred
exactTimes = datetime(exactDatenums,'ConvertFrom','datenum'); %Output every datetime where the code occurred
end