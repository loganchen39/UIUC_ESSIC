Titrd1 = "ti 'GSFC'"
Titrd2 = "ti 'AER'"
Titrd3 = "ti 'CAM'"
Titrd4 = "ti 'CCC'"
Titrd5 = "ti 'CSIRO'"
Titrd6 = "ti 'F-L'"
Titrd7 = "ti 'GFDL'"
Titrd8 = "ti 'AVG'"
Titrd9 = "ti 'AEoff'"

Titrd1 = "noti"
Titrd2 = "ti 'RA'"
Titrd3 = "noti"
Titrd4 = "noti"
Titrd5 = "noti"
Titrd6 = "noti"
Titrd7 = "noti"
Titrd8 = "noti"
Titrd9 = "noti"

PosRad = "\
             using @Xrange:(column(9+@PosCol) * @SclFct + @OffSet) @Titrd9 @Styrd9, \
          '' using @Xrange:(column(8+@PosCol) * @SclFct + @OffSet) @Titrd8 @Styrd8, \
          '' using @Xrange:(column(7+@PosCol) * @SclFct + @OffSet) @Titrd7 @Styrd7, \
          '' using @Xrange:(column(6+@PosCol) * @SclFct + @OffSet) @Titrd6 @Styrd6, \
          '' using @Xrange:(column(5+@PosCol) * @SclFct + @OffSet) @Titrd5 @Styrd5, \
          '' using @Xrange:(column(4+@PosCol) * @SclFct + @OffSet) @Titrd4 @Styrd4, \
          '' using @Xrange:(column(3+@PosCol) * @SclFct + @OffSet) @Titrd3 @Styrd3, \
          '' using @Xrange:(column(2+@PosCol) * @SclFct + @OffSet) @Titrd2 @Styrd2, \
          '' using @Xrange:(column(1+@PosCol) * @SclFct + @OffSet) @Titrd1 @Styrd1  "

PosRad = "\
             using @Xrange:(column(8+@PosCol) * @SclFct + @OffSet) @Titrd8 @Styrd8, \
          '' using @Xrange:(column(7+@PosCol) * @SclFct + @OffSet) @Titrd7 @Styrd7, \
          '' using @Xrange:(column(4+@PosCol) * @SclFct + @OffSet) @Titrd4 @Styrd4, \
          '' using @Xrange:(column(3+@PosCol) * @SclFct + @OffSet) @Titrd3 @Styrd3, \
          '' using @Xrange:(column(2+@PosCol) * @SclFct + @OffSet) @Titrd2 @Styrd2, \
          '' using @Xrange:(column(1+@PosCol) * @SclFct + @OffSet) @Titrd1 @Styrd1  "
