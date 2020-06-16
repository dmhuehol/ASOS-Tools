%%weatherCodeSearch
    %Function to find dates and times that input weather code(s) occurred
    %in an ASOS data structure.
    %
    %Requires MATLAB 2017a+ (uses contains function).
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
    %weatherCode: an ASOS weather code string or string array. Some common
    %codes are given below. See documentation on GitHub for complete table
    %of precipitation codes.
    %   Precip codes: 'RA' = rain, 'SN' = snow, 'PL' = sleet, 'FZRA' =
    %   freezing rain, 'FZDZ' = freezing drizzle, 'DZ' = drizzle
    %   Obscuration codes: 'BR' = mist, 'FG' = fog, 'FU' = smoke, 'HZ' =
    %   haze
    %   Character codes: 'SQ' = squall
    %   Multiple codes can be input as string arrays: i.e. ["RA","SN"] will
    %   return times with either rain or snow
    %ASOS: an ASOS 5-minute data structure.
    %
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version Date: 6/16/2020
    %Last Major Revision: 6/16/2020
    %

function [dates,exactTimes,exactDatenums] = weatherCodeSearch(weatherCode,ASOS)
presentWeather = {ASOS.PresentWeather};

weather = contains(presentWeather,weatherCode);
%All logical 1 elements now correspond to indices of weather code(s)

%Display command window message if no weather codes were found
if isempty(nonzeros(weather))==1
    dates = []; exactTimes = []; exactDatenums = []; %Null outputs
    msg = 'No instances of this weather code could be located.';
    disp(msg)
    return %End the function
end

%Extract times
validYear = [ASOS(weather).Year]';
validMonth = [ASOS(weather).Month]';
validDay = [ASOS(weather).Day]';
validHour = [ASOS(weather).Hour]';
validMinute = [ASOS(weather).Minute]';
fakeSecond = zeros(length(validMinute),1); %Add a fake seconds field (required for datetimes)

validDates = datenum(validYear,validMonth,validDay);
validDates = unique(validDates);
dates = datestr(validDates); %Output unique days with code(s)
exactDatenums = datenum(validYear,validMonth,validDay,validHour,validMinute,fakeSecond); %Output every datenum with code(s)
exactTimes = datetime(exactDatenums,'ConvertFrom','datenum'); %Output every datetime with code(s)
end