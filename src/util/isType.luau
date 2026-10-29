local Type = require(script.Parent.Parent.Type)

return function(v: any): boolean
	return typeof(v) == "table" and getmetatable(v) == Type
end
