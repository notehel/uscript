--- param 要分析的内容

function trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end

function print(content)
    showContent('', content);
end

-- 支持中文
local function strlength(str)
    -- 计算字符串长度，中英文混合
    str = string.gsub(str, "%%", " ") -- 将%替换成" "
    local str = string.gsub(str, "[\128-\191]","")
    local _,ChCount = string.gsub(str, "[\192-\255]","")
    local _,EnCount = string.gsub(str, "[^\128-\255]","")
    return ChCount + EnCount
end

-- @function: 打印table的内容，递归
-- @param: tbl 要打印的table
-- @param: level 递归的层数，默认不用传值进来
-- @param: filteDefault 是否过滤打印构造函数，默认为是
-- @return: return
function PrintTable( tbl , level, filteDefault)
  local msg = ""
  filteDefault = filteDefault or true --默认过滤关键字（DeleteMe, _class_type）
  level = level or 1
  local indent_str = ""
  for i = 1, level do
    indent_str = indent_str.."  "
  end

  print(indent_str .. "{")
  for k,v in pairs(tbl) do
    if filteDefault then
      if k ~= "_class_type" and k ~= "DeleteMe" then
        local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
        print(item_str)
        if type(v) == "table" then
          PrintTable(v, level + 1)
        end
      end
    else
      local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
      print(item_str)
      if type(v) == "table" then
        PrintTable(v, level + 1)
      end
    end
  end
  print(indent_str .. "}")
end

function Split(s, sp)
    local res = {};

    local temp = s;
    local len = 0;

    while true do
        len = string.find(temp, sp);
        if len ~= nil then
            local result = string.sub(temp, 1, len-1);
            temp = string.sub(temp, len+1);
            table.insert(res, result);
        else
            table.insert(res, temp);
            break;
        end
    end

    return res;
end

-- 查看某值是否为表tbl中的key值
function table.kIn(tbl, key)
    if tbl == nil then
        return false
    end
    for k, v in pairs(tbl) do
        if k == key then
            return true
        end
    end
    return false
end

-- 查看某值是否为表tbl中的value值
function table.vIn(tbl, value)
    if tbl == nil then
        return false
    end

    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- table 去重
function removeRepeated(t)
    local check = {};
    for key, value in pairs(t) do
        if table.vIn(check, value) == false then
            table.insert(check, value);
        end
    end
    return check;
end

APP_clearOutput();

content = APP_getContent('param1', '');

local conArr = Split(content, '\n');

local newStr = '';

local names = {};

for k,v in pairs(conArr) do
	line = trim(v)
    if (line ~= '') then
		table.insert(names, line);
    end
end

names = removeRepeated(names)

for k,v in pairs(names) do
	line = trim(v)
	newStr = newStr .. line .. '\r\n';
end

APP_showContent('', trim(newStr));