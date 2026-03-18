WifSolverCuda v4.0 is an upgrade to WifSolverCuda v3.0
Includes the -yprefixes "yourfile.txt" mode and it fixes a few bugs related to using invalid characters (like "l")
ATTENTION -> you need to align correctly your "YYYYY""XXXXXXX" according to the length of your prefixes in your input file
Build
Linux:
Go to linux/ subfolder and execute make all. If your device does not support compute capability=86 (error "No kernel image is available for execution on the device"), do the change in Makefile (for example 1080Ti requires COMPUTE_CAP=61).
