local Raw = require(script.Parent.Raw)
local Type = require(script.Parent.Type)
local castType = require(script.Parent.util.castType)
local isType = require(script.Parent.util.isType)

local Structure = {}

local function tupleCast<T...>(...): T...
	return ...
end

local function evaluateTuple(...): ({ Type.Type }?, boolean?, string?)
	local hasVarg = false
	local types = table.pack(...)

	for index, argType: Type.Type in types do
		if not isType(argType) then
			return nil, nil, `argument #{index} is not a BlackTeaType.`
		end

		if argType._internalKind == "tuple" then
			return nil, nil, "cannot have a tuple within a tuple"
		end

		if argType._internalKind == "vararg" then
			if index == #types then
				hasVarg = true
			else
				return nil, nil, "vararg type can only be at the end of a tuple"
			end
		end
	end

	return types, hasVarg
end

local function tupleMatcher(types: { Type.Type }, hasVarg: boolean)
	return function(...): (boolean, string?)
		local args = { ... }

		if #args > #types and not hasVarg then
			return false, "tuple exceeds limit"
		end

		for idx, argType in types do
			local elem = args[math.min(idx, #types)]

			local ok, err = (argType :: Type.Type):matches(elem)
			if not ok then
				return false, `argument #{idx}: {err or "Unknown match"}`
			end
		end

		return true
	end
end

function Structure.tuple<T...>(...: T...): T...
	local types, hasVararg, checkErr = evaluateTuple(...)
	if not types or hasVararg == nil then
		error(checkErr or "Unknown error while checking tuple")
	end

	local self: Type.TypeBase = {
		kind = `({table.concat(types, ", ")})`,
		_internalKind = "tuple",
		matcher = tupleMatcher(types, hasVararg),
	}

	return tupleCast(setmetatable(self :: any, Type))
end

function Structure.vararg<T>(type: T): ...T
	local castedType = castType(type)
	if castedType._internalKind == "tuple" then
		error("Cannot have a tuple within a vararg")
	end

	local castedTypeKind = tostring(castedType)

	local self: Type.TypeBase = {
		kind = `...{castedTypeKind}`,
		_internalKind = "vararg",
		matcher = function(...: any)
			if castedType.kind == "any" or castedType.kind == "unknown" then
				return true
			end

			local errs: { string } = {}

			local inputs = table.pack(...)
			for idx = 1, inputs.n do
				local value = inputs[idx]
				local argOk, argErr = castedType:matches(value)
				if not argOk then
					table.insert(errs, `argument #{idx} {argErr or "Unknown match"}`)
				end
			end

			if #errs > 0 then
				return false, `vararg is invalid:\n{table.concat(errs, "\n")}`
			end

			return true
		end,
	}

	return setmetatable(self :: any, Type)
end

function Structure.literal<T>(literalValue: T): T
	local kind = if typeof(literalValue) == "string" then string.format("%q", literalValue) else tostring(literalValue)

	local self: Type.TypeBase = {
		kind = kind,
		matcher = function(v: any, ...: any)
			if v == literalValue then
				return true
			end

			return false, `expected literal '{kind}', got '{typeof(v)}'`
		end,
	}

	return setmetatable(self, Type) :: any
end

function Structure.dictionary<K, V>(keyType: K, valueType: V): { [K]: V }
	assert(isType(keyType), "keyType (argument #1), is not a BlackTeaType")
	assert(isType(keyType), "valueType (argument #2), is not a BlakTeaType")

	local self: Type.TypeBase = {
		kind = `\{}`,
		_internalKind = "dictionary",
		matcher = function(dict: any, ...: any)
			local ok: boolean, result: string? = (Raw.table :: any):matches(dict)
			if not ok then
				return false, result
			end

			for key, value in dict do
				local keyOk: boolean = (keyType :: any):matches(key)
				if not keyOk then
					return false, `key type '{tostring(keyType)}' expected, got {typeof(key)} instead.`
				end

				local valueOk: boolean = (valueType :: any):matches(value)
				if not valueOk then
					return false, `value type '{tostring(valueType)}' expected, got {typeof(value)} instead.`
				end
			end

			return true
		end,
	}

	return setmetatable(self :: any, Type)
end

function Structure.array<T>(valueType: T): { T }
	assert(isType(valueType), "valueType (argument #1), is not a BlakTeaType")
	return Structure.dictionary(Raw.number, valueType)
end

function Structure.optional<T>(valueType: T): T?
	assert(isType(valueType), "valueType (argument #1), is not a ZtType")

	local self: Type.TypeBase = {
		kind = `{tostring(valueType)}?`,
		_internalKind = "optional",
		matcher = function(value: any, ...: any)
			if value == nil then
				return true
			end

			local ok: boolean = (valueType :: any):matches(value)
			if not ok then
				return false, `value is type '{typeof(value)}', expected nil or '{tostring(valueType)}'`
			end

			return true
		end,
	}

	return setmetatable(self :: any, Type)
end

type UnionFunc =
	(<T1, T2>(T1, T2) -> T1 | T2)
	& (<T1, T2, T3>(T1, T2, T3) -> T1 | T2 | T3)
	& (<T1, T2, T3, T4>(T1, T2, T3, T4) -> T1 | T2 | T3 | T4)
	& (<T1, T2, T3, T4, T5>(T1, T2, T3, T4, T5) -> T1 | T2 | T3 | T4 | T5)
	& (<T1, T2, T3, T4, T5, T6>(T1, T2, T3, T4, T5, T6) -> T1 | T2 | T3 | T4 | T5 | T6)
	& (<T>(...T) -> T)

local function blackTeaTypeCheck(...: any): string?
	for i, v in { ... } do
		if not isType(v) then
			return `argument #{i}, is not a ZtType.`
		end
	end

	return
end
local function unionMatcher(types: { Type.Type }, kind: string)
	return function(value): (boolean, string?)
		for _, ztype in types do
			local ok: boolean, _ = (ztype :: any):matches(value)
			if ok then
				return true
			end
		end

		return false, `value is type '{typeof(value)}', expected {kind}`
	end
end
local union: UnionFunc = function<T>(...: T): T
	local err = blackTeaTypeCheck(...)
	if err then
		error(err)
	end

	local types = { ... }
	local kind = `({table.concat(types, " | ")})`
	local self: Type.TypeBase = {
		kind = kind,
		_internalKind = "union",
		matcher = unionMatcher(types :: any, kind),
	}

	return setmetatable(self :: any, Type)
end :: any
Structure.union = union

function Structure.stringEnum(...: string): string
	local types: { Type.Type } = {}
	for _, validValue in { ... } do
		table.insert(types, Structure.literal(validValue) :: any)
	end

	return Structure.union(table.unpack(types)) :: any
end

function Structure.args<T...>(...: T...): (T...) -> ()
	return Structure.tuple(...) :: any
end

function Structure.returns<T...>(...: T...): () -> T...
	return Structure.tuple(...) :: any
end

function Structure.fn<Args..., Rets...>(args: (Args...) -> (), returns: () -> Rets...): (Args...) -> Rets...
	assert(isType(args), "args must be BlackTeaType")
	assert(isType(returns), "returns must be BlackTeaType")

	assert(castType(args)._internalKind == "tuple", "args must be a tuple")
	assert(castType(returns)._internalKind == "tuple", "returns must be a tuple")

	local self: Type.TypeBase = {
		kind = `{tostring(args)} -> {tostring(returns)}`,
		_internalKind = "function",
		matcher = function(value: any, ...: any)
			local valueTypeName = typeof(value)
			if valueTypeName ~= "function" then
				return false, `'function' expected, got {valueTypeName} instead.`
			end

			return true
		end,
	}

	return setmetatable(self :: any, Type)
end

function Structure.wrapFn<Args..., Rets...>(args: (Args...) -> (), returns: () -> Rets..., fn: (Args...) -> Rets...): (Args...) -> Rets...
	assert(isType(args), "args must be BlackTeaType")
	assert(isType(returns), "returns must be BlackTeaType")

	local argsType = castType(args)
	local returnsType = castType(returns)

	return function(...)
		local argsOk, argsErr = argsType:matches(...)
		if not argsOk then
			error(`function arguments: {argsErr}`)
		end

		local outputs = table.pack(fn(...))
		local returnsOk, returnsErr = returnsType:matches(table.unpack(outputs, 1, outputs.n))
		if not returnsOk then
			error(`function arguments: {returnsErr}`)
		end

		return table.unpack(outputs, 1, outputs.n)
	end :: any
end

function Structure.wrapArgsFn<Args...>(args: (Args...) -> (), fn: (Args...) -> ...any): (Args...) -> ...any
	assert(isType(args), "args must be BlackTeaType")
	local argsType = castType(args)

	return function(...)
		local ok, err = argsType:matches(...)
		if not ok then
			error(`function arguments: {err}`)
		end
		return fn(...)
	end :: any
end

function Structure.wrapReturnsFn<Rets...>(returns: () -> Rets..., fn: (...any) -> Rets...): (...any) -> Rets...
	assert(isType(returns), "returns must be BlackTeaType")
	local returnsType = castType(returns)

	return function(...)
		local outputs = table.pack(fn(...))
		local ok, err = returnsType:matches(table.unpack(outputs, 1, outputs.n))
		if not ok then
			error(`function arguments: {err}`)
		end

		return table.unpack(outputs, 1, outputs.n)
	end :: any
end

function Structure.struct<T>(template: T): T
	assert(typeof(template) == "table", "expected a table to create struct")

	local literalTemplate = {}
	local genericTemplate = {}
	for keyType, elemType in template :: any do
		if not isType(elemType) then
			error(`value of '{tostring(keyType)}' is not, ZtType`, 2)
		end

		if not isType(keyType) then
			literalTemplate[keyType] = elemType
			continue
		end

		local existingGenericKey = genericTemplate[keyType]
		if existingGenericKey then
			warn(
				debug.traceback(
					`failed to set generic key type '{tostring(keyType)}'.\n'{tostring(existingGenericKey)}' already assigned.`,
					2
				)
			)
			continue
		end

		genericTemplate[keyType] = elemType
	end

	local literalsTable = {}
	for literal, elemType in literalTemplate do
		if elemType.kind == "nil" or elemType._internalKind == "optional" then
			table.insert(literalsTable, literal)
		end
	end

	local function matcher(value: any, ...): (boolean, string?)
		local isTable: boolean, result: string? = (Raw.table :: any):matches(value)
		if not isTable then
			return false, result
		end

		local missingLiterals = table.clone(literalsTable)
		local errors = {}
		for key, elem in value do
			-- Check literal key value
			local elemType = (template :: any)[key] :: Type.Type
			if elemType then
				local ok: boolean = elemType:matches(elem)
				if not ok then
					table.insert(errors, `'{tostring(key)}' key is type {typeof(elem)}, expected {tostring(elemType)}`)
				end

				table.remove(missingLiterals, table.find(missingLiterals, key))
				continue
			end

			-- Check generic key value
			local validGenericKey = false
			for genericKeyType: Type.Type, genericElemType: Type.Type in genericTemplate do
				local matchesKey = genericKeyType:matches(key)
				if not matchesKey then
					continue
				end

				validGenericKey = true
				local matchesElem = genericElemType:matches(elem)
				if not matchesElem then
					table.insert(
						errors,
						`generic key '{tostring(genericKeyType)}' has value type '{typeof(elem)}'. expected '{tostring(
							genericElemType
						)}'`
					)
				end

				break
			end

			if not validGenericKey then
				table.insert(errors, `key {tostring(key)} does not have a valid field name or generic type`)
			end
		end

		for _, missingLiteral in missingLiterals do
			table.insert(errors, `'{tostring(missingLiteral)}' is missing.`)
		end

		local isValid = #errors <= 0
		return isValid,
			if not isValid
				then `'{typeof(value)}' does not match struct, errors:\n{table.concat(errors, "\n")}`
				else nil
	end

	local self: Type.TypeBase = {
		kind = "table",
		_internalKind = "struct",
		matcher = matcher,
	}

	return setmetatable(self :: any, Type)
end

return Structure
