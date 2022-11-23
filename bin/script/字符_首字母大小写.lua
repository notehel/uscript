--- param 要转换小写的内容
--- param 要转换大写的内容

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

function dealContent(content, action)
	outContent = '';
	conArr = Split(content, '\n');
	for k,v in pairs(conArr) do
		aline = v;
		if (action == 'low') then
			aline = lowOne(aline);
		elseif (action == 'up') then
			aline = upOne(aline);
		end
		outContent = outContent .. '\r\n' .. aline;
	end

	return outContent;
end

function trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end

function lowOne(s)
    s = trim(s)
    return string.lower(string.sub(s, 1,1)) .. string.sub(s, 2)
end

function upOne(s)
    s = trim(s)
    return string.upper(string.sub(s, 1,1)) .. string.sub(s, 2)
end

APP_clearOutput();

content1 = APP_getContent('param1', '');
content2 = APP_getContent('param2', '');

APP_showContent('', dealContent(content1, 'low'));

APP_showContent('', dealContent(content2, 'up'));