/*
 * Copyright (c) 2015 Develer S.r.l.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <ctype.h>

#define DEFAULT_PREFIX "DevelBoard"
#define DEFAULT_IFACE  "eth0"

int main(int argc, char *argv[]) {
    const char *iface = DEFAULT_IFACE;
    const char *prefix = DEFAULT_PREFIX;

    while (1) {
        int option_index = 0;
        static struct option long_options[] = {
            {"iface",   required_argument, 0,  'i' },
            {"prefix",  required_argument, 0,  'p' },
            {"help",    no_argument,       0,  'h' },
            {0,         0,                 0,  0   }
        };

        int c = getopt_long(argc, argv, "i:p:h",
                 long_options, &option_index);
        if (c == -1)
            break;

        switch (c) {
            case 'i':
                iface = strdup(optarg);
                break;

            case 'p':
                if (strlen(optarg) > 24) {
                    fprintf(stderr, "specified prefix too long (max 24 chars)\n");
                    return 2;
                }
                prefix = strdup(optarg);
                break;

            default:
                printf(
                    "Usage: genhostname [opts]\n"
                    "\n"
                    "Options:\n"
                    "   -i, --iface IFACE       interface to read MAC address from (default: \"" DEFAULT_IFACE "\")\n"
                    "   -p, --prefix PREFIX     prefix to use in hostname (default: \"" DEFAULT_PREFIX "\")\n"
                );
                return 1;
            }
    }

    char path[256];
    snprintf(path, sizeof(path), "/sys/class/net/%s/address", iface);

    FILE *f = fopen(path, "rb");
    if (!f) {
        fprintf(stderr, "error: cannot open %s: ", path);
        perror("");
        return 2;
    }

    char mac[64];
    if (!fgets(mac, sizeof(mac), f)) {
        fprintf(stderr, "error: cannot read from %s: ", path);
        perror("");
        return 2;
    }
    fclose(f);

    char hostname[64];
    strcpy(hostname, prefix);
    char *h = hostname + strlen(prefix);
    *h++ = '-';
    *h++ = toupper(mac[9]);
    *h++ = toupper(mac[10]);
    *h++ = toupper(mac[12]);
    *h++ = toupper(mac[13]);
    *h++ = toupper(mac[15]);
    *h++ = toupper(mac[16]);
    *h = 0;

    f = fopen("/etc/hostname", "w");
    if (!f) {
        fprintf(stderr, "error: cannot create /etc/hostname: ");
        perror("");
        return 2;
    }
    fputs(hostname, f);
    fputc('\n', f);
    fclose(f);

    sethostname(hostname, strlen(hostname));
}
