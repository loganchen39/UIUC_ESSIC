#!/bin/csh -f
#
#   $Id: MakeNcl.csh,v 1.5 2008/07/27 04:12:48 haley Exp $
#                                                                      
#                Copyright (C)  2004
#        University Corporation for Atmospheric Research
#                All Rights Reserved
#
# The use of this Software is governed by a License Agreement.
#
# Use this script to make an ncl executable from installed libraries.
#

set cc_ld         = "g++"
set cc_opts       = "-ansi -fPIC -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -I/usr/local/include"
set ld_libs       = "-L/d2/haley/5.1.1/lib -L/d2/haley/5.1.0/64bit/lib -lnetcdf -lhdf5_hl -lhdf5 -lsz -lhdfeos -lGctp -lmfhdf -ldf -ljpeg -lz -lgdal -lproj -ludunits  -lgrib2c -ljasper -lpng -lz -lpng -lz  -L../../.././external/sphere3.1_dp -lsphere3.1_dp -L../../.././external/fftpack5_dp -lfftpack5_dp -L../../.././external/lapack -llapack_ncl -L../../.././external/blas -lblas_ncl"
set extra_ld_libs = "-lX11 -lXext /usr/lib64/libgfortran.a -lm -lm  -ldl  "
set libpath       = "/d2/haley/5.1.1/lib"
set incpath       = "/d2/haley/5.1.1/include"
set libdir        = "-L$libpath"
set incdir        = "-I$incpath"
set libncl        = "-lncl"
set libnfp        = "-lnfp -lnfpfort"
set libhlu        = "-lhlu"
set libncarg      = "-lncarg"
set libgks        = "-lncarg_gks"
set libncarg_c    = "-lncarg_c"
set libmath       = "-lngmath"
set ncarg_libs    = "$libncl $libnfp $libhlu $libncarg $libgks $libncarg_c $libmath"

if (! -d "$libpath") then
  echo "Library directory <$libpath> does not exist."
  exit 1
endif

set files      = ""
set extra_opts = ""

foreach arg ($argv)

    switch ($arg)

    case "-*":
        set extra_opts = "$extra_opts $arg"
        breaksw

    default:
        set files = "$files $arg"
        breaksw
    endsw
end

if ("$files" == "") then
  echo "MakeNcl error: You must input one or more *.o files"
  exit 1
endif

set newargv = "$cc_ld $cc_opts $extra_opts -o ncl $files $incdir $libdir $ncarg_libs $ld_libs $extra_ld_libs"

echo $newargv
eval $newargv
