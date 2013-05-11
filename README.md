airPd
=====

Pure Data for adobe AIR.

airPd is an AIR native extension for Pure Data, built using libpd.

notes
=====

- aslib: actionscript lib.
- mac: native source for mac osx (cpp).
- build: building files (ant).
- bin: ane file.
- sample: a simple sample, with init/ open patch/ send float.

The native source only mac osx now. iOS and Android maybe later. 
Mac osx source using libpd's cpp glue: https://github.com/libpd/libpd/tree/master/cpp . 
Only source code here. And maybe quick and dirty ;p 
The xcode project I strongly recommended Dan Wilcox's work: https://github.com/libpd/libpd/tree/master/samples/cppTest

I use AIR SDK 3.7, so it may need add "-swf-version 18" when compiling AIR app.

userfulllll
=====
Pure Data: puredata.info
libpd: https://github.com/libpd/libpd
libpd cpp glue: https://github.com/libpd/libpd/tree/master/samples/cppTest
libpd community: http://createdigitalnoise.com/categories/pd-everywhere

Build AIR ane on multi-platform:
https://github.com/AS3NUI/airkinect-2-core
