
def load_binary_file_to_memory(file_path, skip, length, dest_addr):
    """
    Load a binary file into Ghidra, by setting bytes in writable mapped memory.
    This is different than using the "Add to Program", which creates a new memory block
    on an unmapped address.
    """
    try:
        with open(file_path, 'rb') as f:
            f.seek(skip)
            data = f.read(length)
            print "Read {} bytes from file {}".format(len(data), file_path)
            setBytes(toAddr(dest_addr), data)
            print "Loaded data to memory at address 0x{:x}".format(dest_addr)
    except Exception as e:
        print "Error loading binary file: {}".format(e)

load_binary_file_to_memory("os9-ram.bin", 0xc3a8, 0x2a6, 0x0801c3a8)