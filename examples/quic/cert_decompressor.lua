-- cert_decompressor : 
-- extract a DER certificate from a QUIC crypto compressed 
-- decompress_chain( compressed-str )
--

local ffi=require('ffi')
-- local Z = ffi.load('/lib/x86_64-linux-gnu/libz.so.1')
local Z = ffi.load('z')
local SWB=require'sweepbuf'

ffi.cdef[[
typedef struct z_stream_s {
    const char   *next_in;     /* next input byte */
    int     avail_in;  /* number of bytes available at next_in */
    long    total_in;  /* total number of input bytes read so far */

    char    *next_out; /* next output byte should be put there */
    int     avail_out; /* remaining free space at next_out */
    long    total_out; /* total number of bytes output so far */

    const char *  msg;  /* last error message, NULL if no error */
    void *  state; /* not visible by applications */

    void *  zalloc;  /* used to allocate the internal state */
    void *  zfree;   /* used to free the internal state */
    void *  opaque;  /* private data object passed to zalloc and zfree */

    int     data_type;  /* best guess about the data type: binary or text */
    long    adler;      /* adler32 value of the uncompressed data */
    long    reserved;   /* reserved for future use */
} z_stream;

int  inflateInit_(z_stream *, const char *, size_t );
int  inflate(z_stream *, int);
int  inflateSetDictionary(z_stream*, char * , size_t ); 
int  inflateEnd (z_stream*);


]]
-- End setup FFI into libcrypto 
-------------------------------------------------------------------------------

local kCommonCertSubstrings = {
    0x04, 0x02, 0x30, 0x00, 0x30, 0x1d, 0x06, 0x03, 0x55, 0x1d, 0x25, 0x04,
    0x16, 0x30, 0x14, 0x06, 0x08, 0x2b, 0x06, 0x01, 0x05, 0x05, 0x07, 0x03,
    0x01, 0x06, 0x08, 0x2b, 0x06, 0x01, 0x05, 0x05, 0x07, 0x03, 0x02, 0x30,
    0x5f, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x86, 0xf8, 0x42, 0x04, 0x01,
    0x06, 0x06, 0x0b, 0x60, 0x86, 0x48, 0x01, 0x86, 0xfd, 0x6d, 0x01, 0x07,
    0x17, 0x01, 0x30, 0x33, 0x20, 0x45, 0x78, 0x74, 0x65, 0x6e, 0x64, 0x65,
    0x64, 0x20, 0x56, 0x61, 0x6c, 0x69, 0x64, 0x61, 0x74, 0x69, 0x6f, 0x6e,
    0x20, 0x53, 0x20, 0x4c, 0x69, 0x6d, 0x69, 0x74, 0x65, 0x64, 0x31, 0x34,
    0x20, 0x53, 0x53, 0x4c, 0x20, 0x43, 0x41, 0x30, 0x1e, 0x17, 0x0d, 0x31,
    0x32, 0x20, 0x53, 0x65, 0x63, 0x75, 0x72, 0x65, 0x20, 0x53, 0x65, 0x72,
    0x76, 0x65, 0x72, 0x20, 0x43, 0x41, 0x30, 0x2d, 0x61, 0x69, 0x61, 0x2e,
    0x76, 0x65, 0x72, 0x69, 0x73, 0x69, 0x67, 0x6e, 0x2e, 0x63, 0x6f, 0x6d,
    0x2f, 0x45, 0x2d, 0x63, 0x72, 0x6c, 0x2e, 0x76, 0x65, 0x72, 0x69, 0x73,
    0x69, 0x67, 0x6e, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x45, 0x2e, 0x63, 0x65,
    0x72, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01,
    0x01, 0x05, 0x05, 0x00, 0x03, 0x82, 0x01, 0x01, 0x00, 0x4a, 0x2e, 0x63,
    0x6f, 0x6d, 0x2f, 0x72, 0x65, 0x73, 0x6f, 0x75, 0x72, 0x63, 0x65, 0x73,
    0x2f, 0x63, 0x70, 0x73, 0x20, 0x28, 0x63, 0x29, 0x30, 0x30, 0x09, 0x06,
    0x03, 0x55, 0x1d, 0x13, 0x04, 0x02, 0x30, 0x00, 0x30, 0x1d, 0x30, 0x0d,
    0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x05, 0x05,
    0x00, 0x03, 0x82, 0x01, 0x01, 0x00, 0x7b, 0x30, 0x1d, 0x06, 0x03, 0x55,
    0x1d, 0x0e, 0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86,
    0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01,
    0x0f, 0x00, 0x30, 0x82, 0x01, 0x0a, 0x02, 0x82, 0x01, 0x01, 0x00, 0xd2,
    0x6f, 0x64, 0x6f, 0x63, 0x61, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x43, 0x2e,
    0x63, 0x72, 0x6c, 0x30, 0x1d, 0x06, 0x03, 0x55, 0x1d, 0x0e, 0x04, 0x16,
    0x04, 0x14, 0xb4, 0x2e, 0x67, 0x6c, 0x6f, 0x62, 0x61, 0x6c, 0x73, 0x69,
    0x67, 0x6e, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x72, 0x30, 0x0b, 0x06, 0x03,
    0x55, 0x1d, 0x0f, 0x04, 0x04, 0x03, 0x02, 0x01, 0x30, 0x0d, 0x06, 0x09,
    0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x05, 0x05, 0x00, 0x30,
    0x81, 0xca, 0x31, 0x0b, 0x30, 0x09, 0x06, 0x03, 0x55, 0x04, 0x06, 0x13,
    0x02, 0x55, 0x53, 0x31, 0x10, 0x30, 0x0e, 0x06, 0x03, 0x55, 0x04, 0x08,
    0x13, 0x07, 0x41, 0x72, 0x69, 0x7a, 0x6f, 0x6e, 0x61, 0x31, 0x13, 0x30,
    0x11, 0x06, 0x03, 0x55, 0x04, 0x07, 0x13, 0x0a, 0x53, 0x63, 0x6f, 0x74,
    0x74, 0x73, 0x64, 0x61, 0x6c, 0x65, 0x31, 0x1a, 0x30, 0x18, 0x06, 0x03,
    0x55, 0x04, 0x0a, 0x13, 0x11, 0x47, 0x6f, 0x44, 0x61, 0x64, 0x64, 0x79,
    0x2e, 0x63, 0x6f, 0x6d, 0x2c, 0x20, 0x49, 0x6e, 0x63, 0x2e, 0x31, 0x33,
    0x30, 0x31, 0x06, 0x03, 0x55, 0x04, 0x0b, 0x13, 0x2a, 0x68, 0x74, 0x74,
    0x70, 0x3a, 0x2f, 0x2f, 0x63, 0x65, 0x72, 0x74, 0x69, 0x66, 0x69, 0x63,
    0x61, 0x74, 0x65, 0x73, 0x2e, 0x67, 0x6f, 0x64, 0x61, 0x64, 0x64, 0x79,
    0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x72, 0x65, 0x70, 0x6f, 0x73, 0x69, 0x74,
    0x6f, 0x72, 0x79, 0x31, 0x30, 0x30, 0x2e, 0x06, 0x03, 0x55, 0x04, 0x03,
    0x13, 0x27, 0x47, 0x6f, 0x20, 0x44, 0x61, 0x64, 0x64, 0x79, 0x20, 0x53,
    0x65, 0x63, 0x75, 0x72, 0x65, 0x20, 0x43, 0x65, 0x72, 0x74, 0x69, 0x66,
    0x69, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x20, 0x41, 0x75, 0x74, 0x68,
    0x6f, 0x72, 0x69, 0x74, 0x79, 0x31, 0x11, 0x30, 0x0f, 0x06, 0x03, 0x55,
    0x04, 0x05, 0x13, 0x08, 0x30, 0x37, 0x39, 0x36, 0x39, 0x32, 0x38, 0x37,
    0x30, 0x1e, 0x17, 0x0d, 0x31, 0x31, 0x30, 0x0e, 0x06, 0x03, 0x55, 0x1d,
    0x0f, 0x01, 0x01, 0xff, 0x04, 0x04, 0x03, 0x02, 0x05, 0xa0, 0x30, 0x0c,
    0x06, 0x03, 0x55, 0x1d, 0x13, 0x01, 0x01, 0xff, 0x04, 0x02, 0x30, 0x00,
    0x30, 0x1d, 0x30, 0x0f, 0x06, 0x03, 0x55, 0x1d, 0x13, 0x01, 0x01, 0xff,
    0x04, 0x05, 0x30, 0x03, 0x01, 0x01, 0x00, 0x30, 0x1d, 0x06, 0x03, 0x55,
    0x1d, 0x25, 0x04, 0x16, 0x30, 0x14, 0x06, 0x08, 0x2b, 0x06, 0x01, 0x05,
    0x05, 0x07, 0x03, 0x01, 0x06, 0x08, 0x2b, 0x06, 0x01, 0x05, 0x05, 0x07,
    0x03, 0x02, 0x30, 0x0e, 0x06, 0x03, 0x55, 0x1d, 0x0f, 0x01, 0x01, 0xff,
    0x04, 0x04, 0x03, 0x02, 0x05, 0xa0, 0x30, 0x33, 0x06, 0x03, 0x55, 0x1d,
    0x1f, 0x04, 0x2c, 0x30, 0x2a, 0x30, 0x28, 0xa0, 0x26, 0xa0, 0x24, 0x86,
    0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x63, 0x72, 0x6c, 0x2e,
    0x67, 0x6f, 0x64, 0x61, 0x64, 0x64, 0x79, 0x2e, 0x63, 0x6f, 0x6d, 0x2f,
    0x67, 0x64, 0x73, 0x31, 0x2d, 0x32, 0x30, 0x2a, 0x30, 0x28, 0x06, 0x08,
    0x2b, 0x06, 0x01, 0x05, 0x05, 0x07, 0x02, 0x01, 0x16, 0x1c, 0x68, 0x74,
    0x74, 0x70, 0x73, 0x3a, 0x2f, 0x2f, 0x77, 0x77, 0x77, 0x2e, 0x76, 0x65,
    0x72, 0x69, 0x73, 0x69, 0x67, 0x6e, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x63,
    0x70, 0x73, 0x30, 0x34, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x5a, 0x17,
    0x0d, 0x31, 0x33, 0x30, 0x35, 0x30, 0x39, 0x06, 0x08, 0x2b, 0x06, 0x01,
    0x05, 0x05, 0x07, 0x30, 0x02, 0x86, 0x2d, 0x68, 0x74, 0x74, 0x70, 0x3a,
    0x2f, 0x2f, 0x73, 0x30, 0x39, 0x30, 0x37, 0x06, 0x08, 0x2b, 0x06, 0x01,
    0x05, 0x05, 0x07, 0x02, 0x30, 0x44, 0x06, 0x03, 0x55, 0x1d, 0x20, 0x04,
    0x3d, 0x30, 0x3b, 0x30, 0x39, 0x06, 0x0b, 0x60, 0x86, 0x48, 0x01, 0x86,
    0xf8, 0x45, 0x01, 0x07, 0x17, 0x06, 0x31, 0x0b, 0x30, 0x09, 0x06, 0x03,
    0x55, 0x04, 0x06, 0x13, 0x02, 0x47, 0x42, 0x31, 0x1b, 0x53, 0x31, 0x17,
    0x30, 0x15, 0x06, 0x03, 0x55, 0x04, 0x0a, 0x13, 0x0e, 0x56, 0x65, 0x72,
    0x69, 0x53, 0x69, 0x67, 0x6e, 0x2c, 0x20, 0x49, 0x6e, 0x63, 0x2e, 0x31,
    0x1f, 0x30, 0x1d, 0x06, 0x03, 0x55, 0x04, 0x0b, 0x13, 0x16, 0x56, 0x65,
    0x72, 0x69, 0x53, 0x69, 0x67, 0x6e, 0x20, 0x54, 0x72, 0x75, 0x73, 0x74,
    0x20, 0x4e, 0x65, 0x74, 0x77, 0x6f, 0x72, 0x6b, 0x31, 0x3b, 0x30, 0x39,
    0x06, 0x03, 0x55, 0x04, 0x0b, 0x13, 0x32, 0x54, 0x65, 0x72, 0x6d, 0x73,
    0x20, 0x6f, 0x66, 0x20, 0x75, 0x73, 0x65, 0x20, 0x61, 0x74, 0x20, 0x68,
    0x74, 0x74, 0x70, 0x73, 0x3a, 0x2f, 0x2f, 0x77, 0x77, 0x77, 0x2e, 0x76,
    0x65, 0x72, 0x69, 0x73, 0x69, 0x67, 0x6e, 0x2e, 0x63, 0x6f, 0x6d, 0x2f,
    0x72, 0x70, 0x61, 0x20, 0x28, 0x63, 0x29, 0x30, 0x31, 0x10, 0x30, 0x0e,
    0x06, 0x03, 0x55, 0x04, 0x07, 0x13, 0x07, 0x53, 0x31, 0x13, 0x30, 0x11,
    0x06, 0x03, 0x55, 0x04, 0x0b, 0x13, 0x0a, 0x47, 0x31, 0x13, 0x30, 0x11,
    0x06, 0x0b, 0x2b, 0x06, 0x01, 0x04, 0x01, 0x82, 0x37, 0x3c, 0x02, 0x01,
    0x03, 0x13, 0x02, 0x55, 0x31, 0x16, 0x30, 0x14, 0x06, 0x03, 0x55, 0x04,
    0x03, 0x14, 0x31, 0x19, 0x30, 0x17, 0x06, 0x03, 0x55, 0x04, 0x03, 0x13,
    0x31, 0x1d, 0x30, 0x1b, 0x06, 0x03, 0x55, 0x04, 0x0f, 0x13, 0x14, 0x50,
    0x72, 0x69, 0x76, 0x61, 0x74, 0x65, 0x20, 0x4f, 0x72, 0x67, 0x61, 0x6e,
    0x69, 0x7a, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x31, 0x12, 0x31, 0x21, 0x30,
    0x1f, 0x06, 0x03, 0x55, 0x04, 0x0b, 0x13, 0x18, 0x44, 0x6f, 0x6d, 0x61,
    0x69, 0x6e, 0x20, 0x43, 0x6f, 0x6e, 0x74, 0x72, 0x6f, 0x6c, 0x20, 0x56,
    0x61, 0x6c, 0x69, 0x64, 0x61, 0x74, 0x65, 0x64, 0x31, 0x14, 0x31, 0x31,
    0x30, 0x2f, 0x06, 0x03, 0x55, 0x04, 0x0b, 0x13, 0x28, 0x53, 0x65, 0x65,
    0x20, 0x77, 0x77, 0x77, 0x2e, 0x72, 0x3a, 0x2f, 0x2f, 0x73, 0x65, 0x63,
    0x75, 0x72, 0x65, 0x2e, 0x67, 0x47, 0x6c, 0x6f, 0x62, 0x61, 0x6c, 0x53,
    0x69, 0x67, 0x6e, 0x31, 0x53, 0x65, 0x72, 0x76, 0x65, 0x72, 0x43, 0x41,
    0x2e, 0x63, 0x72, 0x6c, 0x56, 0x65, 0x72, 0x69, 0x53, 0x69, 0x67, 0x6e,
    0x20, 0x43, 0x6c, 0x61, 0x73, 0x73, 0x20, 0x33, 0x20, 0x45, 0x63, 0x72,
    0x6c, 0x2e, 0x67, 0x65, 0x6f, 0x74, 0x72, 0x75, 0x73, 0x74, 0x2e, 0x63,
    0x6f, 0x6d, 0x2f, 0x63, 0x72, 0x6c, 0x73, 0x2f, 0x73, 0x64, 0x31, 0x1a,
    0x30, 0x18, 0x06, 0x03, 0x55, 0x04, 0x0a, 0x68, 0x74, 0x74, 0x70, 0x3a,
    0x2f, 0x2f, 0x45, 0x56, 0x49, 0x6e, 0x74, 0x6c, 0x2d, 0x63, 0x63, 0x72,
    0x74, 0x2e, 0x67, 0x77, 0x77, 0x77, 0x2e, 0x67, 0x69, 0x63, 0x65, 0x72,
    0x74, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x31, 0x6f, 0x63, 0x73, 0x70, 0x2e,
    0x76, 0x65, 0x72, 0x69, 0x73, 0x69, 0x67, 0x6e, 0x2e, 0x63, 0x6f, 0x6d,
    0x30, 0x39, 0x72, 0x61, 0x70, 0x69, 0x64, 0x73, 0x73, 0x6c, 0x2e, 0x63,
    0x6f, 0x73, 0x2e, 0x67, 0x6f, 0x64, 0x61, 0x64, 0x64, 0x79, 0x2e, 0x63,
    0x6f, 0x6d, 0x2f, 0x72, 0x65, 0x70, 0x6f, 0x73, 0x69, 0x74, 0x6f, 0x72,
    0x79, 0x2f, 0x30, 0x81, 0x80, 0x06, 0x08, 0x2b, 0x06, 0x01, 0x05, 0x05,
    0x07, 0x01, 0x01, 0x04, 0x74, 0x30, 0x72, 0x30, 0x24, 0x06, 0x08, 0x2b,
    0x06, 0x01, 0x05, 0x05, 0x07, 0x30, 0x01, 0x86, 0x18, 0x68, 0x74, 0x74,
    0x70, 0x3a, 0x2f, 0x2f, 0x6f, 0x63, 0x73, 0x70, 0x2e, 0x67, 0x6f, 0x64,
    0x61, 0x64, 0x64, 0x79, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x30, 0x4a, 0x06,
    0x08, 0x2b, 0x06, 0x01, 0x05, 0x05, 0x07, 0x30, 0x02, 0x86, 0x3e, 0x68,
    0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x63, 0x65, 0x72, 0x74, 0x69, 0x66,
    0x69, 0x63, 0x61, 0x74, 0x65, 0x73, 0x2e, 0x67, 0x6f, 0x64, 0x61, 0x64,
    0x64, 0x79, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x72, 0x65, 0x70, 0x6f, 0x73,
    0x69, 0x74, 0x6f, 0x72, 0x79, 0x2f, 0x67, 0x64, 0x5f, 0x69, 0x6e, 0x74,
    0x65, 0x72, 0x6d, 0x65, 0x64, 0x69, 0x61, 0x74, 0x65, 0x2e, 0x63, 0x72,
    0x74, 0x30, 0x1f, 0x06, 0x03, 0x55, 0x1d, 0x23, 0x04, 0x18, 0x30, 0x16,
    0x80, 0x14, 0xfd, 0xac, 0x61, 0x32, 0x93, 0x6c, 0x45, 0xd6, 0xe2, 0xee,
    0x85, 0x5f, 0x9a, 0xba, 0xe7, 0x76, 0x99, 0x68, 0xcc, 0xe7, 0x30, 0x27,
    0x86, 0x29, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x63, 0x86, 0x30,
    0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x73, };


-- returns array of DER encoded certificates 
-- 
function decompress_chain( crtstr  ) 

	local Z_OK            =0;
	local Z_FINISH        =4;
	local Z_NEED_DICT     =2;

	local outbuf = ffi.new("char[16000]") 
	local zs = ffi.new("z_stream[1]");
	zs[0].next_out = outbuf
	zs[0].avail_out = 16000
	zs[0].next_in= crtstr
	zs[0].avail_in =  #crtstr

	local ret=Z.inflateInit_(zs,"1.2.8",ffi.sizeof(zs[0]))
	print("inflate ret "..ret)

	-- dictionary maker 
	local dict = ffi.new("unsigned char[?]",#kCommonCertSubstrings) 
	for i,val in ipairs(kCommonCertSubstrings) do
		dict[i-1]=val
	end

	local rv = Z.inflate(zs, Z_FINISH);
	if rv==Z_NEED_DICT then
		print("compressor needs dict , loading ")
		local ret= Z.inflateSetDictionary(zs, dict, #kCommonCertSubstrings)
		assert(ret==Z_OK)

		print("trying deflate with dict")
		local rv = Z.inflate(zs, Z_FINISH);
		print("rv="..rv.."  inflatde="..16000-zs[0].avail_out)
	end 

	-- write out DER cert
	local uncombuf  = ffi.string(outbuf,16000-zs[0].avail_out)
	local swp = SWB.new(uncombuf)

	local certsarr = {} 
	while swp:has_more() do 
		local len = swp:next_u32_le()
		table.insert(certsarr,swp:next_str_to_len(len))
	end

	return certsarr

end 


-- first decompress into DER , then run thru openssl x509 
-- 
function decompress_chain_x509( crtstr )

local crtf = io.open("/tmp/k.crt","wb")
crtf:write(crtstr)
crtf:close()


    local dercerts = decompress_chain(crtstr)
    local x509certs = {} 
    for i,der in ipairs(dercerts)  do
        local tmpn = os.tmpname()
        local tmpf = io.open(tmpn,"wb")
        tmpf:write(der)
        tmpf:close()

        local pipeout = io.popen("openssl x509  -in "..tmpn.." -inform der -text ")
        local xt  = pipeout:read("*a")
        pipeout:close()

        table.insert(x509certs,xt)
    end
    return x509certs

end


-- Test
--[[
local crtf = io.open("/tmp/k.crt","r")
local crtstr =    crtf:read("*all")
crtf:close()

-- Magic 
local certarr = decompress_chain(crtstr)

-- Output certs
for i,crt in ipairs(certarr) do
	local outf = io.open("/tmp/luacert"..i..".der","wb")
	outf:write(crt)
	outf:close()
end
--]]