; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/u0/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/u0/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/u0/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ; data window/  20,  36, 85, 121   ; Cascade
    ;            ,  42,  62, 89, 117   ; North Rockies
    ;            ,  74,  91, 55,  90   ; Central Great Plain
    ;            , 104, 133, 66,  93   ; Midwest
    ;            , 139, 166, 80, 116   ; Northeast
    ;            , 134, 155, 28,  69   ; Southeast
    ;            ,  94, 128, 39,  63   ; Coast States
    ;            ,  51,  70, 16,  70/  ; NAM 

    DATA_DIR = "/scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/data/model_forNOAA"  ; lgchen:
    CASE_NUM = 33  ; 33 = 31 + 2
    caselist = (/"ens-daily", "ave-daily", "cu0-nocu", "cu1-kf", "cu2-bmj", "cu4-gd",  \
                 "cu5-gdl", "cu8-randall", "cu9-gfdl", "cu99-pkf",                     \
                 "lsm-px", "mp02-lin",                                                 \
                 "mp03-wsm3", "mp04-ferrier", "mp05-wsm5",                             \
                 "mp15-wdm5", "mp16-wdm6", "mp86-reisner",                             \
                 "mp87-thompson_v3.0", "pbl-acm", "pbl-boulac", "pbl-cam", "pbl-gfs",  \
                 "pbl-myj", "pbl-qnse", "pbl-uw", "pbl-ysu", "rad-cam",                \
                 "rad-cccma", "rad-eta", "rad-fuliou", "rad-rrtmg",                    \
                 "rad-rrtmlw+gsfcsw"/)  ; lgchen: only without "mp07",

    r_name = (/"Cascade", "North Rockies", "Central Great Plain",  \
               "Midwest", "Northeast", "Southeast", "Coast States", "NAM"/)

    t2m_cc_best  = (/17, 18,  2, 14,  8, 19, 20,  2/)  
    t2m_rms_best = (/10, 18, 19, 18, 20, 20, 20, 21/)
    pr_cc_best   = (/ 3,  3, 10, 10, 25, 30,  4, 22/)
    pr_rms_best  = (/ 7, 30, 30,  7,  7,  3,  7, 30/) 

    xb = (/ 20,  42,  74, 104, 139, 134,  94,  51/)
    xe = (/ 36,  62,  91, 133, 166, 155, 128,  70/)
    yb = (/ 85,  89,  55,  66,  80,  28,  39,  16/)
    ye = (/121, 117,  90,  93, 116,  69,  63,  70/)
    xb = xb - 1
    xe = xe - 1
    yb = yb - 1
    ye = ye - 1
    
    y  = 1993
    mb = 05
    db = 01
    
    me = 07
    de = 28
    
    ; time region
    
    tstart = y*10000 + mb*100 + db
    tend   = y*10000 + me*100 + de
    
    nx = 195
    ny = 138

    tb = day_of_year(y, mb, db)  ; -1 ; julian date of "20040401" =  92
    te = day_of_year(y, me, de)  ; -1 ; julian date of "20041030" = 304
    nt = te - tb + 1
    print(nt)

    time       = int2flt(ispan(tb, te, 1)) - 1
    time@units = "days since " + sprinti("%4.4i", y) + "-" + sprinti("%2.2i", 1) + "-" + sprinti("%2.2i", 1) + " 00:00:0.0"
    timelist   = ut_calendar(time, -2)
    ; t = ispan(tb + 1 + 1993*1000, te + 1 + 1993*1000, 1)
    t          = ispan(tb + 1, te + 1, 1)
    yyyymmdd   = yyyyddd_to_yyyymmdd(t)


    setfileoption("bin", "ReadByteOrder", "BigEndian")

    obsdir   = "/scratch/scratchdirs/lgchen/data/obs_qiao" 
    pro_tmp  = fbindirread(obsdir + "/LAND_OCEAN.pr_rate_daily.1993", 0, (/365, ny, nx/), "float")
    t2mo_tmp = fbindirread(obsdir + "/stm_prism_ta_30km_daily.1993m", 0, (/365, ny, nx/), "float")
    t2mo     = t2mo_tmp(tb:te, :, :)
    pro      = pro_tmp (tb:te, :, :)

    t2mo@missingvalue = 1.e20
    t2mo@_FillValue   = 1.e20
    copy_VarAtts(t2mo, pro)
    
    obs_t2m = new ((/8,           dimsizes(t)/), "float")
    obs_pr  = new ((/8,           dimsizes(t)/), "float")
    mdl_t2m = new ((/8, CASE_NUM, dimsizes(t)/), "float")
    mdl_pr  = new ((/8, CASE_NUM, dimsizes(t)/), "float")

    do iff = 0, CASE_NUM - 1  ; dimsize(caselist) - 1 
        casename = caselist(iff)
  
        t2m = fbindirread(DATA_DIR + "/at2m_" + casename + "_19930502-19930730.bin", 0, (/nt, ny, nx/), "float")
        pr  = fbindirread(DATA_DIR + "/rain_" + casename + "_19930502-19930730.bin", 0, (/nt, ny, nx/), "float")
        
        t2m@missingvalue = 1.e20
        t2m@_FillValue   = 1.e20

        vo = t2mo 
        v  = t2m - 273.15
        if (iff .eq. 0) then
            v = v + 273.15
        end if

        do i = 0, 7
            v_1  = vo(:, yb(i):ye(i), xb(i):xe(i))  ; t2mo, obs
            v_11 = dim_avg(v_1)
            if (iff .eq. 0) then
                obs_t2m(i, :) = dim_avg(v_11)
            end if

            v_1                = v(:, yb(i):ye(i), xb(i):xe(i))  ; t2m, mdl
            v_11               = dim_avg(v_1)
            mdl_t2m(i, iff, :) = dim_avg(v_11)  ; lgchen
           
            delete(v_1)
            delete(v_11)
        end do

        vo = pro 
        v  = pr

        do i = 0, 7
            v_1  = vo(:, yb(i):ye(i), xb(i):xe(i))  ; pro, obs
            v_11 = dim_avg(v_1)
            if (iff .eq. 0) then
                obs_pr(i, :) = dim_avg(v_11)
            end if           

            v_1               = v(:, yb(i):ye(i), xb(i):xe(i))  ; pr, mdl
            v_11              = dim_avg(v_1)
            mdl_pr(i, iff, :) = dim_avg(v_11)

            delete(v_1)
            delete(v_11)
        end do         
    end do  ; end of the loop for 41 cases

    
    ; DRAWING
               
    wks_pdf      = gsn_open_wks("pdf", "./TimeSeries_pr_t2m")
    plot_pdf     = new (2, graphic)
    plot_pdf_t2m = new (8, graphic)
    plot_pdf_pr  = new (8, graphic)
  
    res          = True
    res@gsnDraw  = False  ; don't draw
    res@gsnFrame = False  ; don't advance frame
    res@trXMinF  = t(0) - 1
    res@trXMaxF  = t(dimsizes(t) - 1)

    res@vpHeightF = 0.4              ; change aspect ratio of plot
    res@vpWidthF  = 0.8                  
    
    res@txFont = "Helvetica"
    ; res@pmTickMarkDisplayMode = "Never"
  
    ; res@tmXBMode   = "Explicit"
    ; res@tmXBValues =(/122, 153, 183, 214, 275/)
    ; res@tmXBLabels =(/"Apr", "May", "Jun", "Jul", "Oct"/)
    ; res@tmXBMode   = "Explicit"
    ; res@tmXBValues = (/tb, te, 182/) + 1993*1000
    ; res@tmXBLabels = (/930501, 930601, 930701/)
  
    res@tmLabelAutoStride = True  

    ; res@tmYLFormat = "0@*+^sg"

    res@xyDashPattern     = 0
    res@xyLineThicknesses = (/2.0, 1.0, 1.0, 1.0, 1.0/)  ; first 3 lines: obs, ens, ctl, best cc, best rms
    res@xyLineColors      = (/"black", "red", "blue", "green", "brown"/)

    data_y = new ((/CASE_NUM + 1, dimsizes(t)/), "float")

    do i = 0, 7
        res@tiMainString   = r_name(i)

        res@gsnLeftString  = "PR"
        ; res@tiYAxisString = "PR mm/day"

        data_y(0, :) = obs_pr(i, :)
        data_y(1, :) = mdl_pr(i,              0, :)
        data_y(2, :) = mdl_pr(i,              1, :)
        data_y(3, :) = mdl_pr(i, pr_rms_best(i), :)
        data_y(4, :) = mdl_pr(i, pr_cc_best (i), :)
        plot_pdf_pr(i)  = gsn_csm_xy(wks_pdf, t, data_y(0:4, :), res)

        res@gsnLeftString  = "T2M"
        ; res@tiYAxisString = "T2M Celsius"

        data_y(0, :) = obs_t2m(i, :)
        data_y(1, :) = mdl_t2m(i,               0, :)
        data_y(2, :) = mdl_t2m(i,               1, :)
        data_y(3, :) = mdl_t2m(i, t2m_rms_best(i), :)
        data_y(4, :) = mdl_t2m(i, t2m_cc_best (i), :)
        plot_pdf_t2m(i) = gsn_csm_xy(wks_pdf, t, data_y(0:4, :), res)
    end do

    res_panel          = True
    res_panel@txString = "BLACK-obs, RED-ens, BLUE-ave, GREEN-rms_best, BROWN-cc_best"
    gsn_panel(wks_pdf, plot_pdf_t2m, (/4, 2/), res_panel)
    gsn_panel(wks_pdf, plot_pdf_pr , (/4, 2/), res_panel)

    delete(res@xyLineThicknesses)
    delete(res@xyLineColors)
    delete(res_panel@txString)

    res@xyDashPattern = 1    

    do i = 0, 7
        res@tiMainString      = r_name(i)
        res@xyLineThicknesses = (/2.0, 1.0, 1.0/)  ; first 3 curves: obs, ens, ave
        res@xyLineColors      = (/"black", "red", "blue"/)

        res@gsnLeftString = "T2M"

        data_y(0, :) = obs_t2m(i, :)
        data_y(1, :) = mdl_t2m(i,               0, :)
        data_y(2, :) = mdl_t2m(i,               1, :)

        ; data_y(3, :) = mdl_t2m(i,              26, :)
        ; data_y(4, :) = mdl_t2m(i, t2m_cc_best (i), :)
        ; data_y(5, :) = mdl_t2m(i, t2m_rms_best(i), :)
        j = 3
        do k = 2, CASE_NUM - 1
            ; if (k .ne. t2m_cc_best(i) .and. k .ne. t2m_rms_best(i)) then
            data_y(j, :) = mdl_t2m(i, k, :)
            j = j + 1
            ; end if
        end do
        plot_pdf_t2m(i) = gsn_csm_xy(wks_pdf, t, data_y, res)

        res@gsnLeftString  = "PR"

        data_y(0, :) = obs_pr(i, :)
        data_y(1, :) = mdl_pr(i,              0, :)
        data_y(2, :) = mdl_pr(i,              1, :)
        ; data_y(3, :) = mdl_pr(i,             26, :)
        ; data_y(4, :) = mdl_pr(i, pr_cc_best (i), :)
        ; data_y(5, :) = mdl_pr(i, pr_rms_best(i), :)
        j = 3
        do k = 2, CASE_NUM - 1
            ; if (k .ne. pr_cc_best(i) .and. k .ne. pr_rms_best(i)) then
            data_y(j, :) = mdl_pr(i, k, :)
            j = j + 1
            ; end if
        end do
        plot_pdf_pr(i)  = gsn_csm_xy(wks_pdf, t, data_y, res)       
    end do
    gsn_panel(wks_pdf, plot_pdf_t2m, (/4, 2/), res_panel)
    gsn_panel(wks_pdf, plot_pdf_pr , (/4, 2/), res_panel)

    delete(res@xyLineThicknesses)
    delete(res@xyLineColors)

    res@xyDashPatterns    = (/0, 1/) 
    res@xyLineThicknesses = (/2.0, 1.0/)  
    res@xyLineColors      = (/"black", "blue"/)
    do i = 0, CASE_NUM - 1
        do j = 0, 7
            res@tiMainString   = r_name(j)
            res@gsnRightString = caselist(i)

            res@gsnLeftString = "T2M"
            data_y(0, :)      = obs_t2m(j, :)
            data_y(1, :)      = mdl_t2m(j, i, :)
            plot_pdf_t2m(j)   = gsn_csm_xy(wks_pdf, t, data_y(0:1, :), res)

            res@gsnLeftString = "PR"
            data_y(0, :)      = obs_pr(j, :)
            data_y(1, :)      = mdl_pr(j, i, :)
            plot_pdf_pr(j)    = gsn_csm_xy(wks_pdf, t, data_y(0:1, :), res)
        end do
        gsn_panel(wks_pdf, plot_pdf_t2m, (/4, 2/), res_panel)
        gsn_panel(wks_pdf, plot_pdf_pr , (/4, 2/), res_panel)
    end do

    delete(data_y)
end