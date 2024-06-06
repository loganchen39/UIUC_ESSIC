Titcu1 = "ti 'ECP'"
Titcu2 = "ti 'BMJ'"
Titcu3 = "ti 'CSU'"
Titcu4 = "ti 'GD'"
Titcu5 = "ti 'GFDL'"
Titcu6 = "ti 'MIT'"
Titcu7 = "ti 'ZML'"
Titcu8 = "ti 'NKF'"
Titcu9 = "ti 'SCoff'"
Titcu10= "ti 'G3'"

#Titcu1 = "ti 'CU'"
#Titcu2 = "noti"
#Titcu3 = "noti"
#Titcu4 = "noti"
#Titcu5 = "noti"
#Titcu6 = "noti"
#Titcu7 = "noti"
#Titcu8 = "noti"
#Titcu9 = "noti"

Stycu10 = "@Styln10"

PosCup = "\
             using @Xrange:(column(39+@PosCol)*100) @Titcu10 @Stycu10, \
          '' using @Xrange:(column(38+@PosCol)*100) @Titcu9 @Stycu9, \
          '' using @Xrange:(column(37+@PosCol)*100) @Titcu8 @Stycu8, \
          '' using @Xrange:(column(36+@PosCol)*100) @Titcu7 @Stycu7, \
          '' using @Xrange:(column(35+@PosCol)*100) @Titcu6 @Stycu6, \
          '' using @Xrange:(column(34+@PosCol)*100) @Titcu5 @Stycu5, \
          '' using @Xrange:(column(33+@PosCol)*100) @Titcu4 @Stycu4, \
          '' using @Xrange:(column(32+@PosCol)*100) @Titcu3 @Stycu3, \
          '' using @Xrange:(column(31+@PosCol)*100) @Titcu2 @Stycu2, \
          '' using @Xrange:(column(01+@PosCol)*100) @Titcu1 @Stycu1 "

# remove GD and replaced by G3
PosCup = "\
             using @Xrange:(column(38+@PosCol)*100) @Titcu9 @Stycu9, \
          '' using @Xrange:(column(37+@PosCol)*100) @Titcu8 @Stycu8, \
          '' using @Xrange:(column(36+@PosCol)*100) @Titcu7 @Stycu7, \
          '' using @Xrange:(column(35+@PosCol)*100) @Titcu6 @Stycu6, \
          '' using @Xrange:(column(34+@PosCol)*100) @Titcu5 @Stycu5, \
          '' using @Xrange:(column(39+@PosCol)*100) @Titcu10 @Stycu4, \
          '' using @Xrange:(column(32+@PosCol)*100) @Titcu3 @Stycu3, \
          '' using @Xrange:(column(31+@PosCol)*100) @Titcu2 @Stycu2, \
          '' using @Xrange:(column(01+@PosCol)*100) @Titcu1 @Stycu1 "


#PosCup = "\
#             using @Xrange:(column(29+@PosCol)*100) @Titcu8 @Stycu8, \
#          '' using @Xrange:(column(28+@PosCol)*100) @Titcu7 @Stycu7, \
#          '' using @Xrange:(column(27+@PosCol)*100) @Titcu6 @Stycu6, \
#          '' using @Xrange:(column(26+@PosCol)*100) @Titcu5 @Stycu5, \
#          '' using @Xrange:(column(25+@PosCol)*100) @Titcu4 @Stycu4, \
#          '' using @Xrange:(column(24+@PosCol)*100) @Titcu3 @Stycu3, \
#          '' using @Xrange:(column(01+@PosCol)*100) @Titcu1 @Stycu1 "
