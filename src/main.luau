local HttpService = game:GetService("HttpService")
local Promise = require(script.Promise)
local XMLParser = require(script.XMLParser)  
local Axios = {}
Axios.__index = Axios

function Axios.new(config)
	local self = setmetatable({}, Axios)
	self.baseURL = config.baseURL or ""
	self.headers = config.headers or {}
	self.timeout = config.timeout or 10
	self.retryCount = config.retryCount or 3  
	self.retryDelay = config.retryDelay or 1 
	self.debug = config.debug or false 
	return self
end

function Axios:request(config)
	return Promise.new(function(resolve, reject)
		local method = config.method or "GET"
		local url = self.baseURL .. (config.url or "")
		local headers = config.headers or self.headers
		local data = config.data and HttpService:JSONEncode(config.data) or nil
		local timeout = self.timeout  

		local requestOptions = {
			Url = url,
			Method = method,
			Headers = headers,
			Body = data,
		}

		local attempts = 0
		local requestFinished = false  

		local function tryRequest()
			if attempts >= self.retryCount then
				if not requestFinished then
					reject({ status = 0, error = "Http request failed. (Retry count Failed.)" })
				end
				return
			end

			attempts = attempts + 1
			requestFinished = false

			local response
			local success, err = pcall(function()
				response = HttpService:RequestAsync(requestOptions)
			end)

			if not success then
				task.wait(self.retryDelay)
				tryRequest()
				return
			end

			requestFinished = true

			local responseData
			if response.Body then
				local parsedData
				if response.Headers["Content-Type"] and response.Headers["Content-Type"]:match("xml") then
					parsedData = XMLParser.parseXML(response.Body)
				else
					local parseSuccess, parsed = pcall(function()
						return HttpService:JSONDecode(response.Body)
					end)
					if parseSuccess then
						parsedData = parsed
					else
						parsedData = response.Body
					end
				end

				if response.StatusCode < 200 or response.StatusCode >= 300 then
					reject({
						status = response.StatusCode,
						error = "Request failed with status: " .. response.StatusCode,
						data = parsedData,
					})
					return
				end

				resolve({
					status = response.StatusCode,
					headers = response.Headers,
					data = parsedData,
				})
			else
				reject({ status = 0, error = "Empty response body" })
			end
		end

		task.spawn(function()
			task.wait(timeout)
			if not requestFinished then
				reject({ status = 0, error = "Http request time outted. (timeout " .. timeout .. "s)" })
			end
		end)

		tryRequest()
	end)
end

function Axios:get(url, config)
	config = config or {}
	config.method = "GET"
	config.url = url
	return self:request(config)
end

function Axios:post(url, data, config)
	config = config or {}
	config.method = "POST"
	config.url = url
	config.data = data
	return self:request(config)
end

function Axios:put(url, data, config)
	config = config or {}
	config.method = "PUT"
	config.url = url
	config.data = data
	return self:request(config)
end

function Axios:delete(url, config)
	config = config or {}
	config.method = "DELETE"
	config.url = url
	return self:request(config)
end

function Axios:setTimeout(newTimeout)
	self.timeout = newTimeout
end

function Axios:setHeaders(newHeaders)
	self.headers = newHeaders
end

function Axios:addHeader(key, value)
	self.headers[key] = value
end

function Axios:clearHeaders()
	self.headers = {}
end

function Axios:setBaseURL(baseURL)
	self.baseURL = baseURL
end

function Axios:setRetryConfig(retryCount, retryDelay)
	self.retryCount = retryCount or self.retryCount
	self.retryDelay = retryDelay or self.retryDelay
end

function Axios:getCookies(response)
	local cookies = {}
	if response.Headers["Set-Cookie"] then
		for cookie in response.Headers["Set-Cookie"]:gmatch("([^;]+)") do
			table.insert(cookies, cookie)
		end
	end
	return cookies
end

return Axios
