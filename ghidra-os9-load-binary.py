
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

def load_binary_file():
    try:
        binary_file = askFile("Select binary file", "Load")
        destination_text = askString(
            "Destination address",
            "Enter the destination address (for example, 0x0801c3a8):"
        )
        destination_address = int(destination_text.strip(), 0)

        load_binary_file_to_memory(
            binary_file.getAbsolutePath(),
            0,
            binary_file.length(),
            destination_address
        )
    except Exception as e:
        print "Error selecting binary file or destination address: {}".format(e)

load_binary_file()