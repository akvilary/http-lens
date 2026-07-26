#ifndef CLENS_H
#define CLENS_H

#ifdef __linux__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Compress data using gzip (zlib). Returns compressed size, or -1 on error.
/// `output` must be at least deflateBound(input_len) bytes.
long sl_gzip_compress(const unsigned char *input, long input_len,
                      unsigned char *output, long output_len, int level);

#ifdef __cplusplus
}
#endif

#endif /* __linux__ */
#endif /* CLENS_H */
