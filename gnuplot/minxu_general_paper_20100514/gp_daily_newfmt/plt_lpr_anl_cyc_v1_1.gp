reset
set term postscript landscape enhanced color
set output 'fig_lpr_anl_cyc_v1_1.ps'
set size 1.0, 1.0

#set grid xtics ytics
#set xtics border rotate by 90 font "Courier-Bold, 11"

set xtics border font "Courier, 11"
set ytics border font "Courier, 11"

set termoption font "Times-Roman, 11"

set macros

FilNam1 = "'./data/annual-pr1.dat'"
FilNam2 = "'./data/annual-pr2.dat'"
FilNam3 = "'./data/annual-pr3.dat'"
FilNam4 = "'./data/annual-pr4.dat'"

Season = "DJF"

Xrange = "($0+1)"


#Styln0 = "w l lc 0 lw 2 lt 1"

#Styln1 = "w l lc 1 lw 2 lt 1"   # red
#Styln2 = "w l lc 2 lw 2 lt 1"   # green
#Styln3 = "w l lc 3 lw 2 lt 1"   # blue
#Styln4 = "w l lc 4 lw 2 lt 2"   # purple
#Styln5 = "w l lc 5 lw 2 lt 1"   # cyan
#
#Styln6 = "w l lc rgbcolor 'dark-green' lw 2 lt 1"
#Styln7 = "w l lc rgbcolor 'dark-cyan'  lw 2 lt 2"
#Styln8 = "w l lc rgbcolor 'dark-red'   lw 2 lt 2"
#Styln9 = "w l lc rgbcolor 'dark-blue'  lw 2 lt 2"

call 'styln.gp'

PosInt = "0"
#PosCol = "34 * PosInt"


set xrange [1:12]
set yrange [0:10]

yrang1 = "[1:12][0.1:8]"
yrang2 = "[1:12][0.1:8]"
yrang3 = "[1:12][0.1:8]"
yrang4 = "[1:12][0.1:8]"


set label 21 "Cascade" at screen 0.02, .775 left  font "Times-Roman, 12"
set label 22 "North Rockies" at screen 0.02, .525 left  font "Times-Roman, 12"
set label 23 "Central Great Plain" at screen 0.02, .275 left  font "Times-Roman, 12"
set label 24 "Midwest" at screen 0.02, .025 left  font "Times-Roman, 12"

set label 3 "Precipitation (mm/day)" \
            at screen -0.05, 0.5 rotate by 90 center font "Times-Roman, 18"
set label 4 "Calendar Month of 1993"  \
            at screen 0.5, -0.05 rotate by  0 center font "Times-Roman, 18"

set size 0.2, 0.25
set multiplot


set border 31 lw 0.2 lt -1
set object 1 rect from screen 0, screen 0 to screen 1, screen 1 behind fc rgb "white" fs empty border -1 lw 1.0

set format x ""
set format y ""

# RAD
# ----------------------------------------------------------------------
set tmargin 0
set bmargin 0
set rmargin 0
set lmargin 0

set label 1 "a) RA" at screen 0.0, 1.02 left font "Times-Roman, 12"


Titln0 = "ti 'OBS'"

Titln1 = "ti 'GSFC'"
Titln2 = "ti 'AER'"
Titln3 = "ti 'CAM'"
Titln4 = "ti 'CCCMA'"
Titln5 = "ti 'CAWCR'"
Titln6 = "ti 'FLG'"
Titln7 = "ti 'GFDL'"
Titln8 = "ti 'AvCL'"
Titln9 = "ti 'AEoff'"
Titln10= "ti 'NoCW'"

PosInt = "0"
PosCol = "0"
Posini = "0"
PosRad = "   using @Xrange:(column(10+@PosCol+@Posini)) @Titln10 @Styln10, \
          '' using @Xrange:(column(09+@PosCol+@Posini)) @Titln9 @Styln9, \
          '' using @Xrange:(column(08+@PosCol+@Posini)) @Titln8 @Styln8, \
          '' using @Xrange:(column(07+@PosCol+@Posini)) @Titln7 @Styln7, \
          '' using @Xrange:(column(06+@PosCol+@Posini)) @Titln6 @Styln6, \
          '' using @Xrange:(column(05+@PosCol+@Posini)) @Titln5 @Styln5, \
          '' using @Xrange:(column(04+@PosCol+@Posini)) @Titln4 @Styln4, \
          '' using @Xrange:(column(03+@PosCol+@Posini)) @Titln3 @Styln3, \
          '' using @Xrange:(column(02+@PosCol+@Posini)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)) @Titln1 @Styln1, \
          '' using @Xrange:(column(61+0      )) @Titln0 @Styln0  "

PosRad = "   using @Xrange:(column(10+@PosCol+@Posini)) @Titln10 @Styln9, \
          '' using @Xrange:(column(08+@PosCol+@Posini)) @Titln8 @Styln8, \
          '' using @Xrange:(column(07+@PosCol+@Posini)) @Titln7 @Styln7, \
          '' using @Xrange:(column(06+@PosCol+@Posini)) @Titln6 @Styln6, \
          '' using @Xrange:(column(05+@PosCol+@Posini)) @Titln5 @Styln5, \
          '' using @Xrange:(column(04+@PosCol+@Posini)) @Titln4 @Styln4, \
          '' using @Xrange:(column(03+@PosCol+@Posini)) @Titln3 @Styln3, \
          '' using @Xrange:(column(02+@PosCol+@Posini)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)) @Titln1 @Styln1, \
          '' using @Xrange:(column(61+0      )) @Titln0 @Styln0  "


set format y
set xtics nomirror 0, 2, 12
set ytics nomirror 0, 2, 8

set key off
PosInt = "0"
set origin 0.0, 0.75
plot @yrang1 @FilNam1 @PosRad

unset obj 1
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.0, 0.50
plot @yrang2 @FilNam2 @PosRad

set key off
PosInt = "0"
set origin 0.0, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
#set xtics nomirror 0, 2, 12
set xtics nomirror ("2" 2.0, "4" 4., "6" 6., "8" 8., "10" 10., "12" 12.)

PosInt = "0"
set origin 0.0, 0.00
plot @yrang4 @FilNam4 @PosRad
set format x ""
set format y ""
# ----------------------------------------------------------------------

# SFC
# ----------------------------------------------------------------------
Titln1 = "ti 'CSSP'"
Titln2 = "ti 'NOAH'"
Titln3 = "ti 'PX'"
Titln4 = "ti 'CWRF_W'"
Titln5 = "ti 'UOMoff'"
Titln6 = "ti 'ERI'"
Titln7 = "ti 'NARR'"
#Titln8 = "ti 'WRF/NOAH'"

PosInt = "0"
PosCol = "0"
PosIni = "10"
PosRad = "   using @Xrange:(column(07+@PosCol+@PosIni)) @Titln8 @Styln8, \
          '' using @Xrange:(column(06+@PosCol+@PosIni)) @Titln7 @Styln7, \
          '' using @Xrange:(column(05+@PosCol+@PosIni)) @Titln6 @Styln6, \
          '' using @Xrange:(column(04+@PosCol+@PosIni)) @Titln5 @Styln5, \
          '' using @Xrange:(column(03+@PosCol+@PosIni)) @Titln4 @Styln4, \
          '' using @Xrange:(column(02+@PosCol+@PosIni)) @Titln3 @Styln3, \
          '' using @Xrange:(column(01+@PosCol+@PosIni)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)) @Titln1 @Styln1, \
          '' using @Xrange:(column(61+0      )) @Titln0 @Styln0 "

PosRad = " \
             using @Xrange:(column(06+@PosCol+@PosIni)) @Titln7 @Styln7, \
          '' using @Xrange:(column(05+@PosCol+@PosIni)) @Titln6 @Styln6, \
          '' using @Xrange:(column(04+@PosCol+@PosIni)) @Titln5 @Styln5, \
          '' using @Xrange:(column(03+@PosCol+@PosIni)) @Titln4 @Styln4, \
          '' using @Xrange:(column(02+@PosCol+@PosIni)) @Titln3 @Styln3, \
          '' using @Xrange:(column(01+@PosCol+@PosIni)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)) @Titln1 @Styln1, \
          '' using @Xrange:(column(61+0      )) @Titln0 @Styln0 "
set rmargin 0
set lmargin 0

set label 1 "b) SF" at screen 0.2, 1.02 left font "Times-Roman, 12"

set xtics nomirror 0, 2, 12
set ytics nomirror 0, 2, 8
set key off
PosInt = "0"
set origin 0.2, 0.75
plot @yrang1 @FilNam1 @PosRad

set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.2, 0.50
plot @yrang2 @FilNam2 @PosRad

set key off
PosInt = "0"
set origin 0.2, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
#set xtics nomirror 0, 2, 12
set xtics nomirror ("2" 2.0, "4" 4., "6" 6., "8" 8., "10" 10., "12" 12.)

PosInt = "0"
set origin 0.2, 0.00
plot @yrang4 @FilNam4 @PosRad
set format x ""
set format y ""
# ----------------------------------------------------------------------

# PBL
# ----------------------------------------------------------------------
Titln1 = "ti 'CAM'"
Titln2 = "ti 'ACM'"
Titln3 = "ti 'BouLac'"
Titln4 = "ti 'GFS'"
Titln5 = "ti 'MYJ'"
Titln6 = "ti 'QNSE'"
Titln7 = "ti 'YSU'"
Titln8 = "ti 'UW'"
Titln9 = "ti 'OROoff'"

PosInt = "0"
PosCol = "0"
PosIni = "20"
PosRad = "   using @Xrange:(column(08+@PosCol+@PosIni)) @Titln9 @Styln9, \
          '' using @Xrange:(column(07+@PosCol+@PosIni)) @Titln8 @Styln8, \
          '' using @Xrange:(column(06+@PosCol+@PosIni)) @Titln7 @Styln7, \
          '' using @Xrange:(column(05+@PosCol+@PosIni)) @Titln6 @Styln6, \
          '' using @Xrange:(column(04+@PosCol+@PosIni)) @Titln5 @Styln5, \
          '' using @Xrange:(column(03+@PosCol+@PosIni)) @Titln4 @Styln4, \
          '' using @Xrange:(column(02+@PosCol+@PosIni)) @Titln3 @Styln3, \
          '' using @Xrange:(column(01+@PosCol+@PosIni)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)) @Titln1 @Styln1, \
          '' using @Xrange:(column(61+0      )) @Titln0 @Styln0 "

set rmargin 0
set lmargin 0
set label 1 "c) BL" at screen 0.4, 1.02 left font "Times-Roman, 12"

set xtics nomirror 0, 2, 12
set ytics nomirror 0, 2, 8
set key off
PosInt = "0"
set origin 0.4, 0.75
plot @yrang1 @FilNam1 @PosRad

set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.4, 0.50
plot @yrang2 @FilNam2 @PosRad

set key off
PosInt = "0"
set origin 0.4, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
#set xtics nomirror 0, 2, 12
set xtics nomirror ("2" 2.0, "4" 4., "6" 6., "8" 8., "10" 10., "12" 12.)

PosInt = "0"
set origin 0.4, 0.00
plot @yrang4 @FilNam4 @PosRad
set format x ""
set format y ""
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
Titln8 = "ti 'NKF'"
Titln9 = "ti 'SCoff'"
Titln10= "ti 'G3'"

PosInt = "0"
PosCol = "0"
PosIni = "30"
PosRad = "   using @Xrange:(column(09+@PosCol+@PosIni)) @Titln10 @Styln10, \
          '' using @Xrange:(column(08+@PosCol+@PosIni)) @Titln9 @Styln9, \
          '' using @Xrange:(column(07+@PosCol+@PosIni)) @Titln8 @Styln8, \
          '' using @Xrange:(column(06+@PosCol+@PosIni)) @Titln7 @Styln7, \
          '' using @Xrange:(column(05+@PosCol+@PosIni)) @Titln6 @Styln6, \
          '' using @Xrange:(column(04+@PosCol+@PosIni)) @Titln5 @Styln5, \
          '' using @Xrange:(column(03+@PosCol+@PosIni)) @Titln4 @Styln4, \
          '' using @Xrange:(column(02+@PosCol+@PosIni)) @Titln3 @Styln3, \
          '' using @Xrange:(column(01+@PosCol+@PosIni)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)) @Titln1 @Styln1, \
          '' using @Xrange:(column(61+0      )) @Titln0 @Styln0 "

PosRad = " \
             using @Xrange:(column(08+@PosCol+@PosIni)) @Titln9 @Styln9, \
          '' using @Xrange:(column(07+@PosCol+@PosIni)) @Titln8 @Styln8, \
          '' using @Xrange:(column(06+@PosCol+@PosIni)) @Titln7 @Styln7, \
          '' using @Xrange:(column(05+@PosCol+@PosIni)) @Titln6 @Styln6, \
          '' using @Xrange:(column(04+@PosCol+@PosIni)) @Titln5 @Styln5, \
          '' using @Xrange:(column(09+@PosCol+@PosIni)) @Titln10 @Styln4, \
          '' using @Xrange:(column(02+@PosCol+@PosIni)) @Titln3 @Styln3, \
          '' using @Xrange:(column(01+@PosCol+@PosIni)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)) @Titln1 @Styln1, \
          '' using @Xrange:(column(61+0      )) @Titln0 @Styln0 "


set rmargin 0
set lmargin 0
set label 1 "d) CU" at screen 0.6, 1.02 left font "Times-Roman, 12"

set xtics nomirror 0, 2, 12
set ytics nomirror 0, 2, 8
set key off
PosInt = "0"
set origin 0.6, 0.75
plot @yrang1 @FilNam1 @PosRad

set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.6, 0.50
plot @yrang2 @FilNam2 @PosRad

set key off
PosInt = "0"
set origin 0.6, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
#set xtics nomirror 0, 2, 12
set xtics nomirror ("2" 2.0, "4" 4., "6" 6., "8" 8., "10" 10., "12" 12.)

PosInt = "0"
set origin 0.6, 0.00
plot @yrang4 @FilNam4 @PosRad
set format x ""
set format y ""

# ----------------------------------------------------------------------

# CMP
# ----------------------------------------------------------------------
Titln1 = "ti 'Tao'"
Titln2 = "ti 'Lin'"
Titln3 = "ti 'Morrison'"
Titln4 = "ti 'Thompson'"
Titln5 = "ti 'WDM6'"
Titln6 = "ti 'WSM6'"
Titln7 = "ti 'WSM5'"
Titln8 = "ti 'Zhao'"

PosInt = "0"
PosCol = "0"
PosIni = "40"
PosRad = "   using @Xrange:(column(07+@PosCol+@PosIni)) @Titln8 @Styln8, \
          '' using @Xrange:(column(06+@PosCol+@PosIni)) @Titln7 @Styln7, \
          '' using @Xrange:(column(05+@PosCol+@PosIni)) @Titln6 @Styln6, \
          '' using @Xrange:(column(04+@PosCol+@PosIni)) @Titln5 @Styln5, \
          '' using @Xrange:(column(03+@PosCol+@PosIni)) @Titln4 @Styln4, \
          '' using @Xrange:(column(02+@PosCol+@PosIni)) @Titln3 @Styln3, \
          '' using @Xrange:(column(01+@PosCol+@PosIni)) @Titln2 @Styln2, \
          '' using @Xrange:(column(01+@PosCol)) @Titln1 @Styln1, \
          '' using @Xrange:(column(61+0      )) @Titln0 @Styln0 "

set rmargin 0
set lmargin 0
set label 1 "e) MP" at screen 0.8, 1.02 left font "Times-Roman, 12"

set xtics nomirror 0, 2, 12
set ytics nomirror 0, 2, 8
set key off
PosInt = "0"
set origin 0.8, 0.75
plot @yrang1 @FilNam1 @PosRad

set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.8, 0.50
plot @yrang2 @FilNam2 @PosRad

set key off
PosInt = "0"
set origin 0.8, 0.25
plot @yrang3 @FilNam3 @PosRad

set format x
#set xtics nomirror 0, 2, 12
set xtics nomirror ("2" 2.0, "4" 4., "6" 6., "8" 8., "10" 10., "12" 12.)

PosInt = "0"
set origin 0.8, 0.00
plot @yrang4 @FilNam4 @PosRad

set format x ""
set format y ""


unset multiplot
