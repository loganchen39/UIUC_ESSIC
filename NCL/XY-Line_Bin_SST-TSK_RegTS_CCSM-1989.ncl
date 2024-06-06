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

    DIR_SST  = "/global/scratch/sd/lgchen/data/cwrf_input/ccsm2cwrf_1989"
    DIR_SIM  = "/global/scratch/sd/lgchen/projects/CWRFV3/cwrf_run/ccsm_test_1989_h2p-ncl_v0.1/ctl_test1"
    CASE_NUM = 1
    CASELIST = (/"CCSM"/)

    NDAY      = 364
    NMON      = 12
    MON_NM    = (/"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"/)
    MON_DIG   = (/"01" , "02" , "03" , "04" , "05" , "06" , "07" , "08" , "09" , "10" , "11" , "12" /)
    DOFM_ACCU = (/0, 31, 59   , 90   , 120  , 151  , 181  , 212  , 243  , 273  , 304  , 334  , 364  /)

    NREG       = 8
    REG_NM     = (/"Cascade"  , "North Rockies", "Central Great Plain", "Midwest",  \
                   "Northeast", "Southeast"    , "Coast States"       , "NAM"     /)
    REG_WINDOW = (/(/ 20,  85,  36, 121/)  \  ; (xb, yb, xe, ye) 
               ,   (/ 42,  89,  62, 117/)  \
               ,   (/ 74,  55,  91,  90/)  \
               ,   (/104,  66, 133,  93/)  \
               ,   (/139,  80, 166, 116/)  \
               ,   (/134,  28, 155,  69/)  \
               ,   (/ 94,  39, 128,  63/)  \
               ,   (/ 51,  16,  70,  70/)/)
    REG_WINDOW = REG_WINDOW - 1

    N_SEA_REG   = 3
    SEA_REG_NM  = (/"Lft_Btm", "Mdl_Btm", "Rgt_Top"/)
    SEA_REG_WIN = (/(/16, 16, 30, 30/)  \  ; (xb, yb, xe, ye)
                , (/104, 16, 128, 36/)  \
                , (/168, 80, 178, 90/)/)
    SEA_REG_WIN = SEA_REG_WIN - 1

    N_SEA_PT    = 5
    SEA_PT_IDX  = (/(/20, 60/), (/23, 23/), (/116, 26/), (/166, 49/), (/173, 85/)/)
    SEA_PT_IDX  = SEA_PT_IDX - 1

    NX = 195
    NY = 138

    SPV = 1.0E20
    
    yr = 1989
    ; mb = 01
    ; db = 01
    ; me = 01
    ; de = 31

    ; time region
    ; tstart = yr*10000 + mb*100 + db
    ; tend   = yr*10000 + me*100 + de
    ; 
    ; tb = day_of_year(y, mb, db)  ; -1 ; julian date of "20040401" =  92
    ; te = day_of_year(y, me, de)  ; -1 ; julian date of "20041030" = 304
    ; nt = te - tb + 1
    ; print(nt)

    ; time       = int2flt(ispan(tb, te, 1)) - 1
    ; time@units = "days since " + sprinti("%4.4i", y) + "-" + sprinti("%2.2i", 1)  \
    ;     + "-" + sprinti("%2.2i", 1) + " 00:00:0.0"
    ; timelist   = ut_calendar(time, -2)
    ; ; t        = ispan(tb + 1 + 1993*1000, te + 1 + 1993*1000, 1)
    ; t          = ispan(tb + 1, te + 1, 1)
    ; yyyymmdd   = yyyyddd_to_yyyymmdd(t)

    sst_reg_ts_dly = new ((/N_SEA_REG, NDAY  /), "float")
    tsk_reg_ts_dly = new ((/N_SEA_REG, NDAY  /), "float")
    tsk_reg_ts_hly = new ((/N_SEA_REG, NDAY*8/), "float")

    sst_pt_ts_dly  = new ((/N_SEA_PT , NDAY  /), "float")
    tsk_pt_ts_dly  = new ((/N_SEA_PT , NDAY  /), "float")
    tsk_pt_ts_hly  = new ((/N_SEA_PT , NDAY*8/), "float")

    sst_reg_ts_dly = 0.0
    tsk_reg_ts_dly = 0.0
    tsk_reg_ts_hly = 0.0
    
    sst_pt_ts_dly  = 0.0
    tsk_pt_ts_dly  = 0.0
    tsk_pt_ts_hly  = 0.0

    sst_reg_ts_dly@missingvalue = SPV
    sst_reg_ts_dly@_FillValue   = SPV
    copy_VarAtts(sst_reg_ts_dly, tsk_reg_ts_dly)
    copy_VarAtts(sst_reg_ts_dly, tsk_reg_ts_hly)
    copy_VarAtts(sst_reg_ts_dly, sst_pt_ts_dly )
    copy_VarAtts(sst_reg_ts_dly, tsk_pt_ts_dly )
    copy_VarAtts(sst_reg_ts_dly, tsk_pt_ts_hly )

    var_mly = new ((/32, NY, NX/), "float")
    var_dly = new ((/8 , NY, NX/), "float")


    setfileoption("bin", "ReadByteOrder", "BigEndian")

    ; read-in sst
    do i_mon = 0, NMON - 1
        cmon   = sprinti("%0.2i", i_mon + 1)
        print("cmon = " + cmon)
        fn_sst = "wrfsst_d01.1989" + cmon + "0100.nc"
        fh_sst = addfile(DIR_SST + "/" + fn_sst, "r")
        dofm   = DOFM_ACCU(i_mon + 1) - DOFM_ACCU(i_mon)
        print("dofm = " + dofm + ", SSTB: ")
        printVarSummary(fh_sst->SSTB)
        var_mly(0:dofm, :, :) = fh_sst->SSTB - 273.15
        
        do i_sea_reg = 0, N_SEA_REG - 1
            xb = SEA_REG_WIN(i_sea_reg, 0)
            yb = SEA_REG_WIN(i_sea_reg, 1)
            xe = SEA_REG_WIN(i_sea_reg, 2)
            ye = SEA_REG_WIN(i_sea_reg, 3)
            
            sst_reg_ts_dly(i_sea_reg, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon + 1)-1) =  \
                dim_avg_n(var_mly(0:dofm - 1, yb:ye, xb:xe), (/1, 2/))
        end do
 
        do i_sea_pt = 0, N_SEA_PT - 1
            sst_pt_ts_dly(i_sea_pt, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon + 1)-1) =  \
                var_mly(0:dofm - 1, SEA_PT_IDX(i_sea_pt, 1), SEA_PT_IDX(i_sea_pt, 0))
        end do
	end do

    ; read-in tsk
    do i_mon = 0, NMON - 1
        cmon   = sprinti("%0.2i", i_mon + 1)
        dofm   = DOFM_ACCU(i_mon + 1) - DOFM_ACCU(i_mon)

        do i_day = 0, dofm - 1
            cday      = sprinti("%0.2i", i_day + 1)
            dofy      = DOFM_ACCU(i_mon) + i_day
            print("dofy = " + dofy)
            fn_wrfout = "wrfout_d01_1989-" + cmon + "-" + cday + "_00:00:00.nc"
            fh_wrfout = addfile(DIR_SIM + "/" + fn_wrfout, "r")
            var_dly   = fh_wrfout->TSK - 273.15

            do i_sea_reg = 0, N_SEA_REG - 1
                xb = SEA_REG_WIN(i_sea_reg, 0)
                yb = SEA_REG_WIN(i_sea_reg, 1)
                xe = SEA_REG_WIN(i_sea_reg, 2)
                ye = SEA_REG_WIN(i_sea_reg, 3)
               
                tsk_reg_ts_hly(i_sea_reg, 8*dofy : 8*dofy + 7) =  \
                    dim_avg_n(var_dly(:, yb:ye, xb:xe), (/1, 2/))
                print("i_mon = " + i_mon + ", i_day = " + i_day + ", i_sea_reg = " + i_sea_reg)
                tsk_reg_ts_dly(i_sea_reg, dofy) = avg(var_dly(:, yb:ye, xb:xe))
            end do

            do i_sea_pt = 0, N_SEA_PT - 1
                tsk_pt_ts_hly(i_sea_pt, 8*dofy : 8*dofy + 7) =  \
                    var_dly(:, SEA_PT_IDX(i_sea_pt, 1), SEA_PT_IDX(i_sea_pt, 0))
                tsk_pt_ts_dly(i_sea_pt, dofy) =  \
                    dim_avg(var_dly(:, SEA_PT_IDX(i_sea_pt, 1), SEA_PT_IDX(i_sea_pt, 0)))
            end do
        end do
    end do 

    
    ; DRAWING
               
    wks_pdf  = gsn_open_wks("pdf", "./Sea-Reg-TS_SST-TSK")
    plot_pdf = new (4, graphic)
    ; plot_pdf_t2m = new (4, graphic)
  
    res          = True
    res@gsnDraw  = False  ; don't draw
    res@gsnFrame = False  ; don't advance frame

    res@vpWidthF  = 0.75
    res@vpHeightF = 0.12  ; change aspect ratio of plot
    res@vpXF      = 0.1
    ; res@vpYF    = 0.9
 
    ; res@txFont = "Helvetica"
    ; res@pmTickMarkDisplayMode = "Never"
    ; res@trXMinF  = t(0) - 1
    ; res@trXMaxF  = t(dimsizes(t) - 1)

    res@tmYROn      = False
    res@tmXTOn      = False
    res@tmYLMinorOn = False
    res@tmXBMinorOn = False
    res@tmXBMajorLengthF = 0.005
    res@tmYLMajorLengthF = 0.005
    ; res@tmXBMajorOutwardLengthF = -0.002
    res@tmYLMajorOutwardLengthF = -0.002
    res@tmXBLabelDeltaF = -1.2
    res@tmYLLabelDeltaF = -1.2

    res@tmXBMode = "Manual"  ; "Explicit"
    
    ; res@tmXBMode   = "Explicit"
    ; res@tmXBValues =(/122, 153, 183, 214, 275/)
    ; res@tmXBLabels =(/"Apr", "May", "Jun", "Jul", "Oct"/)
    ; res@tmXBMode   = "Explicit"
    ; res@tmXBValues = (/tb, te, 182/) + 1993*1000
    ; res@tmXBLabels = (/930501, 930601, 930701/)
  
    ; res@tmLabelAutoStride = True  

    ; res@tmYLFormat = "0@*+^sg"

    res@xyDashPattern     = (/0  , 1  , 3  /)
    res@xyLineThicknesses = (/2.0, 2.0, 2.0/)
    res@xyLineColors      = (/"black", "red", "blue"/)  ; order: sst, tsk_dly, tsk_hly

    y_data = new ((/2, 31/), "float")

    do i_sea_reg = 0, N_SEA_REG - 1
        res@gsnLeftString = "Region_avg: " + SEA_REG_NM(i_sea_reg)

        do i_mon = 0, 3
            res@gsnRightString = MON_NM(i_mon)
            dofm   = DOFM_ACCU(i_mon + 1) - DOFM_ACCU(i_mon)
            ; x_time = ispan(DOFM(i_mon) + 1, DOFM(i_mon + 1), 1)
            x_time = ispan(1, dofm, 1)

            res@tmXBTickStartF   = 1
            res@tmXBTickEndF     = dofm
            res@tmXBTickSpacingF = 1
            res@tmXBLabelsOn   = False

            y_data(0, 0:dofm-1) = sst_reg_ts_dly(i_sea_reg, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
            y_data(1, 0:dofm-1) = tsk_reg_ts_dly(i_sea_reg, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
           
            plot_pdf(i_mon) = gsn_csm_xy(wks_pdf, x_time, y_data, res) 

            delete(x_time)
        end do
        gsn_panel(wks_pdf, plot_pdf, (/4, 1/), False)

        do i_mon = 4, 7
            res@gsnRightString = MON_NM(i_mon)
            dofm   = DOFM_ACCU(i_mon + 1) - DOFM_ACCU(i_mon)
            ; x_time = ispan(DOFM(i_mon) + 1, DOFM(i_mon + 1), 1)
            x_time = ispan(1, dofm, 1)

            res@tmXBTickStartF   = 1
            res@tmXBTickEndF     = dofm
            res@tmXBTickSpacingF = 1
            ; res@tmXBLabelsOn   = False

            y_data(0, 0:dofm-1) = sst_reg_ts_dly(i_sea_reg, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
            y_data(1, 0:dofm-1) = tsk_reg_ts_dly(i_sea_reg, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
           
            plot_pdf(i_mon-4) = gsn_csm_xy(wks_pdf, x_time, y_data, res) 
 
            delete(x_time)
        end do
        gsn_panel(wks_pdf, plot_pdf, (/4, 1/), False)

        do i_mon = 8, 11
            res@gsnRightString = MON_NM(i_mon)
            dofm   = DOFM_ACCU(i_mon + 1) - DOFM_ACCU(i_mon)
            x_time = ispan(1, dofm, 1)

            res@tmXBTickStartF   = 1
            res@tmXBTickEndF     = dofm
            res@tmXBTickSpacingF = 1
            ; res@tmXBLabelsOn   = False

            y_data(0, 0:dofm-1) = sst_reg_ts_dly(i_sea_reg, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
            y_data(1, 0:dofm-1) = tsk_reg_ts_dly(i_sea_reg, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
           
            plot_pdf(i_mon-8) = gsn_csm_xy(wks_pdf, x_time, y_data, res) 
 
            delete(x_time)
        end do
        gsn_panel(wks_pdf, plot_pdf, (/4, 1/), False)
    end do

    do i_sea_pt = 0, N_SEA_PT - 1
        res@gsnLeftString = "Point: " + sprinti("%0.1i", i_sea_pt + 1)

        do i_mon = 0, 3
            res@gsnRightString = MON_NM(i_mon)
            dofm   = DOFM_ACCU(i_mon + 1) - DOFM_ACCU(i_mon)
            x_time = ispan(1, dofm, 1)

            res@tmXBTickStartF   = 1
            res@tmXBTickEndF     = dofm
            res@tmXBTickSpacingF = 1
            res@tmXBLabelsOn   = False

            y_data(0, 0:dofm-1) = sst_pt_ts_dly(i_sea_pt, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
            y_data(1, 0:dofm-1) = tsk_pt_ts_dly(i_sea_pt, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
           
            plot_pdf(i_mon) = gsn_csm_xy(wks_pdf, x_time, y_data, res) 

            delete(x_time)
        end do
        gsn_panel(wks_pdf, plot_pdf, (/4, 1/), False)

        do i_mon = 4, 7
            res@gsnRightString = MON_NM(i_mon)
            dofm   = DOFM_ACCU(i_mon + 1) - DOFM_ACCU(i_mon)
            x_time = ispan(1, dofm, 1)

            res@tmXBTickStartF   = 1
            res@tmXBTickEndF     = dofm
            res@tmXBTickSpacingF = 1
            res@tmXBLabelsOn     = False

            y_data(0, 0:dofm-1) = sst_pt_ts_dly(i_sea_pt, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
            y_data(1, 0:dofm-1) = tsk_pt_ts_dly(i_sea_pt, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
           
            plot_pdf(i_mon-4) = gsn_csm_xy(wks_pdf, x_time, y_data, res) 
 
            delete(x_time)
        end do
        gsn_panel(wks_pdf, plot_pdf, (/4, 1/), False)

        do i_mon = 8, 11
            res@gsnRightString = MON_NM(i_mon)
            dofm   = DOFM_ACCU(i_mon + 1) - DOFM_ACCU(i_mon)
            x_time = ispan(1, dofm, 1)

            res@tmXBTickStartF   = 1
            res@tmXBTickEndF     = dofm
            res@tmXBTickSpacingF = 1
            res@tmXBLabelsOn     = False

            y_data(0, 0:dofm-1) = sst_pt_ts_dly(i_sea_pt, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
            y_data(1, 0:dofm-1) = tsk_pt_ts_dly(i_sea_pt, DOFM_ACCU(i_mon):DOFM_ACCU(i_mon+1)-1)
           
            plot_pdf(i_mon-8) = gsn_csm_xy(wks_pdf, x_time, y_data, res) 
 
            delete(x_time)
        end do
        gsn_panel(wks_pdf, plot_pdf, (/4, 1/), False)
    end do

end
