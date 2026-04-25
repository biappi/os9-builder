# @category: OS-9
# @author: Gemini
from ghidra.program.model.symbol import SourceType, RefType
from ghidra.program.model.listing import ParameterImpl, FlowOverride
from ghidra.program.model.data import UnsignedIntegerDataType, UnsignedShortDataType, PointerDataType, UnsignedCharDataType

class OS9MappingError(Exception):
    """Custom exception for OS-9 script failures."""
    pass


def get_syscall_block():
    block_name = "Syscalls"
    memory = currentProgram.getMemory()
    block = memory.getBlock(block_name)
    
    if block is None:
        start_addr = currentProgram.getAddressFactory().getAddress("F0000000")
        try:
            block = memory.createInitializedBlock(block_name, start_addr, 0x10000, 0, None, False)
            print("Created 'Syscalls' memory block at F0000000")
        except Exception as e:
            raise OS9MappingError("Failed to create memory block at F0000000: " + str(e))
            
    return block


def get_or_create_vfunc(name, syscall_id):
    block = get_syscall_block()
    symbol_name = "os9_{}".format(name)
    
    funcs = getGlobalFunctions(symbol_name)
    if funcs:
        return funcs[0]
    
    v_addr = block.getStart().add(syscall_id * 8)
    clearListing(v_addr, v_addr.add(7))
    func = createFunction(v_addr, symbol_name)
    
    if not func:
        raise OS9MappingError("Could not create function '{}' at address {}".format(symbol_name, v_addr))
    
    try:
        def to_parameter(register, type, name):
            reg = currentProgram.getRegister(register)
            if reg is None:
                raise OS9MappingError("Register '{}' not found in program".format(register))
            return ParameterImpl(name, type, reg, currentProgram)

        syscall_info = syscall_map[syscall_id]
        params = [
            to_parameter(*param_info) \
            for param_info in syscall_info["params"]
        ]
        ret_param = None if syscall_info["return"] is None else \
            to_parameter(*syscall_info["return"])

        func.updateFunction(
            None,
            ret_param,
            params,
            func.FunctionUpdateType.CUSTOM_STORAGE,
            True,
            SourceType.USER_DEFINED
        )
    except Exception as e:
        raise OS9MappingError("Failed to update function signature for {}: {}".format(name, str(e)))
        
    return func


syscall_map = {
    0x09: {
        "name": "F$Icpt",
        "params": [
            ("A0", PointerDataType(None), "signal_handler_address"),
            ("A6", PointerDataType(None), "data_area_base_address")
        ],
        "return": None
    },
    0x16: {
        "name": "F$STime",
        "params": [
            ("D0", UnsignedIntegerDataType.dataType, "current_time"),
            ("D1", UnsignedIntegerDataType.dataType, "current_date")
        ],
        "return": ("D1w", UnsignedShortDataType.dataType, "error_code")
    },
    0x80: {
        "name": "I$Attach",
        "params": [
            ("D0b", UnsignedCharDataType.dataType, "access_mode"),
            ("A0", PointerDataType(None).dataType, "path"),
            ("A2", PointerDataType(None), "out_dev_table_entry_address")
        ],
        "return": ("D1w", UnsignedShortDataType.dataType, "error_code")
    }
}

def process_trap_at_address(addr):
    inst = getInstructionAt(addr)
    # Extract syscall ID
    syscall_id = getShort(addr.add(2)) & 0xFFFF
    
    if syscall_id not in syscall_map:
        raise OS9MappingError("Unknown syscall ID {:04x} at address {}".format(syscall_id, addr))
    name = syscall_map[syscall_id]["name"]
    
    vfunc = get_or_create_vfunc(name, syscall_id)
    
    # Fix listing: Clear word, Create word
    clearListing(addr.add(2), addr.add(3))
    createWord(addr.add(2))
    
    # Fix flow: Skip the syscall ID word
    fallthrough_addr = addr.add(4)
    inst.setFallThrough(fallthrough_addr)
    
    # Add XREF and Flow Override for Decompiler/Analysis
    addInstructionXref(addr, vfunc.getEntryPoint(), 0, RefType.UNCONDITIONAL_CALL)
    inst.setFlowOverride(FlowOverride.CALL)
    
    inst.setComment(inst.EOL_COMMENT, "os-9: " + name)
    print("Fixed and resumed flow at {}".format(addr))


def process_and_continue(start_addr):
    """
    Disassembles and fixes traps starting from start_addr until
    the end of the flow.
    """
    addr = start_addr
    
    while addr is not None:
        # 1. Ensure the current address is disassembled
        print("Processing address: {}".format(addr))
        if getInstructionAt(addr) is None:
            disassemble(addr)
        
        inst = getInstructionAt(addr)
        if not inst:
            print("Failed to disassemble at {}, stopping flow.".format(addr))
            break
        
        # 2. Check if this is a trap
        if "trap" in inst.getMnemonicString().lower():
            # Apply your existing fix logic
            process_trap_at_address(addr)
            
            # 3. Get the fallthrough address we just set (addr + 4)
            next_addr = inst.getFallThrough()
            
            # 4. Kickstart disassembly at the next valid instruction
            if next_addr:
                # Clear a small range ahead to ensure there are no bad instructions
                # decoded at wrong addresses.
                clearListing(next_addr, next_addr.add(15))
                disassemble(next_addr)
                addr = next_addr
                continue
        
        # Move to the next instruction in the current flow
        addr = inst.getNext().getAddress()


# --- Main Execution ---
# Start from wherever your cursor is
process_and_continue(currentAddress)