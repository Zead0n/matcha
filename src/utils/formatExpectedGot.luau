local toQuote = require(script.Parent.toQuote)

return function(expectedType: string, v: any)
	return `expected {expectedType}, got {toQuote(v)}`
end
