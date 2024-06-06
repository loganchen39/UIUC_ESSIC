#! /usr/local/bin/gnuplot        #---use gnuplot 
reset                         
set terminal postscript landscape color "courier-new" 18      
set output "armsgp_pblh_diurnal.ps"
set datafile missing '99999.00'
set xdata time
set timefmt "%H.%M"
set format x "%H:%M"
#set xrange ["00:00":"24:00"]
set xrange ["0":"24"]
set xtics "00:00", 10800.
set ylabel 'PBLH (AGL,m)' font "Times-Roman, 18"
set xlabel 'Time (LST)'   font "Times-Roman, 18"
set title  'ARM SGP diurnal average'   font "Times-Roman, 18"
set key reverse left Left
plot 'armsgp_pblh_diurnal.txt' u 2:1 w lp lt -1 lw 4 lc 2 noti 

