local XMLParser = {}

local function trim(str)
	return str:match("^%s*(.-)%s*$")
end

function XMLParser.parseXML(xml)
	xml = trim(xml)

	local parsedData = {}

	local function parseTag(tag, content)
		content = trim(content)
		if content and content ~= "" then
			parsedData[tag] = content
		else
			parsedData[tag] = {}
		end
	end

	local function processTag(tag, xmlStr)
		local result = {}
		local pattern = "<(.-)>(.-)</%1>"

		for innerTag, innerContent in xmlStr:gmatch(pattern) do
			local tagName = trim(innerTag)
			local tagContent = trim(innerContent)
			if result[tagName] then
				table.insert(result[tagName], tagContent)
			else
				result[tagName] = {tagContent}
			end
		end
		return result
	end

	while xml:match("<(.-)>") do
		local tag, content = xml:match("<(.-)>(.-)</%1>")

		if tag then
			local tagName = trim(tag)
			local tagContent = trim(content)

			parsedData[tagName] = processTag(tagName, content)
			xml = xml:gsub("<" .. tag .. ">" .. content .. "</" .. tag .. ">", "", 1)
		end
	end

	return parsedData
end

return XMLParser
