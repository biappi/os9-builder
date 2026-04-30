# Do what the Aesthedes 2 bootloader does: copy OS-9 kernel and modules from EPROM to RAM
# @author Gemini
# @category Memory

from ghidra.program.model.address import Address

def copy_memory_range(src_addr, dst_addr, length):
    try:
        print "Reading {} bytes from {}...".format(length, src_addr)
        from array import array
        buffer = array('b', [0] * length)
        currentProgram.getMemory().getBytes(src_addr, buffer)
        print "Writing to {}...".format(dst_addr)
        setBytes(dst_addr, buffer)
    except Exception as e:
        print "Error during copy: {}".format(e)

# first stage (enough for RAM disk)
start = 0xcd8
end = 0xd080
dest = 0x08010000
size = end - start
copy_memory_range(toAddr(start), toAddr(dest), size)
print "First stage copied from range 0x{:x}-0x{:x} to 0x{:x}-0x{:x}".format(start, end, dest, dest + size)

# second stage (SCSI and floppy)
# 0x2a6 bytes starting from 0xd0c0 (by looking at last nonzero RAM addr in MAME, 0x801c64d)
stage2_start = 0xd0c0
stage2_size = 0x2a6
stage2_end = stage2_start + stage2_size
stage2_dest = dest + size
copy_memory_range(toAddr(stage2_start), toAddr(stage2_dest), stage2_size)
print "Second stage copied from range 0x{:x}-0x{:x} to 0x{:x}-0x{:x}".format(stage2_start, stage2_end, stage2_dest, stage2_dest + stage2_size)