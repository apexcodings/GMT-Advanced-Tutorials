#!/bin/bash

# Purpose:	Automatic map of last 7 days of world-wide seismicity

#
ctr="-Xc -Yc"

for i in 1
do
	fig[i]="Figures/GMT_example11-${i}.ps"
done
gmt set FONT_ANNOT_PRIMARY 10p FONT_TITLE 18p FORMAT_GEO_MAP ddd:mm:ssF

# Get the data (-q quietly) from USGS using the wget (comment out in case
# your system does not have wget or curl)

#wget http://neic.usgs.gov/neis/gis/bulletin.asc -q -O Data/neic_quakes.d
#curl http://neic.usgs.gov/neis/gis/bulletin.asc -s > Data/neic_quakes.d

# Count the number of events (to be used in title later. one less due to header)
n=`cat Data/neic_quakes.d | wc -l`
n=`expr $n - 1`

# Pull out the first and last timestamp to use in legend title
first=`sed -n 2p Data/neic_quakes.d | awk -F, '{printf "%s %s\n", $1, $2}'` #sed print the 2nd line
last=`sed -n '$p' Data/neic_quakes.d | awk -F, '{printf "%s %s\n", $1, $2}'` #sed print the last line
# Assign a string that contains the current user @ the current computer node.
# Note that two @@ is needed to print a single @ in gmt pstext:


# Start plotting. First lay down map, then plot quakes with size = magintude/50":

gmt pscoast -Rg -JK180/9i -B45g30 -B+t"World-wide earthquake activity" -Gchocolate -Slightblue \
	-Dc -A1000 -Y2.75i -K > ${fig[1]}
awk -F, '{ print $4, $3, $6, $5*0.02}' Data/neic_quakes.d \
	| gmt psxy -R -JK -O  -CCPTs/quakes.cpt -Sci -Wthin -h -K >> ${fig[1]}
# Create legend input file for NEIS quake plot

cat > neis.legend << END
H 16 1 $n events during $first to $last
D 0 1p
N 3
V 0 1p
S 0.1i c 0.1i red 0.25p 0.2i Shallow depth (0-100 km)
S 0.1i c 0.1i green 0.25p 0.2i Intermediate depth (100-300 km)
S 0.1i c 0.1i blue 0.25p 0.2i Very deep (> 300 km)
D 0 1p
V 0 1p
N 7
V 0 1p
S 0.1i c 0.06i - 0.25p 0.3i M 3
S 0.1i c 0.08i - 0.25p 0.3i M 4
S 0.1i c 0.10i - 0.25p 0.3i M 5
S 0.1i c 0.12i - 0.25p 0.3i M 6
S 0.1i c 0.14i - 0.25p 0.3i M 7
S 0.1i c 0.16i - 0.25p 0.3i M 8
S 0.1i c 0.18i - 0.25p 0.3i M 9
D 0 1p
V 0 1p
N 1
END

# Put together a reasonable legend text, and add logo and user's name:

cat << END >> neis.legend
G 0.25l
P
T USGS/NEIS most recent earthquakes for the last seven days.  The data were
T obtained automatically from the USGS Earthquake Hazards Program page at
T @_http://neic/usgs.gov @_.  Interested users may also receive email alerts
T from the USGS.
T This script can be called daily to update the latest information.
G 0.4i
G -0.3i
L 12 6 LB 
END

# OK, now we can actually run gmt pslegend.  We center the legend below the map.
# Trial and error shows that 1.7i is a good legend height:

gmt pslegend -DJBC+o0/0.4i+w7i/1.7i -R -J -O -F+p+glightyellow neis.legend  >> ${fig[1]}

# Clean up after ourselves:

rm -f neis.* gmt.conf

gv ${fig[1]}