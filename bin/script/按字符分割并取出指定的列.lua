--- param ÄÚÈÝ
function Split(s, sp)
    local res = {}  
  
    local temp = s  
    local len = 0  
    while true do  
        len = string.find(temp, sp)  
        if len ~= nil then  
            local result = string.sub(temp, 1, len-1)  
            temp = string.sub(temp, len+1)  
            table.insert(res, result)  
        else  
            table.insert(res, temp)  
            break  
        end  
    end  
  
    return res  
end

function trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end

function upOne(s)
    s = trim(s)
    return string.upper(string.sub(s, 1,1)) .. string.sub(s, 2)
end

APP_clearOutput();

content = APP_getContent('param1', '');

local conArr = Split(content, '\n');

local outText = ''

for k,v in pairs(conArr) do
	aline = trim(v);
	sline = ''
    if (aline ~= '') then
		alineArr = Split(aline, ':')
		for sk,sv in pairs(alineArr) do
			if sk == 1 then
				sline = string.gsub(sv,'"','');
			end
		end
	end
	
	outText = outText .. sline .. '\r\n';
end

APP_showContent('', outText);