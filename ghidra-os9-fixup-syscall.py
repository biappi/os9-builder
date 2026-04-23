# @category: OS-9
# @author: Gemini
from ghidra.program.model.symbol import SourceType
from ghidra.program.model.listing import ParameterImpl, FlowOverride
from ghidra.program.model.data import LongDataType, WordDataType, PointerDataType
from ghidra.program.model.symbol import RefType

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
    symbol_name = "os9_syscall_{:04x}_{}".format(syscall_id, name)
    
    funcs = getGlobalFunctions(symbol_name)
    if funcs:
        return funcs[0]
    
    v_addr = block.getStart().add(syscall_id * 8)
    clearListing(v_addr, v_addr.add(7))
    func = createFunction(v_addr, symbol_name)
    
    if not func:
        raise OS9MappingError("Could not create function '{}' at address {}".format(symbol_name, v_addr))
    
    try:
        reg_d0 = currentProgram.getRegister("D0")
        reg_d1 = currentProgram.getRegister("D1")
        reg_a0 = currentProgram.getRegister("A0")
        
        params = [
            ParameterImpl("path", WordDataType.dataType, reg_d0, currentProgram),
            ParameterImpl("count", LongDataType.dataType, reg_d1, currentProgram),
            ParameterImpl("buffer", PointerDataType(None), reg_a0, currentProgram)
        ]
        ret_param = ParameterImpl("status", LongDataType.dataType, reg_d1, currentProgram)
        
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

def process_trap_at_address(addr):
    inst = getInstructionAt(addr)
    if not inst or "trap" not in inst.getMnemonicString().lower():
        return
    
    syscall_id = getShort(addr.add(2)) & 0xFFFF
    
    syscall_map = {0x0009: "i_read", 0x0006: "i_exit"}
    name = syscall_map.get(syscall_id, "unknown_syscall")
    
    vfunc = get_or_create_vfunc(name, syscall_id)
    
    # Fix local flow
    clearListing(addr.add(2), addr.add(3))
    createWord(addr.add(2))
    
    fallthrough_addr = addr.add(4)
    inst.setFallThrough(fallthrough_addr)
    inst.setFlowOverride(FlowOverride.CALL)
    
    addInstructionXref(addr, vfunc.getEntryPoint(), 0, RefType.UNCONDITIONAL_CALL)
    
    inst.setComment(inst.EOL_COMMENT, "os-9: " + name)
    print("Successfully mapped trap at {} to {}".format(addr, name))

process_trap_at_address(toAddr(0x0801af9c))