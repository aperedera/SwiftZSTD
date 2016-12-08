# SwiftZSTD
Swift wrapper around ZSTD compression lib

This is a more usable wrapper than the initial example.  Compression and de-compression of in-memory buffers is supported.  Buffers are represented by Data instances that must use contiguous storage, and in practice most Data instances meet this requirement.  To be decompressed by this code, a buffer must be a complete frame with decompressed size encoded in it and retrievable using ZSTD_getDecompressedSize().  Use of compression/decompression contexts and dictionaries is now supported.

This is actually a fairly useful implementation.  Experimentation shows that even fairly large files (100s of MB),when compressed using the zstd utility provided with the C library, end up in a single frame, which is easily decompressible by this Swift code if read into memory as one piece!

The relevant ZSTD C code has been added to the repository since it is compiled as part of the Xcode project.  See https://github.com/facebook/zstd for additional information, including licensing.

The wrapper includes the ZSTD C code as part of the target.  Other approaches could have been used, e.g. the ZSTD lib could have been packaged as an external library, static or dynamic.  The wrapper could also have been packaged as a framework for use by applications.

This sample code was inspired by a Stack Overflow question, see http://stackoverflow.com/questions/40617471/wrapping-a-library-like-facebooks-zstandard-in-swift.
