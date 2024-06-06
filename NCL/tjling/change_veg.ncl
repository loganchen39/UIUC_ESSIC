begin
  f1=addfile("wrfveg_d01.nc","w")
  f2=addfile("wrfveg_d01.vbs.nc","r")
  f1->LAIB=f2->LAIB
  f1->SAIB=f2->SAIB
  f1->VEGB=f2->VEGB
  f1->ALBB=f2->ALBB
end
