local Type = require(script.Parent.Type)

local function createRawType(kind: string, matcher: (...any) -> (boolean, string?))
	local base: Type.TypeBase = {
		kind = kind,
		matcher = matcher,
	}

	return setmetatable(base, Type) :: any
end

local function primitiveType(expectedType: string, useType: boolean?)
	local function primitiveMatcher(value): (boolean, string?)
		local typeName = if not useType then typeof(value) else type(value)
		if typeName ~= expectedType then
			return false, `'{expectedType}' expected, got '{typeName}' instead`
		end

		return true
	end

	return createRawType(expectedType, primitiveMatcher) :: any
end

-- NOTE: This is the same as primitiveType for now.
-- Should this need to be changed, it should affect all roblox types
local robloxType = primitiveType

local Raw = {}

-- Primitive Types
Raw.any = createRawType("any", function(_value)
	return true
end) :: any
Raw.unknown = Raw.any :: unknown

Raw.never = createRawType("never", function(value)
	return false, `'never' expected, got '{typeof(value)}' instead`
end) :: never

Raw.none = createRawType("nil", function(value)
	if value ~= nil then
		return false, `'nil' expected, got '{typeof(value)}' instead`
	end
	return true
end) :: nil

Raw.nonNil = createRawType("non-nil", function(value)
	if value == nil then
		return false, `'non-nil' expected, got '{typeof(value)}' instead`
	end
	return true
end) :: any

Raw.number = primitiveType("number") :: number
Raw.string = primitiveType("string") :: string
Raw.boolean = primitiveType("boolean") :: boolean
Raw.bool = Raw.boolean
Raw.vector = primitiveType("vector", true) :: vector
Raw.thread = primitiveType("thread", true) :: thread
Raw.buffer = primitiveType("buffer") :: buffer
Raw.table = primitiveType("table") :: { [any]: any }
Raw.userdata = primitiveType("userdata", true) :: any

-- Roblox Types
Raw.BrickColor = robloxType("BrickColor") :: BrickColor
Raw.CFrame = robloxType("CFrame") :: CFrame
Raw.Color3 = robloxType("Color3") :: Color3
Raw.Enum = robloxType("Enum") :: Enum
Raw.EnumItem = robloxType("EnumItem") :: EnumItem
Raw.Font = robloxType("Font") :: Font
Raw.Instance = robloxType("Instance") :: Instance
Raw.Ray = robloxType("Ray") :: Ray
Raw.Rect = robloxType("Rect") :: Rect
Raw.Region3 = robloxType("Region3") :: Region3
Raw.UDim = robloxType("UDim") :: UDim
Raw.UDim2 = robloxType("UDim2") :: UDim2
Raw.Vector2 = robloxType("Vector2") :: Vector2
Raw.Vector3 = robloxType("Vector3") :: Vector3

return Raw
