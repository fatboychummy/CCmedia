--[[FATFILE
1

]]

local funcs

local function betterFind(toFind, dir)
  dir = dir or ""
  local found = {}
  local ls = fs.list(dir)
  for i = 1, #ls do
    print("Checking: " .. dir .. "/" .. ls[i])
    if ls[i] == toFind then
      found[#found + 1] = dir .. "/" .. ls[i]
    elseif fs.isDir(dir .."/" .. ls[i]) then
      local f2 = betterFind(toFind, dir .. "/" .. ls[i])
      for i = 1, #f2 do
        found[#found + 1] = f2[i]
      end
    end
  end
  return found
end


-- gets all files marked by the special --[[FATFILE]] header
local function getFATS()
  -- gets all files that are not directories.
  local function getNonDirs(dir)
    local found = {}
    local ls = fs.list(dir)
    for i = 1,#ls do
      if not fs.isDir(dir .. "/" .. ls[i]) then
        found[#found + 1] = dir .. "/" .. ls[i]
      end
    end
    return found
  end

  -- reads through a file to see if it contains a FATFILE header
  local function checkFiles(tab)
    local fats = {}
    for i = 1, #tab do
      print("Checking: " .. tab[i])
      local h = fs.open(tab[i],"r")
      if h then
        local ln = h.readLine()
        print("DEBUG: Contents of 'ln': \"" .. tostring(ln) .. "\""
          .. "\n(We are searching for \"--[[FATFILE\")")
        repeat
          if ln and type(ln) == "string" then -- if the file is empty, it will error without this.
            if ln:find("--[[FATFILE") then
              fats[#fats + 1] = tab[i]
              break
            end
          end
        until not ln
        h.close()
      else
        printError("Failed to open file: " .. tostring(tab[i]))
      end
    end
    return fats
  end

  local exclude = {
    "/rom/"
  }
  local found = {}

  return checkFiles(getNonDirs(""))
end

funcs = {
  betterFind = betterFind,
  getFATS = getFATS
}

return funcs
