return function(v: any): string
	local vType = typeof(v)
	if vType == "string" then
		v = string.format("%q", v)
	end
	return `{v} ({vType})`
end
