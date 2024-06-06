
Titsf1 = "ti 'CSSP'"
Titsf2 = "ti 'NOAH'"
Titsf3 = "ti 'PX'"
#Titsf4 = "ti 'CSSPn'"
Titsf4 = "ti 'UOM'"
Titsf5 = "ti 'ERI'"
Titsf6 = "ti 'NARR'"
Titsf7 = "ti 'WRF(NOAH)'"

#Titsf1 = "ti 'SF'"
#Titsf2 = "noti"
#Titsf3 = "noti"
#Titsf4 = "noti"
#Titsf5 = "noti"
#Titsf6 = "noti"

Titsf1 = "ti 'CSSP'"
Titsf2 = "ti 'NOAH'"
Titsf3 = "ti 'PX'"
Titsf4 = "ti 'UOM'"
Titsf5 = "ti 'ERI'"
Titsf7 = "ti 'WRF/NOAH'"

PosSfc = "\
             using @Xrange:(column(17+@PosCol)*100) @Titsf7 @Stysf7, \
          '' using @Xrange:(column(15+@PosCol)*100) @Titsf5 @Stysf5, \
          '' using @Xrange:(column(14+@PosCol)*100) @Titsf4 @Stysf4, \
          '' using @Xrange:(column(12+@PosCol)*100) @Titsf3 @Stysf3, \
          '' using @Xrange:(column(11+@PosCol)*100) @Titsf2 @Stysf2, \
          '' using @Xrange:(column(01+@PosCol)*100) @Titsf1 @Stysf1 "

#PosSfc = "\
#             using @Xrange:(column(12+@PosCol)*100) @Titsf4 @Stysf4, \
#          '' using @Xrange:(column(01+@PosCol)*100) @Titsf1 @Stysf1 "
