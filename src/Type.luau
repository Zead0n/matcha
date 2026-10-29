export type TypeBase = {
	kind: string,
	matcher: (...any) -> (boolean, string?),
	_internalKind: string?,
}

local Type = {}

Type.__index = Type

Type.__call = function(self: Type, ...)
	return self:matches(...)
end

Type.__tostring = function(self: Type)
	return self.kind
end

export type Type = typeof(setmetatable({} :: TypeBase, Type))

Type.className = "BlackTea"

function Type.matches(self: Type, ...: any): (boolean, string?)
	return self.matcher(...)
end

function Type.assert<T...>(self: Type, ...): T...
	local ok, reason = self:matches(...)
	if not ok then
		error(reason or "Unknown match", 2)
	end

	return ...
end

return Type
