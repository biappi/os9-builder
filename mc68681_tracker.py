"""
Given a file with MAME console output, tracks the characters sent by the sc68681
driver and received by the MAME mc68681 port emulator and prints, for each
character,  which lines contain the log for the former and the latter. The file
is expected to have logs from one port only.

Enable VERBOSE in mc68681.cpp and rebuild MAME. Run it with "-log -oslog". In
the debug window, add a breakpoint like "bpset 13d60,1,{ printf "port@%06x
D0.b=%02x BaseAddr=%08x OutCount=%3d", a2, d0, d@(a2+0x56+0x18),
w@(a2+0x56+0x1c), b@(a2+0x56+0x2a); g }".
"""

import re

with open('megatrace.duart0.txt', encoding='utf-8') as f:
    lines = f.readlines()

app_chars = []
driver_chars = []

app_regex = re.compile(r"D0\.b=([0-9a-f]{2}).*OutCount=([0-9 ]{3})")
driver_regex = re.compile(r"THRA\) with (..)")

for i, line in enumerate(lines, start=1):
    app_match = app_regex.search(line)
    if app_match:
        val = int(app_match.group(1), base=16)
        fill = int(app_match.group(2).strip())
        app_chars.append((i, val, fill))

    driver_match = driver_regex.search(line)
    if driver_match:
        val = int(driver_match.group(1), base=16)
        driver_chars.append((i, val))

while app_chars and driver_chars:
    app_line, app_char, app_fill = app_chars[0]
    if app_fill == 140:
        app_chars = app_chars[1:]

    driver_line, driver_char = driver_chars[0]
    if app_char != driver_char:
        print(f"failed match: app line {app_line} ({app_char:02x}) vs. driver line {driver_line} ({driver_char:02x})")
        break

    print(f'tracking char {app_char:02x}: app {app_line} driver {driver_line}')
    app_chars = app_chars[1:]
    driver_chars = driver_chars[1:]
