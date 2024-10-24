#!/usr/bin/env ipescript
-- -*- lua -*-
----------------------------------------------------------------------
-- Merge a series of ipe documents into a single document
----------------------------------------------------------------------
--
-- Running this script as "ipescript merge <file 1> ... <file n> <output>" will
-- create <output> as an ipe document that contains all the pages of <file 1> ... <file n>
-- The stylesheets and other properties of the first file are used.
--
----------------------------------------------------------------------

if #argv < 3 then
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
ndoc:setProperties(properties)



for i = 1, #argv - 1 do
    -- print(i, value)
    local file = assert(ipe.Document(argv[i]))
    for pno = 1, #file do
        local newpage = file[pno]:clone()
        ndoc:append(newpage)
    end
end


-- print(type(properties["preamble"]))
ndoc:save(outname)
