reset
set term postscript landscape enhanced color
set macros


set output 'fig_lpr_corr_spa_frq_dist_aio.ps'
FilNam = "'./data_xing/land-corr.dat.conv'"
Xrange = "(-1+$0*0.05)"


call 'basic.gp'
call 'style.gp'

PosInt = "0"
PosCol = "34 * @PosInt"
SclFct = "100"
OffSet = "0"

set label 3 "Spatial Frequency over All Land Grids (%)" at screen -0.05, 0.5 rotate by 90 center font "Times-Roman, 18"
set label 4 "Correlation Coefficient of Daily Mean Precipitation"  \
             at screen 0.5, -0.05 rotate by  0 center font "Times-Roman, 18"

set multiplot
set size 0.25, 0.25

set xrange [0.01:1]
set yrange [0.1:12]

# Global label define
set label 91 "RA" at screen 0.1, screen 1.02 center font "Times-Roman, 12"
set label 92 "SF" at screen 0.3, screen 1.02 center font "Times-Roman, 12"
set label 93 "BL" at screen 0.5, screen 1.02 center font "Times-Roman, 12"
set label 94 "CU" at screen 0.7, screen 1.02 center font "Times-Roman, 12"
set label 95 "MP" at screen 0.9, screen 1.02 center font "Times-Roman, 12"


ScPos1 = "0.0, 0.5"
ScPos2 = "0.5, 0.5"
ScPos3 = "0.0, 0.0"
ScPos4 = "0.5, 0.0"
call 'radaio.gp'

Styrd1 = "@Styln1"
'dd'
Styrd2 = @Styln1
Styrd3 = @Styln1
Styrd4 = @Styln1
Styrd5 = @Styln1
Styrd6 = @Styln1
Styrd7 = @Styln1
Styrd8 = @Styln1
Styrd9 = @Styln1


