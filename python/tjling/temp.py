#!/usr/bin/python
import re
p=
d='ims:ime,jms:jme,naer_type'
d1=d.split(',')
fm=''
for i in d1:
    thisfm=''
    for j in i.split(':'):
        thisfm=thisfm+'","'+'i3.3'
    fm=fm+thisfm+'.'
#echo "    write(dimstr,'(
