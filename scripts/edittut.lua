#!/usr/bin/env ipescript
-- -*- lua -*-
----------------------------------------------------------------------
-- Append to the preamble of an ipe document
----------------------------------------------------------------------
--
-- Running this script as "ipescript edittut <input> <line 1> ... <line n> <output>" will
-- create <output> as copy of <input> with the lines <line 1> ... <line n> appended to the preamble.
--
----------------------------------------------------------------------

if #argv < 2 then
    io.stderr:write("Usage: ipescript merge <file 1> ... <file n> <output>\n")
    return
end
local inname = argv[1]
local outname = argv[#argv]

local inputDoc = assert(ipe.Document(inname))
local ndoc = ipe.Document()

ndoc:remove(1)
local inputSheets = inputDoc:sheets()
ndoc:replaceSheets(inputSheets:clone())


local properties = inputDoc:properties()

local preamble = properties["preamble"] 
for i = 2, #argv - 1 do
    preamble = preamble .. "\n" .. argv[i]
end

properties["preamble"] = preamble

ndoc:setProperties(properties)

for i,p in inputDoc:pages() do
    local newpage = p:clone()
    ndoc:insert(i,newpage)
  end

ndoc:save(outname)
