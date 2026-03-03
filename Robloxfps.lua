-- Roblox FPS Booster / Graphics Optimized (client-side)
-- Mode: aggressive = benar-benar hapus visual; safe = non-destruktif (disables/transparency)
local aggressiveMode = true -- ubah ke true kalau mau agresif
local batchYieldEvery = 50   -- berapa item sebelum task.wait() (turunkan kalau masih nge-lag)
local batchYieldTime = 0.01   -- berapa lama wait tiap batch

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- safe setter (pcall) untuk semua properti
local function safeSet(obj, prop, val)
    pcall(function() obj[prop] = val end)
end

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    return ok, err
end

-- core: neutralize visual properties for an Instance
local function EradicateVisualData(instance)
    if not instance then return end

    -- Base visual reductions
    if instance:IsA("BasePart") then
        safeSet(instance, "Material", Enum.Material.SmoothPlastic)
        safeSet(instance, "Reflectance", 0)
        safeSet(instance, "CastShadow", false)
        -- try both common texture property names
        safeSet(instance, "TextureID", "")
        safeSet(instance, "TextureId", "")
    end

    if instance:IsA("MeshPart") then
        safeSet(instance, "TextureID", "")
    end

    if instance:IsA("SpecialMesh") then
        safeSet(instance, "TextureId", "")
    end

    if instance:IsA("Decal") or instance:IsA("Texture") then
        if aggressiveMode then
            pcall(function() instance:Destroy() end)
        else
            safeSet(instance, "Transparency", 1)
        end
    end

    if instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
        safeSet(instance, "Enabled", false)
    end

    if instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Explosion") then
        -- some have Enabled, some don't — try both
        safeSet(instance, "Enabled", false)
        if aggressiveMode then
            pcall(function() instance:Destroy() end)
        end
    end

    -- sky/atmosphere/clouds handled: often in Lighting
    if instance:IsA("Atmosphere") or instance:IsA("Sky") or instance:IsA("Clouds") then
        if aggressiveMode then
            pcall(function() instance:Destroy() end)
        else
            safeSet(instance, "Enabled", false)
        end
    end
end

-- Batch process a list to avoid spikes
local function batchProcess(list)
    local count = 0
    for _, v in ipairs(list) do
        EradicateVisualData(v)
        count = count + 1
        if count % batchYieldEvery == 0 then
            task.wait(batchYieldTime)
        end
    end
end

-- Disable PostProcessEffects in Lighting (try to disable any PP-like objects)
local function disableLightingEffects()
    for _, eff in pairs(Lighting:GetDescendants()) do
        if eff:IsA("PostEffect") or eff:IsA("PostEffect") or eff:IsA("PostProcessEffect") or eff:IsA("ColorCorrectionEffect")
            or eff:IsA("BlurEffect") or eff:IsA("BloomEffect") or eff:IsA("SunRaysEffect") or eff:IsA("DepthOfFieldEffect") then
            safeSet(eff, "Enabled", false)
            if aggressiveMode then pcall(function() eff:Destroy() end) end
        end
    end
end

-- Apply lighting / terrain settings (pcall for exploit-only calls)
local function applyLightingTerrainOptimizations()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        -- make lighting flat/soft if desired:
        safeSet(Lighting, "Ambient", Color3.fromRGB(128,128,128))
        safeSet(Lighting, "OutdoorAmbient", Color3.fromRGB(128,128,128))
        safeSet(Lighting, "ClockTime", 12) -- midday
    end)

    disableLightingEffects()

    -- terrain tweaks
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            if aggressiveMode then
                pcall(function() terrain.Decoration = false end)
            else
                pcall(function() terrain.Decoration = false end)
            end
        end)
    end

    -- try to set rendering quality & hidden properties (executor-only)
    pcall(function()
        if settings and settings().Rendering then
            pcall(function() settings().Rendering.QualityLevel = 1 end)
        end
    end)

    -- attempt to set lighting technology (exploit-only, will fail without executor)
    pcall(function()
        if sethiddenproperty then
            pcall(function() sethiddenproperty(Lighting, "Technology", 2) end)
            if terrain and sethiddenproperty then
                pcall(function() sethiddenproperty(terrain, "Decoration", false) end)
            end
        end
    end)
end

-- Initial sweep (game:GetDescendants may be large — use batches)
task.spawn(function()
    -- a) Lighting descendants
    local lightingDesc = Lighting:GetDescendants()
    batchProcess(lightingDesc)

    -- b) Workspace descendants
    local wsDesc = Workspace:GetDescendants()
    batchProcess(wsDesc)

    -- c) whole game additional (gui textures etc)
    local allDesc = game:GetDescendants()
    batchProcess(allDesc)

    applyLightingTerrainOptimizations()
end)

-- connect to new instances (workspace + lighting + game)
local function connectDescendantAdded(service)
    service.DescendantAdded:Connect(function(inst)
        -- tiny yield to allow properties to exist
        task.defer(function()
            EradicateVisualData(inst)
            -- also if the new instance has children, batch process them shallowly
            local kids = inst:GetDescendants()
            if #kids > 0 then
                batchProcess(kids)
            end
        end)
    end)
end

connectDescendantAdded(Workspace)
connectDescendantAdded(Lighting)
connectDescendantAdded(game)

print("Optimized FPS script loaded. aggressiveMode =", aggressiveMode)