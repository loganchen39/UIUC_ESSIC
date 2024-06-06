load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; load "/u0/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "/u0/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "/u0/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ; data window/  20,  36, 85, 121   ; Cascade
    ;            ,  42,  62, 89, 117   ; North Rockies
    ;            ,  74,  91, 55,  90   ; Central Great Plain
    ;            , 104, 133, 66,  93   ; Midwest
    ;            , 139, 166, 80, 116   ; Northeast
    ;            , 134, 155, 28,  69   ; Southeast
    ;            ,  94, 128, 39,  63   ; Coast States
    ;            ,  51,  70, 16,  70/  ; NAM 

    OBS_PR_DIR    = "/project/projectdirs/cwrf/cwrf/observation/pr"

    SIM_PR_DIR    = "/scratch/scratchdirs/lgchen/data/sim_1993/pr_daily/pr_daily_ln"
    SIM_CASE_NUM  = 1 + 1 + 7 + 11 + 9 + 10 + 10  ; = 49 = Avg + CTL + bl + cu + mp + ra + sf
    SIM_CASE_LIST = (/"Avg", "CTL", "acm", "boulac", "gfs", "myj", "qnse", "uw", "ysu"        \
                  ,   "bmj_cwp3", "ctl_scuOff", "cu1", "cu1_ishall0", "run_cu10_mit"          \
                  ,   "run_cu2_bmj", "run_cu4_gd", "run_cu5_gdl", "run_cu7_zml"               \
                  ,   "run_cu8_randall", "run_cu9_gfdl"                                       \
                  ,   "mp02", "mp04", "mp05", "mp06", "mp07", "mp10", "mp15", "mp16", "mp86"  \
                  ,   "cam", "cccma", "csiro", "eta", "fuliou", "gsfclxz_aerosol0"            \
                  ,   "gsfclxz_newemis", "ragfdl", "rrtmg", "rrtmlw_gsfcsw"                   \
                  ,   "CWRF-CSSP", "CWRF-NOAH", "CWRF-PX", "ECMWF", "NARR", "WRF-NOAH"        \
                  ,   "WRF-PX", "run_noBLORO", "uom", "uom_caladv"/)

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
    REG_CEN  = new ((/REG_NUM, 2/), "integer")
    do i_reg = 0, REG_NUM - 1
        REG_CEN(i_reg, 0) = (REG_WIN(i_reg, 0) + REG_WIN(i_reg, 2)) / 2
        REG_CEN(i_reg, 1) = (REG_WIN(i_reg, 1) + REG_WIN(i_reg, 3)) / 2
    end do

    NX = 195
    NY = 138

    ; main data structure
    tmp_pr              = new ((/396,          NY, NX/), "float")

    obs_pr              = new ((/396, REG_NUM,  5,  5/), "float")
    obs_pr_avg_reg_5by5 = new ((/396, REG_NUM/)        , "float")
    obs_pr_avg_reg      = new ((/396, REG_NUM/)        , "float")

    sim_pr              = new ((/396, SIM_CASE_NUM, REG_NUM  ,  5,  5/), "float")
    sim_pr_avg_reg_5by5 = new ((/396, SIM_CASE_NUM, REG_NUM/)          , "float")
    sim_pr_avg_reg      = new ((/396, SIM_CASE_NUM, REG_NUM/)          , "float")   

    ; time region
    ; YB = 1992
    ; MB = 12
    ; DB = 01
   
    ; YE = 1993 
    ; ME = 12
    ; DE = 31   
 
    ; tb = day_of_year(y, mb, db)  ; julian date of "20040401" =  92
    ; te = day_of_year(y, me, de)  ; julian date of "20041030" = 304
    ; nt = te - tb + 1
    ; print(nt)

    ; time       = int2flt(ispan(tb, te, 1)) - 1
    ; time@units = "days since " + sprinti("%4.4i", y) + "-" + sprinti("%2.2i", 1) + "-" + sprinti("%2.2i", 1) + " 00:00:0.0"
    ; timelist   = ut_calendar(time, -2)
    ; ; t        = ispan(tb + 1 + 1993*1000, te + 1 + 1993*1000, 1)
    ; t          = ispan(tb + 1, te + 1, 1)
    ; yyyymmdd   = yyyyddd_to_yyyymmdd(t)

    obs_pr@missingvalue = 1.e20
    obs_pr@_FillValue   = 1.e20
    sim_pr@missingvalue = 1.e20
    sim_pr@_FillValue   = 1.e20

    setfileoption("bin", "ReadByteOrder", "BigEndian")

    tmp_pr(0:365, :, :) = fbindirread(OBS_PR_DIR + "/LAND_OCEAN.pr_rate_daily.1992", 0, (/366, NY, NX/), "float")
    do i_reg = 0, REG_NUM - 1
        obs_pr_avg_reg(0:30, i_reg) = dim_avg_n(tmp_pr(0:30, REG_WIN(i_reg, 1):REG_WIN(i_reg, 3)  \
            , REG_WIN(i_reg, 0):REG_WIN(i_reg, 2)), (/1, 2/))
        obs_pr(0:30, i_reg, :, :) = tmp_pr(335:365 ,REG_CEN(i_reg, 1) - 2:REG_CEN(i_reg, 1) + 2  \
            , REG_CEN(i_reg, 0) - 2:REG_CEN(i_reg, 0) + 2)
        obs_pr_avg_reg_5by5(0:30, i_reg) = dim_avg_n(obs_pr(0:30, i_reg:i_reg, :, :), (/2, 3/))  ; lgchen: Ok?
    end do

    tmp_pr(0:364, :, :) = fbindirread(OBS_PR_DIR + "/LAND_OCEAN.pr_rate_daily.1993", 0, (/365, NY, NX/), "float")
    do i_reg = 0, REG_NUM - 1
        obs_pr_avg_reg(31:395, i_reg) = dim_avg_n(tmp_pr(0:364, REG_WIN(i_reg, 1):REG_WIN(i_reg, 3)  \
            , REG_WIN(i_reg, 0):REG_WIN(i_reg, 2)), (/1, 2/))
        obs_pr(31:395, i_reg, :, :) = tmp_pr(0:364, REG_CEN(i_reg, 1) - 2:REG_CEN(i_reg, 1) + 2  \
            , REG_CEN(i_reg, 0) - 2:REG_CEN(i_reg, 0) + 2)
        obs_pr_avg_reg_5by5(31:395, i_reg) = dim_avg_n(obs_pr(31:395, i_reg:i_reg, :, :), (/2, 3/))
    end do
        
    do i_case = 1, SIM_CASE_NUM - 1
        tmp_pr = fbindirread(SIM_PR_DIR + "/" + SIM_CASE_LIST(i_case) + "_PR_daily.bin", 0, (/396, NY, NX/), "float")
        do i_reg = 0, REG_NUM - 1
            sim_pr_avg_reg(:, i_case, i_reg) = dim_avg_n(tmp_pr(:, REG_WIN(i_reg, 1):REG_WIN(i_reg, 3)  \
                , REG_WIN(i_reg, 0):REG_WIN(i_reg, 2)), (/1, 2/))
            sim_pr(:, i_case, i_reg, :, :) = tmp_pr(:, REG_CEN(i_reg, 1) - 2:REG_CEN(i_reg, 1) + 2  \
                , REG_CEN(i_reg, 0) - 2:REG_CEN(i_reg, 0) + 2)
            sim_pr_avg_reg_5by5(:, i_case, i_reg) = dim_avg_n(sim_pr(:, i_case:i_case, i_reg:i_reg, :, :), (/3, 4/))
        end do
    end do

    ; average
    do i_reg = 0, REG_NUM - 1
        sim_pr_avg_reg(:, 0, i_reg)      = dim_avg_n(sim_pr_avg_reg(:, 1:SIM_CASE_NUM-1, i_reg:i_reg), (/1/))
        sim_pr(:, 0, i_reg, :, :)        = dim_avg_n(sim_pr(:, 1:SIM_CASE_NUM-1, i_reg, :, :), (/1/))  ; lgchen: Ok?
        sim_pr_avg_reg_5by5(:, 0, i_reg) = dim_avg_n(sim_pr_avg_reg_5by5(:, 1:SIM_CASE_NUM-1, i_reg:i_reg), (/1/))
    end do

    time_x = ispan(1, 396, 1)
    ; data_y = new (/396, 2/)
    data_y = new ((/2, 396/), "float")


    ; DRAWING
               
    wks_pdf      = gsn_open_wks("pdf", "./TimeSeries_PR")
    plot_pdf_pr  = new (2, graphic)
  
    res          = True
    res@gsnDraw  = False  ; don't draw
    res@gsnFrame = False  ; don't advance frame
    ; res@trXMinF  = t(0) - 1
    ; res@trXMaxF  = t(dimsizes(t) - 1)
    res@txFont = "Helvetica"

    res@vpHeightF = 0.3  ; change aspect ratio of plot
    res@vpWidthF  = 1.0
    res@vpXF      = 0.05 ; originally 0.1
    res@vpYF      = 0.95 ; originally 0.9

    ; CALL NGSETI('LX', 50 )
    ; CALL NGSETI('LY', 50 )
    ; CALL NGSETI('UX', 742)
    ; CALL NGSETI('UY', 742)

    res@pmTickMarkDisplayMode = "Always"  ; "Never"

    res@tmYROn     = False
    res@tmXTOn     = False
    res@tmYLMinorOn = False
    res@tmXBMinorOn = False
    res@tmYLMajorLengthF = 0.008
    res@tmXBMajorLengthF = 0.008
    res@tmYLMajorOutwardLengthF = -0.002
    res@tmXBMajorOutwardLengthF = 0.008
    res@tmXBLabelDeltaF = -1.2
    res@tmYLLabelDeltaF = -1.2

    res@tmXBMode   = "Explicit"
    res@tmXBValues = (/1, 63, 122, 183, 244, 305, 366, 396/)
    res@tmXBLabels = (/921201, 930201, 930401, 930601, 930801, 931001, 931201, 931231/)
  
    res@tmLabelAutoStride = True  

    ; res@tmYLFormat = "0@*+^sg"

    res@xyDashPattern     = (/0, 1/)
    res@xyLineThicknesses = (/1.0, 1.0/)
    res@xyLineColors      = (/"black", "blue"/)

    do i_reg = 0, 0  ; REG_NUM - 1
        res@gsnRightString = REG_NAME(i_reg)

        do i_case = 0, 2  ; SIM_CASE_NUM - 1
            res@gsnLeftString = SIM_CASE_LIST(i_case)

            data_y(0, :)   = obs_pr(:, i_reg, 2, 2)
            data_y(1, :)   = sim_pr(:, i_case, i_reg, 2, 2)
            res@gsnCenterString = "Grid point: (2,2)"
            plot_pdf_pr(0) = gsn_csm_xy(wks_pdf, time_x, data_y, res)

            data_y(0, :)   = obs_pr_avg_reg_5by5(:, i_reg)
            data_y(1, :)   = sim_pr_avg_reg_5by5(:, i_case, i_reg)
            res@gsnCenterString = "Avg_Reg_5by5"
            plot_pdf_pr(1) = gsn_csm_xy(wks_pdf, time_x, data_y, res)

            gsn_panel(wks_pdf, plot_pdf_pr, (/2, 1/), False)

            data_y(0, :)   = obs_pr(:, i_reg, 2, 3)
            data_y(1, :)   = sim_pr(:, i_case, i_reg, 2, 3)
            res@gsnCenterString = "Grid point: (3, 2)"
            plot_pdf_pr(0) = gsn_csm_xy(wks_pdf, time_x, data_y, res)

            data_y(0, :)   = obs_pr_avg_reg(:, i_reg)
            data_y(1, :)   = sim_pr_avg_reg(:, i_case, i_reg)
            res@gsnCenterString = "Ave_Reg"
            plot_pdf_pr(1) = gsn_csm_xy(wks_pdf, time_x, data_y, res)

            gsn_panel(wks_pdf, plot_pdf_pr, (/2, 1/), False)                      
        end do
    end do    

end
