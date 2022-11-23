--- param Ҫ����������

function trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end

function print(content)
    showContent('', content);
end

-- ֧������
local function strlength(str)
    -- �����ַ������ȣ���Ӣ�Ļ��
    str = string.gsub(str, "%%", " ") -- ��%�滻��" "
    local str = string.gsub(str, "[\128-\191]","")
    local _,ChCount = string.gsub(str, "[\192-\255]","")
    local _,EnCount = string.gsub(str, "[^\128-\255]","")
    return ChCount + EnCount
end

-- @function: ��ӡtable�����ݣ��ݹ�
-- @param: tbl Ҫ��ӡ��table
-- @param: level �ݹ�Ĳ�����Ĭ�ϲ��ô�ֵ����
-- @param: filteDefault �Ƿ���˴�ӡ���캯����Ĭ��Ϊ��
-- @return: return
function PrintTable( tbl , level, filteDefault)
  local msg = ""
  filteDefault = filteDefault or true --Ĭ�Ϲ��˹ؼ��֣�DeleteMe, _class_type��
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

-- �鿴ĳֵ�Ƿ�Ϊ��tbl�е�keyֵ
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

-- �鿴ĳֵ�Ƿ�Ϊ��tbl�е�valueֵ
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

-- table ȥ��
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