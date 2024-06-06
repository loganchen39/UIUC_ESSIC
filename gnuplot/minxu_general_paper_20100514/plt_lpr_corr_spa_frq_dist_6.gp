reset
set term postscript landscape enhanced color
set macros
set output 'fig_lpr_corr_spa_frq_dist_6.ps'

FilNam = "'./data_v3/corr6.dat.conv'"

Xrange = "(-1+$0*0.05)"

PosInt = "0"
PosCol = "39 * @PosInt"

call 'basic.gp'
call 'style.gp'

set label 3 "Spatial Frequency over Southeast (%)" at screen -0.05, 0.5 rotate by 90 center font "Times-Roman, 18"
set label 4 "Correlation Coefficient of Daily Mean Precipitation"  \
             at screen 0.5, -0.05 rotate by  0 center font "Times-Roman, 18"

set multiplot
set size 0.2, 0.25

set xrange [0.01:1]
set yrange [0.1:20]

set label 91 "RA" at screen 0.1, 1.02 center font "Times-Roman, 12"
set label 92 "SF" at screen 0.3, 1.02 center font "Times-Roman, 12"
set label 93 "BL" at screen 0.5, 1.02 center font "Times-Roman, 12"
set label 94 "CU" at screen 0.7, 1.02 center font "Times-Roman, 12"
set label 95 "MP" at screen 0.9, 1.02 center font "Times-Roman, 12"

SclFct = "100"
OffSet = "0"

# key options
call 'keyop.gp'


# RAD
# ----------------------------------------------------------------------
call 'radfrq.gp'

Styrd1 = "@Styln1"
Styrd2 = "@Styln2"
Styrd3 = "@Styln3"
Styrd4 = "@Styln4"
Styrd5 = "@Styln5"
Styrd6 = "@Styln6"
Styrd7 = "@Styln7"
Styrd8 = "@Styln8"
Styrd9 = "@Styln9"


set format y
set xtics nomirror 0, 0.2, 1.0
set ytics nomirror 0, 4, 92

set key @KeyOp1
PosInt = "0"
set origin 0.0, 0.75
set label 21 "DJF" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosRad
unset object 1

set key @KeyOp2
PosInt = "1"
set origin 0.0, 0.50
set label 21 "MAM" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosRad

set key @KeyOp3
PosInt = "2"
set origin 0.0, 0.25
set label 21 "JJA" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosRad

set xtics nomirror ("0.0" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set key @KeyOp4
PosInt = "3"
set origin 0.0, 0.00
set label 21 "SON" at 0.05, 01 font "Times-Roman, 12"
plot @FilNam @PosRad

unset label 21
set format y ""
# ----------------------------------------------------------------------

# SFC
# ----------------------------------------------------------------------
call 'sfcfrq.gp'

Stysf1 = "@Styln1"
Stysf2 = "@Styln2"
Stysf3 = "@Styln3"
Stysf4 = "@Styln4"
Stysf5 = "@Styln5"
Stysf6 = "@Styln6"
Stysf7 = "@Styln7"
Stysf8 = "@Styln8"
Stysf9 = "@Styln9"

set xtics nomirror 0, 0.2, 1.0
set ytics nomirror 0, 4, 92
set key @KeyOp1
PosInt = "0"
set origin 0.2, 0.75
plot @FilNam @PosSfc

set key @KeyOp2
PosInt = "1"
set origin 0.2, 0.50
plot @FilNam @PosSfc

set key @KeyOp3
PosInt = "2"
set origin 0.2, 0.25
plot @FilNam @PosSfc

set xtics nomirror ("" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set key @KeyOp4
PosInt = "3"
set origin 0.2, 0.00
plot @FilNam @PosSfc
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

set xtics nomirror 0, 0.2, 1.0
set ytics nomirror 0, 4, 92
set key @KeyOp1
PosInt = "0"
set origin 0.4, 0.75
plot @FilNam @PosPbl

set key @KeyOp2
PosInt = "1"
set origin 0.4, 0.50
plot @FilNam @PosPbl

set key @KeyOp3
PosInt = "2"
set origin 0.4, 0.25
plot @FilNam @PosPbl

set xtics nomirror ("" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set key @KeyOp4
PosInt = "3"
set origin 0.4, 0.00
plot @FilNam @PosPbl
# ----------------------------------------------------------------------

# CUP
# ----------------------------------------------------------------------

call 'cupfrq.gp'
Stycu1 = "@Styln1"
Stycu2 = "@Styln2"
Stycu3 = "@Styln3"
Stycu4 = "@Styln4"
Stycu5 = "@Styln5"
Stycu6 = "@Styln6"
Stycu7 = "@Styln7"
Stycu8 = "@Styln8"
Stycu9 = "@Styln9"

set xtics nomirror 0, 0.2, 1.0
set ytics nomirror 0, 4, 92
set key @KeyOp1
PosInt = "0"
set origin 0.6, 0.75
plot @FilNam @PosCup

set key @KeyOp2
PosInt = "1"
set origin 0.6, 0.50
plot @FilNam @PosCup

set key @KeyOp3
PosInt = "2"
set origin 0.6, 0.25
plot @FilNam @PosCup

set xtics nomirror ("" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set key @KeyOp4
PosInt = "3"
set origin 0.6, 0.00
plot @FilNam @PosCup

# ----------------------------------------------------------------------

# CMP
# ----------------------------------------------------------------------

call 'cmpfrq.gp'
Stymp1 = "@Styln1"
Stymp2 = "@Styln2"
Stymp3 = "@Styln3"
Stymp4 = "@Styln4"
Stymp5 = "@Styln5"
Stymp6 = "@Styln6"
Stymp7 = "@Styln7"
Stymp8 = "@Styln8"
Stymp9 = "@Styln9"

set xtics nomirror 0, 0.2, 1.0
set ytics nomirror 0, 4, 92
set key @KeyOp1
PosInt = "0"
set origin 0.8, 0.75
plot @FilNam @PosCmp

set key @KeyOp2
PosInt = "1"
set origin 0.8, 0.50
plot @FilNam @PosCmp

set key @KeyOp3
PosInt = "2"
set origin 0.8, 0.25
plot @FilNam @PosCmp

set xtics nomirror ("" 0.0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1.0" 1.0)
set key @KeyOp4
PosInt = "3"
set origin 0.8, 0.00
plot @FilNam @PosCmp


unset multiplot
