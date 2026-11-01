> [!CAUTION]
> This is experimental and has not been tested. Discouraged from any form of use.
# Matcha
A roblox luau typechecker that does nothing but 'match a' value to a type. Courtesy to [GreenTea](https://github.com/Corecii/GreenTea) and [Boba](https://github.com/welcomestohell/boba) (typechecker, not the networking package).

# Usage
> [!TIP]
> Abriviate module name to `m`.
```luau
local m = require(path.to.Matcha)

local ok, err = m.number:matches(42)
if not ok then
    warn(err)
end
```
```luau
local m = require(path.to.Matcha)

local ok, err = m.array(m.string):matches("hello")
if not ok then
    warn(err)
end
```

### Roblox Types and Classes
```luau
local m = require(path.to.Matcha)

local ok, err = m.CFrame:matches(CFrame.new())
if not ok then
    warn(err)
end
```
```luau
local m = require(path.to.Matcha)

local ok, err = m.isA["IntValue"]:matches(Instance.new("IntValue"))
if not ok then
    warn(err)
end
```

### Casting
To cast the underlying type use the `_` field. this field is simply `self` of the `Type` and should only be used to cast.
```luau
local m = require(path.to.Matcha)

local PlayerData_m = m.struct({
    money = m.number._,
    inventory = m.array(m.string)._,
    [m.string._] = m.any._
})

export type PlayerData = typeof(PlayerData_m._)

-- Works! Wouldn't recommend this practice though.
local ok, err = (PlayerData_m._ :: any):matches({
    money = 100,
    inventory = { "sword" },
    xp = 50,
})
```

### Using with [Boba](https://github.com/Zead0n/boba) (networking package)
```luau
local Boba = require(path.to.Boba)
local m = require(path.to.Matcha)

local network = Boba.define(script, function(check: m.Type<any>, v: any)
    return check:matches(v)
end)

local someRemoteFunc = network.remoteFunction("SomeRemoteFunc")(m.string._, m.number._)(m.boolean._)
```

# Limitations
- Matcha does not do data validation, only checkes if a value matches a type.
- Matcha does not support tuples and vararg `...: T`.
