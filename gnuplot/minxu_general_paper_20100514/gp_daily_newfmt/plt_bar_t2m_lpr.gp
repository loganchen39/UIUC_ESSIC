reset
set term postscript portrait enhanced solid
set macros
set output 'fig_bar_t2m_lpr.ps'

set grid ytics

FilNam1 = "'./data/bar-T2M.dat'"
FilNam2 = "'./data/bar-PR.dat'"
FilNam3 = "'./data/bar-LWforc.dat'"
FilNam4 = "'./data/bar-SWforc.dat'"


call 'basic.gp'
call 'stybr.gp'


set ytics font "Courier, 12"


SclFct = "1"
OffSet = "0"

Sindex = "1"      # 1 - DJF 2 -MAM 3 - JJA 4 - SON
Season = "@Sindex + 1"

PStrt1 = "0"
PStrt2 = "1"
PStrt3 = "2"
PStrt4 = "3"
PStrt5 = "4"

PSkip1 = "5"
PSkip2 = "5"
PSkip3 = "5"
PSkip4 = "5"
PSkip5 = "5"

tpvar1 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @PSkip1::@PStrt1 ti 'OBS'"
tpvar2 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @PSkip2::@PStrt2 ti 'CTL'"
tpvar3 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @PSkip3::@PStrt3 ti 'UOM'"
tpvar4 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @PSkip4::@PStrt4 ti 'ENS'"
tpvar5 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @PSkip5::@PStrt5 ti 'WRF'"


RStrt0 = "0"
RStrt1 = "1"
RStrt2 = "2"
RStrt3 = "3"
RStrt4 = "4"
RStrt5 = "5"

RSkip0 = "6"
RSkip1 = "6"
RSkip2 = "6"
RSkip3 = "6"
RSkip4 = "6"
RSkip5 = "6"

rdvar0 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @RSkip0::@RStrt0 ti 'ISCCP'"
rdvar1 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @RSkip1::@RStrt1 ti 'SRB'"
rdvar2 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @RSkip2::@RStrt2 ti 'CTL'"
rdvar3 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @RSkip3::@RStrt3 ti 'UOM'"
rdvar4 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @RSkip4::@RStrt4 ti 'ENS'"
rdvar5 = "using (column(@Season)*@SclFct+@OffSet):xtic(1) every @RSkip5::@RStrt5 ti 'WRF'"

KeyOp1 = "top left Left reverse samplen 2 spacing 1"
KeyOp2 = "off"
KeyOp3 = "top right Left reverse samplen 2 spacing 1"
KeyOp4 = "off"


#set label 1 at screen 0.5, screen -.05 center "Regions" font "Times-Roman, 18"
set label 2 at screen -.08, screen 0.875 center rotate by 90 "Temperature (^0C)" font "Times-Roman, 16"
set label 3 at screen -.08, screen 0.625 center rotate by 90 "Precipitation (mm/day)" font "Times-Roman, 16"
set label 4 at screen -.08, screen 0.375 center rotate by 90 "LWforc (Wm^{-2})" font "Times-Roman, 16"
set label 5 at screen -.08, screen 0.125 center rotate by 90 "SWforc (Wm^{-2})" font "Times-Roman, 16"

set multiplot
set size 1.0, 0.25


Xrang1 = "[:]"
Xrang2 = "[:]"
Xrang3 = "[:]"
Xrang4 = "[:]"

Yrang1 = "[260:290]"
Yrang2 = "[0:7]"
Yrang3 = "[0:60]"
Yrang4 = "[-70:0]"

#==========================
set origin 0.0, 0.75
set key @KeyOp1
unset xtics
set format y 

plot @Xrang1 @Yrang1 @FilNam1 @tpvar1 @barsty1, \
                     ''       @tpvar2 @barsty2, \
                     ''       @tpvar3 @barsty3, \
                     ''       @tpvar4 @barsty4, \
                     ''       @tpvar5 @barsty5
unset object 1
#==========================
set origin 0.0, 0.5
set key @KeyOp2
unset xtics
set format y 

plot @Xrang2 @Yrang2 @FilNam2 @tpvar1 @barsty1, \
                     ''       @tpvar2 @barsty2, \
                     ''       @tpvar3 @barsty3, \
                     ''       @tpvar4 @barsty4, \
                     ''       @tpvar5 @barsty5

set origin 0.0, 0.25
set key @KeyOp3
unset xtics

plot @Xrang3 @Yrang3 @FilNam3 @rdvar0 @barsty0, \
                     ''       @rdvar1 @barsty1, \
                     ''       @rdvar2 @barsty2, \
                     ''       @rdvar3 @barsty3, \
                     ''       @rdvar4 @barsty4, \
                     ''       @rdvar5 @barsty5

set origin 0.0, 0.0
set key @KeyOp4
set format x 
set xtics border rotate by -20 nomirror font "Courier, 10"

plot @Xrang4 @Yrang4 @FilNam4 @rdvar0 @barsty0, \
                     ''       @rdvar1 @barsty1, \
                     ''       @rdvar2 @barsty2, \
                     ''       @rdvar3 @barsty3, \
                     ''       @rdvar4 @barsty4, \
                     ''       @rdvar5 @barsty5
unset multiplot

