#!/bin/csh -f
#
#	$Id: nhlf77.csh,v 1.3 2008/02/07 00:22:03 haley Exp $
#

#*********************************************#
#                                             #
# Make sure NCARG_ROOT is set for this script #
#                                             #
#*********************************************#
setenv NCARG_ROOT  `ncargpath root`

if ($status != 0) then
	exit 1
endif

set xlibs = "-lX11 -lXext"
set pnglib = "-lpng -lz"
set system   = ""LINUX""
set f77       = "gfortran"
set loadflags  = "-fPIC -fno-second-underscore -fno-range-check  -O   "
set libdir   = `ncargpath lib`
set incdir   = `ncargpath include`
set syslibdir = ""
set sysincdir = ""
set ro       = "$libdir/ncarg/robj"
set f77libs  = "-lgfortran -lm"
set newargv = "$f77 $loadflags"
set libpath = "-L$libdir $syslibdir"
set incpath = "-I$incdir $sysincdir"

#
# set up default libraries
#
set libncarg    = "-lncarg"
set libgks      = "-lncarg_gks"
set libmath     = ""
set libncarg_c  = "-lncarg_c"
set libhlu      = "-lhlu"
set ncarbd      = "$ro/libncarbd.o"
set ngmathbd    = "$ro/libngmathbd.o"
set extra_libs

set robjs
unset NGMATH_LD
unset NGMATH_BLOCKD_LD

foreach arg ($argv)
  switch ($arg)

  case "-ngmath":
    set libmath     = "-lngmath"
    breaksw

  case "-ncarbd":
    set robjs = "$robjs $ncarbd"
    set NGMATH_BLOCKD_LD
    breaksw

  case "-ngmathbd":
    set robjs = "$robjs $ngmathbd"
# Make sure the ngmath blockdata routine doesn't get loaded twice.
    unset NGMATH_BLOCKD_LD
    breaksw

  case "-netcdf":
  case "-cdf":
    set extra_libs = "$extra_libs -lnetcdf"
    breaksw

  case "-hdf":
    set extra_libs = "$extra_libs -lmfhdf -ldf -ljpeg -lz"
    breaksw

  default:
    set newargv = "$newargv $arg"
  endsw
end

#
# If -ncarbd was set, *and* the ngmath library was loaded,
# then automatically take care of loading libngmathbd.o.
#
if ($?NGMATH_LD && $?NGMATH_BLOCKD_LD) then
  set robjs = "$robjs $ngmathbd"
endif

set ncarg_libs = "$libhlu $libncarg $libgks $libncarg_c $libmath"

set newargv = "$newargv $libpath $incpath $extra_libs $robjs $ncarg_libs $xlibs $pnglib $f77libs"

echo $newargv
eval $newargv
