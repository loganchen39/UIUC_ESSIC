
;***************************************************
; GRIB, GRIB2, HDF, HDF-EOS to netcdf
;***************************************************
;
; ncl_convert2nc inputFile
;           [-i input_directory]
;           [-o output_directory]
;           [-e extension]
;           [-u time_name]
;           [-U new_time_name]
;           [-sed sed1[,...]]
;           [-tps]
;           [-v var1[,...]]
;           [-L]
;           [-c comment]
;           [-d]
;           [-B] <file>
;           [-h]
;
; inputFile             name of GRIB/HDF/HDF-EOS file [required]
; [-i input_directory]  location of input file  [default: current directory] 
; [-o output_directory] location of output file [default: current directory] 
; [-e extension]        file type, defined by extension, to convert
; [-u time_name]        name of the NCL-named time dimension to be UNLIMITED
; [-U new_time_name]    if -u is specified, will rename the NCL-named time dimension for netCDF 
; [-sed sed1[,...]]     set single element time record dimensions [default: None]
;                         GRIB files only; choices are Initial_time, Forecast_time, Level,
;                         Ensemble, Probability, All, None
; [-tps]                GRIB files only; remove suffix representing a time period (e.g. 2h)
;                         from statistically processed variables, leaving only type of
;                         processing as a suffix (e.g. _acc, _avg)
; [-v var1[,...]]       user specified subset of variables [default: all variables]
;                       ncl_filedump can be used to determine desired variable names
; [-L]                  support for writing large (>2Gb) netCDF files [default: no largefile support]"
; [-c comment]          text to be included in netCDF file attribute [default: no comment] 
; [-d]                  upon exit: print contents each netCDF file [like ncdump -h] 
; [-B] <file>           suppress informational messages; redirect messages to <file> if present [default: /dev/null]
; [-h]                  this usage message
;
; Sample Usage 
;      (1) ncl_convert2nc U12345.grb
;             => U12345.nc [location current directory]  
;
;      (2) ncl_convert2nc U12345 -e grb -t
;             => apply ".grb" extension to input file(s)
;             => time coordinate type set to "string"
;
;      (3) ncl_convert2nc U12345.hdf -i /my/input    
;                [/my/input/U12345]
;             => U12345.nc [location current directory] 
;
;      (4) ncl_convert2nc U12345.hdfeos -i /my/input -o /my/output 
;             =>  /my/output/U12345.nc 
;
;      (5) ncl_convert2nc U12345.grb -i /my/input -o /my/output
;             => /my/output/U12345.nc 
;
;      (6) ncl_convert2nc U12345.hdf -c 'Data Support Section: ds124.1'
;             => /my/output/U12345.nc     [includes file attribute "ds124.1"] 
;
;      (7) ncl_convert2nc U12345.grb -o /my/output  \
;                     -v gridlat_236,gridlon_236,PRES_236_SFC,NCPCP_236_SFC_acc1h
;             => /my/output/U12345.nc    [contains 4 variables only] 
;
;      (8) ncl_convert2nc U12345.grb -v gridlat_236,gridlon_236,PRES_236_SFC -L
;             => U12345.nc [location current directory]
;                          [contains only three variables]
;                          [supports large files (>2Gb) for netCDF]
;
;      (9) ncl_convert2nc U78677.grb -u initial_time0_hours
;             => double initial_time0_hours(initial_time0_hours)       ; UNLIMITED
;             => initial_time0_hours:units = "hours since 1800-01-01 00:00" 
;             => float D_GDS4_HYBL_123(initial_time0_hours, lv_HYBL3, g4_lat_1, g4_lon_2) ;
;
;     (10) ncl_convert2nc U78677.grb -u initial_time0_hours -U time
;             => double time(time) ;                            ; UNLIMITED
;             => time:units = "hours since 1800-01-01 00:00" ;
;             => float D_GDS4_HYBL_123(time, lv_HYBL3, g4_lat_1, g4_lon_2) ;
;
;     (11) ncl_convert2nc U78677.grb -sed initial_time,forecast_time
;             => set Single Element Dimensions 'initial_time' and 'forecast_time'
;
;
;***************************************************
; Multiple files
;  The driver shell script gets the expanded file
;  names and invokes this script, one file at a time
;***************************************************
; Sample usage of the NCL script:
;      (a) ncl 'fili="U12345.grb"' anyFile2nc.ncl_v1
;      (b) ncl 'fili="U12345.hdf"' -t
;      (c) ncl 'fili="U12345.hdfeos"'  ncDump=True anyFile2nc.ncl_v1
;      (d) ncl 'fili="U12345.grb"' 'filo=Ugrib' anyFile2nc.ncl_v1
;      (e) ncl 'fili="U12345.hdf"' 'diri="/my/input"' anyFile2nc.ncl_v1
;      (f) ncl 'fili="U12345.hdfeos"' 'diri="/my/input"' 'diro="/my/output"' anyFile2nc.ncl_v1
;      (g) ncl 'fili="U12345.grb"' 'diri="/my/input"' \
;              'diro="/my/output"'\
;              'comment="Data Support Section: ds124.1"' anyFile2nc.ncl_v1
;      (h) ncl 'fili="U12345.grb"' 'varSelect=(/"gridlat_236","gridlon_236", \
;                                           "PRES_236_SFC,"NCPCP_236_SFC_acc1h"/)  anyFile2nc.ncl_v1
;      (h) ncl 'fili="U12345.grb"' 'varSelect=(/"gridlat_236","gridlon_236", \
;                                           "PRES_236_SFC/) -L  anyFile2nc.ncl_v1
;      (i) ncl 'fili="U78677.hdf"' -u "forecast_time0_hours"
;      (j) ncl 'fili="U78677.hdfeos"' -u "initial_time0_hours -U time"
;      (k) ncl 'fili="U78677.grb"'  'singleElemDims=(/"forecast_time", "initial_time"/)
;***************************************************

begin
;    debug          = True
    debug          = False

;***************************************************
; fili is *required*
;***************************************************
    if (.not. isvar("fili")) then
        print(pname + ": REQUIRED input file name(s) missing, exiting.")
        exit
    end if

;***************************************************
; The following are optional command line variables
;***************************************************
    if (.not. isvar("diri")) then
        diri  = "./"                     ; default input dir
    else
        diri = diri + "/"
    end if

    if (.not. isvar("diro")) then
        diro  = "./"                     ; default output dir
    else
        diro = diro + "/"
    end if

    if (.not. isvar("comment")) then
        comment = ""                     ; comment option
    end if

;***************************************************
; Specify that COARDS style output desired
; NOTE: [not yet implemented]
;***************************************************
    ;;setfileoption(f, "COARDS", True)   ; place holder

;***************************************************
; Specify the type of time coordinate
; [default is 'numeric'] [obsolete]
;
; Specify the type(s) of time record dimension
; NOTE: valid for GRIB files only
;***************************************************
    if (ftype .eq. "GRIB") then
;        setfileoption(f, "InitialTimeCoordinateType", "numeric")

        sed = singleElemDims
        if (debug) then
            print("Setting file option: SingleElementDimensions: " + sed)
        end if

        setfileoption("grib", "SingleElementDimensions", sed)

        tps = timePeriodSuffix
        if (debug) then
            print("Setting file option: TimePeriodSuffix: " + tps)
        end if

        setfileoption("grib", "TimePeriodSuffix", tps)
    end if

;***************************************************
; open file with appropriate extension
;***************************************************
    iFileName = diri + fili
    f = addfile(iFileName, "r")     ; suffix ok 

;***************************************************
; Get all the global [file] attributes.  These will
; be copied to the output file.
; NOTE: GRIB files will return "missing"
;***************************************************

    fInAtts = getvaratts( f )

;***************************************************
; Get *all* variables names on the file 
;     or
; Specify a subset of variables. All variable names,
; including coordinate variable names, must be
; specified.
;***************************************************
;***************************************************
; Get *all* variables names on the file 
;     or
; Specify a subset of variables. All variable names,
; including coordinate variable names, must be
; specified.
;***************************************************
    if (.not. isvar("nvars")) then    
        fVarNames = getfilevarnames(f)     ; all files names 
     else
        fVarNames = vars                     ; user specified variables
     end if
     nfNames = dimsizes(fVarNames)

     if (debug) then
        print(nfNames)
        print(fVarNames)
    end if

;***************************************************
; optionally, create new names for the output netcdf
; file.  Add variable renaming later.
;***************************************************
    ncVarNames  = fVarNames         ; default: netCDF names <==>  NCL names
    if (time_name .ne. "" .and. TIME_NAME .ne. "") then
        if (any(ncVarNames .eq. time_name)) then
            tu_dim = ind(ncVarNames .eq. time_name)
            ncVarNames(tu_dim) = TIME_NAME
        end if
    end if

;***************************************************
; open output netcdf file
; Set for 'large file' netCDF support if specified
;***************************************************
    netcdfSizeType = ncdfSize
    setfileoption("netcdf", "format", netcdfSizeType)

    ncFileName = diro + filo + ".nc"      
    system("/bin/rm -f " + ncFileName)  ; remove pre-existing file (if any)
    fnc = addfile(ncFileName, "c")      ; "c"reate the netCDF file

;***************************************************
; define file options [version a033 and beyond]
;***************************************************
    setfileoption(fnc, "prefill", False)
    setfileoption(fnc, "suppressclose", True)
    setfileoption(fnc, "definemode", True)

;***********************************************
; assign standard file attributes [Sample]
;***********************************************
    fAtt               = True
    title = "NCL: convert-" + ftype + "-to-netCDF"
    fAtt@title         = title

    if (ftype .eq. "GRIB") then
        fAtt@grib_source   = fili
    end if

    if (ftype .eq. "HDF") then
        fAtt@hdf_source   = fili
    end if

    if (ftype .eq. "HDFEOS") then
        fAtt@hdfeos_source   = fili
    end if

    fAtt@conventions   = "None"
    fAtt@system        = systemfunc("uname -a")
    fAtt@NCL_Version   = get_ncl_version()
    fAtt@creation_date = systemfunc ("date")
    if (comment .ne. "") then
        fAtt@comment   = comment 
    end if

;***********************************************
; copy input file attributes to output file
;***********************************************

    if (.not. all(ismissing(fInAtts))) then
        do i = 0, dimsizes(fInAtts) - 1
            fAtt@$fInAtts(i)$ = f@$fInAtts(i)$
        end do
    end if

    fileattdef(fnc, fAtt)

;***********************************************
; predefine the file's dimension names, sizes
; and types
;***********************************************
    dimNames = getvardims(f)
    dimSizes = getfiledimsizes(f)
    dimUnlim = new(dimsizes(dimNames), "logical")
    dimUnlim = False

;***********************************************
; file variable to make dimension as UNLIMITED
;***********************************************
    if (time_name .ne. "") then
        if (any(dimNames .eq. time_name)) then
            tu_dim = ind(dimNames .eq. time_name)
            dimUnlim(tu_dim) = True
            if (TIME_NAME .ne. "") then 
                dimNames(tu_dim) = TIME_NAME
            end if
        end if
    end if
    filedimdef(fnc, dimNames, dimSizes, dimUnlim)

    if (debug) then
        print(dimNames)
        print(dimSizes)
        print(dimUnlim)
    end if

;***********************************************
; determine the type of each variable
;***********************************************
    varType = getfilevartypes(f, fVarNames)

;***********************************************
; loop over each variable: skip variables of type
; string [not allowed by netCDF v3.6.x]
; (1) define name, type and dimension names
; (2) rather than read in the variable [could be
;     big and slow], read each attribute of a
;     variable and assign to a dummy variable
;***********************************************
    do i = 0, nfNames - 1 
        if (debug) then
            print(" ")
            print(i + "  ncl_name = " + fVarNames(i))
            print(i + "  ncl_type = " + varType(i))
            print(i + "  dim_names " + getfilevardims(f, fVarNames(i)))
        end if

        if (varType(i) .ne. "string") then      ; netCDF (currently no strings)
                                                ; predefine variable
            if (TIME_NAME .eq. "") then
                filevardef(fnc, ncVarNames(i), varType(i), (/ getfilevardims(f, fVarNames(i)) /))
            else
                dimVarNames = getfilevardims(f, fVarNames(i))
                if (any(dimVarNames .eq. time_name)) then
                    tu_dim  = ind(dimVarNames .eq. time_name)
                    dimVarNames(tu_dim) = TIME_NAME
                end if

                filevardef(fnc, ncVarNames(i), varType(i), dimVarNames)
                delete(dimVarNames)
            end if

            varAtts = getfilevaratts(f, fVarNames(i))
            if (.not. all(ismissing(varAtts))) then
                nAtts   = dimsizes(varAtts)

                dumAtts = new (1, varType(i))    ; dummy to attach varAtts 
                delete(dumAtts@_FillValue)       ; delete auto assigned _FillValue

                do j = 0, nAtts - 1
                    dumAtts@$varAtts(j)$ = f->$fVarNames(i)$@$varAtts(j)$
                end do

                if (debug) then                    ; can lead to much output
                    print(varAtts)
                    print(nAtts)
                    print(dumAtts) 
                end if

                ; define variable attributes
                filevarattdef(fnc, ncVarNames(i) , dumAtts)

                delete(dumAtts)
            end if
            delete(varAtts)

        end if
    end do

    setfileoption(fnc, "definemode", False) ; not necessary

;***************************************************************************************
; Write *only* data values to predefined locations.  If the variable exceeds a         *
; certain size, perform the operation in a loop to save on core memory. There          *
; is no way to get the size of a type in NCL (!!!).  The approach used could be        *
; inefficient if the leftmost dimensions have more elements than the rightmost.        *
; Hopefully that is a rare occurence -- certainly it would be very rare in GRIB files. *
;***************************************************************************************
    fvar_types = getfilevartypes(f,fVarNames)
    threshold_size = 250000000
    do i = 0, nfNames - 1
        if (varType(i) .ne. "string") then
            if (debug) then
                print("write loop: i = " + i + "  " + fVarNames(i))
            end if

            dsizes = getfilevardimsizes(f,fVarNames(i))
            type_size = 1
            if (fvar_types(i) .eq. "double") then
                type_size =  8
            else if (fvar_types(i) .eq. "short") then
                type_size = 2
            else if (fvar_types(i) .ne. "byte" .and. fvar_types(i) .ne. "character") then
                type_size = 4
            end if
            end if
            end if

            tsize = product(dsizes) * type_size
            if (debug) then
                print(fVarNames(i) + " : " + tsize  + " (size in bytes) :  " + dimsizes(dsizes) + " (number of dimensions)")
            end if

            ndims = dimsizes(dsizes)
            ; no special handling for ndims greater than 6 or less than 3
            if (tsize .lt. threshold_size .or. ndims .gt. 7 .or. ndims .lt. 3) then
                fnc->$ncVarNames(i)$ = (/ f->$fVarNames(i)$ /)
            else
                if (ndims .eq. 7) then
                    if (tsize / dsizes(0) .lt. threshold_size) then
                        do j = 0, dsizes(0) - 1
                            if (debug) then
                                print("copying " + fVarNames(i) + "(" + j + ",:,:,:,:,:,:)")
                            end if

                            fnc->$ncVarNames(i)$(j,:,:,:,:,:,:) = (/ f->$fVarNames(i)$(j,:,:,:,:,:,:) /)
                        end do
                    else
                        do j = 0, dsizes(0) - 1
                            do k = 0, dsizes(1) -1
                                if (debug) then
                                    print("copying " + fVarNames(i) + "(" + j + "," + k +  ",:,:,:,:,:)")
                                end if

                                fnc->$ncVarNames(i)$(j,k,:,:,:,:,:) = (/ f->$fVarNames(i)$(j,k,:,:,:,:,:) /)
                            end do
                        end do
                    end if
                end if

	        
                if (ndims .eq. 6) then
                    if (tsize / dsizes(0) .lt. threshold_size) then
                        do j = 0, dsizes(0) - 1
                            if (debug) then
                                print("copying " + fVarNames(i) + "(" + j + ",:,:,:,:,:)")
                            end if

                            fnc->$ncVarNames(i)$(j,:,:,:,:,:) = (/ f->$fVarNames(i)$(j,:,:,:,:,:) /)
                        end do
                    else
                        do j = 0, dsizes(0) - 1
                            do k = 0, dsizes(1) - 1
                                if (debug) then
                                    print("copying " + fVarNames(i) + "(" + j + "," + k +  ",:,:,:,:)")
                                end if

                                fnc->$ncVarNames(i)$(j,k,:,:,:,:) = (/ f->$fVarNames(i)$(j,k,:,:,:,:) /)
                            end do
                        end do
                    end if
                end if

                if (ndims .eq. 5) then
                    if (tsize / dsizes(0) .lt. threshold_size) then
                        do j = 0, dsizes(0) - 1
                            if (debug) then
                                print("copying " + fVarNames(i) + "(" + j + ",:,:,:,:)")
                            end if

                            fnc->$ncVarNames(i)$(j,:,:,:,:) = (/ f->$fVarNames(i)$(j,:,:,:,:) /)
                        end do
                    else
                        do j = 0, dsizes(0) - 1
                            do k = 0, dsizes(1) -1
                                if (debug) then
                                    print("copying " + fVarNames(i) + "(" + j + "," + k +  ",:,:,:)")
                                end if

                                fnc->$ncVarNames(i)$(j,k,:,:,:) = (/ f->$fVarNames(i)$(j,k,:,:,:) /)
                            end do
                        end do
                    end if
                end if

                if (ndims .eq. 4) then
                    if (tsize / dsizes(0) .lt. threshold_size) then
                        do j = 0, dsizes(0) - 1
                            if (debug) then
                                print("copying " + fVarNames(i) + "(" + j + ",:,:,:)")
                            end if

                            fnc->$ncVarNames(i)$(j,:,:,:) = (/ f->$fVarNames(i)$(j,:,:,:) /)
                        end do
                    else
                        do j = 0, dsizes(0) - 1
                            do k = 0, dsizes(1) -1
                                if (debug) then
                                    print("copying " + fVarNames(i) + "(" + j + "," + k +  ",:,:)")
                                end if

                                fnc->$ncVarNames(i)$(j,k,:,:) = (/ f->$fVarNames(i)$(j,k,:,:) /)
                            end do
                        end do
                    end if
                end if

                if (ndims .eq. 3) then
                    if (tsize / dsizes(0) .lt. threshold_size) then
                        do j = 0, dsizes(0) - 1
                            if (debug) then
                                print("copying " + fVarNames(i) + "(" + j + ",:,:)")
                            end if

                            fnc->$ncVarNames(i)$(j,:,:) = (/ f->$fVarNames(i)$(j,:,:) /)
                        end do
                    else
                        do j = 0, dsizes(0) - 1
                            do k = 0, dsizes(1) -1
                                if (debug) then
                                    print("copying " + fVarNames(i) + "(" + j + "," + k +  ",:)")
                                end if

                                fnc->$ncVarNames(i)$(j,k,:) = (/ f->$fVarNames(i)$(j,k,:) /)
                            end do
                        end do
                    end if
                end if
            end if
            
            delete(dsizes)
        end if
    end do

    delete(f)   ; not necessary
 end 
