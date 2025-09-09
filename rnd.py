import random

rs = ""

for i in range(0, 32):
    r = random.randint(0, 255)
    rs += f"${r:02x}, "

print (rs)