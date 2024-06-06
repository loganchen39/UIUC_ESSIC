reset
set term postscript landscape enhanced color
set macros
set output 'fig_t2m_rmse_spa_frq_dist_pbl.ps'


FilNam = "'./data/land-rmse-t2m.dat'"

Xrange = "(0.+$0*0.1)"



PosInt = "0"
PosCol = "60 * @PosInt"

call 'basic.gp'

call 'styln.gp'

set label 3 "Spatial Frequency over U.S. Land Grids (%)" \
             at screen -0.05, 0.5 rotate by 90 center font "Times-Roman, 18"
set label 4 "RMS Error of Daily Mean Surface Air Temperature (^oC)"  \
             at screen 0.5, -0.05 rotate by  0 center font "Times-Roman, 18"

set multiplot
set size 0.5, 0.5

set xrange [0.01: 5]
set yrange [0.01:10]

#set label 91 "RA" at screen 0.1, 1.02 center font "Times-Roman, 12"
#set label 92 "SF" at screen 0.3, 1.02 center font "Times-Roman, 12"
#set label 93 "BL" at screen 0.5, 1.02 center font "Times-Roman, 12"
#set label 94 "CU" at screen 0.7, 1.02 center font "Times-Roman, 12"
#set label 95 "MP" at screen 0.9, 1.02 center font "Times-Roman, 12"

SclFct = "100"
OffSet = "0"

# key options

KeyOp1 = "left top Left reverse samplen 2 spacing 1"
KeyOp2 = "off"
KeyOp3 = "off"
KeyOp4 = "off"

# RAD
# ----------------------------------------------------------------------
# ----------------------------------------------------------------------

# PBL
# ----------------------------------------------------------------------

call 'pblfrq.gp'
Stybl1 = "@Styln1"
Stybl2 = "@Styln2"
Stybl3 = "@Styln3"
Stybl4 = "@Styln4"
Stybl5 = "@Styln5"
Stybl6 = "@Styln6"
Stybl7 = "@Styln7"
Stybl8 = "@Styln8"
Stybl9 = "@Styln9"


set xtics nomirror 0, 1,  5
set ytics nomirror 0, 2, 10

set ytics nomirror ("0" 0, "2" 2, "4" 4, "6" 6, "8" 8, "10" 10, "20" 20)
set key @KeyOp1
PosInt = "0"
set origin 0.0, 0.5
set label 21 "DJF" at 3.9, 08 font "Times-Roman, 12"
plot @FilNam @PosPbl
unset object 1

set xtics nomirror ("0" 0, "1" 1, "2" 2, "3" 3, "4" 4, "5" 5)
set key @KeyOp2
PosInt = "1"
set origin 0.0, 0.0
set label 21 "MAM" at 3.9, 08 font "Times-Roman, 12"
plot @FilNam @PosPbl

set xtics nomirror 0, 1,  5
set ytics nomirror 0, 2, 10
set format y ""
set format x ""

set key @KeyOp3
PosInt = "2"
set origin 0.5, 0.5
set label 21 "JJA" at 3.9, 08 font "Times-Roman, 12"
plot @FilNam @PosPbl

set xtics nomirror ("0" 0, "1" 1, "2" 2, "3" 3, "4" 4, "5" 5)
set key @KeyOp4
PosInt = "3"
set origin 0.5, 0.0
set label 21 "SON" at 3.9, 08 font "Times-Roman, 12"
plot @FilNam @PosPbl
# ----------------------------------------------------------------------

unset multiplot
