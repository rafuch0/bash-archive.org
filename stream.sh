#!/bin/bash

fblack=$(tput setaf 0);
fred=$(tput setaf 1);
fgreen=$(tput setaf 2);
fyellow=$(tput setaf 3);
fblue=$(tput setaf 4);
fmagenta=$(tput setaf 5);
fcyan=$(tput setaf 6);
fwhite=$(tput setaf 7);
bblack=$(tput setab 0);
bred=$(tput setab 1);
bgreen=$(tput setab 2);
byellow=$(tput setab 3);
bblue=$(tput setab 4);
bmagenta=$(tput setab 5);
bcyan=$(tput setab 6);
bwhite=$(tput setab 7);
fbunderline=$(tput smul);
fbreset=$(tput sgr0)

rm all.m3u stream.m3u results.csv 2> /dev/null

wget -q "http://www.archive.org/advancedsearch.php?q=%28${1}%29+AND+%28format%3Amp3+OR+mediatype%3Aaudio%29&fl%5B%5D=identifier&fl%5B%5D=title&fl%5B%5D=subject&sort%5B%5D=identifier+asc&sort%5B%5D=&sort%5B%5D=&rows=100000&page=1&save=yes&output=csv" -O - | tail -n +2 | sed s/\"//g > results.csv

while IFS=, read -r id title subject; do
	printf '%40s - %-40s %80s\n' "${fbunderline}${fwhite}${id}" "${fyellow}${title}${fbreset}" "${fcyan}${subject}"
done < results.csv

echo -ne "${fbreset}\nTotal Record(s): $(grep -c . results.csv)\nCompile? (enter)\n"
read

while IFS=, read -r id title subject; do
	echo -ne "\n${fbreset}\nFetching ${fbunderline}${id} - ${title}${fbreset}:\n \t${fyellow}http://www.archive.org/details/${id}\n \thttp://www.archive.org/stream/${id}\n \thttp://www.archive.org/compress/${id}${fbreset}"
	echo -ne "\nAdding Track(s):${fyellow}\n"
	wget -q http://www.archive.org/stream/${id} -O - | sort -t_ -k2 -g | tee --append all.m3u | sed s/^/\\t/
done < results.csv

echo "***************${1}***************" > stream.m3u
grep -i -v "vbr" all.m3u | grep -i -v "64kb" | grep -i -v "Malformed" >> stream.m3u
grep -i "vbr" all.m3u >> stream.m3u
grep -i "64kb" all.m3u >> stream.m3u

#echo -ne "${fbreset}\nTotal Record(s): $(grep -c . results.csv)\nPlay? (enter)\n"
#read

#xmms -e stream.m3u

echo -ne "${fbreset}\nTotal Record(s): $(grep -c . results.csv)\nTotal Track(s):  $(( $(grep -c . stream.m3u) - 1 ))\n"

rm all.m3u stream.m3u results.csv 2> /dev/null
