local Promise = {}
Promise.__index = Promise

function Promise.new(executor)
	local self = setmetatable({}, Promise)
	self.status = "pending"
	self.value = nil
	self.reason = nil
	self.successCallbacks = {}
	self.failureCallbacks = {}

	local function resolve(value)
		if self.status == "pending" then
			self.status = "fulfilled"
			self.value = value
			for _, callback in ipairs(self.successCallbacks) do
				callback(value)
			end
		end
	end

	local function reject(reason)
		if self.status == "pending" then
			self.status = "rejected"
			self.reason = reason
			for _, callback in ipairs(self.failureCallbacks) do
				callback(reason)
			end
		end
	end

	task.spawn(function()
		local success, err = pcall(executor, resolve, reject)
		if not success then
			reject(err)
		end
	end)

	return self
end

function Promise:Then(onFulfilled, onRejected)
	local nextPromise = Promise.new(function(resolve, reject)
		local function handleSuccess(value)
			if type(onFulfilled) == "function" then
				local success, result = pcall(onFulfilled, value)
				if success then
					resolve(result)
				else
					reject(result)
				end
			else
				resolve(value)
			end
		end

		local function handleFailure(reason)
			if type(onRejected) == "function" then
				local success, result = pcall(onRejected, reason)
				if success then
					resolve(result)
				else
					reject(result)
				end
			else
				reject(reason)
			end
		end

		if self.status == "fulfilled" then
			task.spawn(handleSuccess, self.value)
		elseif self.status == "rejected" then
			task.spawn(handleFailure, self.reason)
		else
			table.insert(self.successCallbacks, handleSuccess)
			table.insert(self.failureCallbacks, handleFailure)
		end
	end)
	return nextPromise
end

function Promise:Catch(onRejected)
	return self:Then(nil, onRejected)
end

function Promise:Finally(onFinally)
	return self:Then(
		function(value)
			if onFinally then onFinally() end
			return value
		end,
		function(reason)
			if onFinally then onFinally() end
			error(reason)
		end
	)
end

return Promise
