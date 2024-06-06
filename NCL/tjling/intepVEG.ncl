begin
  system("cp -f wrfveg_d01.org wrfveg_d01.nc")
  f=addfile("wrfveg_d01.nc","w")
  f1=addfile("wrfbdy_d01.nc","r")
  f2=addfile("wrflowinp_d01.nc","r")
  mt_bdy=f1->md___thisbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_
  mn_bdy=f1->md___nextbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_
  t=f2->Times
  
  f->Times=t

  f->md___thisvegtimee_x_t_d_o_m_a_i_n_m_e_t_a_data_=t
  t(0:47,:)=t(1:48,:)
  printVarSummary(t(48,:))

  print("______________________")
  a=stringtochar("1998-01-02_00:30:00")
  t(48,:)=(/a(0:18)/)

  f->md___nextvegtimee_x_t_d_o_m_a_i_n_m_e_t_a_data_=t

  sst=f->VEGB
  sst(48,:,:)=(/sst(1,:,:)/)
  do i=1,47
    sst(i,:,:)=(/sst(0,:,:)/)
  end do
  f->VEGB=sst

  sst=f->GRNB
  sst(48,:,:)=(/sst(1,:,:)/)
  do i=1,47
    sst(i,:,:)=(/sst(0,:,:)/)
  end do
  f->GRNB=sst
  
  sst=f->LAIB
  sst(48,:,:)=(/sst(1,:,:)/)
  do i=1,47
    sst(i,:,:)=(/sst(0,:,:)/)
  end do
  f->LAIB=sst
  
  
  sst=f->SAIB
  sst(48,:,:)=(/sst(1,:,:)/)
  do i=1,47
    sst(i,:,:)=(/sst(0,:,:)/)
  end do
  f->SAIB=sst


  sst=f->ALBB
  sst(48,:,:)=(/sst(1,:,:)/)
  do i=1,47
    sst(i,:,:)=(/sst(0,:,:)/)
  end do
  f->ALBB=sst


  f@VEGFRQ=1800.0

  printVarSummary(sst)


  
  

end
