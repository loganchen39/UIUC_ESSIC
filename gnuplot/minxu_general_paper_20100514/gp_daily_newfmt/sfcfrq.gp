
Titsf1 = "ti 'CSSP'"
Titsf2 = "ti 'NOAH'"
Titsf3 = "ti 'PX'"
#Titsf4 = "ti 'CSSPn'"
Titsf4 = "ti 'CWRF_W'"
Titsf5 = "ti 'UOMoff'"
Titsf6 = "ti 'ERI'"
Titsf7 = "ti 'NARR'"
Titsf8 = "ti 'WRF/NOAH'"
#Titsf8 = "ti 'WRF'"

#Titsf1 = "ti 'SF'"
#Titsf2 = "noti"
#Titsf3 = "noti"
#Titsf4 = "noti"
#Titsf5 = "noti"
#Titsf6 = "noti"

PosSfc = "\
             using @Xrange:(column(16+@PosCol)*100) @Titsf7 @Stysf7, \
          '' using @Xrange:(column(15+@PosCol)*100) @Titsf6 @Stysf6, \
          '' using @Xrange:(column(14+@PosCol)*100) @Titsf5 @Stysf5, \
          '' using @Xrange:(column(13+@PosCol)*100) @Titsf4 @Stysf4, \
          '' using @Xrange:(column(12+@PosCol)*100) @Titsf3 @Stysf3, \
          '' using @Xrange:(column(11+@PosCol)*100) @Titsf2 @Stysf2, \
          '' using @Xrange:(column(01+@PosCol)*100) @Titsf1 @Stysf1 "

#PosSfc = "\
#             using @Xrange:(column(12+@PosCol)*100) @Titsf4 @Stysf4, \
#          '' using @Xrange:(column(01+@PosCol)*100) @Titsf1 @Stysf1 "
