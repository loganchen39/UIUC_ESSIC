begin
path="../NRA2.1998030100.v213"
filelist=""
lastfile="wrfout_d01_022320"
fileprefix="wrfout_d01_"
nlist=ispan(0,21600,720)
do i=0,dimsizes(nlist)-1
   filelist=filelist+" "+fileprefix+sprinti("%0.6i",nlist(i))
end do
s="time ncea -O -v T2M,HFX,QFX,XUPTKW -p "+path+" "+filelist+" "+" -o mean_v213.nc"
print(s)
system(s)
end
