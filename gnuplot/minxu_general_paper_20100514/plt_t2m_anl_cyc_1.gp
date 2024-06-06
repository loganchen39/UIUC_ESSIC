reset
set term postscript landscape enhanced color
set output 'fig_t2m_anl_cyc_1.ps'
set size 1.0, 1.0

#set grid xtics ytics
#set xtics border rotate by 90 font "Courier-Bold, 11"

set xtics border font "Courier-Bold, 11"

set termoption font "Times-Roman, 11"

set macros

FilNam1 = "'./data_xing/annual-t2m1.dat.conv'"
FilNam2 = "'./data_xing/annual-t2m2.dat.conv'"
FilNam3 = "'./data_xing/annual-t2m3.dat.conv'"
FilNam4 = "'./data_xing/annual-t2m4.dat.conv'"
FilNam5 = "'./data_xing/annual-t2m5.dat.conv'"
FilNam6 = "'./data_xing/annual-t2m6.dat.conv'"
FilNam7 = "'./data_xing/annual-t2m7.dat.conv'"
FilNam8 = "'./data_xing/annual-t2m8.dat.conv'"

Season = "DJF"

Xrange = "($0+1)"

Styln0 = "w l lc 0 lw 2 lt 1"

Styln1 = "w l lc 1 lw 2 lt 1"   # red
Styln2 = "w l lc 2 lw 2 lt 1"   # green
Styln3 = "w l lc 3 lw 2 lt 1"   # blue
Styln4 = "w l lc 4 lw 2 lt 1"   # purple
Styln5 = "w l lc 5 lw 2 lt 1"   # cyan

Styln6 = "w l lc rgbcolor 'dark-green' lw 2 lt 1"
Styln7 = "w l lc rgbcolor 'dark-cyan'  lw 2 lt 2"
Styln8 = "w l lc rgbcolor 'dark-red'   lw 2 lt 2"
Styln9 = "w l lc rgbcolor 'dark-blue'  lw 2 lt 2"


PosInt = "0"
#PosCol = "34 * PosInt"


set xrange [1:12]
set yrange [265:310]

#yrang1 = "[1:12][-7.9:18]"
#yrang2 = "[1:12][-7.9:16]"
#yrang3 = "[1:12][-7.9:30]"
#yrang4 = "[1:12][-7.9:30]"

yrang1 = "[1:12][-5:5]"
yrang2 = "[1:12][-5:5]"
yrang3 = "[1:12][-5:5]"
yrang4 = "[1:12][-5:5]"

set label 21 "Cascade" at screen 0.02, .775 left  font "Times-Roman, 12"
set label 22 "North Rockies" at screen 0.02, .525 left  font "Times-Roman, 12"
set label 23 "Central Great Plain" at screen 0.02, .275 left  font "Times-Roman, 12"
set label 24 "Midwest" at screen 0.02, .025 left  font "Times-Roman, 12"

set label 3 "Surface Air Temperature Bias (^oC)" \
            at screen -0.05, 0.5 rotate by 90 center font "Times-Roman, 18"
set label 4 "Calendar Month of 1993"  \
            at screen 0.5, -0.05 rotate by  0 center font "Times-Roman, 18"

set size 0.2, 0.25
set multiplot

set border 31 lw 0.2 lt -1
set object 1 rect from screen 0, screen 0 to screen 1, screen 1 behind fc rgb "white" fs empty border -1 lw 2.0

set format x ""
set format y ""

# RAD
# ----------------------------------------------------------------------
set tmargin 0
set bmargin 0
set rmargin 0
set lmargin 0

set label 1 "RAD" at screen 0.1, 1.02 center font "Times-Roman, 12"


Titln0 = "ti 'OBS'"
Titln1 = "ti 'GSFC'"
Titln2 = "ti 'AER'"
Titln3 = "ti 'CAM'"
Titln4 = "ti 'CCC'"
Titln5 = "ti 'CSIRO'"
Titln6 = "ti 'F-L'"
Titln7 = "ti 'GFDL'"
Titln8 = "ti 'AVG'"

PosInt = "0"
PosCol = "1"
PosRad = "   using @Xrange:(column(8+@PosCol)-column(1)) @Titln8 @Styln8, \
          '' using @Xrange:(column(7+@PosCol)-column(1)) @Titln7 @Styln7, \
          '' using @Xrange:(column(6+@PosCol)-column(1)) @Titln6 @Styln6, \
          '' using @Xrange:(column(5+@PosCol)-column(1)) @Titln5 @Styln5, \
          '' using @Xrange:(column(4+@PosCol)-column(1)) @Titln4 @Styln4, \
          '' using @Xrange:(column(3+@PosCol)-column(1)) @Titln3 @Styln3, \
          '' using @Xrange:(column(2+@PosCol)-column(1)) @Titln2 @Styln2, \
          '' using @Xrange:(column(1+@PosCol)-column(1)) @Titln1 @Styln1 "

set format y
set xtics nomirror 0, 2, 12 
set ytics nomirror -6, 2, 8
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.0, 0.75
plot @yrang1 @FilNam1 @PosRad
unset object 1

set key off
PosInt = "0"
set origin 0.0, 0.50
plot @yrang2 @FilNam2 @PosRad

PosInt = "0"
set origin 0.0, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
set xtics nomirror 0, 2, 12
PosInt = "0"
set origin 0.0, 0.00
plot @yrang4 @FilNam4 @PosRad

set format y ""
set format x ""
# ----------------------------------------------------------------------

# SFC
# ----------------------------------------------------------------------
Titln1 = "ti 'CSSP'"
Titln2 = "ti 'NOAH'"
Titln3 = "ti 'PX'"
Titln4 = "ti 'CSSPn'"
Titln5 = "ti 'ERI'"

PosInt = "0"
PosCol = "1"
PosRad = "   using @Xrange:(column(12+@PosCol)-column(1)) @Titln5 @Styln5, \
          '' using @Xrange:(column(11+@PosCol)-column(1)) @Titln4 @Styln4, \
          '' using @Xrange:(column(10+@PosCol)-column(1)) @Titln3 @Styln3, \
          '' using @Xrange:(column(09+@PosCol)-column(1)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)-column(1)) @Titln1 @Styln1 "

set rmargin 0
set lmargin 0

set label 1 "SFC" at screen 0.3, 1.02 center font "Times-Roman, 12"

set xtics nomirror 0, 2, 12 
set ytics nomirror -6, 2, 8
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.2, 0.75
plot @yrang1 @FilNam1 @PosRad

set key off
PosInt = "0"
set origin 0.2, 0.50
plot @yrang2 @FilNam2 @PosRad

PosInt = "0"
set origin 0.2, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
set xtics nomirror 0, 2, 12
PosInt = "0"
set origin 0.2, 0.00
plot @yrang4 @FilNam4 @PosRad

set format y ""
set format x ""
# ----------------------------------------------------------------------

# PBL
# ----------------------------------------------------------------------
Titln1 = "ti 'CAM'"
Titln2 = "ti 'ACM'"
Titln3 = "ti 'BouLAC'"
Titln4 = "ti 'GFS'"
Titln5 = "ti 'MYJ'"
Titln6 = "ti 'QNSE'"
Titln7 = "ti 'YSU'"
Titln8 = "ti 'UW'"
Titln9 = "ti 'OROoff'"

PosInt = "0"
PosCol = "1"
PosRad = "   using @Xrange:(column(20+@PosCol)-column(1)) @Titln9 @Styln9, \
          '' using @Xrange:(column(19+@PosCol)-column(1)) @Titln8 @Styln8, \
          '' using @Xrange:(column(18+@PosCol)-column(1)) @Titln7 @Styln7, \
          '' using @Xrange:(column(17+@PosCol)-column(1)) @Titln6 @Styln6, \
          '' using @Xrange:(column(16+@PosCol)-column(1)) @Titln5 @Styln5, \
          '' using @Xrange:(column(15+@PosCol)-column(1)) @Titln4 @Styln4, \
          '' using @Xrange:(column(14+@PosCol)-column(1)) @Titln3 @Styln3, \
          '' using @Xrange:(column(13+@PosCol)-column(1)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)-column(1)) @Titln1 @Styln1 "

set rmargin 0
set lmargin 0
set label 1 "PBL" at screen 0.5, 1.02 center font "Times-Roman, 12"

set xtics nomirror 0, 2, 12 
set ytics nomirror -6, 2, 8
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.4, 0.75
plot @yrang1 @FilNam1 @PosRad

set key off
PosInt = "0"
set origin 0.4, 0.50
plot @yrang2 @FilNam2 @PosRad

PosInt = "0"
set origin 0.4, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
set xtics nomirror 0, 2, 12
PosInt = "0"
set origin 0.4, 0.00
plot @yrang4 @FilNam4 @PosRad

set format y ""
set format x ""
# ----------------------------------------------------------------------

# CUP
# ----------------------------------------------------------------------
Titln1 = "ti 'ECP'"
Titln2 = "ti 'BMJ'"
Titln3 = "ti 'CSU'"
Titln4 = "ti 'GD'"
Titln5 = "ti 'GFDL'"
Titln6 = "ti 'MIT'"
Titln7 = "ti 'ZML'"

PosInt = "0"
PosCol = "1"
PosRad = "   using @Xrange:(column(26+@PosCol)-column(1)) @Titln7 @Styln7, \
          '' using @Xrange:(column(25+@PosCol)-column(1)) @Titln6 @Styln6, \
          '' using @Xrange:(column(24+@PosCol)-column(1)) @Titln5 @Styln5, \
          '' using @Xrange:(column(23+@PosCol)-column(1)) @Titln4 @Styln4, \
          '' using @Xrange:(column(22+@PosCol)-column(1)) @Titln3 @Styln3, \
          '' using @Xrange:(column(21+@PosCol)-column(1)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)-column(1)) @Titln1 @Styln1 "

set rmargin 0
set lmargin 0
set label 1 "CUP" at screen 0.7, 1.02 center font "Times-Roman, 12"

set xtics nomirror 0, 2, 12 
set ytics nomirror -6, 2, 8
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.6, 0.75
plot @yrang1 @FilNam1 @PosRad

set key off
PosInt = "0"
set origin 0.6, 0.50
plot @yrang2 @FilNam2 @PosRad

PosInt = "0"
set origin 0.6, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
set xtics nomirror 0, 2, 12
PosInt = "0"
set origin 0.6, 0.00
plot @yrang4 @FilNam4 @PosRad

set format y ""
set format x ""
# ----------------------------------------------------------------------

# CMP
# ----------------------------------------------------------------------
Titln1 = "ti 'Thompson'"
Titln2 = "ti 'Lin'"
Titln3 = "ti 'Morrison'"
Titln4 = "ti 'Tao'"
Titln5 = "ti 'WDM6'"
Titln6 = "ti 'WSM6'"
Titln7 = "ti 'WSM5'"
Titln8 = "ti 'Zhao'"

PosInt = "0"
PosCol = "1"
PosRad = "   using @Xrange:(column(33+@PosCol)-column(1)) @Titln8 @Styln8, \
          '' using @Xrange:(column(32+@PosCol)-column(1)) @Titln7 @Styln7, \
          '' using @Xrange:(column(31+@PosCol)-column(1)) @Titln6 @Styln6, \
          '' using @Xrange:(column(30+@PosCol)-column(1)) @Titln5 @Styln5, \
          '' using @Xrange:(column(29+@PosCol)-column(1)) @Titln4 @Styln4, \
          '' using @Xrange:(column(28+@PosCol)-column(1)) @Titln3 @Styln3, \
          '' using @Xrange:(column(27+@PosCol)-column(1)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)-column(1)) @Titln1 @Styln1 "

set rmargin 0
set lmargin 0
set label 1 "CMP" at screen 0.9, 1.02 center font "Times-Roman, 12"

set xtics nomirror 0, 2, 12 
set ytics nomirror -6, 2, 8
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.8, 0.75
plot @yrang1 @FilNam1 @PosRad

set key off
PosInt = "0"
set origin 0.8, 0.50
plot @yrang2 @FilNam2 @PosRad

PosInt = "0"
set origin 0.8, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
set xtics nomirror 0, 2, 12
PosInt = "0"
set origin 0.8, 0.00
plot @yrang4 @FilNam4 @PosRad

set format y ""
set format x ""

unset multiplot
