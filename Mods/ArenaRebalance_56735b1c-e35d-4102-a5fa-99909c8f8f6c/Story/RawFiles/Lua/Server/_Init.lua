Ext.Require("Server/TauntMutes.lua")
Ext.Require("Server/RemoveMuted_Taunt.lua")
Ext.Require("Server/NoSuckerPunchLoop.lua")
Ext.Require("Server/InSurfaceTracker.lua")
Ext.Require("Server/SurfaceStatusController.lua")
Ext.Require("Server/RebalanceTalentFix.lua")
Ext.Require("Server/SP_DiminishingReturn.lua")
Ext.Require("Server/LX_Taunt.lua")
Ext.Require("Server/RestorationDamageMultiplier.lua")
Ext.Require("Server/SideCastFix.lua")


---A duration of -1 will keep the status active only while in the surface. Any duration >0 emulates surface roottemplate KeepAlive 
InSurfaceTracker:CreateNewController("SmokeCloud", "SP_SMOKEREWORK", -1)
InSurfaceTracker:CreateNewController("SmokeCloudCursed", "SP_SMOKEREWORK", -1)
InSurfaceTracker:CreateNewController("SmokeCloudBlessed", "SP_SMOKEREWORK", -1)