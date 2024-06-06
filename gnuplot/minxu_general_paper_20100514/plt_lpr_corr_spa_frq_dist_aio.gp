reset
set term postscript landscape enhanced color
set macros

set output 'fig_lpr_corr_spa_frq_dist_aio.ps'
FilNam = "'./data_v3/land-corr.dat.conv'"
Xrange = "(-1+$0*0.05)"


call 'basic.gp'
call 'style.gp'

PosInt = "0"
PosCol = "39 * @PosInt"
SclFct = "100"
OffSet = "0"

set label 3 "Spatial Frequency over All Land Grids (%)" at screen -0.05, 0.5 rotate by 90 center font "Times-Roman, 18"
set label 4 "Correlation Coefficient of Daily Mean Precipitation"  \
             at screen 0.5, -0.05 rotate by  0 center font "Times-Roman, 18"

set multiplot
set size 0.50, 0.50

set xrange [0.01:1]
set yrange [0.1:12]

# Global label define
#set label 91 "RA" at screen 0.1, screen 1.02 center font "Times-Roman, 12"
#set label 92 "SF" at screen 0.3, screen 1.02 center font "Times-Roman, 12"
#set label 93 "BL" at screen 0.5, screen 1.02 center font "Times-Roman, 12"
#set label 94 "CU" at screen 0.7, screen 1.02 center font "Times-Roman, 12"
#set label 95 "MP" at screen 0.9, screen 1.02 center font "Times-Roman, 12"

# key options
KeyOp1 = "left top Left reverse samplen 2 spacing 1"
#KeyOp1 = "off"
KeyOp2 = "off"
KeyOp3 = "off"
KeyOp4 = "off"


ScPos1 = "0.0, 0.5"
ScPos2 = "0.5, 0.5"
ScPos3 = "0.0, 0.0"
ScPos4 = "0.5, 0.0"

# RAD
# ----------------------------------------------------------------------
call 'radaio.gp'

Styrd1 = "@Styln0" 
Styrd2 = "@Styln1"
Styrd3 = "@Styln1"
Styrd4 = "@Styln1"
Styrd5 = "@Styln1"
Styrd6 = "@Styln1"
Styrd7 = "@Styln1"
Styrd8 = "@Styln1"
Styrd9 = "@Styln1"

call 'sfcaio.gp'
Stysf1 = "@Styln0"
Stysf2 = "@Styln2"
Stysf3 = "@Styln2"
Stysf4 = "@Styln2"
Stysf5 = "@Styln2"
Stysf6 = "@Styln2"
Stysf7 = "@Styln2"
Stysf8 = "@Styln2"
Stysf9 = "@Styln2"

call 'pblaio.gp'
Stybl1 = "@Styln0"
Stybl2 = "@Styln3"
Stybl3 = "@Styln3"
Stybl4 = "@Styln3"
Stybl5 = "@Styln3"
Stybl6 = "@Styln3"
Stybl7 = "@Styln3"
Stybl8 = "@Styln3"
Stybl9 = "@Styln3"

call 'cupaio.gp'
Stycu1 = "@Styln0"
Stycu2 = "@Styln4"
Stycu3 = "@Styln4"
Stycu4 = "@Styln4"
Stycu5 = "@Styln4"
Stycu6 = "@Styln4"
Stycu7 = "@Styln4"
Stycu8 = "@Styln4"
Stycu9 = "@Styln4"

call 'cmpaio.gp'
Stymp1 = "@Styln0"
Stymp2 = "@Styln5"
Stymp3 = "@Styln5"
Stymp4 = "@Styln5"
Stymp5 = "@Styln5"
Stymp6 = "@Styln5"
Stymp7 = "@Styln5"
Stymp8 = "@Styln5"
Stymp9 = "@Styln5"

set format y
set xtics nomirror 0, 0.2, 1.0
set ytics nomirror 0, 2, 12

set key @KeyOp1
PosInt = "0"
set origin @ScPos1
set label 21 "DJF" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosRad, @FilNam @PosSfc, @FilNam @PosPbl, @FilNam @PosCup, @FilNam @PosCmp, \
      @FilNam using @Xrange:(column(38+@PosCol)*100) ti 'ENS' w l lc 0 lw 4 lt 1
      #@FilNam using @Xrange:(column(39+@PosCol)*100) ti 'ENS2' w l lc 0 lw 4 lt 22
unset object 1

set format y ""
set key @KeyOp2
PosInt = "1"
set origin @ScPos2
set label 21 "MAM" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosRad, @FilNam @PosSfc, @FilNam @PosPbl, @FilNam @PosCup, @FilNam @PosCmp, \
      @FilNam using @Xrange:(column(38+@PosCol)*100) ti 'ENS' w l lc 0 lw 4 lt 1
      #@FilNam using @Xrange:(column(39+@PosCol)*100) ti 'ENS2' w l lc 0 lw 4 lt 22

set xtics nomirror ("0.0" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set format y
set key @KeyOp3
PosInt = "2"
set origin @ScPos3
set label 21 "JJA" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosRad, @FilNam @PosSfc, @FilNam @PosPbl, @FilNam @PosCup, @FilNam @PosCmp, \
      @FilNam using @Xrange:(column(38+@PosCol)*100) ti 'ENS' w l lc 0 lw 4 lt 1
      #@FilNam using @Xrange:(column(39+@PosCol)*100) ti 'ENS2' w l lc 0 lw 4 lt 22

set xtics nomirror ("0.0" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set format y ""
set key @KeyOp4
set key off
PosInt = "3"
set origin @ScPos4
set label 21 "SON" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosRad, @FilNam @PosSfc, @FilNam @PosPbl, @FilNam @PosCup, @FilNam @PosCmp, \
      @FilNam using @Xrange:(column(38+@PosCol)*100) ti 'ENS' w l lc 0 lw 4 lt 1
      #@FilNam using @Xrange:(column(39+@PosCol)*100) ti 'ENS2' w l lc 0 lw 4 lt 22

unset label 21
set format y ""



unset multiplot
