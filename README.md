# ASOS Tools
 Code for processing, visualizing, and analyzing 5-minute Automated Surface Observations System (ASOS) data. Requires MATLAB 2017a+. Please note that many external links in this documentation are broken as of 1/2023.
 
 ## Table of Contents
* [**Workflow for individual files**](#workflow-for-individual-files)  
* [**Example images**](#example-images)  
    * [Code to replicate example images](#code-to-replicate-example-images) 
* [**Workflow for multiple files**](#workflow-for-multiple-files)
    * [Example for multiple files](#example-for-multiple-files)
* [**Searching for weather codes**](#searching-for-weather-codes)
* [**Extracting storms from ASOS data**](#extracting-storms-from-asos-data)
    * [Workflow for identifying storms corresponding to the NEUS archive](#workflow-for-identifying-storms-corresponding-to-the-neus-archive)
* [**Exploring very large ASOS structures**](#exploring-very-large-asos-structures)
* [**Finding ASOS stations**](#finding-asos-stations)  
    * [List of common ASOS stations](#list-of-common-asos-stations)  
        * [Long Island area](#long-island-area)  
        * [Northeast US](#northeast-us)  
        * [Selected co-located ASOS and radiosonde launch sites](#selected-co-located-asos-and-radiosonde-launch-sites)  
        * [Front Range](#front-range)  
        * [Utah](#utah)        
* [**ASOS documentation**](#asos-documentation)  
* [**Table of common weather codes**](#table-of-common-weather-codes)
* [**Resolving common problems**](#resolving-problems)
    * [I downloaded data, then cleared my workspace/closed MATLAB and lost all the filenames!](#i-downloaded-data-then-cleared-my-workspaceclosed-matlab-and-lost-all-the-filenames)  
    * [Connection/FTP errors when running ASOSdownloadFiveMin](#error-using-connect-error-in-ftp-when-running-asosdownloadfivemin)
    * [Why isn't precipitation amount included in the output structure?](#why-isnt-precipitation-amount-included-in-the-output-structure)
* [**Sources and Credit**](#sources-and-credit)
 
 ## Workflow for individual files
 1. `[downloadedFilenames] = ASOSdownloadFiveMin(email,site,year,month,downloadToPath)` downloads a file from the [NCEI FTP server](https://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/automated-surface-observing-system-asos) to the folder given by the `downloadToPath` variable. Make sure to include a trailing slash in the path. The location of the file(s) downloaded is output as a cell array. This cell array of filenames is also saved to the same directory as the data, so it can be easily accessed after the workspace is cleared without requiring the download command to be rerun.  
 2. `[primaryStruct,fullStruct] = ASOSimportFiveMin(dataFile)` imports the file at the location given by the `dataFile` string. Creates two structures: `primaryStruct` contains only the important fields, while `fullStruct` contains every field in the file.  
 3. `[subsetStruct] = surfacePlotter(startDatetime,endDatetime,primaryStruct)` plots data in the structure created in step 2.
 
 ## Example images
 The `surfacePlotter` generates two types of figures. The first, which is always produced, is a timeseries for sea-level pressure, temperature, dewpoint, relative humidity with respect to water, wind, and wind character. The example shown below is drawn from a winter storm in Raleigh, NC on December 9, 2018.  
![Example surface plot](images/ex_surface_raleigh_20181209.png)
The second type of figure is an abacus plot that displays precipitation type, as well as the presence of fog and mist. This plot is only generated when precipitation, fog, or mist occurs within the requested timespan. The example below corresponds to the same winter storm as the surface plot.  
![Example abacus plot](images/ex_abacus_raleigh_20181209.png)

### Code to replicate example images
1. `[downloadedFilenames] = ASOSdownloadFiveMin(emailAddress,'KRDU',2018,12,downloadToPath)`
    * `emailAddress` must be input as a string, e.g. ('stuff(at)that_place.edu' not stuff(at)that_place.edu)
    * `downloadToPath` variable requires a trailing slash, e.g. ('/Users/username/Downloads/' not '/Users/username/Downloads')
2. `[krdu_1218,~] = ASOSimportFiveMin(downloadedFilenames{1})`
3. `startDatetime = datetime(2018,12,9,9,0,0);` `endDatetime = datetime(2018,12,9,22,0,0);`
4. `[winterStormEx] = surfacePlotter(startDatetime,endDatetime,krdu_1218)`

## Workflow for multiple files
1. `[downloadedFilenames] = ASOSdownloadFiveMin(email,site,year,month,downloadToPath)` downloads files to the folder given by the `downloadToPath` variable. To download multiple sites, input them as a cell array. Multiple years or months can be input as arrays. The output downloadedFilenames contains all of the downloaded filenames in a 3-dimensional cell array, where D1 represents years, D2 is stations, and D3 corresponds to months.
2. `[primaryCompositeStruct,fullCompositeStruct] = ASOSimportManyFiveMin(downloadedFilenames,stationList)` imports the files at downloadedFilenames corresponding to the stations input as a cell array in stationList.  
The composite structures contain substructures corresponding to each station, accessible with dot notation. The other functions like `surfacePlotter` and `weatherCodeSearch` can be used on the substructures inside of the composite.  

### Example for multiple files
This example downloads and imports all data from March through May for the years 2017-2019 at stations KISP, KHWV, and KFRG, then plots data from 1200-1500 24 March 2018.
1. `[downloadedFilenames] = ASOSdownloadFiveMin(email,{'KISP','KHWV','KFRG'},2017:2019,3:5,downloadToPath)`
2. `[pComposite,fComposite] = ASOSimportManyFiveMin(downloadedFilenames,{'KISP','KHWV','KFRG'})`
3. `startDatetime = datetime(2018,3,24,12,0,0);` `endDatetime = datetime(2018,3,24,15,0,0)`
4. `[subset] = surfacePlotter(startDatetime,endDatetime,pComposite.KHWV)`

## Searching for weather codes
A month of ASOS data usually contains 8000-9000 observations. It's often useful to be able to search these structures for a given weather code. `weatherCodeSearch` outputs a list of times corresponding to all observations of a given weather code. For example, to locate all times where ice pellets were detected in the krdu_1218 structure from the example above, use the following command.  
```[dates,exactTimes,exactDatenums] = weatherCodeSearch('PL',krdu_1218)```  
`dates` contains strings of all the days where the input codes occurred  
`exactTimes` stores the exact dates and times of all observations as MATLAB datetimes  
`exactDatenums` stores the exact dates and times of all observations as MATLAB datenums  
Note that `weatherCodeSearch` does work on the composite structures created by `ASOSimportManyFiveMin`. For example, for the composite structure `pComposite` in the example for multiple files, use the following command to find snow observations from KISP in the structure.  
```[dates,exactTimes,exactDatenums] = weatherCodeSearch('SN',pComposite.KISP)```  
You can also use `weatherCodeSearch` to search for multiple codes at once by inputting codes as an array of strings. For example, to search the `krdu_1218` structure for all times with either rain or snow, use the following command.  
```[dates,exactTimes,exactDatenums] = weatherCodeSearch(["SN","RA"],krdu_1218)```

## Extracting storms from ASOS data
`stormFinder` is designed to extract the start time, end time, and the hour of peak intensity (for storms of sufficient duration) for all storms within a structure of ASOS data. This is particularly useful when run on multiple seasons of data. The start time is the time of the first precipitation code detected. The end time is the time of the last precipitation code before a gap greater than 2 hours.  
ASOS 5-minute data does not include rain measurement or snow water equivalent. Thus, the peak intensity is approximated using the weather codes. The ASOS weather codes include a +/- signifier for heavy/light precipitation. We assign the different weather codes a numerical intensity score based on this signifier, and sum this score by hour while a storm is happening. The hour with the highest intensity score is designated the hour of peak precipitation intensity. This metric is untested, but should correspond qualitatively to the period of peak precipitation intensity at the surface.  
The following example shows how to identify storms in the `krdu_1218` structure.  
```[storms] = stormFinder(krdu_1218)```  
The storms structure contains two substructures. One is named `all`, which contains all storms identified. The other is named `filtered`, and restricts the storms to those with an intensity score above 15. This removes trace events. Hours of peak intensity are only calculated for the storms in the filtered substructure.

### Workflow for identifying storms corresponding to the NEUS archive
Environment Analytics has an archive of [100+ significant winter storms in the northeastern US](http://www.environmentanalytics.com/neus/). This archive was created as part of Nicole Hoban's master's thesis in 2016, with Spencer Rhodes, Dr. Sandra Yuter, and Michael Tai Bryant also participating in the creation of this webpage. This example shows how to identify storms at KLGA corresponding to these events. The storms do not perfectly match up--some storms in the archive miss KLGA, the surface air may be too dry for precipitation to reach the surface, ASOS stations occasionally lose power, etc. Overall, though, the correspondence is quite good.
1. `[downloadedFilenames] = ASOSdownloadFiveMin(email,{'KLGA'},2001:2016,[1,2,3,11,12],downloadToPath)`
2. `[pLGA_neusArchive,~] = ASOSimportManyFiveMin(downloadedFilenames,{'KLGA'})`
3. `[storms] = stormFinder(pLGA_neusArchive.KLGA)`

## Exploring very large ASOS structures
Structures containing several months of data can be a challenge to explore, particularly on older computers where MATLAB struggles to display large structures in the workspace. `extract500Ind` outputs a useful subset of the structure consisting of 500 indices after an input datetime. The following example demonstrates extracting a subset of interest from the pLGA_neusArchive structure (described above) corresponding to February 16, 2013.  
1. `[dtExtract] = datetime(2013,2,16,0,0,0)`
2. `[subset] = extract500Ind(dtExtract,pLGA_neusArchive.KLGA)`
 
 # Finding ASOS Stations
 There are many, many ASOS stations around the US, and finding the best one(s) for one's purposes can be difficult. The Federal Aviation Administration keeps [a zoomable map](https://www.faa.gov/air_traffic/weather/asos/) of ASOS/AWOS stations by state. Note that only ASOS 5-minute stations, denoted by gray placemarks on this map, are supported by the code in this repository. Some common ASOS stations used by our Environment Analytics group are listed below.
 ### List of Common ASOS Stations
 ----
 #### Long Island area
KISP: Islip, closest to Stony Brook University  
KHWV: Brookhaven  
KFRG: Farmingdale  
KFOK: Westhampton  
KFJK: JFK airport  
KLGA: La Guardia  
KEWR: Newark  
KTEB: Teterboro 
![Long Island area ASOS stations](images/long_island_area_ASOS.jpg)
#### Northeast US
Connecticut: KHVN KBDR KGON  
New Jersey: KVAY KTTN KCDW KSMQ KACY  
New York: KHPN KFWN KPOU KMGJ  
Rhode Island: KWST  
![Northeast US area ASOS stations](images/northeast_area_ASOS.jpg)
#### Selected co-located ASOS and radiosonde launch sites
KGSO/GSO: Greensboro, NC  
KFFC/FFC: Peachtree City, GA  
KALB/ALB: Albany, NY  
KDET/DTX: Detroit/White Lake, MI  
KCAR/CAR: Caribou, ME  
KHQM/UIL: Quillayute, WA  
KBIS/BIS: Bismarck, ND  
#### Front Range
KAPA: Denver - Centennial, CO  
KDEN: Denver, CO  
KCYS: Cheyenne, WY  
KLAR: Laramie, WY
#### Utah
KLGU: Logan  
KOGD: Ogden  
KSLC: Salt Lake City, closest to Alta  
 
 # ASOS Documentation
 Sadly, ASOS documentation is scattered around several places and there is no one true "master" document.  
 [**ASOS User's Guide**](https://www.weather.gov/media/asos/aum-toc.pdf) is the NWS user's guide to understanding the sensors and algorithms behind the ASOS data. However, it does not fully explain the present weather codes. NOTE THAT MUCH OF THE INFORMATION IN THIS USER'S GUIDE IS NO LONGER ACCURATE. For example, it states only one weather code is detected at a time, when the data files clearly show up to four weather codes can be reported at once. Unfortunately, this is still the most current official documentation provided, despite being last updated in 1998. There is no word on whether or when NCEI will provide more current documentation.  
 [**NWS Surface Training**](https://web.archive.org/web/20170510212516/https://www.nws.noaa.gov/om/forms/resources/SFCTraining.pdf) is a NWS training guide originally created to help NWS personnel interpret METAR/SPECI weather observations, which are in a similar format to ASOS. This document includes many of the present weather codes found in ASOS, but not all of them.  
 [**Federal Meteorological Handbook**](https://www.icams-portal.gov/publications/fmh/FMH1/FMH1.pdf) defines standards for reporting surface conditions, with Table 8-5 including all of the codes used by ASOS. However, as it is designed for meteorological observers, it doesn't discuss any of the science behind the ASOS observation strategies.  
 [**TD-6401**](https://www.ncei.noaa.gov/pub/data/asos-fivemin/td6401b.txt) is the official dataset documentation for the ASOS 5-minute data format. However, the information for the weather codes given here is outdated; the codes described in "weather and obstructions" do not correspond to the codes in actual data.  
 These links active as of 1/6/2022.
 
 # Table of common weather codes
| Weather code | Weather type | Code class |
| ------------ | ------------ | ---------- |
| BLSN         | Blowing snow | Unknown
| BR           | Mist         | Obscuration|
| DZ           | Drizzle      | Precip     |
| FG           | Fog          | Obscuration|
| FZDZ         | Freezing drizzle| Precip  |
| FZFG         | Freezing fog | Obscuration|
| FZRA         | Freezing rain| Precip     |
| GR           | Hail         | Precip     |
| GS           | Graupel      | Precip     |
| HZ           | Haze         | Obscuration|
| IC           | Ice crystals | Precip     |
| PL           | Ice pellets (sleet)|Precip|
| RA           | Rain         | Precip     |
| SG           | Graupel      | Precip     |
| SN           | Snow         | Precip     |
| TS           | Thunderstorm | Other      |
| UP           | Unknown precipitation|Precip|

| Modifiers    | Description  | Code class |
| ------------ | ------------ | ---------- |
| -            | Light precip | Precip intensity |
| +            | Heavy precip | Precip intensity |
 
# Resolving problems
### I downloaded data, then cleared my workspace/closed MATLAB and lost all the filenames!
The cell array of filenames that's output to the workspace is saved as a .mat file to the same directory as the ASOS data. Navigate to the directory in MATLAB's file viewer and open it manually, or use the MATLAB ```load``` function. The filename is saved with the naming convention "downloadedFilenames_requested_yyyymmdd_HHMMSS" where the time of the filename corresponds to the time the save command ran within the function.
### Error using connect, error in ftp when running ASOSdownloadFiveMin
This tends to happen when one makes a large number of requests in a very short span of time. Try waiting a few minutes and running the function again. If the problem persists, it is likely a temporary problem or maintenance on the NCEI server. Wait 24 hours and try again.
### Why isn't precipitation amount included in the output structure?
Unfortunately, ASOS 5-minute data only records precipitation type and intensity. It DOES NOT record precipitation amount. This is not because of the import code--there simply isn't a precipitation amount field to import! ASOS 1-minute and 1-hour data include precipitation amount, but this data is in a different format which does not interface with this codebase.

## Sources and Credit

Unless otherwise specified, code and documentation are written and maintained by Daniel Hueholt under the advisement of Dr. Sandra Yuter at North Carolina State University.  
[<img src="http://www.environmentanalytics.com/wp-content/uploads/2016/05/cropped-Environment_Analytics_Logo_Draft.png">](http://www.environmentanalytics.com)  
`addaxis` written by [Harry Lee](https://www.mathworks.com/matlabcentral/profile/authors/863384-harry-lee), found on the [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis).  
Copyright (c) 2016, Harry Lee
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  

`tlabel` written by [Carlos Adrian Vargas Aguilera](https://www.mathworks.com/matlabcentral/profile/authors/869698-carlos-adrian-vargas-aguilera), found on the [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/19314-tlabel-m-v2-6-1-sep-2009)  
Copyright (c) 2008,2009, Carlos Adrian Vargas Aguilera
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  

`windbarb` written by [Laura Tomkins](https://github.com/lauratomkins/), found at the following [github link](https://github.com/lauratomkins/SBJ). Used by permission.

The Okabe-Ito colorblind-safe discrete color scale is used for line colors.  
**Okabe, M., and K. Ito. 2008.** “Color Universal Design (CUD): How to Make Figures and Presentations That Are Friendly to Colorblind People.” http://jfly.iam.u-tokyo.ac.jp/color/.
