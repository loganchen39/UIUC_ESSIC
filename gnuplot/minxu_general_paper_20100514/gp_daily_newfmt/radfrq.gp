Titrd1 = "ti 'GSFC'"
Titrd2 = "ti 'AER'"
Titrd3 = "ti 'CAM'"
Titrd4 = "ti 'CCCMA'"
Titrd5 = "ti 'CAWCR'"
Titrd6 = "ti 'FLG'"
Titrd7 = "ti 'GFDL'"
Titrd8 = "ti 'AvCL'"
Titrd9 = "ti 'AEoff'"
Titrd10= "ti 'NoCW'"

#Titrd1 = "ti 'RA'"
#Titrd2 = "noti"
#Titrd3 = "noti"
#Titrd4 = "noti"
#Titrd5 = "noti"
#Titrd6 = "noti"
#Titrd7 = "noti"
#Titrd8 = "noti"
#Titrd9 = "noti"


Styrd10 = "@Styln10"
PosRad = "\
             using @Xrange:(column(10+@PosCol) * @SclFct + @OffSet) @Titrd10 @Styrd10, \
          '' using @Xrange:(column(09+@PosCol) * @SclFct + @OffSet) @Titrd9 @Styrd9, \
          '' using @Xrange:(column(08+@PosCol) * @SclFct + @OffSet) @Titrd8 @Styrd8, \
          '' using @Xrange:(column(07+@PosCol) * @SclFct + @OffSet) @Titrd7 @Styrd7, \
          '' using @Xrange:(column(06+@PosCol) * @SclFct + @OffSet) @Titrd6 @Styrd6, \
          '' using @Xrange:(column(05+@PosCol) * @SclFct + @OffSet) @Titrd5 @Styrd5, \
          '' using @Xrange:(column(04+@PosCol) * @SclFct + @OffSet) @Titrd4 @Styrd4, \
          '' using @Xrange:(column(03+@PosCol) * @SclFct + @OffSet) @Titrd3 @Styrd3, \
          '' using @Xrange:(column(02+@PosCol) * @SclFct + @OffSet) @Titrd2 @Styrd2, \
          '' using @Xrange:(column(01+@PosCol) * @SclFct + @OffSet) @Titrd1 @Styrd1  "

PosRad = "\
             using @Xrange:(column(10+@PosCol) * @SclFct + @OffSet) @Titrd10 @Styrd9, \
          '' using @Xrange:(column(08+@PosCol) * @SclFct + @OffSet) @Titrd8 @Styrd8, \
          '' using @Xrange:(column(07+@PosCol) * @SclFct + @OffSet) @Titrd7 @Styrd7, \
          '' using @Xrange:(column(06+@PosCol) * @SclFct + @OffSet) @Titrd6 @Styrd6, \
          '' using @Xrange:(column(05+@PosCol) * @SclFct + @OffSet) @Titrd5 @Styrd5, \
          '' using @Xrange:(column(04+@PosCol) * @SclFct + @OffSet) @Titrd4 @Styrd4, \
          '' using @Xrange:(column(03+@PosCol) * @SclFct + @OffSet) @Titrd3 @Styrd3, \
          '' using @Xrange:(column(02+@PosCol) * @SclFct + @OffSet) @Titrd2 @Styrd2, \
          '' using @Xrange:(column(01+@PosCol) * @SclFct + @OffSet) @Titrd1 @Styrd1  "


#PosRad = "\
#             using @Xrange:(column(8+@PosCol) * @SclFct + @OffSet) @Titrd8 @Styrd8, \
#          '' using @Xrange:(column(7+@PosCol) * @SclFct + @OffSet) @Titrd7 @Styrd7, \
#          '' using @Xrange:(column(4+@PosCol) * @SclFct + @OffSet) @Titrd4 @Styrd4, \
#          '' using @Xrange:(column(3+@PosCol) * @SclFct + @OffSet) @Titrd3 @Styrd3, \
#          '' using @Xrange:(column(2+@PosCol) * @SclFct + @OffSet) @Titrd2 @Styrd2, \
#          '' using @Xrange:(column(1+@PosCol) * @SclFct + @OffSet) @Titrd1 @Styrd1  "
