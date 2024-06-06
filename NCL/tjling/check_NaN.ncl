
begin
  f1=addfile("./wrfout_d01.nc","r")
  
  n1=getfilevarnames(f1)
  do i=0,dimsizes(n1)-1
     v1=f1->$n1(i)$
     ;vartypes=getfilevartypes(f1,n1)
     if (typeof(v1).eq."float") then
	if (any(isnan_ieee(v1))) then
	     print(n1(i)+" has "+sprinti("%6i",num(isnan_ieee(v1)))+ \
	     " NaN !!!!")
	end if
     end if
     delete(v1)
  end do

  


end
