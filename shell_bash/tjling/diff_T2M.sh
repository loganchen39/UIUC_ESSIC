#!/bin/bash
ln -sf $2/$4 tmpa.nc
ln -sf $3/$4 tmpb.nc
echo compare $1 of  $2/$4 $3/$4
cat > temp.ncl <<EOF
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
  a=addfile("tmpa.nc","r")
  b=addfile("tmpb.nc","r")
  t1=a->U(0,:,:,:)
  t2=b->U(0,:,:,:)
  printMinMax(t1,True)
  printMinMax(t2,True)
  t=t1-t2
  printMinMax(t,True)
  delete(t1)
  delete(t2)
  delete(t)
  t1=a->T(0,:,:,:)
  t2=b->T(0,:,:,:)
  printMinMax(t1,True)
  printMinMax(t2,True)
  t=t1-t2
  printMinMax(t,True)
end
EOF
ncl temp.ncl
rm temp.ncl tmpa.nc tmpb.nc
