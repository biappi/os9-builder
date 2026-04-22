# Scan for OS-9/68k modules in the "ram" fragment of the Ghidra program,
# where the Aesthedes 2 bootloader has copied them for execution.
# The script is written for Python 2.7, and tested for Ghidra 10.1.5.
# Usage: copy-paste the entire script into the Ghidra Script Editor and run it.

from ghidra.program.model.address import AddressSet
from ghidra.program.model.data import IntegerDataType
from ghidra.program.model.symbol import SourceType

def os9_crc(addr, size):
    # OS-9/68k 24-bit CRC calculation
    # Polynomial: 0x800063
    crc = 0xFFFFFF
    for i in range(size):
        byte = getByte(addr.add(i)) & 0xFF
        crc ^= (byte << 16)
        for _ in range(8):
            if (crc & 0x800000):
                crc = (crc << 1) ^ 0x800063
            else:
                crc <<= 1
        crc &= 0xFFFFFF
    # The result is XORed with 0xFFFFFF and compared at the end
    return crc ^ 0xFFFFFF


def find_modules(start_addr):
    sync_pattern = "\x4A\xFC"
    current_addr = start_addr
    #
    while True:
        current_addr = find(current_addr, sync_pattern)
        if current_addr is None:
            return
        #
        try:
            # Offset 0x04: Module Size (4 bytes)
            mod_size = getInt(current_addr.add(0x04))
            #
            # Sanity check size before trying to CRC
            if mod_size < 0x30 or mod_size > 0x100000:
                current_addr = current_addr.add(2)
                continue
            #
            # OS-9 CRC covers everything except the last 3 bytes
            calc_crc = os9_crc(current_addr, mod_size - 3)
            stored_crc = getInt(current_addr.add(mod_size - 4)) & 0xFFFFFF
            #
            if calc_crc != stored_crc:
                # False positive: sync code found but CRC failed
                current_addr = current_addr.add(2)
                continue
            #
            # If we reach here, it's a valid module
            yield current_addr, mod_size
            current_addr = current_addr.add(mod_size)
        except Exception as e:
            print("Error at {}: {}".format(current_addr, str(e)))


def get_module_name(current_addr):
    name_ptr_offset = getInt(current_addr.add(0x0C))
    name_addr = current_addr.add(name_ptr_offset)
    #
    mod_name = ""
    i = 0
    while i < 32:
        char = getByte(name_addr.add(i)) & 0xFF
        if char == 0 or char == 0x0D: break
        mod_name += chr(char)
        i += 1
    #
    if not mod_name:
        mod_name = "Module_" + str(current_addr)
    #
    return mod_name


def add_fragment(mod_name, current_addr, mod_size):
    tree_manager = currentProgram.getTreeManager()
    tree = tree_manager.getRootModule("Program Tree")
    if not tree:
        raise Exception("Could not find 'Program Tree'.")
    #
    new_set = AddressSet(current_addr, current_addr.add(mod_size - 1))
    fragment = tree_manager.getFragment("Program Tree", mod_name)
    if fragment is None:
        tree.createFragment(mod_name).move(new_set.minAddress, new_set.maxAddress)
    else:
        fragment.move(new_set.minAddress, new_set.maxAddress)


def create_label_with_namespaces(label, address):
    # Create namespaces for a label with '::' separators, if they don't exist
    parts = label.split("::")
    if len(parts) < 2:
        return None  # No namespaces needed
    #
    symbol_table = currentProgram.getSymbolTable()
    #
    current_namespace = None
    for part in parts[:-1]:  # All but the last part are namespaces
        if symbol_table.getNamespace(part, current_namespace) is not None:
            current_namespace = symbol_table.getNamespace(part, current_namespace)
        else:
            current_namespace = symbol_table.createNameSpace(current_namespace, part, SourceType.USER_DEFINED)
    #
    return symbol_table.createLabel(address, parts[-1], current_namespace, SourceType.USER_DEFINED)  # Create the label in the final namespace


def add_label_and_datatype_for_module_name(current_addr, mod_name):
    listing = currentProgram.getListing()
    #
    # Set datatype and label for the name_ptr_offset field at offset 0x0C
    uint32_type = IntegerDataType.dataType
    name_ptr_addr = current_addr.add(0x0C)
    # If there is data already, clear it before creating new data
    existing_data = listing.getDataAt(name_ptr_addr)
    if existing_data:
        listing.clearCodeUnits(name_ptr_addr, name_ptr_addr, False)
    listing.createData(name_ptr_addr, uint32_type)
    #
    label_name = "{}::os9::hdr::M$Name".format(mod_name)
    create_label_with_namespaces(label_name, name_ptr_addr)


def run(start_addr, end_addr):
    for module_addr, module_size in find_modules(start_addr):
        module_name = get_module_name(module_addr)
        print("Found module '{}' at {}".format(module_name, module_addr))
        add_fragment(module_name, module_addr, module_size)
        add_label_and_datatype_for_module_name(module_addr, module_name)


# only scan RAM fragment because that's where the modules will
# be executed, unlike the EPROM at addr 0x0.
memory = currentProgram.getMemory()
ram_block = memory.getBlock("ram")
start_addr = ram_block.getStart()
end_addr = ram_block.getEnd()
run(start_addr, end_addr)