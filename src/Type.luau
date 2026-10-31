local Type = {}
Type.__index = Type

type TypeBase<T> = {
	kind: string,
	matcher: (any) -> (boolean, string?),
	_: T,
}

export type Type<T> = typeof(setmetatable({} :: TypeBase<T>, Type))

function Type.new<T>(kind: string, matcher: (any) -> (boolean, string?)): Type<T>
	local self = setmetatable({}, Type) :: Type<T>
	self.kind = kind
	self.matcher = matcher
	self._ = self :: any
	return self
end

function Type.isType(v: any): boolean
	return typeof(v) == "table" and getmetatable(v) == Type
end

function Type.__call<T>(self: Type<T>, v: any): (boolean, string?)
	return self:matches(v)
end

function Type.matches<T>(self: Type<T>, v: any): (boolean, string?)
	return self.matcher(v)
end

function Type.assert<T>(self: Type<T>, v: any): T
	local ok, err = self:matches(v)
	if not ok then
		error(err or "Unknown type")
	end

	return v
end

return Type
