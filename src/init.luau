local Adv = require(script.Adv)
local Roblox = require(script.Roblox)
local Type = require(script.Type)

local formatExpectedGot = require(script.utils.formatExpectedGot)

function createTypeof(typeName: string): Type.Type<any>
	return Type.new(typeName, function(v)
		if typeof(v) ~= typeName then
			return false, formatExpectedGot(typeName, v)
		end

		return true
	end)
end

local Matcha = {}

export type Type<T> = Type.Type<T>

Matcha.isType = Type.isType

Matcha.custom = Type.new
Matcha.any = Type.new("any", function()
	return true
end)
Matcha.unknown = Type.new("unknown", function()
	return true
end)
Matcha.never = Type.new("never", function()
	return false, "No value is valid"
end)
Matcha.none = Type.new("nil", function(v)
	if v ~= nil then
		return false, formatExpectedGot("nil", v)
	end

	return true
end)

Matcha.number = createTypeof("number") :: Type<number>
Matcha.num = Matcha.num
Matcha.string = createTypeof("string") :: Type<string>
Matcha.str = Matcha.string
Matcha.boolean = createTypeof("boolean") :: Type<boolean>
Matcha.bool = Matcha.boolean
Matcha.vector = createTypeof("vector") :: Type<vector>
Matcha.thread = createTypeof("thread") :: Type<thread>
Matcha.buffer = createTypeof("buffer") :: Type<buffer>
Matcha.table = createTypeof("table") :: Type<{ [any]: any }>

Matcha.literal = Adv.literal
Matcha.optional = Adv.optional
Matcha.opt = Adv.optional
Matcha.array = Adv.array
Matcha.arr = Adv.array
Matcha.dictionary = Adv.dictionary
Matcha.dict = Adv.dictionary
Matcha.map = Adv.dictionary
Matcha.struct = Adv.struct
Matcha.union = Adv.union
Matcha.enum = Adv.enum

Matcha.Axes = Roblox.Axes
Matcha.BrickColor = Roblox.BrickColor
Matcha.CatalogSearchParams = Roblox.CatalogSearchParams
Matcha.CFrame = Roblox.CFrame
Matcha.Color3 = Roblox.Color3
Matcha.ColorSequence = Roblox.ColorSequence
Matcha.ColorSequenceKeypoint = Roblox.ColorSequenceKeypoint
Matcha.Content = Roblox.Content
Matcha.DateTime = Roblox.DateTime
Matcha.DockWidgetPluginGuiInfo = Roblox.DockWidgetPluginGuiInfo
Matcha.Enum = Roblox.Enum
Matcha.EnumItem = Roblox.EnumItem
Matcha.Enums = Roblox.Enums
Matcha.Faces = Roblox.Faces
Matcha.FloatCurveKey = Roblox.FloatCurveKey
Matcha.Font = Roblox.Font
Matcha.Instance = Roblox.Instance
Matcha.NumberRange = Roblox.NumberRange
Matcha.NumberSequence = Roblox.NumberSequence
Matcha.NumberSequenceKeypoint = Roblox.NumberSequenceKeypoint
Matcha.OverlapParams = Roblox.OverlapParams
Matcha.Path2DControlPoint = Roblox.Path2DControlPoint
Matcha.PathWaypoint = Roblox.PathWaypoint
Matcha.PhysicalProperties = Roblox.PhysicalProperties
Matcha.Random = Roblox.Random
Matcha.Ray = Roblox.Ray
Matcha.RaycastParams = Roblox.RaycastParams
Matcha.RaycastResult = Roblox.RaycastResult
Matcha.RBXScriptConnection = Roblox.RBXScriptConnection
Matcha.RBXScriptSignal = Roblox.RBXScriptSignal
Matcha.Rect = Roblox.Rect
Matcha.Region3 = Roblox.Region3
Matcha.Region3int16 = Roblox.Region3int16
Matcha.RotationCurveKey = Roblox.RotationCurveKey
Matcha.Secret = Roblox.Secret
Matcha.SharedTable = Roblox.SharedTable
Matcha.TweenInfo = Roblox.TweenInfo
Matcha.UDim = Roblox.UDim
Matcha.UDim2 = Roblox.UDim2
Matcha.ValueCurveKey = Roblox.ValueCurveKey
Matcha.Vector2 = Roblox.Vector2
Matcha.Vector2int16 = Roblox.Vector2int16
Matcha.Vector3 = Roblox.Vector3
Matcha.Vector3int16 = Roblox.Vector3int16

Matcha.isA = Roblox.isA

return Matcha
