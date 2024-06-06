load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
   f=addfile("wrfsst_d01.nc","w")
   t=f->SSTB
   a0=int2flt(floattoint(t(0,:,:)))
   do i=0,48
     a=t(i,:,:)
     a=where(a0.lt.0,a0,a0+i*0.01)
     t(i,:,:)=a
   end do
   f->SSTB=t
end
