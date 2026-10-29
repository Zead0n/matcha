local Classes = require(script.Classes)
local Raw = require(script.Raw)
local Structure = require(script.Structure)
local Type = require(script.Type)

local castType = require(script.util.castType)
local isType = require(script.util.isType)

export type Type = Type.Type

local BlackTea = {}

-- Primitive Types
BlackTea.any = Raw.any
BlackTea.unknown = Raw.unknown
BlackTea.never = Raw.never
BlackTea.nonNil = Raw.nonNil
BlackTea.none = Raw.none
BlackTea.number = Raw.number
BlackTea.string = Raw.string
BlackTea.boolean = Raw.boolean
BlackTea.bool = Raw.bool
BlackTea.vector = Raw.vector
BlackTea.thread = Raw.thread
BlackTea.buffer = Raw.buffer
BlackTea.table = Raw.table
BlackTea.userdata = Raw.userdata

-- Roblox Types
BlackTea.BrickColor = Raw.BrickColor
BlackTea.CFrame = Raw.CFrame
BlackTea.Color3 = Raw.Color3
BlackTea.Enum = Raw.Enum
BlackTea.EnumItem = Raw.EnumItem
BlackTea.Font = Raw.Font
BlackTea.Instance = Raw.Instance
BlackTea.Ray = Raw.Ray
BlackTea.Rect = Raw.Rect
BlackTea.Region3 = Raw.Region3
BlackTea.UDim = Raw.UDim
BlackTea.UDim2 = Raw.UDim2
BlackTea.Vector2 = Raw.Vector2
BlackTea.Vector3 = Raw.Vector3

-- Structured Types
BlackTea.array = Structure.array
BlackTea.dictionary = Structure.dictionary
BlackTea.struct = Structure.struct
BlackTea.tuple = Structure.tuple
BlackTea.vararg = Structure.vararg
BlackTea.union = Structure.union
BlackTea.literal = Structure.literal
BlackTea.stringEnum = Structure.stringEnum
BlackTea.optional = Structure.optional
BlackTea.opt = Structure.optional
BlackTea.args = Structure.args
BlackTea.returns = Structure.returns
BlackTea.rets = Structure.returns
BlackTea.fn = Structure.fn
BlackTea.wrapFn = Structure.wrapFn
BlackTea.wrapArgsFn = Structure.wrapArgsFn
BlackTea.wrapReturnsFn = Structure.wrapReturnsFn

BlackTea.isBlackTeaType = isType
BlackTea.cast = castType

BlackTea.IsA = function<T>(obj: string): T
	local objClass = Classes[obj]
	if not objClass then
		error(`'{obj}' Class type is not valid, or is missing`)
	end

	return Classes[obj]
end

local mt = {
	__call = function<T>(self, structTemplate: T): T
		assert(typeof(structTemplate) == "table", "zt only takes a table to make a struct.")
		return BlackTea.struct(structTemplate)
	end,
}

return setmetatable(BlackTea, mt)
