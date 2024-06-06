load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
d=(/       \
"US_MEX.pr_rate.195x138.monthly.19880112", \
"US_MEX.pr_rate.195x138.monthly.19930112", \
"US_MEX.pr_rate.195x138.monthly.19980112", \
"obs_ta.195x138.1988.monthly", \
"obs_ta.195x138.1993.monthly", \
"obs_ta.195x138.1998.monthly"/)


do i=0,dimsizes(d)-1
  setfileoption("bin","ReadByteOrder","BigEndian")
  obs=fbindirread(d(i),0,(/12,138,195/),"float")
  print(d(i))
  printMinMax(obs,True)
end do

end
