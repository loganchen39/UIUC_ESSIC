#!/bin/bash
# sed -e "s/,/\n/g;" aa > aa1
# grep "[a-z,a-Z]" aa1 > aa2
# sed -e "s/;/,/g" aa2 > aa3
# sed -e "s#^#write(999,\*) \"#g" aa3 > aa4
# sed -e "s#=#=\",#g" aa4 > aa5
# 
writeoutarray()
{
	  # get dimesion and filename
	  intent=`echo $i | sed -e "s/.*intent(//g" -e "s/).*//g"`
	  d=`echo $i | sed -e "s/.*dimension(//g" -e "s/).*//g"`
	  dimstr=`dimstostr.py $d`
	  #d1=`echo $d | sed -e "s/\w*/i3.2/g" | sed -e "s/,/,\".\",/g;s/:/,\"_\",/g"`
          #d2=`echo $d | sed -e "s/:/,/g"`
	 ## echo "dimstr=''" >> $subname
          #echo "write(dimstr,'($d1)') $d2" >> $subname
         ## echo "$dimstr" >> $subname
	  # 
	  echo $i | sed -e "s/.*:://g" > subnow
          sed -e "s/,/\ /g" subnow > subnext
          cp subnext subnow
          for j in `cat subnow`
          do
	     # echo "   write(tempstr,'(i4.4)') $itimestep " >> $subname
             # echo "   filename='debug/'"  >> $subname
             # echo "   filename=trim(filename)//tempstr//'.${debuginfo}.$j'" >> $subname
             # echo "   filename=trim(filename)//'.$posofsub.$intent.'//trim(dimstr) " >> $subname
	     # echo "   open(900+mytask,file=filename,form='unformatted',status='unknown')" >> $subname
	     # echo "   write(900+mytask)  $j " >> $subname
	     # echo "   close(900+mytask)     " >> $subname
	     echo " write(6,*) \"shape of $j is \", shape($j) ">>$subname
          done

}
if [ -z "$1" ]
then
   echo "usage: $0 XXXX.F.debug"
   echo "no arguments mean you have a file \"cplines\" including variables and defination."
   debuginfo="radiation_driver"
   itimestep="itimestep"
   cp cplines now
else
   echo "Running $0 $1"
   chmod 700 $1
   source $1
   ls -l now
   sed -n "$ib,${ie}p" $f > now
fi
#fdist=/mnt/tg2/projects/ciaqex/tiejun/cwrf31/mpi/CWRFV3.1/phys/module_radiation_driver.F
#cp $fdist .
#f=`basename $fdist`
#ib=274  #begin of variables with intent(IN/OUT)
#ie=715  #end of variables with intent(IN/OUT)
#
#insl0=734 # for define
#insl1=735
#insl2=1003
#debuginfo="radiation_driver"
#itimestep="itimestep"

#sed -n "$ib,${ie}p" $f > now

sed -e "s/!.*//g" now > next # delete comment
cp next now
sed -e "s/[[:space:]]//g" now > next # delete space
cp next now
sed -e "/^$/d" now > next
cp next now
sed -e "s/\ //g" now > next
for ((i=1;i<=20;i++))  # continue the broken line
do
	if diff next now > /dev/null
	then
		cp next now
		sed ":a;N;s/&\n//;ba;" now > next
	else
		echo "next is now"
		echo $i times sed continue
		i=21
	fi
done
cp next now
sed -e "s/&//g" now > next
#cp next now
#cat now | tr 'A-Z' 'a-z'  > next
#====================================================================================
#  write ============================================================================

#define local variables
subname="define"
rm -f $subname
# echo "!write(999,*)\"ltj $debuginfo debug add define_begin =======================\"" >> $subname
# echo "      character(len=200)::filename !ltj" >> $subname
# echo "      character(len=4)::tempstr    !ltj" >> $subname
# echo "      character(len=100)::dimstr    !ltj" >> $subname
# echo "      integer::itemp    !ltj" >> $subname
# echo "!write(999,*)\"ltj $debuginfo debug add define_end =======================\"" >> $subname

subname="inout"
rm -f $subname
echo "write(6,*)\"ltj $debuginfo debug add inout_begin ====================\"" >> $subname

for i in `cat next`
do

   if [ "${i:0:1}" = "#" ]
   then
     echo $i |sed -e "s/ifdef/ifdef /g;s/ifndef/ifndef /g" >> $subname
   else
     echo "!"$i >> $subname
     i=`echo $i  | tr 'A-Z' 'a-z' `
   fi

   #if echo $i | grep  "intent(in" | grep -v "optional" | grep -v "^type"  > /dev/null
   if echo $i | grep  "intent(" |  grep -v "^type"  > /dev/null
   then
     #echo "intent(in/inout) variables !!!!"
     if echo $i | grep "dimension" > /dev/null
     then
	if echo $i | grep -E "^real|^integer" > /dev/null
	then
	  posofsub="begin"
	  writeoutarray
	fi
	if echo $i | grep "^logical" > /dev/null
	then
	  echo $i | sed -e "s/.*:://g" > subnow
          sed -e "s/,/\ /g" subnow > subnext
          cp subnext subnow
          for j in `cat subnow`
          do
	     continue
	     #echo "write(999,*) \"count of $j=\",count($j)" >> $subname
          done
	fi 
     else
	echo $i | sed -e "s/.*:://g" > subnow
        sed -e "s/,/\ /g" subnow > subnext
        cp subnext subnow
        for j in `cat subnow`
        do
	   echo "write(6,*) \"$j=\",$j" >> $subname
        done
     fi
   fi
done
echo "write(6,*)\"ltj $debuginfo debug add inout_end =========================\"" >> $subname
echo "call flush(6)"  >> $subname

#subname="out"
#rm -f $subname
#echo "write(999,*)\"ltj $debuginfo debug add out_begin =======================\"" >> $subname
#
#for i in `cat next`
#do
#
#   if [ "${i:0:1}" = "#" ]
#   then
#     echo $i |sed -e "s/ifdef/ifdef /g;s/ifndef/ifndef /g" >> $subname
#   else
#     echo "!"$i >> $subname
#     i=`echo $i  | tr 'A-Z' 'a-z' `
#   fi
#
#   if echo $i | grep -E "intent\(inout|intent\(out" | grep -v "optional" | grep -v "^type"  > /dev/null
#   then
#     #echo "intent(in/inout) variables !!!!"
#     if echo $i | grep "dimension" > /dev/null
#     then
#	if echo $i | grep -E "^real|^integer" > /dev/null
#	then
#	   posofsub="end"
#	   writeoutarray
#	fi
#	if echo $i | grep "^logical" > /dev/null
#	then
#	  echo $i | sed -e "s/.*:://g" > subnow
#          sed -e "s/,/\ /g" subnow > subnext
#          cp subnext subnow
#          for j in `cat subnow`
#          do
#	     continue
#	     #echo "write(999,*) \"count of $j=\",count($j)" >> $subname
#          done
#	fi 
#     else
#	echo $i | sed -e "s/.*:://g" > subnow
#        sed -e "s/,/\ /g" subnow > subnext
#        cp subnext subnow
#        for j in `cat subnow`
#        do
#	   echo "write(999,*) \"$j=\",$j" >> $subname
#        done
#     fi
#   fi
#done
#
#echo "write(999,*)\"ltj $debuginfo debug add out_end =====================\"" >> $subname
rm -f now next subnow subnext
cat  inout  > shapeprint.f90
cp addprint ~/tmp/
exit

cp $f $f.org
sed -i "$insl2 r out" $f
sed -i "$insl1 r inout" $f
sed -i "$insl0 r define" $f

cp $f `readlink -f $fdist`
