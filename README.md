# pngplayground
Tool for experimenting with and repairing PNG files.

Designed for fixing up intentionally-broken PNGs in things like CTF events, but
hopefully useful in other scenarios too.

Features:
- Parses and interprets PNG chunks, giving you the info in plain text.
- Checks CRCs on chunks and lets you see any that are bad (in the future will
  also check zlib CRC on IDAT blocks)
- Allows extracting specific blocks to separate files for easier analysis (and
  in the future, importing specific blocks back from these files)
- In the future, will allow editing of all internal PNG data in chunks.
