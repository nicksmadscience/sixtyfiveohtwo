from py65emu.cpu import CPU
from py65emu.mmu import MMU

from shiftregister import ShiftRegister

import time

f = open("lsr.out", "rb")  # Open your rom

# define your blocks of memory.  Each tuple is
# (start_address, length, readOnly=True, value=None, valueOffset=0)
mmu = MMU([
        (0x00, 0x1000), # Create RAM
        (0x8000, 0x8000, True, f), # Create ROM starting at 0x1000 with your program.
        (0x6000, 16, False, f)
])

# Create the CPU with the MMU and the starting program counter address
# You can also optionally pass in a value for stack_page, which defaults
# to 1, meaning the stack will be from 0x100-0x1ff.  As far as I know this
# is true for all 6502s, but for instance in the 6507 used by the Atari
# 2600 it is in the zero page, stack_page=0.
c = CPU(mmu, 0x8000)

sr = ShiftRegister(40)

def bit(val, bit):
    return (val >> bit) & 1


def formatByte(val):
    f = ""
    for i in range(0, 8):
        f += str(bit(val, i))
    return f
        

for i in range(0, 10):
    print()

# Do this to execute one instruction
counter = 0
mode = 0
# c.writeByte(0x6008, 0) 
while True:
    try:
        c.step()

        srval = c.readByte(0x6000)
        # print (c.op, "\ta:", formatByte(c.r.a), "\tx:", c.r.x, "\ty:", c.r.y,
        #        "\tsrval:", formatByte(srval), "\tsource:", formatByte(c.readByte(0x0000)),
        #        "\tin:", formatByte(c.readByte(0x6008)))
        # print ("debug:", c.readByte(0x0200),
        #        "\tpausetime:", c.readByte(0x000d),
        #        "\tpattern:", c.readByte(0x0015),
        #        "\tsuperpause:", c.readByte(0x0014))
        sr.data(bool(bit(srval, 0)))
        sr.clock(bool(bit(srval, 1)))
        sr.latch(bool(bit(srval, 2)))
        sr.printregister()
    except IndexError:
        print ('index error')
        exit()

    time.sleep(0.0001)
    counter += 1

    # c.writeByte(0x6008, 15) 

    
    if counter % 20000 == 0:
        
        if mode == 16:
            mode = 0
        print ("mode", mode)
        
        c.writeByte(0x6008, mode)
        mode += 1

    # input()


    



# # You can check the registers and memory values to determine what has changed
# print(c.r.a) 	# A register
# print(c.r.x) 	# X register
# print(c.r.y) 	# Y register
# print(c.r.s) 	# Stack Pointer
# print(c.r.pc) 	# Program Counter

# print(c.cc)     # Print the number of cycles that passed during the last step.
#                 # This number resets for each call to `.step()`

# print(c.r.getFlag('C')) # Get the value of a flag from the flag register.

# print(mmu.read(0xff)) # Read a value from memory