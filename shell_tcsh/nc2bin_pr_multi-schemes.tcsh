#!/bin/tcsh

unalias cp
cd /scratch/scratchdirs/lgchen/projects/PrMOS/Fortran/nc2bin_rain

set SCHM_NUM = 39
set SCHM_DIR = (ctl                                                \
    bl_acm bl_boulac bl_gfs bl_myj bl_orooff bl_qnse bl_uw bl_ysu  \
    cu_bmj cu_bmjcwp3 cu_csu cu_g3 cu_gd cu_gfdl cu_mit cu_nkf     \
    cu_shallow_off cu_zml                                          \
    mp_lin mp_morrison mp_thompson mp_wdm6 mp_wsm5 mp_wsm6 mp_zhao \
    ra_aerosoloff ra_cam ra_cawcr ra_cccma ra_doclavg ra_fuliou    \
    ra_gfdl ra_rrtmg                                               \
    sf_eri sf_narr sf_noah sf_px sf_uomoff) 
set SCHM_FN_PREF = (ctl                            \
    acm boulac gfs myj oro_off qnse uw ysu         \
    bmj bmj_cwp3 csu g3 gd gfdl mit nkf            \
    shallow0 zml_bluefire                          \
    lin morrison thompson wdm6 wsm5 wsm6 zhao      \
    aerosol_off cam cawcr cccma do_cl_avg1 fuliou  \
    gfdl rrtmg                                     \
    CWRF-ERI CWRF-NARR CWRF-NOAH CWRF-PX uom_off)

set i_schm = 1
while ($i_schm <= $SCHM_NUM)
    cp -f ./config.nml_template config.nml
    sed -i -e '/test_name/s/bl_acm/'$SCHM_DIR[$i_schm]'/;  \
        /input_data_dir/s/bl_acm/'$SCHM_DIR[$i_schm]'/;    \
        /input_fn_prefix/s/acm/'$SCHM_FN_PREF[$i_schm]'/;  \
        /output_fn_prefix/s/acm/'$SCHM_FN_PREF[$i_schm]'/' config.nml 

    if (cu_gfdl == $SCHM_DIR[$i_schm]) then 
        sed -i -e '/output_fn_prefix/s/gfdl/cu_gfdl/' config.nml
    else if (ra_gfdl == $SCHM_DIR[$i_schm]) then
        sed -i -e '/output_fn_prefix/s/gfdl/ra_gfdl/' config.nml
    endif

    ./nc2bin_rain.exe

    @ i_schm++
end  
