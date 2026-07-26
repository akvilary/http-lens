#define _GNU_SOURCE
#ifdef __linux__

#include "CLens.h"
#include <string.h>
#include <zlib.h>

long sl_gzip_compress(const unsigned char *input, long input_len,
                      unsigned char *output, long output_len, int level) {
    z_stream stream;
    memset(&stream, 0, sizeof(stream));
    stream.next_in = (Bytef *)input;
    stream.avail_in = (uInt)input_len;
    stream.next_out = (Bytef *)output;
    stream.avail_out = (uInt)output_len;

    int ret = deflateInit2(&stream, level, Z_DEFLATED, 15 | 16, 8, Z_DEFAULT_STRATEGY);
    if (ret != Z_OK) return -1;

    ret = deflate(&stream, Z_FINISH);
    long total = (long)stream.total_out;
    deflateEnd(&stream);

    if (ret != Z_STREAM_END) return -1;
    return total;
}

#endif /* __linux__ */
