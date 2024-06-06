load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    DATA_SIM_ROOT = "/scratch2/scratchdirs/zfsu79/CWRF_RUN/results" 
    DATA_SIM      = (/"cam", "cccma", "eta", "fuliou", "gsfclxz", "rrtmg", "rrtmlw+gsfcsw"/)
    DATA_OBS_ROOT = "/scratch2/scratchdirs/zfsu79/CWRF_RUN/results"
    DATA_OBS_RAD  = "ISCCP" 
    DATA_OBS_RT   = "observation"  ; rain and surface air temprature t2m
    
    VAR = (/"ASWUPT", "ALWUPT", "ASWDNS", "ALWDNS", "ASWUPS", "ALWUPS"               \
        ,   "NSWS", "NLWS", "CRF_SW_TOA", "CRF_LW_TOA", "CRF_SW_SFC", "CRF_LW_SFC",  \
        ,   "PALB", "AT2M", "RAIN", "TCWP", "TCC"/) 

    ASWUPT     = 0  ; wanted it to be used as array indices, good try although never been used
    ALWUPT     = 1
    ASWDNS     = 2
    ALWDNS     = 3
    ASWUPS     = 4
    ALWUPS     = 5
    NSWS       = 6
    NLWS       = 7
    CRF_SW_TOA = 8
    CRF_LW_TOA = 9
    CRF_SW_SFC = 10
    CRF_LW_SFC = 11
    PALB       = 12
    AT2M       = 13
    RAIN       = 14
    TCWP       = 15
    TCC        = 16  
                       
    MONTH     = (/"May", "Jun", "Jul"/)
    MONTH_DIG = (/"05", "06", "07"/)
    DOFM      = (/31, 30, 30/)  ; try to use array and then loop to simplify the code

    NMONTH  = 3   ; in the order as defined
    NSCHEME = 7   ; in the order as defined 
    NVAR    = 17  ; in the order as defined
    NX      = 195
    NY      = 138
    
    data_obs = new ((/NMONTH, NVAR, NY, NX/), "float")  ; main data structure to store in/out/main data
    data_obs = 0.
    data_sim = new ((/NSCHEME, NMONTH, NVAR, NY, NX/), "float")
    data_sim = 0.

    data_rec_tmp = new ((/NMONTH, 3, NY, NX/), "float")  ; secondary data structure
    data_rec_tmp = 0.
    integer_tmp  = new ((/6/), "integer")
    integer_tmp  = 0

    ; read-in observation data first
    ; comment: we could read all these observation data in a loop with those named indices, then use them,
    ; and release the memory resource as soon as they are no longer used.

    setfileoption("bin","ReadByteOrder","BigEndian")  ; built-in function
    integer_tmp = (/6, 4, 2, 0, 3, 1/)  ; secondary integer array to apply loop thus simplify the code

    ; ASWUPT ~ ALWUPS, 6 in all
    do i = 0, 5
        do j = 0, 2
            data_obs(j, i, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RAD + "/"   \  ; read direct access binary file 
                                 + "rad93.grd", 14*j + integer_tmp(i), (/NY, NX/), "float")  ; written by Fortran with "recl" setting
        end do
    end do

    ; NSWS, NLWS
    do i = 0, 2
        data_obs(i, 6, :, :) = data_obs(i, 2, :, :) - data_obs(i, 4, :, :)
        data_obs(i, 7, :, :) = data_obs(i, 3, :, :) - data_obs(i, 5, :, :)
    end do 

    ; CRF_SW_TOA
    ; first read-in related variables in order: ASWDNT, ASWDNTC, ASWUPTC
    integer_tmp = (/5, 12, 13, 0, 0, 0/)

    do i = 0, 2
        do j = 0, 2  
            data_rec_tmp(j, i, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RAD + "/"  \
                                     + "rad93.grd", 14*j + integer_tmp(i), (/NY, NX/), "float")
        end do
    end do

    ; calculate CRF_SW_TOA
    do i = 0, 2
        data_obs(i, 8, :, :) = (data_rec_tmp(i, 0, :, :) - data_obs(i, 0, :, :))  \
                             - (data_rec_tmp(i, 1, :, :) - data_rec_tmp(i, 2, :, :))
    end do

    ; CRF_LW_TOA
    ; first read-in related variables in order: ALWUPTC
    data_rec_tmp = 0.

    do i = 0, 2 
        data_rec_tmp(i, 0, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RAD  \
                                 + "/" + "rad93.grd", 14*i + 11, (/NY, NX/), "float")
    end do

    ; calculate CRF_LW_TOA
    do i = 0, 2
        data_obs(i, 9, :, :) = (0. - data_obs(i, 1, :, :)) - (0. - data_rec_tmp(i, 0, :, :))
    end do

    ; CRF_SW_SFC
    ; first read-in related variables in order: ASWDNSC, ASWUPSC
    data_rec_tmp = 0.
    integer_tmp  = (/9, 10, 0, 0, 0, 0/)

    do i = 0, 1
        do j = 0, 2 
            data_rec_tmp(j, i, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RAD + "/"  \
                                     + "rad93.grd", 14*j + integer_tmp(i), (/NY, NX/), "float")
        end do
    end do

    ; calculate CRF_SW_SFC
    do i = 0, 2
        data_obs(i, 10, :, :) = (data_obs(i, 2, :, :) - data_obs(i, 4, :, :))  \
                              - (data_rec_tmp(i, 0, :, :) - data_rec_tmp(i, 1, :, :))
    end do

    ; CRF_LW_SFC
    ; first read-in related variables in order: ALWDNSC, ALWUPSC
    data_rec_tmp = 0.
    integer_tmp  = (/7, 8, 0, 0, 0, 0/)

    do i = 0, 1
        do j = 0, 2  
            data_rec_tmp(j, i, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RAD + "/"  \
                                     + "rad93.grd", 14*j + integer_tmp(i), (/NY, NX/), "float")
        end do
    end do

    ; calculate CRF_LW_SFC
    do i = 0, 2
        data_obs(i, 11, :, :) = (data_obs(i, 3, :, :) - data_obs(i, 5, :, :))  \
                              - (data_rec_tmp(i, 0, :, :) - data_rec_tmp(i, 1, :, :))
    end do

    ; PALB
    ; first read-in related variables in order: ASWDNT
    data_rec_tmp = 0.

    do i = 0, 2  
        data_rec_tmp(i, 0, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RAD  \
                                 + "/" + "rad93.grd", 14*i + 5, (/NY, NX/), "float")
    end do

    ; calculate PALB
    do i = 0, 2
        data_obs(i, 12, :, :) = data_obs(i, 0, :, :) / data_rec_tmp(i, 0, :, :)
    end do

    ; AT2M
    do i = 0, 2
        data_obs(i, 13, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RT  \
                              + "/" + "obs_ta.195x138.1993.monthly", i + 4     \
                              , (/NY, NX/), "float")
    end do

    ; RAIN
    do i = 0, 2
        data_obs(i, 14, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RT    \
                              + "/" + "US_MEX.pr_rate.195x138.monthly.19930112"  \
                              , i + 4, (/NY, NX/), "float")
    end do

    ;; leave TCWP and TCC alone here, another NCL script could deal with them as Feng ZHANG said.

    ; calculate result data from numerical simulation with several radiation schemes

    data_rec_tmp = 0.
    integer_tmp  = 0
    str_date_tmp = new ((/1/), string)

    do i = 0, NSCHEME - 1
        do j = 0, 2
            do k = 1, DOFM(j)
               
                str_date_tmp = k
                if (k .lt. 10)          
                    nc_name_tmp = "wrfout_d01_1993-" + MONTH_DIG(j) + "-0" + str_date_tmp + "_00:00:00.nc"
                else
                    nc_name_tmp = "wrfout_d01_1993-" + MONTH_DIG(j) + "-"  + str_date_tmp + "_00:00:00.nc"
                end if

                nc_file = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(i) + "/" + nc_name_tmp, "r")
                
                if (j .eq. 0 .and. k .eq. 1)
                    do m = 1, 7
                        data_sim(i, j, 0, :, :) = data_sim(i, j, 0, :, :) + nc_file->ASWUPT(m, :, :)
                        data_sim(i, j, 1, :, :) = data_sim(i, j, 1, :, :) + nc_file->ALWUPT(m, :, :)
                        data_sim(i, j, 2, :, :) = data_sim(i, j, 2, :, :) + nc_file->ASWDNS(m, :, :)
                        data_sim(i, j, 3, :, :) = data_sim(i, j, 3, :, :) + nc_file->ALWDNS(m, :, :)
                        data_sim(i, j, 4, :, :) = data_sim(i, j, 4, :, :) + nc_file->ASWUPS(m, :, :)
                        data_sim(i, j, 5, :, :) = data_sim(i, j, 5, :, :) + nc_file->ALWUPS(m, :, :)

                        data_sim(i, j, 6, :, :)  = data_sim(i, j, 6, :, :)   \
                                                 + nc_file->ASWDNS(m, :, :) - nc_file->ASWUPS(m, :, :)
                        data_sim(i, j, 7, :, :)  = data_sim(i, j, 7, :, :)   \
                                                 + nc_file->ALWDNS(m, :, :) - nc_file->ALWUPS(m, :, :)

                        data_sim(i, j, 8, :, :)  = data_sim(i, j, 8, :, :)   \
                                                 + (nc_file->ASWDNT (m, :, :) - nc_file->ASWUPT (m, :, :))  \
                                                 - (nc_file->ASWDNTC(m, :, :) - nc_file->ASWUPTC(m, :, :)) 
                        data_sim(i, j, 9, :, :)  = data_sim(i, j, 9, :, :)   \
                                                 + (nc_file->ALWDNT (m, :, :) - nc_file->ALWUPT (m, :, :))  \
                                                 - (nc_file->ALWDNTC(m, :, :) - nc_file->ALWUPTC(m, :, :)) 
                        data_sim(i, j, 10, :, :) = data_sim(i, j, 10, :, :)  \
                                                 + (nc_file->ASWDNS (m, :, :) - nc_file->ASWUPS (m, :, :))  \
                                                 - (nc_file->ASWDNSC(m, :, :) - nc_file->ASWUPSC(m, :, :)) 
                        data_sim(i, j, 11, :, :) = data_sim(i, j, 11, :, :)  \
                                                 + (nc_file->ALWDNS (m, :, :) - nc_file->ALWUPS (m, :, :))  \
                                                 - (nc_file->ALWDNSC(m, :, :) - nc_file->ALWUPSC(m, :, :)) 
                        
                        data_rec_tmp(j, 0, :, :) = data_rec_tmp(j, 0, :, :) + nc_file->ASWUPT(m, :, :)  ; for PALB
                        data_rec_tmp(j, 1, :, :) = data_rec_tmp(j, 1, :, :) + nc_file->ASWDNT(m, :, :)  ; for PALB

                        data_sim(i, j, 13, :, :) = data_sim(i, j, 13, :, :) + nc_file->AT2M(m, :, :)
                    end do
                else
                    do m = 0, 7
                        data_sim(i, j, 0, :, :) = data_sim(i, j, 0, :, :) + nc_file->ASWUPT(m, :, :)
                        data_sim(i, j, 1, :, :) = data_sim(i, j, 1, :, :) + nc_file->ALWUPT(m, :, :)
                        data_sim(i, j, 2, :, :) = data_sim(i, j, 2, :, :) + nc_file->ASWDNS(m, :, :)
                        data_sim(i, j, 3, :, :) = data_sim(i, j, 3, :, :) + nc_file->ALWDNS(m, :, :)
                        data_sim(i, j, 4, :, :) = data_sim(i, j, 4, :, :) + nc_file->ASWUPS(m, :, :)
                        data_sim(i, j, 5, :, :) = data_sim(i, j, 5, :, :) + nc_file->ALWUPS(m, :, :)

                        data_sim(i, j, 6, :, :)  = data_sim(i, j, 6, :, :)   \
                                                 + nc_file->ASWDNS(m, :, :) - nc_file->ASWUPS(m, :, :)
                        data_sim(i, j, 7, :, :)  = data_sim(i, j, 7, :, :)   \
                                                 + nc_file->ALWDNS(m, :, :) - nc_file->ALWUPS(m, :, :)

                        data_sim(i, j, 8, :, :)  = data_sim(i, j, 8, :, :)   \
                                                 + (nc_file->ASWDNT (m, :, :) - nc_file->ASWUPT (m, :, :))  \
                                                 - (nc_file->ASWDNTC(m, :, :) - nc_file->ASWUPTC(m, :, :)) 
                        data_sim(i, j, 9, :, :)  = data_sim(i, j, 9, :, :)   \
                                                 + (nc_file->ALWDNT (m, :, :) - nc_file->ALWUPT (m, :, :))  \
                                                 - (nc_file->ALWDNTC(m, :, :) - nc_file->ALWUPTC(m, :, :)) 
                        data_sim(i, j, 10, :, :) = data_sim(i, j, 10, :, :)  \
                                                 + (nc_file->ASWDNS (m, :, :) - nc_file->ASWUPS (m, :, :))  \
                                                 - (nc_file->ASWDNSC(m, :, :) - nc_file->ASWUPSC(m, :, :)) 
                        data_sim(i, j, 11, :, :) = data_sim(i, j, 11, :, :)  \
                                                 + (nc_file->ALWDNS (m, :, :) - nc_file->ALWUPS (m, :, :))  \
                                                 - (nc_file->ALWDNSC(m, :, :) - nc_file->ALWUPSC(m, :, :)) 

                        data_rec_tmp(j, 0, :, :) = data_rec_tmp(j, 0, :, :) + nc_file->ASWUPT(m, :, :) ; for PALB
                        data_rec_tmp(j, 1, :, :) = data_rec_tmp(j, 1, :, :) + nc_file->ASWDNT(m, :, :) ; for PALB

                        data_sim(i, j, 13, :, :) = data_sim(i, j, 13, :, :) + nc_file->AT2M(m, :, :)
                    end do         
                end if

            end do
          
            if (j .eq. 0)  ; May
                nc_name_tmp = "wrfout_d01_1993-06-01_00:00:00.nc"
                nc_file     = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(i) + "/" + nc_name_tmp, "r")

                data_sim(i, j, 0, :, :) = data_sim(i, j, 0, :, :) + nc_file->ASWUPT(0, :, :)
                data_sim(i, j, 1, :, :) = data_sim(i, j, 1, :, :) + nc_file->ALWUPT(0, :, :)
                data_sim(i, j, 2, :, :) = data_sim(i, j, 2, :, :) + nc_file->ASWDNS(0, :, :)
                data_sim(i, j, 3, :, :) = data_sim(i, j, 3, :, :) + nc_file->ALWDNS(0, :, :)
                data_sim(i, j, 4, :, :) = data_sim(i, j, 4, :, :) + nc_file->ASWUPS(0, :, :)
                data_sim(i, j, 5, :, :) = data_sim(i, j, 5, :, :) + nc_file->ALWUPS(0, :, :)

                data_sim(i, j, 6, :, :)  = data_sim(i, j, 6, :, :)   \
                                         + nc_file->ASWDNS(0, :, :) - nc_file->ASWUPS(0, :, :)
                data_sim(i, j, 7, :, :)  = data_sim(i, j, 7, :, :)   \
                                         + nc_file->ALWDNS(0, :, :) - nc_file->ALWUPS(0, :, :)

                data_sim(i, j, 8, :, :)  = data_sim(i, j, 8, :, :)   \
                                         + (nc_file->ASWDNT (0, :, :) - nc_file->ASWUPT (0, :, :))  \
                                         - (nc_file->ASWDNTC(0, :, :) - nc_file->ASWUPTC(0, :, :)) 
                data_sim(i, j, 9, :, :)  = data_sim(i, j, 9, :, :)   \
                                         + (nc_file->ALWDNT (0, :, :) - nc_file->ALWUPT (0, :, :))  \
                                         - (nc_file->ALWDNTC(0, :, :) - nc_file->ALWUPTC(0, :, :)) 
                data_sim(i, j, 10, :, :) = data_sim(i, j, 10, :, :)  \
                                         + (nc_file->ASWDNS (0, :, :) - nc_file->ASWUPS (0, :, :))  \
                                         - (nc_file->ASWDNSC(0, :, :) - nc_file->ASWUPSC(0, :, :)) 
                data_sim(i, j, 11, :, :) = data_sim(i, j, 11, :, :)  \
                                         + (nc_file->ALWDNS (0, :, :) - nc_file->ALWUPS (0, :, :))  \
                                         - (nc_file->ALWDNSC(0, :, :) - nc_file->ALWUPSC(0, :, :)) 
                    
                data_sim(i, j, 12, :, :) = data_rec_tmp(j, 0, :, :) / data_rec_tmp(j, 1, :, :)

                data_sim(i, j, 13, :, :) = data_sim(i, j, 13, :, :) + nc_file->AT2M(0, :, :)

                data_sim(i, j, 0:11, :, :) = data_sim(i, j, 0:11, :, :) / 248
                data_sim(i, j, 13  , :, :) = data_sim(i, j, 13  , :, :) / 248
            else  ; Jun, Jul
                data_sim(i, j, 12, :, :)   = data_rec_tmp(j, 0, :, :) / data_rec_tmp(j, 1, :, :)

                data_sim(i, j, 0:11, :, :) = data_sim(i, j, 0:11, :, :) / 240
                data_sim(i, j, 13  , :, :) = data_sim(i, j, 13  , :, :) / 240
            end if
        end do      
    end do

    ; RAIN
    
    do i = 0, NSCHEME - 1
        ; May
        nc_name_tmp              = "wrfout_d01_1993-06-01_00:00:00.nc"
        nc_file                  = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(i) + "/" + nc_name_tmp, "r")
        data_sim(i, 0, 14, :, :) = nc_file->RAINC(0, :, :) + nc_file->RAINNC(0, :, :)
        data_sim(i, 0, 14, :, :) = data_sim(i, 0, 14, :, :) / 31.

        ; Jun
        nc_name_tmp_1            = "wrfout_d01_1993-07-01_00:00:00.nc"
        nc_file_1                = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(i) + "/" + nc_name_tmp_1, "r")
        data_sim(i, 1, 14, :, :) = nc_file_1->RAINC(0, :, :) + nc_file_1->RAINNC(0, :, :)  \
                                 - (nc_file->RAINC(0, :, :) + nc_file->RAINNC(0, :, :)) 
        data_sim(i, 1, 14, :, :) = data_sim(i, 1, 14, :, :) / 30.

        ; Jul
        nc_name_tmp              = "wrfout_d01_1993-07-30_00:00:00.nc"
        nc_file                  = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(i) + "/" + nc_name_tmp, "r")
        data_sim(i, 2, 14, :, :) = nc_file->RAINC(7, :, :) + nc_file->RAINNC(7, :, :)  \
                                 - (nc_file_1->RAINC(0, :, :) + nc_file_1->RAINNC(0, :, :)) 
        data_sim(i, 2, 14, :, :) = data_sim(i, 2, 14, :, :) / 30.
    end do


    ; DRAWING

    ; wks_x11 = gsn_open_wks("x11", "radiation_flux_MJJ_1993")
    wks_pdf = gsn_open_wks("pdf", "radiation_flux_MJJ_1993")  ; ncgm(1), ps(up to 15), pdf(1), x11
    ; gsn_define_colormap(wks_x11, "gui_default")
    gsn_define_colormap(wks_pdf, "gui_default")  ; default: "hlu_default", 32 colors; gui_default: 24 colors
                                                 ; predefined color map: 87 in all; use named colors (around 752) 
                                                 ; and RGB triplets to create your own color map/table

    res          = True
    res@gsnDraw  = False        ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame = False        ; the frame will not be advanced when the gsn function is called
    res@txFont   = "Helvetica"  ; specifies the font used for the "TextItem" when txFontQuality is set 
                                ; to "High", 31 fonts which are categorized into 2 types: stroked using 
                                ; lines or filled as areas
    res@tfDoNDCOverlay = True   ; DataTransform = False; NDCViewport = True; NDCDataExtent
        
    res@mpLimitMode       = "Corners"  ; This resource of type NhlTMapLimitMode specifies how MapTransformation 
                                       ; determines the extent of the projected globe that is mapped into the 
                                       ; viewport area. 8 possible settings. 
    res@mpLeftCornerLatF  = 15.22807   ; with "Corners" option above, MapTransformation maps into the viewport 
                                       ; a rectangular area with one corner at the point mpLeftCornerLatF and 
                                       ; mpLeftCornerLonF, and the opposite corner at the point mpRightCornerLatF 
                                       ; and mpRightCornerLonF.
    res@mpLeftCornerLonF  = -120.7703  
    res@mpRightCornerLatF = 49.03231   ; latitude
    res@mpRightCornerLonF = -52.39819  ; longitude

    res@pmTickMarkDisplayMode = "Always"                  ; This resource of type NhlTAnnotationDisplayMode 
                                                          ; determines whether the plot object displays a TickMark object 
    res@mpFillOn              = False                     ; switch for drawing of MapPlot area fill
    res@mpOutlineDrawOrder    = "PostDraw"                ; This resource of type NhlTDrawOrder determines when 
                                                          ; MapPlot area outlines are drawn relative to other 
                                                          ; elements of the plot
    res@mpOutlineBoundarySets = "GeophysicalAndUSStates"  ; MapPlot will draw area outlines for geophysical features: 
                                                          ; continents, oceans, islands, and inland water areas; as 
                                                          ; well as the states of U.S.

    res@mpProjection        = "LambertConformal"          ; defines the projection used for the map transformation, 17 in all
    res@mpLambertParallel1F = 60.                         ; for lambert conformal projection
    res@mpLambertParallel2F = 30.
    res@mpLambertMeridianF  = -95.5                       ; central meridian (line of longitude in degrees) of lambert 
                                                          ; conformal projection

    res@cnLineLabelsOn    = False  ; if contour line labels will or will not appear in the contour plot
    res@cnFillOn          = True   ; whether the areas between contour levels are filled with a solid color
                                   ; if it's on, you can choose between three fill methods by setting the resource cnFillMode 
    res@cnLinesOn         = False  ; no contour lines will appear in the contour plot, regardless of the values contained in 
                                   ; the cnLevelFlags array resource 
    res@gsnSpreadColors   = True   ; If set to True when calling any gsn function that produces vectors and/or contours, 
                                   ; then the colors used will be spread across the whole color map. the color range is
                                   ; determined by gsnSpreadColorStart and gsnSpreadColorEnd
    res@lbLabelAutoStride = True   ; If true, LabelBar labels are checked for overlap before being drawn. If overlap would  
                                   ; otherwise occur, a stride is set through the labels such that overlap will be avoided.

    res@lbOrientation            = "Vertical"  ; whether the labelbar boxes are arranged horizontally in a row or vertically in a column.
    res@pmLabelBarOrthogonalPosF = -0.01       ; move label bar closer. pmLabelBarOrthogonalPosF sets the coordinate of the 
                                               ; base location of the LabelBar object annotation orthogonal to the current pmLabelBarSide.
    res@lbLabelStride            = 2           ; Determines which labels actually are rendered the LabelBar is drawn. For example, 
                                               ; if the stride is set to 2, only every other label will be drawn, starting with the first label.

    res@gsnAddCyclic = False  ; For geo-referenced data, a longitude cyclic point is added as a default to ensure a gap 
                              ; is not plotted at the Greenwich Meridian. This resource only applies to gsn_csm plotting 
                              ; routines that overlay data on a map.
    ; res@tfDoNDCOverlay = True  ; 

    
    ; plot_x11 = new (6, graphic)
    plot_pdf = new (8, graphic)

    do i = 0, 2
        res@cnLevelSelectionMode = "ManualLevels"  ; four methods for selecting the contour intervals displayed in a plot,
                                                   ; AutomaticLevels, ManualLevels, ExplicitLevels, EqualSpacedLevels

        ; ASWUPT 
        varString = "ASWUPT" 

        res@cnLevelSpacingF = 10.0   ; the spacing between contour intervals for ManualLevels and AutomaticLevels
        res@cnMinLevelValF  = 40.0   ; the lowest contour level for mode ManualLevels
        res@cnMaxLevelValF  = 240.0  ; the highest contour level for mode ManualLevels
 
        ; observation 
        res@gsnLeftString = "OBS " + varString  ; For any gsn_csm plotting routine, this resource adds the given string just 
                                                ; above the plot's upper boundary and left-justifies it
        res@gsnRightString = MONTH(i)  ; the same as gsnLeftString except right-justifies it.
        ; plot_x11(0) = gsn_csm_contour_map(wks_x11, data_obs(i, 0, :, :), res)
        plot_pdf(0) = gsn_csm_contour_map(wks_pdf, data_obs(i, 0, :, :), res)  ; Creates and draws a contour plot over a map

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 0, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)  ; Draws multiple plots of identical size on a single frame.

        ; difference
        res@cnLevelSpacingF = 5.0    
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
          res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
          plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 0, :, :)  \
                            - data_obs(i, 0, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)
     
        ; ALWUPT 
        varString = "ALWUPT" 

        res@cnLevelSpacingF = 10.0  
        res@cnMinLevelValF  = 160.0 
        res@cnMaxLevelValF  = 320.0 
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 1, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 1, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1) = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 1, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 1, :, :)  \
                              - data_obs(i, 1, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)   

        ; ASWDNS 
        varString = "ASWDNS" 

        res@cnLevelSpacingF = 10.0  
        res@cnMinLevelValF  = 150.0 
        res@cnMaxLevelValF  = 390.0 
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 2, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 2, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 2, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 2, :, :)  \
                              - data_obs(i, 2, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; ALWDNS 
        varString = "ALWDNS" 

        res@cnLevelSpacingF = 10.0   
        res@cnMinLevelValF  = 260.0  
        res@cnMaxLevelValF  = 420.0  
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 3, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 3, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 3, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0    
        res@cnMinLevelValF  = -50.0  
        res@cnMaxLevelValF  = 50.0   

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 3, :, :) \
                              - data_obs(i, 3, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; ASWUPS 
        varString = "ASWUPS" 

        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = 10.0  
        res@cnMaxLevelValF  = 90.0  
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 4, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 4, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 4, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1) = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 4, :, :)  \
                            - data_obs(i, 4, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; ALWUPS 
        varString = "ALWUPS" 

        res@cnLevelSpacingF = 10.0   
        res@cnMinLevelValF  = 320.0  
        res@cnMaxLevelValF  = 540.0  
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 5, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 5, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 5, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 5, :, :)  \
                              - data_obs(i, 5, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; NSWS
        varString = "NSWS" 

        res@cnLevelSpacingF = 10.0  
        res@cnMinLevelValF  = 160.0 
        res@cnMaxLevelValF  = 340.0 
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 6, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 6, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 6, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
          res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
          plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 6, :, :)  \
                            - data_obs(i, 6, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; NLWS 
        varString = "NLWS" 

        res@cnLevelSpacingF = 10.0   
        res@cnMinLevelValF  = -200.0 
        res@cnMaxLevelValF  = 0.0    
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 7, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 7, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 7, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 7, :, :)  \
                              - data_obs(i, 7, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; CRF_SW_TOA
        varString = "CRF_SW_TOA" 

        res@cnLevelSpacingF = 10.0  
        res@cnMinLevelValF  = -200.0
        res@cnMaxLevelValF  = -20.0 
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 8, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 8, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 8, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 8, :, :)  \
                              - data_obs(i, 8, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; CRF_LW_TOA
        varString = "CRF_LW_TOA" 

        res@cnLevelSpacingF = 10.0 
        res@cnMinLevelValF  = 10.0 
        res@cnMaxLevelValF  = 140.0
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 9, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 9, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 9, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
          res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
          plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 9, :, :)  \
                            - data_obs(i, 9, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; CRF_SW_SFC
        varString = "CRF_SW_SFC" 

        res@cnLevelSpacingF = 10.0   
        res@cnMinLevelValF  = -220.0 
        res@cnMaxLevelValF  = -20.0  
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 10, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 10, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 10, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
          res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
          plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 10, :, :)  \
                            - data_obs(i, 10, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; CRF_LW_SFC
        varString = "CRF_LW_SFC" 

        res@cnLevelSpacingF = 5.0  
        res@cnMinLevelValF  = 5.0  
        res@cnMaxLevelValF  = 70.0 
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 11, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 11, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 11, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 5.0   
        res@cnMinLevelValF  = -50.0 
        res@cnMaxLevelValF  = 50.0  

        do j = 0, NSCHEME - 1
          res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
          plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 11, :, :)  \
                            - data_obs(i, 11, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; PALB
        varString = "PALB" 

        res@cnLevelSpacingF = 0.05 
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 0.8  
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 12, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 12, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 12, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 0.05  
        res@cnMinLevelValF  = -0.5  
        res@cnMaxLevelValF  = 0.5   

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 12, :, :)  \
                              - data_obs(i, 12, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; AT2M
        varString = "AT2M" 

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 35.0 
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 13, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 13, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1) = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 13, :, :) - 273.15, res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 1.0    
        res@cnMinLevelValF  = -10.0  
        res@cnMaxLevelValF  = 10.0   

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 13, :, :)  \
                              - data_obs(i, 13, :, :) - 273.15, res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; RAIN
        varString = "RAIN" 

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 16.0 
 
        ; observation 
        res@gsnLeftString  = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        ; plot_x11(0)      = gsn_csm_contour_map(wks_x11, data_obs(i, 14, :, :), res)
        plot_pdf(0)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 14, :, :), res)

        ; simulation
        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 14, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)

        ; difference
        res@cnLevelSpacingF = 1.0   
        res@cnMinLevelValF  = -10.0 
        res@cnMaxLevelValF  = 10.0  

        do j = 0, NSCHEME - 1
            res@gsnLeftString = DATA_SIM(j) + " - OBS " + varString
            plot_pdf(j + 1)   = gsn_csm_contour_map(wks_pdf, data_sim(j, i, 14, :, :)  \
                              - data_obs(i, 14, :, :), res)
        end do

        gsn_panel(wks_pdf, plot_pdf, (/4, 2/), False)
    end do  
 
end
