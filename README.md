qtd
===

Fork of bitbucket repo



##Build Instructions

##Linux
==========================================================================================

you need:
- Qt 4.8 (development headers for all Qt packages)
- cmake

after cloning repo, create build_dir:  
`cd qtd`  
`mkdir build_dir`  
`cd build_dir`   

configure:  
`cmake -DCMAKE_CXX_FLAGS="-fpermissive" ../`  

or if you have multiple qt sdks installed (e.g. qt4, and qt5) use qt4:  
`cmake -DCMAKE_CXX_FLAGS="-fpermissive" -DQT_QMAKE_EXECUTABLE=<path-to-qt4>/bin/qmake ../`  

compile:  
`make`  

install:  
`make install`  


##Windows
==========================================================================================

you need:
- Qt 4.8 SDK which includes
- MinGW (you must use the one included in Qt SDK distribution). qt\bin (that contains qmake.exe) and mingw\bin directories need to be in the PATH environment variable.
- cmake

after cloning repo, create build_dir:  
`cd qtd`  
`mkdir build_dir`  
`cd build_dir`   

configure:   
`cmake -G"MinGW Makefiles" -DCMAKE_CXX_FLAGS="-fpermissive -m32 -mstackrealign" ../`  

compile:  
`mingw32-make`  

install:  
`mingw32-make install`  

