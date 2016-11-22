# SwiftZSTD
Swift wrapper around ZSTD compression lib

This is a demo of how one could wrap ZSTD compression library for use in Swift.  This is an initial, very incomplete attempt and is work in progress.  At this point only compression/decompression of in-memory buffers without use of contexts and dictionaries has been implemented.

The relevant ZSTD C code has been added to the repository as it is compiled as part of the Xcode project.  See https://github.com/facebook/zstd for additional information, including licensing.

The wrapper includes the ZSTD C code as part of the target.  Other approaches could have been used, e.g. the ZSTD lib could have been packaged as an external library, static or dynamic.  The wrapper could also have been packaged as a framework for use by applications.

This sample code was inspired by a Stack Overflow question, see http://stackoverflow.com/questions/40617471/wrapping-a-library-like-facebooks-zstandard-in-swift.
