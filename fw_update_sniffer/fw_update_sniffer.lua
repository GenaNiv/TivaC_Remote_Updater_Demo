-- Create a new protocol dissector
bootloader_proto = Proto("fw_update", "Firmware Update Protocol")

-- Define protocol fields
local f_size = ProtoField.uint8("bootloader.size", "Size", base.HEX)
local f_checksum = ProtoField.uint8("bootloader.checksum", "Checksum", base.HEX)
local f_command = ProtoField.uint8("bootloader.command", "Command", base.HEX)
local f_command_name = ProtoField.string("bootloader.command_name", "Command Name")
local f_address = ProtoField.uint32("bootloader.address", "Program Address", base.HEX)
local f_program_size = ProtoField.uint32("bootloader.program_size", "Program Size", base.DEC)
local f_fw_data = ProtoField.bytes("bootloader.fw_data", "Firmware Data")

-- Register fields
bootloader_proto.fields = { f_size, f_checksum, f_command, f_command_name, f_address, f_program_size, f_fw_data }

function bootloader_proto.dissector(buffer, pinfo, tree)
    local length = buffer:len()
    
		-- Ignore 0x00 single-byte frames
	if length == 1 and buffer(0,1):uint() == 0x00 then
		pinfo.cols.info = "Ignored 0x00 Frame"
		print("Ignoring 0x00 Frame at", pinfo.number)  -- Debugging output
		return  -- Skip processing
	end

    -- 🔹 **Handle single-byte ACK and NAK responses**  
    if length == 1 then
        local response = buffer(0,1):uint()
        local response_str = "Unknown Response"

        if response == 0xCC then
            response_str = "ACK (Success)"
        elseif response == 0x33 then
            response_str = "NAK (Error)"
        end

        -- Set protocol and Wireshark info column
        pinfo.cols.protocol = "Bootloader"
        pinfo.cols.info = "Bootloader Response: " .. response_str

        -- Create response subtree
        local subtree = tree:add(bootloader_proto, buffer(), "Bootloader Response")
        subtree:add(f_command_name, response_str)

        return  -- Stop further processing
    end

    -- 🔹 **Ensure packet is large enough for valid Bootloader packets**
    if length < 3 then return end  

    -- 🔹 **Extract first three bytes**
    local size = buffer(0,1):uint()
    local checksum = buffer(1,1):uint()
    local command = buffer(2,1):uint()

    -- **Ensure we do not exceed packet size**
    if size > length then
        pinfo.cols.info = "Bootloader: Packet too short!"
        return
    end

    -- **Set protocol and add base tree node**
    pinfo.cols.protocol = "Bootloader"
    local subtree = tree:add(bootloader_proto, buffer(), "Bootloader Packet")
    subtree:add(f_size, buffer(0,1))
    subtree:add(f_checksum, buffer(1,1))
    subtree:add(f_command, buffer(2,1))


	-- **Ensure Bootloader Packet is within the captured frame**
	local actual_size = math.min(size, length)

	-- ✅ **Append Bootloader Packet Size in the Info Column**
	pinfo.cols.info:append(" [Bootloader Size: " .. actual_size .. "]")

    -- 🔹 **Identify command type**
    local command_str = "Unknown"
    if command == 0x20 then
        command_str = "PING"
    elseif command == 0x21 then
        command_str = "DOWNLOAD"
    elseif command == 0x22 then
        command_str = "RUN"
    elseif command == 0x23 then
        command_str = "GET_STATUS"
    elseif command == 0x24 then
        command_str = "FW_TRANSFER"
    elseif command == 0x25 then
        command_str = "RESET"
    end
    subtree:add(f_command_name, command_str)
    pinfo.cols.info = "Bootloader Command: " .. command_str

    -- 🔹 **Handle FW_TRANSFER Command (0x24)**
    if command == 0x24 then
        if size > 3 and (size <= length) then
            local data_length = size - 3  -- Data size excluding header
            local data_subtree = subtree:add(f_fw_data, buffer(3, data_length))

            -- Convert data to hex and append info
            local hex_data = buffer(3, data_length):bytes():tohex()
            data_subtree:set_text("Firmware Data (" .. data_length .. " bytes): " .. hex_data)
        else
            pinfo.cols.info = "Bootloader Command: FW_TRANSFER [Invalid Packet]"
        end
    end

    -- 🔹 **Handle Type-2 Response Packets (GET_STATUS Response)**
    if size == 0x03 and command >= 0x40 and command <= 0x45 then
        local response_str = "Unknown Status"
        if command == 0x40 then
            response_str = "COMMAND_RET_SUCCESS"
        elseif command == 0x41 then
            response_str = "COMMAND_RET_UNKNOWN_CMD"
        elseif command == 0x42 then
            response_str = "COMMAND_RET_INVALID_CMD"
        elseif command == 0x43 then
            response_str = "COMMAND_RET_INVALID_ADR"
        elseif command == 0x44 then
            response_str = "COMMAND_RET_FLASH_FAIL"
        elseif command == 0x45 then
            response_str = "COMMAND_RET_CRC_FAIL"
        end

        pinfo.cols.info = "Bootloader Status Response: " .. response_str
        subtree:add(f_command_name, response_str)
    end
end

-- Attach dissector to USB Bulk Transfers
usb_table = DissectorTable.get("usb.bulk")
usb_table:add(0xffff, bootloader_proto)
