#!/usr/bin/python
import sys
if len(sys.argv)==1:
    print 'no args'
    sys.exit()
d=sys.argv[1]
#d='ims:ime,1:nl_soil-nl_snow,jms:jme'
#d0=d.replace(':',',')
d1=d.split(',')
#print d1
#d2=[ 'i3.2' for i in range(len(d1)) ]
#fm=",".join(d2)
for i in range(len(d1)):
    d2=d1[i].split(":")
    dtemp=[ 'i3.2' for j in range(len(d2)) ]
    d1[i]=',"_",'.join(dtemp)
d2=',".",'.join(d1)
#print d
#print d2
d0=d.replace(':',',')
print '''write(dimstr,'('''+d2+''')') '''+d0+'''
         do itemp=1,len(trim(adjustl(dimstr)))
            if (dimstr(itemp:itemp)==" ") dimstr(itemp:itemp)="0"
         end do
      '''
