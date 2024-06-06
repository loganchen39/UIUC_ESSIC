set label 1 "RAD" at screen 0.1, 1.02 center font "Times-Roman, 12"
Titln1 = "ti 'GSFC'"
Titln2 = "ti 'AER'"
Titln3 = "ti 'CAM'"
Titln4 = "ti 'CCC'"
Titln5 = "ti 'CSIRO'"
Titln6 = "ti 'F-L'"
Titln7 = "ti 'GFDL'"
Titln8 = "ti 'AVG'"

PosRad = "   using @Xrange:(column(8+@PosCol)*100) @Titln8 @Styln8, \
          '' using @Xrange:(column(7+@PosCol)*100) @Titln7 @Styln7, \
          '' using @Xrange:(column(6+@PosCol)*100) @Titln6 @Styln6, \
          '' using @Xrange:(column(5+@PosCol)*100) @Titln5 @Styln5, \
          '' using @Xrange:(column(4+@PosCol)*100) @Titln4 @Styln4, \
          '' using @Xrange:(column(3+@PosCol)*100) @Titln3 @Styln3, \
          '' using @Xrange:(column(2+@PosCol)*100) @Titln2 @Styln2, \
          '' using @Xrange:(column(1+@PosCol)*100) @Titln1 @Styln1  "

