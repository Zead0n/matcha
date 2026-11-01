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

local BlackTea = {}

export type Type<T> = Type.Type<T>

BlackTea.isType = Type.isType

BlackTea.custom = Type.new
BlackTea.any = Type.new("any", function()
	return true
end)
BlackTea.unknown = Type.new("unknown", function()
	return true
end)
BlackTea.never = Type.new("never", function()
	return false, "No value is valid"
end)
BlackTea.none = Type.new("nil", function(v)
	if v ~= nil then
		return false, formatExpectedGot("nil", v)
	end

	return true
end)

BlackTea.number = createTypeof("number") :: Type<number>
BlackTea.num = BlackTea.num
BlackTea.string = createTypeof("string") :: Type<string>
BlackTea.str = BlackTea.string
BlackTea.boolean = createTypeof("boolean") :: Type<boolean>
BlackTea.bool = BlackTea.boolean
BlackTea.vector = createTypeof("vector") :: Type<vector>
BlackTea.thread = createTypeof("thread") :: Type<thread>
BlackTea.buffer = createTypeof("buffer") :: Type<buffer>
BlackTea.table = createTypeof("table") :: Type<{ [any]: any }>

BlackTea.literal = Adv.literal
BlackTea.optional = Adv.optional
BlackTea.opt = Adv.optional
BlackTea.array = Adv.array
BlackTea.arr = Adv.array
BlackTea.dictionary = Adv.dictionary
BlackTea.dict = Adv.dictionary
BlackTea.map = Adv.dictionary
BlackTea.struct = Adv.struct
BlackTea.union = Adv.union
BlackTea.enum = Adv.enum

BlackTea.Axes = Roblox.Axes
BlackTea.BrickColor = Roblox.BrickColor
BlackTea.CatalogSearchParams = Roblox.CatalogSearchParams
BlackTea.CFrame = Roblox.CFrame
BlackTea.Color3 = Roblox.Color3
BlackTea.ColorSequence = Roblox.ColorSequence
BlackTea.ColorSequenceKeypoint = Roblox.ColorSequenceKeypoint
BlackTea.Content = Roblox.Content
BlackTea.DateTime = Roblox.DateTime
BlackTea.DockWidgetPluginGuiInfo = Roblox.DockWidgetPluginGuiInfo
BlackTea.Enum = Roblox.Enum
BlackTea.EnumItem = Roblox.EnumItem
BlackTea.Enums = Roblox.Enums
BlackTea.Faces = Roblox.Faces
BlackTea.FloatCurveKey = Roblox.FloatCurveKey
BlackTea.Font = Roblox.Font
BlackTea.Instance = Roblox.Instance
BlackTea.NumberRange = Roblox.NumberRange
BlackTea.NumberSequence = Roblox.NumberSequence
BlackTea.NumberSequenceKeypoint = Roblox.NumberSequenceKeypoint
BlackTea.OverlapParams = Roblox.OverlapParams
BlackTea.Path2DControlPoint = Roblox.Path2DControlPoint
BlackTea.PathWaypoint = Roblox.PathWaypoint
BlackTea.PhysicalProperties = Roblox.PhysicalProperties
BlackTea.Random = Roblox.Random
BlackTea.Ray = Roblox.Ray
BlackTea.RaycastParams = Roblox.RaycastParams
BlackTea.RaycastResult = Roblox.RaycastResult
BlackTea.RBXScriptConnection = Roblox.RBXScriptConnection
BlackTea.RBXScriptSignal = Roblox.RBXScriptSignal
BlackTea.Rect = Roblox.Rect
BlackTea.Region3 = Roblox.Region3
BlackTea.Region3int16 = Roblox.Region3int16
BlackTea.RotationCurveKey = Roblox.RotationCurveKey
BlackTea.Secret = Roblox.Secret
BlackTea.SharedTable = Roblox.SharedTable
BlackTea.TweenInfo = Roblox.TweenInfo
BlackTea.UDim = Roblox.UDim
BlackTea.UDim2 = Roblox.UDim2
BlackTea.ValueCurveKey = Roblox.ValueCurveKey
BlackTea.Vector2 = Roblox.Vector2
BlackTea.Vector2int16 = Roblox.Vector2int16
BlackTea.Vector3 = Roblox.Vector3
BlackTea.Vector3int16 = Roblox.Vector3int16

BlackTea.isA = Roblox.isA
BlackTea.isClass = Roblox.isClass

return BlackTea
