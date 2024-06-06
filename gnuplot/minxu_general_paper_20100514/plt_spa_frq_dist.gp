reset
set term postscript landscape enhanced color solid
set output 'fig_spa_frq_dist.ps'
set size 1.0, 1.0

#set grid xtics ytics
#set xtics border rotate by 90 font "Courier-Bold, 11"

set xtics border font "Courier-Bold, 11"

set termoption font "Times-Roman, 11"

set macros

FilNam = "'./data_xing/land-corr-t2m.dat.conv'"

Season = "DJF"

Xrange = "(0.5+$0*0.01)"


Titln1 = "ti 'GSFC'"
Titln2 = "ti 'AER'"
Titln3 = "ti 'CAM'"
Titln4 = "ti 'CCC'"
Titln5 = "ti 'CSIRO'"
Titln6 = "ti 'F-L'"
Titln7 = "ti 'GFDL'"
Titln8 = "ti 'AVG'"

Styln1 = "w l lc 0 lw 2" 
Styln2 = "w l lc 1 lw 2" 
Styln3 = "w l lc 2 lw 2" 
Styln4 = "w l lc 3 lw 2" 
Styln5 = "w l lc 4 lw 2" 
Styln6 = "w l lc 5 lw 2" 
Styln7 = "w l lc 6 lw 2" 
Styln8 = "w l lc rgbcolor 'grey' lw 2" 
Styln9 = "w l lc rgbcolor 'gold' lw 2" 

PosInt = "0"
PosCol = "34 * @PosInt"

PosRad = "   using @Xrange:(column(1+@PosCol)*100) @Titln1 @Styln1, \
          '' using @Xrange:(column(2+@PosCol)*100) @Titln2 @Styln2, \
          '' using @Xrange:(column(3+@PosCol)*100) @Titln3 @Styln3, \
          '' using @Xrange:(column(4+@PosCol)*100) @Titln4 @Styln4, \
          '' using @Xrange:(column(5+@PosCol)*100) @Titln5 @Styln5, \
          '' using @Xrange:(column(6+@PosCol)*100) @Titln6 @Styln6, \
          '' using @Xrange:(column(7+@PosCol)*100) @Titln7 @Styln7, \
          '' using @Xrange:(column(8+@PosCol)*100) @Titln8 @Styln8  "

set xrange [0.5:1]
set yrange [0:20]

set label 3 "Frquency (%)" at screen -0.05, 0.5 rotate by 90 center font "Times-Roman, 12"
set label 4 "Correlation"  at screen 0.5, -0.05 rotate by  0 center font "Times-Roman, 12"

set size 0.2, 0.25
set multiplot


# RAD
# ----------------------------------------------------------------------
set tmargin 0
set bmargin 0
set rmargin 0
set lmargin 0

set label 1 "RAD" at screen 0.1, 1.02 center font "Times-Roman, 12"
set label 2 "SON" at screen 1.02, .125 center rotate by 90 font "Times-Roman, 12"

set xtics ""
set ytics nomirror
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.0, 0.75
plot @FilNam @PosRad

set key off
PosInt = "1"
set origin 0.0, 0.50
plot @FilNam @PosRad

PosInt = "2"
set origin 0.0, 0.25
plot @FilNam @PosRad

set xtics nomirror autofreq
PosInt = "3"
set origin 0.0, 0.00
plot @FilNam @PosRad
# ----------------------------------------------------------------------

# SFC
# ----------------------------------------------------------------------
Titln1 = "ti 'CSSP'"
Titln2 = "ti 'NOAH'"
Titln3 = "ti 'PX'"
Titln4 = "ti 'CSSPn'"
Titln5 = "ti 'ERI'"

PosRad = "   using @Xrange:(column(01+@PosCol)*100) @Titln1 @Styln1, \
          '' using @Xrange:(column(09+@PosCol)*100) @Titln2 @Styln2, \
          '' using @Xrange:(column(10+@PosCol)*100) @Titln3 @Styln3, \
          '' using @Xrange:(column(11+@PosCol)*100) @Titln4 @Styln4, \
          '' using @Xrange:(column(12+@PosCol)*100) @Titln5 @Styln5 "

set rmargin 0
set lmargin 0

set label 1 "SFC" at screen 0.3, 1.02 center font "Times-Roman, 12"
set label 2 "JJA" at screen 1.02, .375 center rotate by 90 font "Times-Roman, 12"

set ytics ""
set xtics ""
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.2, 0.75
plot @FilNam @PosRad

set key off
PosInt = "1"
set origin 0.2, 0.50
plot @FilNam @PosRad

PosInt = "2"
set origin 0.2, 0.25
plot @FilNam @PosRad

set xtics nomirror autofreq
PosInt = "3"
set origin 0.2, 0.00
plot @FilNam @PosRad
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

PosRad = "   using @Xrange:(column(01+@PosCol)*100) @Titln1 @Styln1, \
          '' using @Xrange:(column(13+@PosCol)*100) @Titln2 @Styln2, \
          '' using @Xrange:(column(14+@PosCol)*100) @Titln3 @Styln3, \
          '' using @Xrange:(column(15+@PosCol)*100) @Titln4 @Styln4, \
          '' using @Xrange:(column(16+@PosCol)*100) @Titln5 @Styln5, \
          '' using @Xrange:(column(17+@PosCol)*100) @Titln6 @Styln6, \
          '' using @Xrange:(column(18+@PosCol)*100) @Titln7 @Styln7, \
          '' using @Xrange:(column(19+@PosCol)*100) @Titln8 @Styln8, \
          '' using @Xrange:(column(20+@PosCol)*100) @Titln9 @Styln9 "

set rmargin 0
set lmargin 0
set label 1 "PBL" at screen 0.5, 1.02 center font "Times-Roman, 12"
set label 2 "MAM" at screen 1.02, .625 center rotate by 90 font "Times-Roman, 12"


set ytics ""
set xtics ""
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.4, 0.75
plot @FilNam @PosRad

set key off
PosInt = "1"
set origin 0.4, 0.50
plot @FilNam @PosRad

PosInt = "2"
set origin 0.4, 0.25
plot @FilNam @PosRad

set xtics nomirror autofreq
PosInt = "3"
set origin 0.4, 0.00
plot @FilNam @PosRad
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

PosRad = "   using @Xrange:(column(01+@PosCol)*100) @Titln1 @Styln1, \
          '' using @Xrange:(column(21+@PosCol)*100) @Titln2 @Styln2, \
          '' using @Xrange:(column(22+@PosCol)*100) @Titln3 @Styln3, \
          '' using @Xrange:(column(23+@PosCol)*100) @Titln4 @Styln4, \
          '' using @Xrange:(column(24+@PosCol)*100) @Titln5 @Styln5, \
          '' using @Xrange:(column(25+@PosCol)*100) @Titln6 @Styln6, \
          '' using @Xrange:(column(26+@PosCol)*100) @Titln7 @Styln7 "

set rmargin 0
set lmargin 0
set label 1 "CUP" at screen 0.7, 1.02 center font "Times-Roman, 12"
set label 2 "DJF" at screen 1.02, .875 center rotate by 90 font "Times-Roman, 12"

set ytics ""
set xtics ""
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.6, 0.75
plot @FilNam @PosRad

set key off
PosInt = "1"
set origin 0.6, 0.50
plot @FilNam @PosRad

PosInt = "2"
set origin 0.6, 0.25
plot @FilNam @PosRad

set xtics nomirror autofreq
PosInt = "3"
set origin 0.6, 0.00
plot @FilNam @PosRad

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

PosRad = "   using @Xrange:(column(01+@PosCol)*100) @Titln1 @Styln1, \
          '' using @Xrange:(column(27+@PosCol)*100) @Titln2 @Styln2, \
          '' using @Xrange:(column(28+@PosCol)*100) @Titln3 @Styln3, \
          '' using @Xrange:(column(29+@PosCol)*100) @Titln4 @Styln4, \
          '' using @Xrange:(column(30+@PosCol)*100) @Titln5 @Styln5, \
          '' using @Xrange:(column(31+@PosCol)*100) @Titln6 @Styln6, \
          '' using @Xrange:(column(32+@PosCol)*100) @Titln7 @Styln7, \
          '' using @Xrange:(column(33+@PosCol)*100) @Titln8 @Styln8 "
set rmargin 0
set lmargin 0
set label 1 "CMP" at screen 0.9, 1.02 center font "Times-Roman, 12"

set ytics ""
set xtics ""
set key Left reverse samplen 2 spacing 1
PosInt = "0"
set origin 0.8, 0.75
plot @FilNam @PosRad

set key off
PosInt = "1"
set origin 0.8, 0.50
plot @FilNam @PosRad

PosInt = "2"
set origin 0.8, 0.25
plot @FilNam @PosRad

set xtics nomirror autofreq
PosInt = "3"
set origin 0.8, 0.00
plot @FilNam @PosRad


unset multiplot
