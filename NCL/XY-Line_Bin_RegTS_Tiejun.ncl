load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ; data window/  20,  36,  85, 121   ; Cascade
    ;            ,  42,  62,  89, 117   ; North Rockies
    ;            ,  74,  91,  55,  90   ; Central Great Plain
    ;            , 104, 133,  66,  93   ; Midwest
    ;            , 139, 166,  80, 116   ; Northeast
    ;            , 134, 155,  28,  69   ; Southeast
    ;            ,  94, 128,  39,  63   ; Coast States
    ;            ,  51,  70,  16,  70/  ; NAM 

    casename = "xy_1"
    r_name   = (/"Cascade","North Rockies","Central Great Plain",  \
                 "Midwest","Northeast","Southeast","Coast States","NAM"/)
    
    xb = (/ 20,  42,  74, 104, 139, 134,  94,  51/)
    xe = (/ 36,  62,  91, 133, 166, 155, 128,  70/)
    yb = (/ 85,  89,  55,  66,  80,  28,  39,  16/)
    ye = (/121, 117,  90,  93, 116,  69,  63,  70/)
    
    xb = xb - 1
    xe = xe - 1
    yb = yb - 1
    ye = ye - 1
    
    nt = 90
    nx = 195
    ny = 138
    
    tstart = 19930501
    tend   = 19930729
    
    setfileoption("bin", "ReadByteOrder", "BigEndian")
    t2m = fbindirread("./output/" + casename + "_T2M_daily", 0, (/nt, ny, nx/), "float")
    pr  = fbindirread("./output/" + casename + "_PR_daily" , 0, (/nt, ny, nx/), "float")
    
    tb = 121 -1  ; julian date of "19930501" = 121
    te = 210 -1  ; julian date of "19930729" = 210
    
    t        = ispan(121 + 1993*1000, 210 + 1993*1000,1)
    yyyymmdd = yyyyddd_to_yyyymmdd(t)
    
    t2mo_tmp = fbindirread("./1993_PR_T2M/obs_ta.195x138.daily.19930101", 0, (/365, ny, nx/), "float")
    pro_tmp  = fbindirread("./1993_PR_T2M/US_MEX.pr_rate_daily.19930101", 0, (/365, ny, nx/), "float")
    t2mo     = t2mo_tmp(tb:te, :, :)
    pro      = pro_tmp(tb:te, :, :)

    t2mo@missingvalue = 1.e20
    t2mo@_FillValue   = 1.e20
    copy_VarAtts(t2mo, pro)
    
    data = new((/2, dimsizes(t)/), "float")
    
    wks  = gsn_open_wks("ps", "./output/" + casename + "_1d")
    plot = new(8, graphic)
    
    res          = True
    res@gsnDraw  = False     ; don't draw
    res@gsnFrame = False     ; don't advance frame
    res@trXMinF  = t(0) - 1
    res@trXMaxF  = t(dimsizes(t) - 1)
    
    res@vpHeightF = 0.4  ; change aspect ratio of plot
    res@vpWidthF  = 0.8                  
    
    res@txFont    = "Helvetica"
    
    res@tmXBMode   = "Explicit"
    res@tmXBValues = (/120, 151, 182/) + 1993*1000
    res@tmXBLabels = (/930501, 930601, 930701/)
    
    res@tmLabelAutoStride = True
    
    v       = t2m - 273.15
    vo      = t2mo 
    lstring = " T2M "

    do i =0, 7
        v_1        = vo(:, yb(i):ye(i), xb(i):xe(i))
        v_11       = dim_avg(v_1)
        data(0, :) = dim_avg(v_11)
        v_1        = v(:, yb(i):ye(i), xb(i):xe(i))
        v_11       = dim_avg(v_1)
        data(1, :) = dim_avg(v_11)

        delete(v_1)
        delete(v_11)

        res@tiMainString   = r_name(i)
        res@gsnLeftString  = casename + lstring
        res@gsnRightString = "OBS:Soild MLD:Dash"
        plot(i) = gsn_csm_xy(wks, t, data, res)

        delete(res@gsnLeftString)
        delete(res@gsnRightString)
    end do

    gsn_panel(wks, plot, (/4, 2/), False)
    
    v       = pr
    vo      = pro 
    lstring = " PR "

    do i = 0, 7
        v_1        = vo(:, yb(i):ye(i), xb(i):xe(i))
        v_11       = dim_avg(v_1)
        data(0, :) = dim_avg(v_11)
        v_1        = v(:, yb(i):ye(i), xb(i):xe(i))
        v_11       = dim_avg(v_1)
        data(1, :) = dim_avg(v_11)

        delete(v_1)
        delete(v_11)

        res@tiMainString   = r_name(i)
        res@gsnLeftString  = casename + lstring
        res@gsnRightString = "OBS:Soild MLD:Dash"
        plot(i) = gsn_csm_xy(wks, t, data, res)

        delete(res@gsnLeftString)
        delete(res@gsnRightString)
    end do

    gsn_panel(wks, plot, (/4, 2/), False)
end
