reset
set term postscript landscape enhanced color
set macros
set output 'fig_lpr_corr_spa_frq_dist_sfc.ps'

FilNam = "'./data/land-corr.dat'"

Xrange = "(-1+$0*0.05)"

PosInt = "0"
PosCol = "60 * @PosInt"

call 'basic.gp'
call 'styln.gp'

set label 3 "Spatial Frequency over All Land Grids (%)" at screen -0.05, 0.5 rotate by 90 center font "Times-Roman, 18"
set label 4 "Correlation Coefficient of Daily Mean Precipitation"  \
             at screen 0.5, -0.05 rotate by  0 center font "Times-Roman, 18"

set multiplot
set size 0.5, 0.5

set xrange [0.01:1]
set yrange [0.1:12]

#set label 91 "RA" at screen 0.1, 1.02 center font "Times-Roman, 12"
#set label 92 "SF" at screen 0.3, 1.02 center font "Times-Roman, 12"
#set label 93 "BL" at screen 0.5, 1.02 center font "Times-Roman, 12"
#set label 94 "CU" at screen 0.7, 1.02 center font "Times-Roman, 12"
#set label 95 "MP" at screen 0.9, 1.02 center font "Times-Roman, 12"

SclFct = "100"
OffSet = "0"

# key options
KeyOp1 = "off"
KeyOp2 = "off"
KeyOp3 = "Left reverse samplen 2 spacing 1"
KeyOp4 = "off"

set format y
set xtics nomirror 0, 0.2, 1.0
set ytics nomirror 0, 4, 12

# ----------------------------------------------------------------------

# SFC
# ----------------------------------------------------------------------

call 'sfcfrq_spec.gp'
Stysf1 = "@Styln1"
Stysf2 = "@Styln2"
Stysf3 = "@Styln3"
Stysf4 = "@Styln4"
Stysf5 = "@Styln5"
Stysf6 = "@Styln6"
Stysf7 = "@Styln7"
Stysf8 = "@Styln8"
Stysf9 = "@Styln9"

set format y
set xtics nomirror 0, 0.2, 1.0
set ytics nomirror 0, 4, 12
set key @KeyOp1
PosInt = "0"
set origin 0.0, 0.5
set label 21 "DJF" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosSfc
unset object 1

set xtics nomirror ("" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set key @KeyOp2
PosInt = "1"
set origin 0.0, 0.0
set label 21 "MAM" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosSfc
set format y ""

set xtics nomirror 0, 0.2, 1.0
set key @KeyOp3
PosInt = "2"
set origin 0.5, 0.5
set label 21 "JJA" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosSfc

set xtics nomirror ("" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set key @KeyOp4
PosInt = "3"
set origin 0.5, 0.0
set label 21 "SON" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosSfc

unset multiplot