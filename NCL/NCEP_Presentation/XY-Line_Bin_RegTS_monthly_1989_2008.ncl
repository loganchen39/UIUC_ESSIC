load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/nas/lgchen/lib/NCL/self_defined.ncl"


begin
    ; data window/  20,  36, 85, 121   ; Cascade
    ;            ,  42,  62, 89, 117   ; North Rockies
    ;            ,  74,  91, 55,  90   ; Central Great Plain
    ;            , 104, 133, 66,  93   ; Midwest
    ;            , 139, 166, 80, 116   ; Northeast
    ;            , 134, 155, 28,  69   ; Southeast
    ;            ,  94, 128, 39,  63   ; Coast States
    ;            ,  51,  70, 16,  70/  ; NAM 

    setfileoption("bin", "ReadByteOrder" , "BigEndian")
    setfileoption("bin", "WriteByteOrder", "BigEndian")

    NX = 195
    NY = 138

    FN_LCC         = "/nas/lgchen/data/lcc_xing/lcc"
    FN_US_LANDMASK = "/nas/lgchen/data/USLandmask/US.landmask.zjh"
    lcc            = new ((/NY, NX/), "float")
    us_landmask    = new ((/NY, NX/), "float")
    lcc            = fbindirread(FN_LCC        , 0, (/NY, NX/), "float")
    us_landmask    = fbindirread(FN_US_LANDMASK, 0, (/NY, NX/), "float")
 

    PR_OBS_MLY = "/nas/lgchen/data/obs/pr/LAND_OCEAN.pr_rate_monthly.1979_2009"
    PR_MOD_MLY = "/nas/lgchen/data/mod/CWRF-ERI/CWRF-ERI_PR_monthly_mean_198901_200812.bin"

    REG_NUM  = 8
    REG_NAME = (/"Cascade", "North Rockies", "Central Great Plain",  \
                 "Midwest", "Northeast", "Southeast", "Coast States", "NAM"/)
    REG_WIN  = (/(/ 20,  85,  36, 121/)  \  ; (xb, yb, xe, ye) 
             ,   (/ 42,  89,  62, 117/)  \
             ,   (/ 74,  55,  91,  90/)  \
             ,   (/104,  66, 133,  93/)  \
             ,   (/139,  80, 166, 116/)  \
             ,   (/134,  28, 155,  69/)  \
             ,   (/ 94,  39, 128,  63/)  \
             ,   (/ 51,  16,  70,  70/)/)
    REG_WIN  = REG_WIN - 1

    START_YEAR = 1989
    END_YEAR   = 2008
    N_YEAR     = END_YEAR - START_YEAR + 1


    ; main data structure
    ; pr_obs_reg_ts_mly = new ((/12, REG_NUM, N_YEAR/), "float")
    ; pr_mod_reg_ts_mly = new ((/12, REG_NUM, N_YEAR/), "float")
    pr_obs_reg_ts_mly = new ((/REG_NUM, N_YEAR*12/), "float")
    pr_mod_reg_ts_mly = new ((/REG_NUM, N_YEAR*12/), "float")

    pr_obs_reg_ts_mly@missingvalue = 1.e20
    pr_obs_reg_ts_mly@_FillValue   = 1.e20
    pr_mod_reg_ts_mly@missingvalue = 1.e20
    pr_mod_reg_ts_mly@_FillValue   = 1.e20

    pr_obs_tmp = new ((/NY, NX/), "float")
    pr_mod_tmp = new ((/NY, NX/), "float")

    pr_obs_tmp@missingvalue = 1.e20
    pr_obs_tmp@_FillValue   = 1.e20
    pr_mod_tmp@missingvalue = 1.e20
    pr_mod_tmp@_FillValue   = 1.e20


    ; fn = "/nas/lgchen/data/mod/CWRF-ERI/CWRF-ERI_PR_monthly_mean_198901_200812.bin"
    ; do i_yr = 1989, 2008
    ;     do i_mon = 1, 12
    ;         i_rec_mod = get_record_index_monthly(1989, 1, i_yr, i_mon)
    ;         pr_mod_tmp = fbindirread(PR_MOD_MLY, i_rec_mod, (/NY, NX/), "float")
    ;         pr_mod_tmp = pr_mod_tmp / days_in_month(i_yr, i_mon)
    ;         fbindirwrite(fn, pr_mod_tmp)
    ;     end do
    ; end do

    ; exit()


    start_rec_obs = get_record_index_monthly(1979, 1, 1989, 1)
    start_rec_mod = get_record_index_monthly(1989, 1, 1989, 1)

    do i_rec = 0, N_YEAR*12 - 1
        pr_obs_tmp = fbindirread(PR_OBS_MLY, start_rec_obs + i_rec, (/NY, NX/), "float")
        pr_mod_tmp = fbindirread(PR_MOD_MLY, start_rec_mod + i_rec, (/NY, NX/), "float")

        pr_obs_tmp = where(lcc .ne. 16, pr_obs_tmp, pr_obs_tmp@_FillValue)
        pr_mod_tmp = where(lcc .ne. 16, pr_mod_tmp, pr_mod_tmp@_FillValue)

        do i_reg = 0, REG_NUM - 1
            pr_obs_reg_ts_mly(i_reg, i_rec) = avg(pr_obs_tmp(  \
                REG_WIN(i_reg, 1):REG_WIN(i_reg, 3), REG_WIN(i_reg, 0):REG_WIN(i_reg, 2)))
            pr_mod_reg_ts_mly(i_reg, i_rec) = avg(pr_mod_tmp(  \
                REG_WIN(i_reg, 1):REG_WIN(i_reg, 3), REG_WIN(i_reg, 0):REG_WIN(i_reg, 2)))
        end do       
    end do


    time_x = ispan(0, N_YEAR*12 - 1, 1)
    data_y = new ((/2, N_YEAR*12/), "float")


    ; PLOTTING
    load "/nas/lgchen/lib/NCL/res_settings.ncl"

    wks_pdf   = gsn_open_wks("ps", "./PR_REG_TS_MLY_Northeast_Cascade_1989_2008")
    plot_pdf  = new (2, graphic)

    res_1d@vpHeightF = 0.3  ; change aspect ratio of plot
    res_1d@vpWidthF  = 1.0
    res_1d@vpXF      = 0.05 ; originally 0.1
    res_1d@vpYF      = 0.95 ; originally 0.9

    ; res_1d@tmXBMode   = "Explicit"
    ; res_1d@tmXBValues = (/1, 63, 122, 183, 244, 305, 366, 396/)
    ; res_1d@tmXBLabels = (/921201, 930201, 930401, 930601, 930801, 931001, 931201, 931231/)

    ; panel resource for function gsn_panel
    res_panel               = True
    res_panel@gsnPanelDebug = True  ; To get information from panel
    
    res_panel@gsnPanelXF = (/0.0737378, 0.0737378/)
    res_panel@gsnPanelYF = (/0.823615 , 0.498677 /)

    res_1d@tiYAxisString   = "Rain (mm/day)"

    res_1d@pmLegendDisplayMode    = "Always"
    res_1d@pmLegendSide           = "Top"  ; "Bottom"
    res_1d@pmLegendParallelPosF   = 0.92 ; 0.9  ; 0.8   ; 0.15  ; 0.25  ; 0.3  ; 0.7 ; 0.1 ; 0.4  ; 0.6    ; bigger = right
    res_1d@pmLegendOrthogonalPosF = -0.55  ; -0.6  ; -0.8  ; -0.7 ; more negative = down
    res_1d@pmLegendWidthF         = 0.1
    res_1d@pmLegendHeightF        = 0.1  ; 0.15
    
    res_1d@lgLabelFontHeightF     = 0.015
    res_1d@lgPerimOn              = False
    res_1d@lgItemOrder            = (/1, 0/)
    res_1d@xyExplicitLegendLabels = (/"OBS", "CWRF"/)

    ; res_1d@xyDashPattern   = (/0, 1/)
    res_1d@xyLineThicknesses = (/2.0, 2.0/)
    res_1d@xyLineColors      = (/"blue", "red"/)


    IDX_MIDWEST   = 3
    IDX_CASCADE   = 0
    IDX_NORTHEAST = 4

    res_1d@tmXBMode         = "Explicit"
    res_1d@tmXBLabelsOn     = True

    delete(res_1d@tmXBValues)
    delete(res_1d@tmXBLabels)
    res_1d@tmXBValues = ispan(0, N_YEAR*12-1, 12)
    res_1d@tmXBLabels = (/"89","90","91","92","93","94","95","96","97","98","99","00","01","02","03","04","05","06","07","08"/) 


    ; ; Midwest
    ; data_y(0, 0:N_YEAR*12-1) = pr_obs_reg_ts_mly(IDX_MIDWEST, 0:N_YEAR*12-1)
    ; data_y(1, 0:N_YEAR*12-1) = pr_mod_reg_ts_mly(IDX_MIDWEST, 0:N_YEAR*12-1)

    ; res_1d@tmYLMode          = "Manual"
    ; res_1d@tmYLLabelsOn      = True

    ; res_1d@trYMinF           = 0
    ; res_1d@trYMaxF           = 9
    ; res_1d@tmYLTickStartF    = 0
    ; res_1d@tmYLTickEndF      = 9
    ; res_1d@tmYLTickSpacingF  = 3
    ; res_1d@tmYLAutoPrecision = False
    ; res_1d@tmYLPrecision     = 2

    ; res_1d@gsnLeftString   = REG_NAME(IDX_MIDWEST)
    ; res_1d@gsnCenterString = "Monthly-mean precipitation variation"
    ; res_1d@gsnRightString  = ""
    ; plot_pdf(0) = gsn_csm_xy(wks_pdf, time_x(0:N_YEAR*12-1), data_y(:, 0:N_YEAR*12-1), res_1d)


    ; Northeast
    data_y(0, 0:N_YEAR*12-1) = pr_obs_reg_ts_mly(IDX_NORTHEAST, 0:N_YEAR*12-1)
    data_y(1, 0:N_YEAR*12-1) = pr_mod_reg_ts_mly(IDX_NORTHEAST, 0:N_YEAR*12-1)

    res_1d@pmLegendDisplayMode = "Never"

    res_1d@tmYLMode          = "Manual"
    res_1d@tmYLLabelsOn      = True

    res_1d@trYMinF           = 0
    res_1d@trYMaxF           = 7
    res_1d@tmYLTickStartF    = 0
    res_1d@tmYLTickEndF      = 7
    res_1d@tmYLTickSpacingF  = 3.5
    res_1d@tmYLAutoPrecision = False
    res_1d@tmYLPrecision     = 2   

    res_1d@gsnLeftString   = REG_NAME(IDX_NORTHEAST)
    res_1d@gsnCenterString = "Monthly-mean precipitation variation"
    res_1d@gsnRightString  = ""
    plot_pdf(0) = gsn_csm_xy(wks_pdf, time_x(0:N_YEAR*12-1), data_y(:, 0:N_YEAR*12-1), res_1d)


    ; Cascade
    data_y(0, 0:N_YEAR*12-1) = pr_obs_reg_ts_mly(IDX_CASCADE, 0:N_YEAR*12-1)
    data_y(1, 0:N_YEAR*12-1) = pr_mod_reg_ts_mly(IDX_CASCADE, 0:N_YEAR*12-1)

    res_1d@pmLegendDisplayMode = "Always"

    res_1d@trYMinF           = 0
    res_1d@trYMaxF           = 15
    res_1d@tmYLTickStartF    = 0
    res_1d@tmYLTickEndF      = 15
    res_1d@tmYLTickSpacingF  = 5
    res_1d@tmYLAutoPrecision = False
    res_1d@tmYLPrecision     = 2

    res_1d@gsnLeftString   = REG_NAME(IDX_CASCADE)
    res_1d@gsnCenterString = ""
    res_1d@gsnRightString  = ""
    plot_pdf(1) = gsn_csm_xy(wks_pdf, time_x(0:N_YEAR*12-1), data_y(:, 0:N_YEAR*12-1), res_1d)

    gsn_panel(wks_pdf, plot_pdf(0:1), (/2, 1/), res_panel)

    exit()


    ; midwest, 1989 ~ 2008
    IDX_MIDWEST   = 3
    IDX_CASCADE   = 0
    IDX_NORTHEAST = 4

    do i_yr = 2002, 2002  ; START_YEAR, END_YEAR
        start_day = 1
        if (i_yr .eq. 1989) then
            start_day = 2
        end if

        end_day = 365
        x_max = (/120, 243, 365/)
        if (isleapyear(i_yr)) then
            end_day = 366
            x_max = x_max + 1
        end if

        data_y(0, start_day:end_day) = pr_obs_reg_ts(start_day-1:end_day-1, IDX_NORTHEAST, i_yr - 1989)
        data_y(1, start_day:end_day) = pr_mod_reg_ts(start_day-1:end_day-1, IDX_NORTHEAST, i_yr - 1989)

        res_1d@pmLegendDisplayMode    = "Always"

        res_1d@tmXBMode         = "Manual"
        res_1d@tmXBLabelsOn     = True

        res_1d@trXMinF          = 0
        res_1d@trXMaxF          = x_max(0)  ; 120
        res_1d@tmXBTickStartF   = 0
        res_1d@tmXBTickEndF     = x_max(0)  ; 120
        res_1d@tmXBTickSpacingF = 10

        res_1d@gsnLeftString   = REG_NAME(IDX_NORTHEAST)
        res_1d@gsnCenterString = "Daily-mean precipitation variation"
        res_1d@gsnRightString  = "JFMA, " + sprinti("%0.4i", i_yr)
        plot_pdf(0) = gsn_csm_xy(wks_pdf, time_x(start_day:x_max(0)), data_y(:, start_day-1:x_max(0) - 1), res_1d)

        res_1d@pmLegendDisplayMode = "Never"

        res_1d@trXMinF          = x_max(0) + 1  ; 121
        res_1d@trXMaxF          = x_max(1)      ; 243
        res_1d@tmXBTickStartF   = 120
        res_1d@tmXBTickEndF     = x_max(1)      ; 243
        res_1d@tmXBTickSpacingF = 10

        res_1d@gsnCenterString = ""
        res_1d@gsnRightString  = "MJJA, " + sprinti("%0.4i", i_yr)
        plot_pdf(1) = gsn_csm_xy(wks_pdf, time_x(x_max(0)+1:x_max(1)), data_y(:, x_max(0):x_max(1)-1), res_1d)

        res_1d@trXMinF          = x_max(1) + 1  ; 244
        res_1d@trXMaxF          = x_max(2)      ; 365
        res_1d@tmXBTickStartF   = 240
        res_1d@tmXBTickEndF     = x_max(2)      ; 365
        res_1d@tmXBTickSpacingF = 10

        res_1d@gsnRightString  = "SOND, " + sprinti("%0.4i", i_yr)
        plot_pdf(2) = gsn_csm_xy(wks_pdf, time_x(x_max(1) + 1:x_max(2)), data_y(:, x_max(1):x_max(2) - 1), res_1d)

        gsn_panel(wks_pdf, plot_pdf(0:2), (/3, 1/), res_panel)
    end do
end
