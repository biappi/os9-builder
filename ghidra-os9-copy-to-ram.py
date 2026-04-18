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


start = 0xcd8
end = 0xd080
dest = 0x08010000
copy_memory_range(toAddr(start), toAddr(dest), end - start)
