import os, struct, zlib
S = 1024
bg, fg = bytes((5, 8, 16)), bytes((0, 180, 216))
rows = []
for y in range(S):
    row = bytearray(bg * S)
    if 230 <= y <= 800:
        t = (y - 230) / 570
        for c in (300 + t * 212, 724 - t * 212):
            a, b = max(0, int(c - 95)), min(S, int(c + 95))
            row[a * 3:b * 3] = fg * (b - a)
    rows.append(b"\x00" + bytes(row))

def chunk(t, d):
    return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

png = (b"\x89PNG\r\n\x1a\n"
       + chunk(b"IHDR", struct.pack(">IIBBBBB", S, S, 8, 2, 0, 0, 0))
       + chunk(b"IDAT", zlib.compress(b"".join(rows), 9))
       + chunk(b"IEND", b""))

d = "Assets.xcassets/AppIcon.appiconset"
os.makedirs(d, exist_ok=True)
open("Assets.xcassets/Contents.json", "w").write('{"info":{"author":"xcode","version":1}}')
open(d + "/Contents.json", "w").write('{"images":[{"filename":"icon.png","idiom":"universal","platform":"ios","size":"1024x1024"}],"info":{"author":"xcode","version":1}}')
open(d + "/icon.png", "wb").write(png)
print("icon ready")
