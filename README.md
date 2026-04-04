# SwiftZSTD: Swift Wrapper Around ZSTD Compression Library

A subset of the underlying C library functionality is exposed as a Swift API.  Simple core API, context-based, and streaming operations are supported.  Dictionaries are also supported, but not with streaming at this time.  

To compress or decompress a file small enough to be stored in memory, read it into a buffer (`Data` instance) and then use `ZSTDProcessor`, `DictionaryZSTDProcessor`, or `ZSTDStream`.

To compress a large file that does not conveniently fit into memory
- Read the file in chunks, e.g. using `InputStream`.
- Use `ZSTDProcessor`, `DictionaryZSTDProcessor`, or `ZSTDStream` to compress each chunk.
	- Using `ZSTDStream` will result in an output file containing a single frame.
- Write each compressed chunk to the output file, e.g. using `OutputStream`.
To decompress a large file that contains a single compressed frame, read the file in chunks, decompress each using `ZSTDStream`, and write it to the output file.

When using this code in your project, please build with compiler optimization enabled.  

This codebase has been mostly tested on macOS and, to a lesser extent, iOS.  `Package.swift` in the official ZSTD distribution on github also suggests that tvOS is supported (based on the listed minimum platform version requirements), but this code has never been tested on tvOS. 

The relevant ZSTD C code has been added to the repository since it is compiled as part of the project.  See https://github.com/facebook/zstd for additional information, including licensing.

The wrapper is an SPM package and includes the ZSTD C code as a separate target.

