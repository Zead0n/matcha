local Type = require(script.Parent.Type)
local toQuote = require(script.Parent.utils.toQuote)

local BlackTea = {}

function BlackTea.literal<T>(literal: T): Type.Type<T>
	local vType = typeof(literal)
	local typeStr = tostring(literal)
	if vType == "string" then
		typeStr = string.format("%q", literal :: any)
	end

	return Type.new(typeStr, function(v)
		return if rawequal(v, literal) then true else false, `expected literal {typeStr}, got {toQuote(v)}`
	end)
end

function BlackTea.array<T>(bType: Type.Type<T>): Type.Type<{ T }>
	return Type.new(`\{ {bType.kind} \}`, function(v): (boolean, string?)
		if typeof(v) ~= "table" then
			return false, `expected 'table', got {toQuote(v)}`
		end

		local expected = #v
		local encountered = 0

		for key, value in v do
			encountered += 1

			if encountered > expected or typeof(key) ~= "number" then
				return false, `non-numeric indexes, such as key {toQuote(key)}`
			end

			local valueOk, valueErr = bType:matches(value)
			if not valueOk then
				return false, `#{key}: {valueErr}`
			end
		end

		return true
	end)
end

function BlackTea.dictionary<K, V>(kbType: Type.Type<K>, vbType: Type.Type<V>): Type.Type<{ [K]: V }>
	return Type.new(`\{ [{kbType.kind}]: {vbType.kind} \}`, function(v)
		if typeof(v) ~= "table" then
			return false, `expected 'table', got {toQuote(v)}`
		end

		for key, value in pairs(v) do
			local keyOk, keyErr = kbType:matches(key)
			if not keyOk then
				return false, `key error: {keyErr or "Unknown error"}`
			end

			local valueOk, valueErr = vbType:matches(value)
			if not valueOk then
				return false, `value error: {valueErr or "Unknown error"}`
			end
		end

		return true
	end)
end

function BlackTea.struct<T>(tbl: T): Type.Type<T>
	local literalTypes: { [string]: Type.Type<any> } = {}
	local generalTypes: { [Type.Type<any>]: Type.Type<any> } = {}

	local kindStrings: { string } = {}

	for expectedKey: string | Type.Type<any>, expectedValue: Type.Type<any> in tbl :: any do
		if Type.isType(expectedKey) then
			local keyType = expectedKey :: Type.Type<any>
			generalTypes[keyType] = expectedValue
			table.insert(kindStrings, `[{keyType.kind}]: {expectedValue.kind}`)
		else
			local keyLiteral = expectedKey :: string
			literalTypes[keyLiteral] = expectedValue
			table.insert(kindStrings, `[{string.format("%q", keyLiteral)}]: {expectedValue.kind}`)
		end
	end

	return Type.new(`\{\n\t {table.concat(kindStrings, "\n\t")} \}`, function(v)
		if typeof(v) ~= "table" then
			return false, `expected 'table', got {toQuote(v)}`
		end

		for key, value in v do
			local literalType = literalTypes[key] :: Type.Type<any>?
			if literalType then
				local ok, err = literalType:matches(value)
				if not ok then
					return false, `key literal '{key}': {err}`
				end

				continue
			end

			local err: string? = "Struct doesn't allow general keys"
			for generalType, valueType in generalTypes do
				local keyOk = (generalType :: Type.Type<any>):matches(key)
				if not keyOk then
					err = `key error: struct doesn't support key type {typeof(key)}`
					continue
				end
				err = nil

				local valueOk, valueErr = (valueType :: Type.Type<any>):matches(value)
				if not valueOk then
					err = `value error: {valueErr or "Unknown error"}`
					continue
				end
				err = nil
			end

			if err then
				return false, err
			end
		end

		return true
	end)
end

type BlackTeaEnum<T1, T2, T3, T4, T5, T6, T7, T8> = Type.Type<T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8>

type UnionFunc =
	(<T1, T2>(Type.Type<T1>, Type.Type<T2>) -> Type.Type<T1 | T2>)
	& (<T1, T2, T3>(Type.Type<T1>, Type.Type<T2>, Type.Type<T3>) -> Type.Type<T1 | T2 | T3>)
	& (<T1, T2, T3, T4>(
		Type.Type<T1>,
		Type.Type<T2>,
		Type.Type<T3>,
		Type.Type<T4>
	) -> Type.Type<T1 | T2 | T3 | T4>)
	& (<T1, T2, T3, T4, T5>(
		Type.Type<T1>,
		Type.Type<T2>,
		Type.Type<T3>,
		Type.Type<T4>,
		Type.Type<T4>,
		Type.Type<T5>
	) -> Type.Type<T1 | T2 | T3 | T4 | T5>)
	& (<T1, T2, T3, T4, T5, T6>(
		Type.Type<T1>,
		Type.Type<T2>,
		Type.Type<T3>,
		Type.Type<T4>,
		Type.Type<T4>,
		Type.Type<T5>,
		Type.Type<T6>
	) -> Type.Type<T1 | T2 | T3 | T4 | T5 | T6>)
	& (<T1, T2, T3, T4, T5, T6, T7>(
		Type.Type<T1>,
		Type.Type<T2>,
		Type.Type<T3>,
		Type.Type<T4>,
		Type.Type<T4>,
		Type.Type<T5>,
		Type.Type<T6>,
		Type.Type<T7>
	) -> Type.Type<T1 | T2 | T3 | T4 | T5 | T6 | T7>)
	& (<T1, T2, T3, T4, T5, T6, T7, T8>(
		Type.Type<T1>,
		Type.Type<T2>,
		Type.Type<T3>,
		Type.Type<T4>,
		Type.Type<T4>,
		Type.Type<T5>,
		Type.Type<T6>,
		Type.Type<T7>,
		Type.Type<T8>
	) -> Type.Type<T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8>)

BlackTea.union = function(...)
	local unionTypes = { ... }
	local kindStrings: { string } = {}

	for _, bType in unionTypes :: { Type.Type<any> } do
		table.insert(kindStrings, bType.kind)
	end

	return Type.new(`({table.concat(kindStrings, " | ")})`, function(v)
		for _, bType in unionTypes do
			local ok: boolean, _ = (bType :: Type.Type<any>):matches(v)
			if ok then
				return true
			end
		end

		return false, `expected , got {typeof(v)}`
	end)
end :: UnionFunc

type EnumFunc =
	(<T1, T2>(T1, T2) -> Type.Type<T1 | T2>)
	& (<T1, T2, T3>(T1, T2, T3) -> Type.Type<T1 | T2 | T3>)
	& (<T1, T2, T3, T4>(T1, T2, T3, T4) -> Type.Type<T1 | T2 | T3 | T4>)
	& (<T1, T2, T3, T4, T5>(T1, T2, T3, T4, T4, T5) -> Type.Type<T1 | T2 | T3 | T4 | T5>)
	& (<T1, T2, T3, T4, T5, T6>(T1, T2, T3, T4, T4, T5, T6) -> Type.Type<T1 | T2 | T3 | T4 | T5 | T6>)
	& (<T1, T2, T3, T4, T5, T6, T7>(
		T1,
		T2,
		T3,
		T4,
		T4,
		T5,
		T6,
		T7
	) -> Type.Type<T1 | T2 | T3 | T4 | T5 | T6 | T7>)
	& (<T1, T2, T3, T4, T5, T6, T7, T8>(
		T1,
		T2,
		T3,
		T4,
		T4,
		T5,
		T6,
		T7,
		T8
	) -> Type.Type<T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8>)

BlackTea.enum = function(...): Type.Type<string>
	local types: { Type.Type<string> } = {}
	for _, validValue in { ... } do
		table.insert(types, BlackTea.literal(validValue) :: any)
	end

	return BlackTea.union(table.unpack(types)) :: any
end :: EnumFunc

return BlackTea
