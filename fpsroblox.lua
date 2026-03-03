-- ULTRA AGGRESSIVE FPS BOOSTER (MAX PERFORMANCE)
-- Fokus: FPS setinggi mungkin, visual dihancurkan total

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local function safeSet(obj, prop, val)
    pcall(function() obj[prop] = val end)
end

local function nukeInstance(v)
    if not v then return end

    -- PART
    if v:IsA("BasePart") then
        safeSet(v, "Material", Enum.Material.SmoothPlastic)
        safeSet(v, "Reflectance", 0)
        safeSet(v, "CastShadow", false)
        safeSet(v, "Transparency", 0)
        safeSet(v, "TextureID", "")
        safeSet(v, "TextureId", "")
    end

    -- MESH
    if v:IsA("MeshPart") then
        safeSet(v, "TextureID", "")
    end

    if v:IsA("SpecialMesh") then
        safeSet(v, "TextureId", "")
    end

    -- HAPUS SEMUA VISUAL EFFECT
    if v:IsA("Decal")
    or v:IsA("Texture")
    or v:IsA("ParticleEmitter")
    or v:IsA("Trail")
    or v:IsA("Beam")
    or v:IsA("Fire")
    or v:IsA("Smoke")
    or v:IsA("Sparkles")
    or v:IsA("Explosion")
    or v:IsA("Atmosphere")
    or v:IsA("Clouds")
    or v:IsA("Sky")
    or v:IsA("PostEffect")
    or v:IsA("BloomEffect")
    or v:IsA("BlurEffect")
    or v:IsA("ColorCorrectionEffect")
    or v:IsA("SunRaysEffect")
    or v:IsA("DepthOfFieldEffect") then
        pcall(function() v:Destroy() end)
    end
end

-- APPLY LIGHTING FLAT TOTAL
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.ClockTime = 12
    Lighting.Ambient = Color3.fromRGB(150,150,150)
    Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)
end)

-- PAKSA TECHNOLOGY KE PALING RINGAN (EXECUTOR ONLY)
pcall(function()
    if sethiddenproperty then
        sethiddenproperty(Lighting, "Technology", 2)
    end
end)

-- TERRAIN DISABLE
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    pcall(function()
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
        terrain.Decoration = false
    end)
end

-- TURUNKAN RENDER QUALITY
pcall(function()
    if settings and settings().Rendering then
        settings().Rendering.QualityLevel = 1
    end
end)

-- NUKING SEMUA DESCENDANTS
for _, v in ipairs(game:GetDescendants()) do
    nukeInstance(v)
end

-- AUTO NUKE OBJECT BARU
game.DescendantAdded:Connect(function(v)
    task.wait()
    nukeInstance(v)
end)

print("🔥 ULTRA AGGRESSIVE FPS MODE ACTIVE 🔥")