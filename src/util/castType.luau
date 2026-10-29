local Type = require(script.Parent.Parent.Type)

return function(...): Type.Type
	return ... :: any
end
