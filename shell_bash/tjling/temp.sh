#!/bin/bash
function test1()
{
	echo " test================"
	echo $a
	echo $b
}
d='ims:ime,jms:jme,naer_type'
d1=`echo $d | sed -e "s/\w*/i3.3/g" | sed -e "s/,/,\".\",/g;s/:/,\"_\",/g"`
d2=`echo $d | sed -e "s/:/,/g"`
echo "write(dimstr,'($d1)') $d2"
a='11'
b='22'
test1
a='33'
b='44'
test1
source a.sh
test1


