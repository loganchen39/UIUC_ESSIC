set xtics border font "Courier-Bold, 11"
set ytics border font "Courier-Bold, 11"

set termoption font "Times-Roman, 11"

set border 31 lw 0.2 lt -1
set object 1 rect from screen 0, screen 0 to screen 1, screen 1 behind fc rgb "white" fs empty border -1 lw 1.0

set format x ""
set format y ""

set tmargin 0
set bmargin 0
set rmargin 0
set lmargin 0

set datafile missing "-999.0000"
