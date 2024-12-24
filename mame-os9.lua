function printx(name, value)
    print(string.format(name .. ": %x", value))
end

function dump_16(mem, name, addr)
    printx(name, mem:read_u16(addr))
end

function dump_32(mem, name, addr)
    printx(name, mem:read_u32(addr))
end

function read_asciiz(mem, addr)
    local a = addr
    local s = ""

    while true do
        local c = mem:read_u8(a)
        if c == 0 then break end
        s = s .. string.char(c)
        a = a + 1
    end

    return s
end

function get_cpu()
    return manager.machine.devices[":maincpu"]
end

function get_mem()
    return get_cpu().spaces['program']
end

function module_dir()
    local mem = get_mem()
    local sys_glob = mem:read_u32(0)
    local module_dir_start = mem:read_u32(sys_glob + 0x3c)
    local module_dir_end = mem:read_u32(sys_glob + 0x40)

    local modules = {}

    local addr = module_dir_start
    while addr < module_dir_end do
        if mem:read_u32(addr) == 0 then break end

        local module_addr     = mem:read_u32(addr + 0x00)
        local module_size     = mem:read_u32(module_addr + 0x04)
        local module_name_off = mem:read_u32(module_addr + 0x0c)
        local module_name     = read_asciiz(mem, module_addr + module_name_off)

        table.insert(modules, {
            addr = module_addr,
            size = module_size,
            name = module_name
        })

        addr = addr + 0x10
    end

    return modules
end


function mdir()
    local mem = get_mem()
    local sys_glob = mem:read_u32(0)
    local module_dir_start = mem:read_u32(sys_glob + 0x3c)
    local module_dir_end = mem:read_u32(sys_glob + 0x40)

    printx("system global", sys_glob)
    printx("modules start", module_dir_start)
    printx("modules end  ", module_dir_end)

    print("ptr       size      group     static    link  c.sum ")
    print("--------- --------- --------- --------- ----- ----- ")
    --     0003d0c8  --------- 00005d00  0004c88a  0000  ab70

    local addr = module_dir_start
    while addr < module_dir_end do
        if mem:read_u32(addr) == 0 then break end

        local module_addr     = mem:read_u32(addr + 0x00)
        local module_size     = mem:read_u32(module_addr + 0x04)
        local module_name_off = mem:read_u32(module_addr + 0x0c)
        local module_name     = read_asciiz(mem, module_addr + module_name_off)

        print(string.format("%08x  %08x  %08x  %08x  %04x  %04x    %s",
            mem:read_u32(addr + 0x00),
            module_size,
            mem:read_u32(addr + 0x04),
            mem:read_u32(addr + 0x08),
            mem:read_u16(addr + 0x0c),
            mem:read_u16(addr + 0x0e),
            module_name
        ))
        addr = addr + 0x10
    end
end

local os9_fcall_start = 0x00
local os9_fcall_end   = 0x61
local os9_icall_start = 0x80
local os9_icall_end   = 0x93

local os9_fcalls = {
 { "F$Link",     0x00020002, 0x003f000a }, -- 0x00
 { "F$Load",     0x00020001, 0x003f000a }, -- 0x01
 { "F$UnLink",   0x00300000, 0x00000000 }, -- 0x02
 { "F$Fork",     0x000e02be, 0x00030002 }, -- 0x03
 { "F$Wait",     0x00000000, 0x0000000a }, -- 0x04
 { "F$Chain",    0x000e02be, 0x00000000 }, -- 0x05
 { "F$Exit",     0x00000008, 0x00000000 }, -- 0x06
 { "F$Mem",      0x00000003, 0x000c0003 }, -- 0x07
 { "F$Send",     0x0000000a, 0x00000000 }, -- 0x08
 { "F$Icpt",     0x30030000, 0x00000000 }, -- 0x09
 { "F$Sleep",    0x00000003, 0x00000003 }, -- 0x0a
 { "F$SSpd",     0x00000002, 0x00000008 }, -- 0x0b
 { "F$ID",       0x00000000, 0x0000002e }, -- 0x0c
 { "F$SPrior",   0x0000000a, 0x00000000 }, -- 0x0d
 { "F$STrap",    0x000f0000, 0x00000000 }, -- 0x0e
 { "F$PErr",     0x0000000a, 0x00000000 }, -- 0x0f
 { "F$PrsNam",   0x00020000, 0x000f0009 }, -- 0x10
 { "F$CmpNam",   0x000a0008, 0x00000000 }, -- 0x11
 { "F$SchBit",   0x00000002, 0x00000008 }, -- 0x12
 { "F$AllBit",   0x00000002, 0x00000008 }, -- 0x13
 { "F$DelBit",   0x00000002, 0x00000008 }, -- 0x14
 { "F$Time",     0x00000002, 0x000000ef }, -- 0x15
 { "F$STime",    0x0000000f, 0x00000000 }, -- 0x16
 { "F$CRC",      0x0003000f, 0x0000000c }, -- 0x17
 { "F$GPrDsc",   0x0003000a, 0x00000000 }, -- 0x18
 { "F$GBlkMp",   0x0003000a, 0x000300ff }, -- 0x19
 { "F$GModDr",   0x0003000c, 0x0000000c }, -- 0x1a
 { "F$CpyMem",   0x000f000e, 0x00000000 }, -- 0x1b
 { "F$SUser",    0x0000000c, 0x00000000 }, -- 0x1c
 { "F$UnLoad",   0x00020002, 0x00030000 }, -- 0x1d
 { "F$RTE",      0x00000000, 0x00000000 }, -- 0x1e
 { "F$GPrDBT",   0x0003000c, 0x0000000c }, -- 0x1f
 { "F$Julian",   0x0000000f, 0x0000000f }, -- 0x20
 { "F$TLink",    0x0002000e, 0x003f0000 }, -- 0x21
 { "F$DFork",    0x00000002, 0x00000008 }, -- 0x22
 { "F$DExec",    0x00000002, 0x00000008 }, -- 0x23
 { "F$DExit",    0x00000002, 0x00000008 }, -- 0x24
 { "F$DatMod",   0x000200ab, 0x003f000a }, -- 0x25
 { "F$SetCRC",   0x00030000, 0x00000000 }, -- 0x26
 { "F$SetSys",   0x0000003e, 0x00000030 }, -- 0x27
 { "F$SRqMem",   0x00000003, 0x00300003 }, -- 0x28
 { "F$SRtMem",   0x00300003, 0x00000000 }, -- 0x29
 { "F$IRQ",      0x00000002, 0x00000008 }, -- 0x2a
 { "F$IOQu",     0x00000002, 0x00000008 }, -- 0x2b
 { "F$AProc",    0x00000002, 0x00000008 }, -- 0x2c
 { "F$NProc",    0x00000002, 0x00000008 }, -- 0x2d
 { "F$VModul",   0x00000002, 0x00000008 }, -- 0x2e
 { "F$FindPD",   0x00000002, 0x00000008 }, -- 0x2f
 { "F$AllPD",    0x00000002, 0x00000008 }, -- 0x30
 { "F$RetPD",    0x00000002, 0x00000008 }, -- 0x31
 { "F$SSvc",     0x00cc0000, 0x00000000 }, -- 0x32
 { "F$IODel",    0x00000002, 0x00000008 }, -- 0x33
 { "F$???_34",   0x00000002, 0x00000008 }, -- 0x34
 { "F$???_35",   0x00000002, 0x00000008 }, -- 0x35
 { "F$???_36",   0x00000002, 0x00000008 }, -- 0x36
 { "F$GProcP",   0x00000002, 0x00000008 }, -- 0x37
 { "F$Move",     0x00000002, 0x00000008 }, -- 0x38
 { "F$AllRAM",   0x00000002, 0x00000008 }, -- 0x39
 { "F$Permit",   0x00300007, 0x00000008 }, -- 0x3a
 { "F$Protect",  0x00000002, 0x00000008 }, -- 0x3b
 { "F$SetImg",   0x00000002, 0x00000008 }, -- 0x3c
 { "F$FreeLB",   0x00000002, 0x00000008 }, -- 0x3d
 { "F$FreeHB",   0x00000002, 0x00000008 }, -- 0x3e
 { "F$AllTsk",   0x00000002, 0x00000008 }, -- 0x3f
 { "F$DelTsk",   0x00000002, 0x00000008 }, -- 0x40
 { "F$SetTsk",   0x00000002, 0x00000008 }, -- 0x41
 { "F$ResTsk",   0x00000002, 0x00000008 }, -- 0x42
 { "F$RelTsk",   0x00000002, 0x00000008 }, -- 0x43
 { "F$DATLog",   0x00000002, 0x00000008 }, -- 0x44
 { "F$DATTmp",   0x00000002, 0x00000008 }, -- 0x45
 { "F$LDAXY",    0x00000002, 0x00000008 }, -- 0x46
 { "F$LDAXYP",   0x00000002, 0x00000008 }, -- 0x47
 { "F$LDDDXY",   0x00000002, 0x00000008 }, -- 0x48
 { "F$LDABX",    0x00000002, 0x00000008 }, -- 0x49
 { "F$STABX",    0x00000002, 0x00000008 }, -- 0x4a
 { "F$AllPrc",   0x00000002, 0x00000008 }, -- 0x4b
 { "F$DelPrc",   0x00000002, 0x00000008 }, -- 0x4c
 { "F$ELink",    0x00000002, 0x00000008 }, -- 0x4d
 { "F$FModul",   0x00000002, 0x00000008 }, -- 0x4e
 { "F$MapBlk",   0x00000002, 0x00000008 }, -- 0x4f
 { "F$ClrBlk",   0x00000002, 0x00000008 }, -- 0x50
 { "F$DelRAM",   0x00000002, 0x00000008 }, -- 0x51
 { "F$SysDbg",   0x00000000, 0x00000000 }, -- 0x52
 { "F$Event",    0x400300ab, 0x00030003 }, -- 0x53
 { "F$Gregor",   0x0000000f, 0x0000000f }, -- 0x54
 { "F$SysID",    0x00000002, 0x00000008 }, -- 0x55
 { "F$Alarm",    0x000003fb, 0x00000003 }, -- 0x56
 { "F$Sigmask",  0x0000000f, 0x00000000 }, -- 0x57
 { "F$ChkMem",   0x00000002, 0x00000008 }, -- 0x58
 { "F$UAcct",    0x00000002, 0x00000008 }, -- 0x59
 { "F$CCtl",     0x00000003, 0x00000000 }, -- 0x5a
 { "F$GSPUMp",   0x00000002, 0x00000008 }, -- 0x5b
 { "F$SRqCMem",  0x0000000f, 0x00300003 }, -- 0x5c
 { "F$POSK",     0x00000002, 0x00000008 }, -- 0x5d
 { "F$Panic",    0x00000002, 0x00000008 }, -- 0x5e
 { "F$MBuf",     0x00000002, 0x00000008 }, -- 0x5f
 { "F$Trans",    0x00000002, 0x00000008 }  -- 0x60
}

local os9_icalls = {
 { "I$Attach",   0x00020001, 0x00300000 }, -- 0x80
 { "I$Detach",   0x00300000, 0x00000000 }, -- 0x81
 { "I$Dup",      0x00000002, 0x00000002 }, -- 0x82
 { "I$Create",   0x00020039, 0x00030002 }, -- 0x83
 { "I$Open",     0x00020001, 0x00030002 }, -- 0x84
 { "I$MakDir",   0x00020039, 0x00030000 }, -- 0x85
 { "I$ChgDir",   0x00020001, 0x00030000 }, -- 0x86
 { "I$Delete",   0x00020001, 0x00030000 }, -- 0x87
 { "I$Seek",     0x0000000e, 0x00000000 }, -- 0x88
 { "I$Read",     0x0003000e, 0x0000000c }, -- 0x89
 { "I$Write",    0x0003000e, 0x0000000c }, -- 0x8a
 { "I$ReadLn",   0x0003000e, 0x0000000c }, -- 0x8b
 { "I$WritLn",   0x0003000e, 0x0000000c }, -- 0x8c
 { "I$GetStt",   0x800300fa, 0x000300ff }, -- 0x8d
 { "I$SetStt",   0x800300fa, 0x000300ff }, -- 0x8e
 { "I$Close",    0x00000002, 0x00000000 }, -- 0x8f
 { "I$???_90",   0x00000002, 0x00000008 }, -- 0x90
 { "I$???_91",   0x00000002, 0x00000008 }, -- 0x91
 { "I$SGetSt",   0x800300fa, 0x000300ff }  -- 0x92
}

local os9_ss_opts = {
    "SS_Opt",
    "SS_Ready",
    "SS_Size",
    "SS_Reset",
    "SS_WTrk",
    "SS_Pos",
    "SS_EOF",
    "SS_Link",
    "SS_ULink",
    "SS_Feed",
    "SS_Frz",
    "SS_SPT",
    "SS_SQD",
    "SS_DCmd",
    "SS_DevNm",
    "SS_FD",
    "SS_Ticks",
    "SS_Lock",
    "SS_DStat",
    "SS_Joy",
    "SS_BlkRd",
    "SS_BlkWr",
    "SS_Reten",
    "SS_WFM",
    "SS_RFM",
    "SS_ELog",
    "SS_SSig",
    "SS_Relea",
    "SS_Attr",
    "SS_Break",
    "SS_RsBit",
    "SS_RMS",
    "SS_FDInf",
    "SS_ACRTC",
    "SS_IFC",
    "SS_OFC",
    "SS_EnRTS",
    "SS_DsRTS",
    "SS_DCOn",
    "SS_DCOff",
    "SS_Skip",
    "SS_Mode",
    "SS_Open",
    "SS_Close",
    "SS_Path",
    "SS_Play",
    "SS_HEADER",
    "SS_Raw",
    "SS_Seek",
    "SS_Abort",
    "SS_CDDA",
    "SS_Pause",
    "SS_Eject",
    "SS_Mount",
    "SS_Stop",
    "SS_Cont",
    "SS_Disable",
    "SS_Enable",
    "SS_ReadToc",
    "SS_SM",
    "SS_SD",
    "SS_SC",
    "SS_SEvent",
    "SS_Sound",
    "SS_DSize",
    "SS_Net",
    "SS_Rename",
    "SS_Free",
    "SS_VarSect",
    "SS_VolStore",
    "SS_MIDI",
    "SS_ISDN",
    "SS_PMOD",
    "SS_SPF",
    "SS_LUOPT",
    "SS_RTNFM",
}

local os9_event_opts = {
    "Ev_Link",
    "Ev_UnLnk",
    "Ev_Creat",
    "Ev_Delet",
    "Ev_Wait",
    "Ev_WaitR",
    "Ev_Read",
    "Ev_Info",
    "Ev_Signl",
    "Ev_Pulse",
    "Ev_Set",
    "Ev_SetR",
}

function is_print(c)
    return c >= 32 and c < 127
end

function addr_comment(cpu, mem, addr)
    local count = 0
    local s = ""

    while true do
        local c = mem:read_u8(addr + count)
        if not is_print(c) then
            if count == 0 then return "" end
            return " (" .. s .. ")"
        end
        s = s .. string.char(c)
        count = count + 1
    end
end

function print_reg(cpu, mem, regs, regnum, lenspec)
    local reg = string.format("%s%d", regs, regnum)
    local value = cpu.state[reg].value
    local spec = nil
    local val = nil
    local comm = ""

    if     lenspec == 1 then
        val = string.format("%02x", value & 0xff)
        spec = ".b"
    elseif lenspec == 2 then
        val = string.format("%04x", value & 0xffff)
        spec = ".w"
    elseif lenspec == 3 then
        val = string.format("%08x", value & 0xffffffff)
        spec = ".l"
    else
        return nil
    end

    if regs == "A" then
        comm = addr_comment(cpu, mem, value)
    end

    -- return string.format("%s%s: %s", reg, spec, val)
    return string.format("%s: %s%s", reg, val, comm)
end

function print_regs(sys, cpu, mem, regmask)
    local REGBITS = 0x3FFFFFFF
    local STATCALL = 0x80000000

    local stname = ""

    if (regmask & STATCALL) == STATCALL then
        local st = cpu.state["D1"].value
        local name = os9_ss_opts[st + 1]
        if name then stname = string.format("(%s) ", name) end
    end

    if sys == 0x53 then
        local ev = cpu.state["D1"].value
        local name = os9_event_opts[ev + 1]
        if name then stname = string.format("(%s) ", name) end
    end

    local mask = regmask & REGBITS

    local line = { }

    for i=0,7 do
        local r = print_reg(cpu, mem, "D", i, mask & 0x03)
        if r then table.insert(line, r) end
        mask = mask >> 2
    end

    for i=0,7 do
        local r = print_reg(cpu, mem, "A", i, mask & 0x03)
        if r then table.insert(line, r) end
        mask = mask >> 2
    end

    return stname .. table.concat(line, ", ")
end

function in_module(pc)
    local modules = module_dir()

    for i=1,#modules do
        local m = modules[i]
        if m.addr <= pc and pc < (m.addr + m.size) then
            return m
        end
    end

    return nil
end

function pc_name(pc)
    local GHIDRA_OFFSET = 0x00030000
    local module = in_module(pc)
    if module then
        return string.format("%s+%08x", module.name, pc - module.addr + GHIDRA_OFFSET)
    else
        return string.format("%08x", pc)
    end
end

-- The list of actions that will be run when a module is loaded in memory.
-- Each item is a key-value pair, with:
--   module: the name of the module
--   func: the function to run; it will be invoked with the absolute address of
--         the module
module_load_actions = {}

-- The set of modules loaded in memory at the last invocation of
-- run_module_load_actions().
last_loaded_modules = {}

function run_module_load_actions()
    if next(module_load_actions) == nil then 
        return 
    end
    
    local modules = module_dir()
    local loaded_modules = {}
    local loaded_modules_now = {}

    for i=1,#modules do
        local m = modules[i]
        loaded_modules[m.name] = m.addr
        if not last_loaded_modules[m.name] then
            print(string.format("Now loaded: %s@%08x", m.name, m.addr))
            loaded_modules_now[m.name] = m.addr
        end
    end

    last_loaded_modules = loaded_modules

    for j=1,#module_load_actions do
        local action = module_load_actions[j]
        for name, addr in pairs(loaded_modules_now) do
            if name == action.module then
                action.func(addr)
            end
        end
    end
end

function trap_0_callback(cpu, mem)
    local sp  = cpu.state['SP'].value
    local ret = mem:read_u32(sp + 2)
    local sys = mem:read_u16(ret)

    local info = nil

    if     sys >= os9_fcall_start and sys < os9_fcall_end then
       info = os9_fcalls[sys - os9_fcall_start + 1] 
    elseif sys >= os9_icall_start and sys < os9_icall_end then
       info = os9_icalls[sys - os9_icall_start + 1] 
    end
 
    local name   = info[1]
    local inreg  = info[2]
    local outreg = info[3]

    local label = pc_name(ret - 2)
    local regs = print_regs(sys, cpu, mem, inreg)

    print(string.format("OS9 syscall: %s  %-13s %s", label, name, regs))

    run_module_load_actions()
end

-- Adds a breakpoint at a given module and Ghidra address.
-- If the module is not found, it postpones the addition until an invocation of
-- F$Link for that module.
function os9_break(module_name, ghidra_address)
    local modules = module_dir()

    local bp_func = function(base_addr)
        local addr = base_addr + ghidra_address - 0x30000
        manager.machine.debugger:command(string.format("bpset %08x", addr))
        print(string.format("Breakpoint set at %s", pc_name(addr)))
    end

    for i=1,#modules do
        local m = modules[i]
        if m.name == module_name then
            bp_func(m.addr)
            return
        end    
    end    

    print("Module not found; will add breakpoint when loaded in memory")
    -- add action to run when module is loaded
    table.insert(module_load_actions, {
        module = module_name,
        func = bp_func
    })
end

-- returns PC, adjusted for Ghidra
function pc_ghidra()
    local cpu = get_cpu()
    local pc = cpu.state['PC'].value
    return pc - 0x30000
end

function trace_syscalls()
    manager.machine.debugger:command("bpset 52c,1,{ print w@(d@(a7 + 2)) }")
end

-- Given a memory address and a text, calls the debugger to set a breakpoint
-- that prints the text and resumes.
function trace_exec(addr, text)
    local command = string.format("bpset %08x,1,{ print \"%s\"; g }", addr, text)
    manager.machine.debugger:command(command)
end

function import_comments_from_ghidra(module, file_name)
    local file = io.open(file_name, "r");
    local lines = {}
    for line in file:lines() do
        table.insert(lines, line);
    end
    file:close()
    
    add_comments = function(module_addr)
        print("Adding comments for " .. module)
        for i=1,#lines do
            local line = lines[i]
            local match = line:find("^module:%x%x%x%x%x%x%x%x")
            if match then
                local ghidra_addr = tonumber(line:sub(match + 8, match + 15), 16)
                local addr = module_addr + ghidra_addr - 0x30000
                local comment = line:sub(33)
                local command = string.format('comadd %08x,"%s"', addr, comment)
                manager.machine.debugger:command(command)
            end
        end
    end
    
    table.insert(module_load_actions, {
        module = module,
        func = add_comments
    })
end

local consolelog = manager.machine.debugger.consolelog
local consolelast = 0

installed_callback = false

function periodic_cb()
    local last = consolelast
    local msg = consolelog[#consolelog]
    consolelast = #consolelog
    if #consolelog > last and msg:find("Stopped at", 1, true) then
        local point = tonumber(msg:match("Stopped at breakpoint ([0-9]+)"))
        if point then
            local cpu = get_cpu()
            local mem = get_mem()

            if cpu.state['PC'].value == 0x52c then
                trap_0_callback(cpu, mem)
                manager.machine.debugger:command("g")
            else
                print("Breakpoint is at " .. pc_name(cpu.state['PC'].value))
            end
        end
    end
end

if not installed_callback then
    emu.register_periodic(periodic_cb)
    installed_callback = true
end

