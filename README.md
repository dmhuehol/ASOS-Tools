# ASOS Tools
 Code for processing, visualizing, and analyzing Automated Surface Observations System (ASOS) data, particularly 5-minute ASOS data.  
 ## Workflow
 1. **ASOSdownloadFiveMin**(email,site,year,month,path) to download a file from the [NCDC FTP server](https://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/automated-surface-observing-system-asos) to the folder given by the path variable.  
 2. [primaryStruct,fullStruct] = **ASOSimportFiveMin**(fileloc) import the file at the location given by the fileloc string. Creates two structures: primaryStruct contains only the important fields, while fullStruct contains every field in the file.  
 3. [subsetStruct] = **surfacePlotter**(start_day,start_hour,end_day,end_hour,primaryStruct) plots the data in the structure created in step 2. This always plots a figure with timeseries for sea-level pressure, wind, temperature, dewpoint, and relative humidity with respect to water. If precipitation or fog occurs, it will also plot an abacus plot of precipitation type based on the present weather code.
 
 # Finding ASOS Stations
 There are many, many ASOS stations around the US, and finding the best one(s) for one's purposes can be difficult. The Federal Aviation Administration keeps [a zoomable map](https://www.faa.gov/air_traffic/weather/asos/) of ASOS/AWOS stations by state. Note that only ASOS 5-minute stations, denoted by gray placemarks on this map, are supported by the code in this repository. Additionally, some common ASOS stations used by our group are listed below.
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
 Unfortunately, ASOS documentation is scattered around several places and there is no one true "master" document.  
 [**ASOS User's Guide**](https://www.weather.gov/media/asos/aum-toc.pdf) is the NWS user's guide to understanding the sensors and algorithms behind the ASOS data. However, it does not fully explain the present weather codes.  
 [**NWS Surface Training**](https://web.archive.org/web/20170510212516/https://www.nws.noaa.gov/om/forms/resources/SFCTraining.pdf) is a NWS training guide originally created to help NWS personnel interpret METAR/SPECI weather observations, which are in a similar format to ASOS. This document includes many of the present weather codes found in ASOS, but not all of them.  
 [**Federal Meteorological Handbook**](https://www.ofcm.gov/publications/fmh/FMH1/FMH1.pdf) defines standards for reporting surface conditions, with Table 8-5 including all of the codes used by ASOS. However, as it is designed for meteorological observers, it doesn't discuss any of the science behind the ASOS observation strategies.  
 [**TD-6401**](https://www1.ncdc.noaa.gov/pub/data/documentlibrary/tddoc/td6401.pdf) is the official dataset documentation for the ASOS 5-minute data format. However, the information for the weather codes given here is outdated; the codes described in "weather and obstructions" do not correspond to the codes in actual data.

## Sources and Credit
------

All code and documentation, unless otherwise specified, written by Daniel Hueholt, under the advisement of Dr. Sandra Yuter at North Carolina State University.  
[<img src="http://www.environmentanalytics.com/wp-content/uploads/2016/05/cropped-Environment_Analytics_Logo_Draft.png">](http://www.environmentanalytics.com)  
**addaxis** written by [Harry Lee](https://www.mathworks.com/matlabcentral/profile/authors/863384-harry-lee), found on the [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis).  
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

**tlabel** written by [Carlos Adrian Vargas Aguilera](https://www.mathworks.com/matlabcentral/profile/authors/869698-carlos-adrian-vargas-aguilera), found on the [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/19314-tlabel-m-v2-6-1-sep-2009)  
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

**windbarb** written by [Laura Tomkins](https://github.com/lauratomkins/), found at the following [github link](https://github.com/lauratomkins/SBJ). Used by permission.
