# SwiftZSTD: Multiplatform Swift Wrapper Around ZSTD Compression Library

A subset of the underlying C library functionality is exposed as a multiplatform Swift API.  Simple core API, context-based, and streaming operations are supported.  As of this release, dictionaries are also supported, but not with streaming.  Streaming operations are currently available on Apple platforms only.

To compress or decompress a file small enough to be stored in memory, read it into a buffer (`Data` instance) and then use `ZSTDProcessor`, `DictionaryZSTDProcessor`, or `ZSTDStream`.  Please note that a file being decompressed using `ZSTDProcessor` or `DictionaryZSTDProcessor` must be a single compressed frame.  `ZSTDStream` can decompress multi-frame inputs.

To compress a large file that does not conveniently fit into memory
- Read the file in chunks, e.g. using `InputStream`.
- Use `ZSTDProcessor`, `DictionaryZSTDProcessor`, or `ZSTDStream` to compress each chunk.
- Write each compressed chunk to the output file, e.g. using `OutputStream`.
    - Please note that `ZSTDProcessor` or `DictionaryZSTDProcessor` will compress each chunk into a separate frame, so you will end up with multi-frame output.  Use `ZSTDStream` if you want the combined output to be a single frame.

To decompress a large file, read the file in chunks, decompress each using `ZSTDStream`, and write it to the output file.

The wrapper is an SPM package.  The relevant ZSTD C code is not part of the repository.  `Package.swift` references the official ZSTD C repository on GitHub as a dependency.  See https://github.com/facebook/zstd for additional information, including licensing.

When using this code in your project, please build with compiler optimization enabled.  

## Platform Support

This codebase has been mostly tested on macOS, Linux, and, to a lesser extent, iOS.  `Package.swift` in the official ZSTD distribution on GitHub also suggests that tvOS is supported (based on the listed minimum platform version requirements), but this code has never been tested on tvOS. 

Tests will fail for any platform other than macOS, Linux, or iOS, but you may be able to use the library on other Apple platforms and Windows.  Streaming APIs (i.e. using `ZSTDStream`) are expected to fail on Linux and Windows.  Platform support is expected to be expanded in upcoming releases.

