--- param 字符长度
--- param 取值范围
--- param 个数

function rannum(len)
	local str = '';
	math.randomseed(tostring(os.time()):reverse():sub(1, 6));
	math.randomseed(os.clock()*10000);
	for N=1,len do
		str = str .. math.random(100,999);
	end
	return str ;
end

function ranstr(len, srcStr)
	if srcStr == "" then
		srcStr = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
	end

	local str = '';
	math.randomseed(tostring(os.time()):reverse():sub(1, 6));
	math.randomseed(os.clock()*10000);

	aID = math.random(100,999)
	
	-- math.randomseed(os.clock()*10000*aID);
	
	-- 总长度
	slen = #srcStr

	for N=1,len do
		spos = math.random(1,slen);
		str = str .. string.sub(srcStr, spos, spos);
	end

	return str;
end

--数组去重函数
function removeRepeat(a)
    local b = {}
    for k,v in ipairs(a) do
        if(#b == 0) then
            b[1]=v;
        else
            local index = 0
            for i=1,#b do
                if(v == b[i]) then
                    break

                end
                index = index + 1
            end
            if(index == #b) then
                b[#b + 1] = v;
            end
        end
    end
    return b
end

function isExist(key, t)
    for _,v in ipairs(t) do
        if v == key then
		return true
	end
    end
    return false
end


APP_clearOutput();

list = {};

count = tonumber(APP_getContent('param1', ''));
source = APP_getContent('param2', '');
len = tonumber(APP_getContent('param3', ''));

while (#list< len) -- 个数
do
	oneStr = ranstr(count, source); -- 长度
	if isExist(oneStr, list) == false then
		table.insert(list, oneStr)
	end
	
end

for _,v in ipairs(list) do
	APP_showContent('', v);
end
