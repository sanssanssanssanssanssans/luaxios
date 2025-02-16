local HttpService = game:GetService("HttpService")

local Axios = {}
Axios.__index = Axios

function Axios.new(config)
	local self = setmetatable({}, Axios)
	self.baseURL = config.baseURL or ""
	self.headers = config.headers or {}
	self.timeout = config.timeout or 10
	self.retryCount = config.retryCount or 3  
	self.retryDelay = config.retryDelay or 1 
	return self
end

function Axios:request(config, callback)
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
				callback({ status = 0, error = "HTTP 요청 실패 (재시도 초과)" })
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
			local parseSuccess, parsedData = pcall(function()
				return HttpService:JSONDecode(response.Body)
			end)
			responseData = parseSuccess and parsedData or response.Body
		end

		self:handleResponse(response, responseData, callback)
	end

	task.spawn(function()
		task.wait(timeout)
		if not requestFinished then
			callback({ status = 0, error = "HTTP 요청 시간 초과 (timeout " .. timeout .. "s)" })
		end
	end)

	tryRequest()
end


function Axios:handleResponse(response, responseData, callback)
	if response.StatusCode < 200 or response.StatusCode >= 300 then
		callback({
			status = response.StatusCode,
			error = "Request failed with status: " .. response.StatusCode,
			data = responseData,
		})
		return
	end

	callback({
		status = response.StatusCode,
		headers = response.Headers,
		data = responseData,
	})
end

function Axios:get(url, config, callback)
	config = config or {}
	config.method = "GET"
	config.url = url
	self:request(config, callback)
end

function Axios:post(url, data, config, callback)
	config = config or {}
	config.method = "POST"
	config.url = url
	config.data = data
	self:request(config, callback)
end

function Axios:patch(url, data, config, callback)
	config = config or {}
	config.method = "PATCH"
	config.url = url
	config.data = data
	self:request(config, callback)
end

function Axios:put(url, data, config, callback)
	config = config or {}
	config.method = "PUT"
	config.url = url
	config.data = data
	self:request(config, callback)
end

function Axios:delete(url, config, callback)
	config = config or {}
	config.method = "DELETE"
	config.url = url
	self:request(config, callback)
end

return Axios
