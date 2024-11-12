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
preamble = preamble:gsub("\\setcounter{tutweek}{1}",argv[2])
properties["preamble"] = preamble

ndoc:setProperties(properties)

for i,p in inputDoc:pages() do
    local newpage = p:clone()
    ndoc:insert(i,newpage)
  end




local prefix = "pagenumbers"
local format_layer = prefix .. "_format"
local pagenr_layer = prefix .. "_page"
local dont_count_layer = prefix .. "_dont_count"

local page_wildcard = "%[page%]" -- ignore the %



----------------------------------------------------------------------
-- refresh the page numbers ------------------------------------------

function refresh_pagenumbers(doc)
    -- first find the pagenumber objects that should be printed on
    -- every page
    local pagenr_objects = find_pagenr_objects(doc)
 
    -- if something was found, print the page numbers on every page
    if #pagenr_objects > 0 then
       print_on_every_page(doc, pagenr_objects)
    end
 end
 
 ----------------------------------------------------------------------
 -- find pagenumber objects -------------------------------------------
 
 function find_pagenr_objects(doc)
    res = {}
    p1 = doc[1]
    for i, obj, sel, layer in p1:objects() do
       -- find layer called format_layer
       if layer == format_layer then
      if obj:type() == "text" then
         res[#res+1] = obj
      end
       end
    end
    
    return res
 end
 
 ----------------------------------------------------------------------
 -- print given pagenumber objects on every page ----------------------
 
 function print_on_every_page(doc, pagenr_objects)

    local clones = {}
    for i = 1, #doc do
       local clone_objs = {}
       for j, obj in ipairs(pagenr_objects) do
      clone_objs[j] = obj:clone()
       end
       clones[i] = clone_objs
    end
    
    -- then add the clones
    local pagenr = 0
    for i = 1, #doc do
       local p = doc[i]
       
       -- increase the pagenr, if the current page does not contain the
       -- dont_count layer
       if not page_has_layer(p, dont_count_layer) then
      pagenr = pagenr + 1
       end
 
       -- if the layer does not exists, create it
       -- print "create layer"
       if not page_has_layer(p, pagenr_layer) then
      p:addLayer(pagenr_layer)
      make_layer_visible(p, pagenr_layer)
       end
       
       -- lock the layer
       p:setLocked(pagenr_layer, true)
 
       -- remove all objects from the layer
       clear_layer(p, pagenr_layer)
 
       -- add the pagenumbers to the layer
       -- print "add pagenumbers"
       for j = 1, #pagenr_objects do
      -- print (i, j, clones[i][j])
      -- print(string.gsub(clones[i][j]:text(), page_wildcard, pagenr))
      local repl_text = clones[i][j]:text():gsub(page_wildcard, pagenr)
      clones[i][j]:setText(repl_text)
      p:insert(nil, clones[i][j], nil, pagenr_layer)
       end
    end
 end
 
 ----------------------------------------------------------------------
 -- some helper function ----------------------------------------------
 
 -- make a layer visible on all vies of a page
 function make_layer_visible(p, layer)
    for i = 1, p:countViews() do
       p:setVisible(i, layer, true)
    end
 end
 
 -- remove all objects in a given layer
 function clear_layer(p, layer)
    local i = 1
    while i <= #p do
       if p:layerOf(i) == layer then
      p:remove(i)
       else
      i = i + 1
       end
    end
 end
 
 -- returns true if and only if the page p contains the given layer
 function page_has_layer(p, layer)
    for _, layer_ in ipairs(p:layers()) do
       if layer == layer_ then
      return true
       end
    end
    return false
 end
 


refresh_pagenumbers(ndoc)
ndoc:save(outname)
