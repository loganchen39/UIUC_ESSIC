#!/usr/bin/ksh
set -e

if [ $# != 2 ] 
then
   echo "usage: $0 in.grib1 out.grib2"
   exit 1
fi

grib_filter=/home/tjling//bin/grib_filter

cat >rules.filter<<EOF
if ( ! typeOfLevel is 'hybrid' ) {
  print "Error: typeOfLevel='[typeOfLevel]' unable to convert. Only typeOfLevel='hybrid' can be converted.";
  assert( typeOfLevel is 'hybrid' );
}
set edition=2;
write;
EOF

set +e
$grib_filter -o $2 rules.filter $1

error=$?

#rm -f rules.filter

exit $error

