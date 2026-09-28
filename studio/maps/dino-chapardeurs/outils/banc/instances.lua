-- Banc d'essai Dino Chapardeurs : arbre d'instances Roblox simulé (propriétés, attributs, hiérarchie, méthodes).
local banc = BANC
local v3, cf = banc.v3, banc.cf
local estType = banc.estType

local donnees = setmetatable({}, { __mode = "k" }) -- instance -> données internes
banc.donnees = donnees
local Instmt = { __typeof = "Instance" }

-- ===== hiérarchie des classes =====
local PARENTS = {
	PVInstance = "Instance", BasePart = "PVInstance", FormFactorPart = "BasePart", Part = "FormFactorPart",
	WedgePart = "FormFactorPart", CornerWedgePart = "BasePart", TrussPart = "BasePart", MeshPart = "BasePart",
	SpawnLocation = "Part", Seat = "Part", Terrain = "BasePart", Model = "PVInstance", Workspace = "Model",
	Folder = "Instance", Configuration = "Instance",
	GuiBase = "Instance", GuiBase2d = "GuiBase", GuiObject = "GuiBase2d", Frame = "GuiObject", ScrollingFrame = "GuiObject",
	TextLabel = "GuiObject", TextButton = "GuiButton", TextBox = "GuiObject", ImageLabel = "GuiObject",
	ImageButton = "GuiButton", GuiButton = "GuiObject", ViewportFrame = "GuiObject", CanvasGroup = "GuiObject",
	LayerCollector = "GuiBase2d", ScreenGui = "LayerCollector", SurfaceGuiBase = "LayerCollector",
	SurfaceGui = "SurfaceGuiBase", BillboardGui = "LayerCollector",
	UIComponent = "Instance", UIBase = "UIComponent", UICorner = "UIComponent", UIStroke = "UIComponent",
	UIGradient = "UIComponent", UIGridStyleLayout = "UIComponent", UIListLayout = "UIGridStyleLayout",
	UIGridLayout = "UIGridStyleLayout", UIPadding = "UIComponent", UIConstraint = "UIComponent",
	UIAspectRatioConstraint = "UIConstraint", UISizeConstraint = "UIConstraint", UITextSizeConstraint = "UIConstraint",
	UIScale = "UIComponent", UIFlexItem = "UIComponent", UIPageLayout = "UIGridStyleLayout", UITableLayout = "UIGridStyleLayout",
	Light = "Instance", PointLight = "Light", SpotLight = "Light", SurfaceLight = "Light",
	ProximityPrompt = "Instance", ClickDetector = "Instance", Attachment = "Instance", Bone = "Attachment",
	Beam = "Instance", Trail = "Instance", ParticleEmitter = "Instance", Fire = "Instance", Smoke = "Instance",
	Sparkles = "Instance", Sound = "Instance", SoundGroup = "Instance", RemoteEvent = "Instance",
	UnreliableRemoteEvent = "Instance", RemoteFunction = "Instance", BindableEvent = "Instance",
	BindableFunction = "Instance", ValueBase = "Instance", BoolValue = "ValueBase", IntValue = "ValueBase",
	NumberValue = "ValueBase", StringValue = "ValueBase", ObjectValue = "ValueBase", Vector3Value = "ValueBase",
	CFrameValue = "ValueBase", Color3Value = "ValueBase", FaceInstance = "Instance", Decal = "FaceInstance",
	Texture = "Decal", DataModelMesh = "Instance", SpecialMesh = "DataModelMesh", BlockMesh = "DataModelMesh",
	JointInstance = "Instance", Weld = "JointInstance", Motor6D = "JointInstance", WeldConstraint = "Instance",
	Highlight = "Instance", SelectionBox = "Instance", Humanoid = "Instance", Animator = "Instance",
	Animation = "Instance", Atmosphere = "Instance", Sky = "Instance", Clouds = "Instance",
	PostEffect = "Instance", BloomEffect = "PostEffect", ColorCorrectionEffect = "PostEffect",
	SunRaysEffect = "PostEffect", BlurEffect = "PostEffect", DepthOfFieldEffect = "PostEffect",
	Explosion = "Instance", Constraint = "Instance", AlignPosition = "Constraint", AlignOrientation = "Constraint",
	LinearVelocity = "Constraint", VectorForce = "Constraint", RopeConstraint = "Constraint", SpringConstraint = "Constraint",
	HingeConstraint = "Constraint", BodyMover = "Instance", BodyPosition = "BodyMover", BodyVelocity = "BodyMover", BodyGyro = "BodyMover",
	Camera = "Instance", Tool = "Instance", Backpack = "Instance", PlayerGui = "Instance", PlayerScripts = "Instance",
	Player = "Instance", HumanoidDescription = "Instance", LuaSourceContainer = "Instance",
	BaseScript = "LuaSourceContainer", Script = "BaseScript", LocalScript = "Script", ModuleScript = "LuaSourceContainer",
	Team = "Instance", Accessory = "Instance", Shirt = "Instance", Pants = "Instance", BodyColors = "Instance",
	PathfindingModifier = "Instance", Dialog = "Instance", StarterGear = "Instance", DataModel = "Instance",
}
banc.PARENTS = PARENTS
local CREABLES = {}
for c in pairs(PARENTS) do CREABLES[c] = true end
for _, c in ipairs({ "PVInstance", "BasePart", "FormFactorPart", "GuiBase", "GuiBase2d", "GuiObject", "GuiButton",
	"LayerCollector", "SurfaceGuiBase", "UIComponent", "UIBase", "UIGridStyleLayout", "UIConstraint", "Light",
	"ValueBase", "FaceInstance", "DataModelMesh", "JointInstance", "PostEffect", "Constraint", "BodyMover",
	"LuaSourceContainer", "BaseScript", "Terrain", "Workspace", "Player", "PlayerGui", "PlayerScripts", "DataModel" }) do
	CREABLES[c] = nil
end

local function estA(classe, nom)
	local c = classe
	while c do
		if c == nom then return true end
		c = PARENTS[c]
	end
	return nom == "Instance"
end
banc.estA = estA

-- ===== valeurs par défaut =====
local C3 = Color3.new
local gris = function() return C3(0.639, 0.635, 0.647) end
local DEFAUTS = {
	Instance = { Archivable = true },
	BasePart = {
		Size = function() return v3(4, 1, 2) end, CFrame = function() return CFrame.new() end, Color = gris,
		Transparency = 0, Reflectance = 0, Anchored = false, CanCollide = true, CanTouch = true, CanQuery = true,
		CastShadow = true, Locked = false, Massless = false, Material = function() return Enum.Material.Plastic end,
		TopSurface = function() return Enum.SurfaceType.Smooth end, BottomSurface = function() return Enum.SurfaceType.Smooth end,
		LeftSurface = function() return Enum.SurfaceType.Smooth end, RightSurface = function() return Enum.SurfaceType.Smooth end,
		FrontSurface = function() return Enum.SurfaceType.Smooth end, BackSurface = function() return Enum.SurfaceType.Smooth end,
		AssemblyLinearVelocity = function() return Vector3.zero end, AssemblyAngularVelocity = function() return Vector3.zero end,
		Velocity = function() return Vector3.zero end, RotVelocity = function() return Vector3.zero end,
		CollisionGroup = "Default", PivotOffset = function() return CFrame.new() end, RootPriority = 0,
		CustomPhysicalProperties = nil, Mass = 1, AssemblyMass = 1, MaterialVariant = "",
		BrickColor = function() return BrickColor.new("Medium stone grey") end, EnableFluidForces = true, AudioCanCollide = true,
	},
	Part = { Shape = function() return Enum.PartType.Block end },
	SpawnLocation = { Neutral = true, Duration = 0, Enabled = true, AllowTeamChangeOnTouch = false, TeamColor = function() return BrickColor.new("White") end },
	Seat = { Disabled = false },
	TrussPart = { Style = 0 },
	MeshPart = { MeshId = "", TextureID = "", DoubleSided = false, RenderFidelity = 0 },
	Model = { LevelOfDetail = 0, ModelStreamingMode = function() return Enum.ModelStreamingMode.Default end },
	Workspace = { Gravity = 196.2, DistributedGameTime = 0, StreamingEnabled = false, FallenPartsDestroyHeight = -500, AirDensity = 0.0012, GlobalWind = function() return Vector3.zero end },
	GuiObject = {
		Size = function() return UDim2.new(0, 100, 0, 100) end, Position = function() return UDim2.new() end,
		AnchorPoint = function() return Vector2.new() end, BackgroundColor3 = function() return C3(1, 1, 1) end,
		BackgroundTransparency = 0, BorderSizePixel = 1, BorderColor3 = function() return C3(0.1, 0.16, 0.2) end,
		BorderMode = function() return Enum.BorderMode.Outline end,
		Visible = true, ZIndex = 1, LayoutOrder = 0, Rotation = 0, ClipsDescendants = false, Active = false,
		AutomaticSize = function() return Enum.AutomaticSize.None end, SizeConstraint = function() return Enum.SizeConstraint.RelativeXY end,
		AbsoluteSize = function() return Vector2.new(100, 100) end, AbsolutePosition = function() return Vector2.new(0, 0) end,
		AbsoluteRotation = 0, Selectable = false, Interactable = true, GuiState = 0,
	},
	GuiButton = { AutoButtonColor = true, Modal = false, Selected = false, Style = function() return Enum.ButtonStyle.Custom end },
	TextLabel = {}, TextButton = {}, TextBox = { ClearTextOnFocus = true, PlaceholderText = "", PlaceholderColor3 = function() return C3(0.7, 0.7, 0.7) end, MultiLine = false, TextEditable = true, CursorPosition = 1 },
	ImageLabel = {}, ImageButton = {},
	ScrollingFrame = {
		CanvasSize = function() return UDim2.new(0, 0, 2, 0) end, CanvasPosition = function() return Vector2.new() end,
		ScrollBarThickness = 12, ScrollingDirection = function() return Enum.ScrollingDirection.XY end,
		AutomaticCanvasSize = function() return Enum.AutomaticSize.None end, ScrollingEnabled = true,
		ScrollBarImageColor3 = function() return C3(0, 0, 0) end, ScrollBarImageTransparency = 0,
		ElasticBehavior = function() return Enum.ElasticBehavior.WhenScrollable end, AbsoluteCanvasSize = function() return Vector2.new(100, 200) end,
		AbsoluteWindowSize = function() return Vector2.new(100, 100) end, VerticalScrollBarInset = function() return Enum.ScrollBarInset.None end,
		HorizontalScrollBarInset = function() return Enum.ScrollBarInset.None end, TopImage = "", MidImage = "", BottomImage = "",
	},
	CanvasGroup = { GroupTransparency = 0, GroupColor3 = function() return C3(1, 1, 1) end },
	ViewportFrame = { CurrentCamera = nil, Ambient = function() return C3(0.8, 0.8, 0.8) end, LightColor = function() return C3(0.55, 0.55, 0.55) end, LightDirection = function() return v3(-1, -1, -1) end, ImageColor3 = function() return C3(1, 1, 1) end, ImageTransparency = 0 },
	LayerCollector = { Enabled = true, ResetOnSpawn = true, ZIndexBehavior = function() return Enum.ZIndexBehavior.Global end },
	ScreenGui = { DisplayOrder = 0, IgnoreGuiInset = false, ClipToDeviceSafeArea = true, SafeAreaCompatibility = 0, ScreenInsets = 0, AbsoluteSize = function() return Vector2.new(1280, 720) end },
	SurfaceGuiBase = { Face = function() return Enum.NormalId.Front end, Adornee = nil, Active = true },
	SurfaceGui = {
		SizingMode = function() return Enum.SurfaceGuiSizingMode.FixedSize end, PixelsPerStud = 50,
		CanvasSize = function() return Vector2.new(800, 600) end, LightInfluence = 1, AlwaysOnTop = false,
		Brightness = 1, MaxDistance = 1000, ZOffset = 0, ClipsDescendants = true, ToolPunchThroughDistance = 0,
		AbsoluteSize = function() return Vector2.new(800, 600) end,
	},
	BillboardGui = {
		Size = function() return UDim2.new() end, StudsOffset = function() return Vector3.zero end,
		StudsOffsetWorldSpace = function() return Vector3.zero end, ExtentsOffset = function() return Vector3.zero end,
		ExtentsOffsetWorldSpace = function() return Vector3.zero end, SizeOffset = function() return Vector2.new() end,
		AlwaysOnTop = false, MaxDistance = math.huge, LightInfluence = 0, Adornee = nil, Brightness = 1,
		ClipsDescendants = false, DistanceLowerLimit = 0, DistanceUpperLimit = -1, DistanceStep = 0, Active = false,
		AbsoluteSize = function() return Vector2.new(100, 100) end,
	},
	UICorner = { CornerRadius = function() return UDim.new(0, 8) end },
	UIStroke = { Color = function() return C3(0, 0, 0) end, Thickness = 1, Transparency = 0, Enabled = true,
		ApplyStrokeMode = function() return Enum.ApplyStrokeMode.Contextual end, LineJoinMode = function() return Enum.LineJoinMode.Round end },
	UIGradient = { Color = function() return ColorSequence.new(C3(1, 1, 1)) end, Transparency = function() return NumberSequence.new(0) end,
		Rotation = 0, Offset = function() return Vector2.new() end, Enabled = true },
	UIGridStyleLayout = { FillDirection = function() return Enum.FillDirection.Vertical end, SortOrder = function() return Enum.SortOrder.Name end,
		HorizontalAlignment = function() return Enum.HorizontalAlignment.Left end, VerticalAlignment = function() return Enum.VerticalAlignment.Top end,
		AbsoluteContentSize = function() return Vector2.new(100, 100) end },
	UIListLayout = { Padding = function() return UDim.new() end, Wraps = false, HorizontalFlex = 0, VerticalFlex = 0, ItemLineAlignment = 0 },
	UIGridLayout = { CellSize = function() return UDim2.new(0, 100, 0, 100) end, CellPadding = function() return UDim2.new(0, 5, 0, 5) end,
		FillDirectionMaxCells = 0, StartCorner = 0 },
	UIPadding = { PaddingTop = function() return UDim.new() end, PaddingBottom = function() return UDim.new() end,
		PaddingLeft = function() return UDim.new() end, PaddingRight = function() return UDim.new() end },
	UIAspectRatioConstraint = { AspectRatio = 1, AspectType = function() return Enum.AspectType.FitWithinMaxSize end, DominantAxis = function() return Enum.DominantAxis.Width end },
	UISizeConstraint = { MinSize = function() return Vector2.new() end, MaxSize = function() return Vector2.new(math.huge, math.huge) end },
	UITextSizeConstraint = { MaxTextSize = 100, MinTextSize = 1 },
	UIScale = { Scale = 1 },
	Light = { Brightness = 1, Color = function() return C3(1, 1, 1) end, Enabled = true, Shadows = false },
	PointLight = { Range = 8 }, SpotLight = { Range = 16, Angle = 90, Face = function() return Enum.NormalId.Front end },
	SurfaceLight = { Range = 16, Angle = 90, Face = function() return Enum.NormalId.Front end },
	ProximityPrompt = { ActionText = "Interact", ObjectText = "", HoldDuration = 0, MaxActivationDistance = 10,
		RequiresLineOfSight = true, Enabled = true, KeyboardKeyCode = function() return Enum.KeyCode.E end,
		GamepadKeyCode = function() return Enum.KeyCode.ButtonX end, Style = function() return Enum.ProximityPromptStyle.Default end,
		UIOffset = function() return Vector2.new() end, ClickablePrompt = true, AutoLocalize = true,
		Exclusivity = function() return Enum.ProximityPromptExclusivity.OnePerButton end },
	ClickDetector = { MaxActivationDistance = 32, CursorIcon = "" },
	Attachment = { CFrame = function() return CFrame.new() end, Visible = false, Axis = function() return v3(1, 0, 0) end, SecondaryAxis = function() return v3(0, 1, 0) end },
	Beam = { Attachment0 = nil, Attachment1 = nil, Color = function() return ColorSequence.new(C3(1, 1, 1)) end,
		Width0 = 1, Width1 = 1, Transparency = function() return NumberSequence.new(0.5) end, LightEmission = 0,
		LightInfluence = 1, FaceCamera = false, Segments = 10, Texture = "", TextureSpeed = 1, TextureLength = 1,
		TextureMode = function() return Enum.TextureMode.Stretch end, CurveSize0 = 0, CurveSize1 = 0, Enabled = true, ZOffset = 0, Brightness = 1 },
	Trail = { Attachment0 = nil, Attachment1 = nil, Lifetime = 2, Color = function() return ColorSequence.new(C3(1, 1, 1)) end,
		Transparency = function() return NumberSequence.new(0.5) end, WidthScale = function() return NumberSequence.new(1) end,
		MinLength = 0.1, MaxLength = 0, LightEmission = 0, LightInfluence = 1, FaceCamera = false, Enabled = true, Texture = "",
		TextureMode = function() return Enum.TextureMode.Stretch end, TextureLength = 1, Brightness = 1 },
	ParticleEmitter = { Rate = 20, Lifetime = function() return NumberRange.new(5, 10) end, Speed = function() return NumberRange.new(5) end,
		SpreadAngle = function() return Vector2.new() end, Color = function() return ColorSequence.new(C3(1, 1, 1)) end,
		Size = function() return NumberSequence.new(1) end, Transparency = function() return NumberSequence.new(0) end,
		Texture = "rbxasset://textures/particles/sparkles_main.dds", LightEmission = 0, LightInfluence = 0, Enabled = true,
		EmissionDirection = function() return Enum.NormalId.Top end, Acceleration = function() return Vector3.zero end, Drag = 0,
		Rotation = function() return NumberRange.new(0) end, RotSpeed = function() return NumberRange.new(0) end, LockedToPart = false,
		ZOffset = 0, Shape = function() return Enum.ParticleEmitterShape.Box end, ShapeStyle = function() return Enum.ParticleEmitterShapeStyle.Volume end,
		ShapeInOut = function() return Enum.ParticleEmitterShapeInOut.Outward end, Brightness = 1, Squash = function() return NumberSequence.new(0) end,
		VelocityInheritance = 0, TimeScale = 1, Orientation = 0 },
	Fire = { Enabled = true, Color = function() return C3(0.93, 0.38, 0.14) end, SecondaryColor = function() return C3(0.54, 0.16, 0) end, Size = 5, Heat = 9, TimeScale = 1 },
	Smoke = { Enabled = true, Color = function() return C3(1, 1, 1) end, Opacity = 0.5, RiseVelocity = 1, Size = 1, TimeScale = 1 },
	Sparkles = { Enabled = true, SparkleColor = function() return C3(0.56, 0.36, 1) end, TimeScale = 1 },
	Sound = { SoundId = "", Volume = 0.5, Playing = false, Looped = false, PlaybackSpeed = 1, TimePosition = 0, TimeLength = 1,
		IsPlaying = false, IsLoaded = true, IsPaused = false, RollOffMaxDistance = 10000, RollOffMinDistance = 10,
		RollOffMode = function() return Enum.RollOffMode.Inverse end, SoundGroup = nil, PlayOnRemove = false, Pitch = 1 },
	SoundGroup = { Volume = 0.5 },
	BoolValue = { Value = false }, IntValue = { Value = 0 }, NumberValue = { Value = 0 }, StringValue = { Value = "" },
	ObjectValue = { Value = nil }, Vector3Value = { Value = function() return Vector3.zero end },
	CFrameValue = { Value = function() return CFrame.new() end }, Color3Value = { Value = function() return C3(0, 0, 0) end },
	FaceInstance = { Face = function() return Enum.NormalId.Front end },
	Decal = { Texture = "", Color3 = function() return C3(1, 1, 1) end, Transparency = 0, ZIndex = 1 },
	Texture = { StudsPerTileU = 2, StudsPerTileV = 2, OffsetStudsU = 0, OffsetStudsV = 0 },
	SpecialMesh = { MeshType = function() return Enum.MeshType.Head end, Scale = function() return v3(1, 1, 1) end,
		Offset = function() return Vector3.zero end, MeshId = "", TextureId = "", VertexColor = function() return v3(1, 1, 1) end },
	BlockMesh = { Scale = function() return v3(1, 1, 1) end, Offset = function() return Vector3.zero end },
	JointInstance = { Part0 = nil, Part1 = nil, C0 = function() return CFrame.new() end, C1 = function() return CFrame.new() end, Enabled = true },
	Motor6D = { Transform = function() return CFrame.new() end, DesiredAngle = 0, MaxVelocity = 0, CurrentAngle = 0 },
	WeldConstraint = { Part0 = nil, Part1 = nil, Enabled = true, Active = true },
	Highlight = { FillColor = function() return C3(1, 0, 0) end, FillTransparency = 0.5, OutlineColor = function() return C3(1, 1, 1) end,
		OutlineTransparency = 0, Adornee = nil, DepthMode = function() return Enum.HighlightDepthMode.AlwaysOnTop end, Enabled = true },
	SelectionBox = { Adornee = nil, Color3 = function() return C3(0.05, 0.4, 0.8) end, LineThickness = 0.15, Transparency = 0,
		SurfaceColor3 = function() return C3(0.05, 0.4, 0.8) end, SurfaceTransparency = 1, Visible = true },
	Humanoid = { Health = 100, MaxHealth = 100, WalkSpeed = 16, JumpPower = 50, JumpHeight = 7.2, UseJumpPower = false,
		DisplayName = "", HipHeight = 2, AutoRotate = true, RootPart = nil, MoveDirection = function() return Vector3.zero end,
		FloorMaterial = function() return Enum.Material.Grass end, Sit = false, PlatformStand = false, Jump = false,
		DisplayDistanceType = function() return Enum.HumanoidDisplayDistanceType.Viewer end, NameDisplayDistance = 100,
		HealthDisplayDistance = 100, BreakJointsOnDeath = true, RequiresNeck = true, AutoJumpEnabled = true },
	Animation = { AnimationId = "" },
	Atmosphere = { Density = 0.3, Offset = 0, Color = function() return C3(0.78, 0.78, 0.78) end, Decay = function() return C3(0.36, 0.24, 0.2) end, Glare = 0, Haze = 0 },
	Sky = { SkyboxBk = "", SkyboxDn = "", SkyboxFt = "", SkyboxLf = "", SkyboxRt = "", SkyboxUp = "", SunAngularSize = 21,
		MoonAngularSize = 11, StarCount = 3000, CelestialBodiesShown = true, SunTextureId = "", MoonTextureId = "", SkyboxOrientation = function() return Vector3.zero end },
	Clouds = { Cover = 0.5, Density = 0.7, Color = function() return C3(1, 1, 1) end, Enabled = true },
	PostEffect = { Enabled = true },
	BloomEffect = { Intensity = 1, Size = 24, Threshold = 2 },
	ColorCorrectionEffect = { Brightness = 0, Contrast = 0, Saturation = 0, TintColor = function() return C3(1, 1, 1) end },
	SunRaysEffect = { Intensity = 0.25, Spread = 1 }, BlurEffect = { Size = 24 },
	DepthOfFieldEffect = { FarIntensity = 0.75, FocusDistance = 0.05, InFocusRadius = 10, NearIntensity = 0.75 },
	Explosion = { Position = function() return Vector3.zero end, BlastRadius = 4, BlastPressure = 500000,
		DestroyJointRadiusPercent = 1, ExplosionType = function() return Enum.ExplosionType.Craters end, Visible = true, TimeScale = 1 },
	Camera = { CFrame = function() return CFrame.lookAt(v3(0, 80, 90), v3(0, 0, 0)) end, Focus = function() return CFrame.new() end,
		FieldOfView = 70, CameraType = function() return Enum.CameraType.Custom end, CameraSubject = nil,
		ViewportSize = function() return Vector2.new(1280, 720) end, NearPlaneZ = -0.1, HeadScale = 1 },
	Tool = { RequiresHandle = true, CanBeDropped = true, ToolTip = "", TextureId = "", Enabled = true, ManualActivationOnly = false, Grip = function() return CFrame.new() end },
	Team = { TeamColor = function() return BrickColor.new("White") end, AutoAssignable = true },
	Constraint = { Enabled = true, Attachment0 = nil, Attachment1 = nil, Visible = false },
	LuaSourceContainer = { Disabled = false, Enabled = true },
}
local TEXTE = {
	Text = "Label", TextColor3 = function() return C3(0.1, 0.1, 0.1) end, TextSize = 14, TextScaled = false, TextWrapped = false,
	Font = function() return Enum.Font.Legacy end, TextXAlignment = function() return Enum.TextXAlignment.Center end,
	TextYAlignment = function() return Enum.TextYAlignment.Center end, TextTransparency = 0, TextStrokeTransparency = 1,
	TextStrokeColor3 = function() return C3(0, 0, 0) end, RichText = false, LineHeight = 1,
	TextTruncate = function() return Enum.TextTruncate.None end, MaxVisibleGraphemes = -1,
	TextBounds = function() return Vector2.new(50, 14) end, TextFits = true, ContentText = "",
	FontFace = function() return Font.fromEnum(Enum.Font.Legacy) end, TextDirection = 0, LocalizationMatchIdentifier = "",
}
local IMAGE = {
	Image = "", ImageColor3 = function() return C3(1, 1, 1) end, ImageTransparency = 0,
	ScaleType = function() return Enum.ScaleType.Stretch end, ImageRectOffset = function() return Vector2.new() end,
	ImageRectSize = function() return Vector2.new() end, SliceCenter = function() return Rect.new(0, 0, 0, 0) end,
	SliceScale = 1, TileSize = function() return UDim2.new(1, 0, 1, 0) end, ResampleMode = function() return Enum.ResamplerMode.Default end,
	HoverImage = "", PressedImage = "", IsLoaded = true,
}
for k, v in pairs(TEXTE) do DEFAUTS.TextLabel[k] = v; DEFAUTS.TextButton[k] = v; DEFAUTS.TextBox[k] = v end
DEFAUTS.TextBox.Text = ""
DEFAUTS.TextButton.Text = "Button"
for k, v in pairs(IMAGE) do DEFAUTS.ImageLabel[k] = v; DEFAUTS.ImageButton[k] = v end

local function defaut(classe, cle)
	local c = classe
	while c do
		local t = DEFAUTS[c]
		if t then
			local v = t[cle]
			if v ~= nil then return true, v end
			-- clé présente avec valeur nil explicite
			for k in pairs(t) do if k == cle then return true, nil end end
		end
		c = PARENTS[c]
	end
	local t = DEFAUTS.Instance
	if t[cle] ~= nil then return true, t[cle] end
	return false
end

-- propriétés qui existent mais valent nil par défaut
local NILS = {
	PrimaryPart = "Model", Adornee = "Instance", Attachment0 = "Instance", Attachment1 = "Instance", Part0 = "Instance",
	Part1 = "Instance", SoundGroup = "Sound", CameraSubject = "Camera", CustomPhysicalProperties = "BasePart",
	Character = "Player", Team = "Player", RespawnLocation = "Player", RootPart = "Humanoid", CurrentCamera = "ViewportFrame",
	Value = "ObjectValue", NextSelectionDown = "GuiObject", NextSelectionUp = "GuiObject", NextSelectionLeft = "GuiObject",
	NextSelectionRight = "GuiObject", SelectionImageObject = "GuiObject", PlaceholderText = "TextBox", Occupant = "Seat",
	OnServerInvoke = "RemoteFunction", OnClientInvoke = "RemoteFunction", OnInvoke = "BindableFunction", Handle = "Tool",
	TextureID = "MeshPart", Parent = "Instance",
}

-- ===== types attendus à l'écriture =====
local TYPES = {
	Size = function(classe) if estA(classe, "BasePart") then return "Vector3" end if estA(classe, "GuiObject") or classe == "BillboardGui" then return "UDim2" end end,
	Position = function(classe) if estA(classe, "BasePart") or classe == "Attachment" or classe == "Explosion" then return "Vector3" end if estA(classe, "GuiObject") then return "UDim2" end end,
	CFrame = "CFrame", WorldPivot = "CFrame", PivotOffset = "CFrame", C0 = "CFrame", C1 = "CFrame",
	Color = function(classe)
		if estA(classe, "BasePart") or estA(classe, "Light") or classe == "UIStroke" or classe == "Atmosphere" or classe == "Clouds"
			or classe == "Fire" or classe == "Smoke" then return "Color3" end
		if classe == "Beam" or classe == "Trail" or classe == "ParticleEmitter" or classe == "UIGradient" then return "ColorSequence" end
	end,
	Color3 = "Color3", BackgroundColor3 = "Color3", TextColor3 = "Color3", BorderColor3 = "Color3", ImageColor3 = "Color3",
	TextStrokeColor3 = "Color3", FillColor = "Color3", OutlineColor = "Color3", Ambient = "Color3", OutdoorAmbient = "Color3",
	FogColor = "Color3", TintColor = "Color3", ColorShift_Top = "Color3", ColorShift_Bottom = "Color3", Decay = "Color3",
	PlaceholderColor3 = "Color3", SparkleColor = "Color3", SecondaryColor = "Color3", ScrollBarImageColor3 = "Color3",
	Transparency = function(classe) if classe == "Beam" or classe == "Trail" or classe == "ParticleEmitter" or classe == "UIGradient" then return "NumberSequence" end return "number" end,
	BackgroundTransparency = "number", TextTransparency = "number", ImageTransparency = "number", TextStrokeTransparency = "number",
	Brightness = "number", Range = "number", Volume = "number", TextSize = "number", ZIndex = "number", Rotation = function(classe) if estA(classe, "BasePart") then return "Vector3" end if classe == "ParticleEmitter" then return "NumberRange" end return "number" end,
	Material = "EnumItem:Material", Shape = function(classe) if estA(classe, "BasePart") then return "EnumItem:PartType" end end,
	Font = "EnumItem:Font", Face = "EnumItem:NormalId", SizingMode = "EnumItem:SurfaceGuiSizingMode",
	TextXAlignment = "EnumItem:TextXAlignment", TextYAlignment = "EnumItem:TextYAlignment",
	Anchored = "boolean", CanCollide = "boolean", Visible = "boolean", TextScaled = "boolean", Enabled = "boolean",
	Name = "string", Text = "string|number", SoundId = "string", Image = "string",
	AnchorPoint = "Vector2", CornerRadius = "UDim", Padding = "UDim", CellSize = "UDim2", CanvasSize = function(classe) if classe == "ScrollingFrame" then return "UDim2" end return "Vector2" end,
	StudsOffset = "Vector3", Lifetime = function(classe) if classe == "ParticleEmitter" then return "NumberRange" end return "number" end,
	Speed = function(classe) if classe == "ParticleEmitter" then return "NumberRange" end end,
	Orientation = function(classe) if estA(classe, "BasePart") or classe == "Attachment" then return "Vector3" end end,
	PrimaryPart = "Instance?", Adornee = "Instance?", Attachment0 = "Instance?", Attachment1 = "Instance?", Part0 = "Instance?", Part1 = "Instance?",
	HoldDuration = "number", MaxActivationDistance = "number", ActionText = "string", ObjectText = "string",
	ClockTime = "number", FieldOfView = "number",
}
local function verifierType(classe, cle, v)
	local attendu = TYPES[cle]
	if type(attendu) == "function" then attendu = attendu(classe) end
	if not attendu then return end
	local t = typeof(v)
	if attendu == "Instance?" then
		if v == nil or t == "Instance" then return end
	elseif string.sub(attendu, 1, 9) == "EnumItem:" then
		if t == "EnumItem" and v.EnumType.nom == string.sub(attendu, 10) then return end
		if t == "string" or t == "number" then return end -- Roblox convertit les noms et valeurs d'Enum
	elseif attendu == "string|number" then
		if t == "string" or t == "number" then return end
	elseif t == attendu then
		return
	elseif attendu == "number" and t == "number" then
		return
	end
	error(string.format("Unable to assign property %s. %s expected, got %s", cle, attendu, t), 3)
end

-- ===== création =====
local compteurId = 0
local function nouvelle(classe)
	compteurId = compteurId + 1
	local inst = setmetatable({}, Instmt)
	donnees[inst] = { classe = classe, props = { Name = classe }, enfants = {}, parent = nil, attributs = {}, signaux = {},
		signauxAttr = {}, signauxProp = {}, tags = {}, id = compteurId, detruite = false }
	return inst
end
banc.nouvelleInstance = nouvelle

-- ===== événements connus =====
local EVENEMENTS = {}
for n in string.gmatch([[Changed ChildAdded ChildRemoved DescendantAdded DescendantRemoving AncestryChanged Destroying
	AttributeChanged Touched TouchEnded Triggered TriggerEnded PromptButtonHoldBegan PromptButtonHoldEnded PromptShown PromptHidden
	Activated MouseButton1Click MouseButton1Down MouseButton1Up MouseButton2Click MouseEnter MouseLeave MouseMoved InputBegan
	InputEnded InputChanged FocusLost Focused MouseClick RightMouseClick MouseHoverEnter MouseHoverLeave
	OnServerEvent OnClientEvent Event Died HealthChanged Running Jumping StateChanged MoveToFinished Seated
	CharacterAdded CharacterRemoving CharacterAppearanceLoaded Chatted Idled Ended Played Paused Resumed Stopped Loaded DidLoop
	Completed Equipped Unequipped Hit PlayerAdded PlayerRemoving Heartbeat RenderStepped Stepped PreRender PreSimulation
	PostSimulation PromptTriggered PromptTriggerEnded TouchTap TouchStarted TouchEnded TouchMoved TouchLongPress TouchSwipe
	TouchPinch LastInputTypeChanged WindowFocused WindowFocusReleased Button1Down Button1Up Button2Down Button2Up Move
	KeyDown KeyUp WheelForward WheelBackward PromptGamePassPurchaseFinished PromptProductPurchaseFinished
	PromptPurchaseFinished MenuOpened MenuClosed Close OnTeleport Destroying Blocked]], "%S+") do
	EVENEMENTS[n] = true
end

local function obtenirSignal(inst, nom)
	local d = donnees[inst]
	local s = d.signaux[nom]
	if not s then
		s = banc.signal(nom)
		d.signaux[nom] = s
	end
	return s
end
banc.obtenirSignal = obtenirSignal

local function signalSiExiste(inst, nom, ...)
	local d = donnees[inst]
	local s = d and d.signaux[nom]
	if s then s:Fire(...) end
end

local METHODES = {} -- classe -> { nom -> fonction }
banc.METHODES = METHODES
local function methode(classe, nom, fn)
	METHODES[classe] = METHODES[classe] or {}
	METHODES[classe][nom] = fn
end
banc.methode = methode
local function trouverMethode(classe, nom)
	local c = classe
	while c do
		local t = METHODES[c]
		if t and t[nom] then return t[nom] end
		c = PARENTS[c]
	end
	local t = METHODES.Instance
	return t and t[nom]
end

-- ===== espaces de coordonnées =====
local function positionDe(inst)
	local d = donnees[inst]
	local c = d.props.CFrame
	if not c then return Vector3.zero end
	return c.Position
end

-- ===== index =====
local LECTURES = {} -- propriétés calculées : classe -> nom -> fn(inst)
local function lecture(classe, nom, fn)
	LECTURES[classe] = LECTURES[classe] or {}
	LECTURES[classe][nom] = fn
end
banc.lecture = lecture
local ECRITURES = {}
local function ecriture(classe, nom, fn)
	ECRITURES[classe] = ECRITURES[classe] or {}
	ECRITURES[classe][nom] = fn
end
banc.ecriture = ecriture
local function chercher(table_, classe, nom)
	local c = classe
	while c do
		local t = table_[c]
		if t and t[nom] then return t[nom] end
		c = PARENTS[c]
	end
	local t = table_.Instance
	return t and t[nom]
end

-- conteneurs sans propriétés propres : un membre inconnu est une erreur, comme dans Roblox
local STRICTS = { Folder = true, Configuration = true, ModuleScript = true, Script = true, LocalScript = true,
	ReplicatedStorage = true, ServerStorage = true, ServerScriptService = true, PlayerGui = true, PlayerScripts = true,
	Backpack = true, StarterGui = false }
Instmt.__index = function(inst, k)
	local d = donnees[inst]
	if k == "Parent" then return d.parent end
	if k == "ClassName" then return d.classe end
	local lire = chercher(LECTURES, d.classe, k)
	if lire then return lire(inst) end
	local v = d.props[k]
	if v ~= nil then return v end
	local m = trouverMethode(d.classe, k)
	if m then return m end
	if EVENEMENTS[k] then return obtenirSignal(inst, k) end
	local existe, def = defaut(d.classe, k)
	if existe then
		if type(def) == "function" then def = def() end
		if def ~= nil then d.props[k] = def end
		return def
	end
	for _, e in ipairs(d.enfants) do
		if donnees[e].props.Name == k then return e end
	end
	if NILS[k] and estA(d.classe, NILS[k]) then return nil end
	if d.classe == "DataModel" then
		local s = banc.service(k, true)
		if s then return s end
	end
	if STRICTS[d.classe] then
		error(tostring(k) .. " is not a valid member of " .. d.classe .. " \"" .. inst:GetFullName() .. "\"", 2)
	end
	return banc.mockAny(d.classe .. "." .. tostring(k))
end

local function detacher(inst)
	local d = donnees[inst]
	local p = d.parent
	if not p then return end
	local dp = donnees[p]
	for i, e in ipairs(dp.enfants) do
		if e == inst then table.remove(dp.enfants, i) break end
	end
	d.parent = nil
	signalSiExiste(p, "ChildRemoved", inst)
	local a = p
	while a do
		signalSiExiste(a, "DescendantRemoving", inst)
		a = donnees[a].parent
	end
end

local function estDescendantDe(inst, ancetre)
	local p = donnees[inst].parent
	while p do
		if p == ancetre then return true end
		p = donnees[p].parent
	end
	return false
end

local function changerParent(inst, parent)
	local d = donnees[inst]
	if d.detruite then error("The Parent property of " .. d.props.Name .. " is locked, current parent: NULL, new parent " .. tostring(parent), 3) end
	if parent ~= nil and typeof(parent) ~= "Instance" then error("Parent : Instance attendue, reçu " .. typeof(parent), 3) end
	if parent == inst or (parent and estDescendantDe(parent, inst)) then error("Attempt to set parent of " .. d.props.Name .. " to itself or a descendant", 3) end
	if d.parent == parent then return end
	detacher(inst)
	d.parent = parent
	if parent then
		table.insert(donnees[parent].enfants, inst)
		signalSiExiste(parent, "ChildAdded", inst)
		local a = parent
		while a do
			signalSiExiste(a, "DescendantAdded", inst)
			a = donnees[a].parent
		end
		if banc.surAjout then banc.surAjout(inst) end
	end
	signalSiExiste(inst, "AncestryChanged", inst, parent)
end

Instmt.__newindex = function(inst, k, v)
	local d = donnees[inst]
	if k == "Parent" then changerParent(inst, v) return end
	if k == "ClassName" then error("ClassName est en lecture seule", 2) end
	if trouverMethode(d.classe, k) then error("impossible d'écrire le membre " .. k .. " (méthode) de " .. d.classe, 2) end
	if EVENEMENTS[k] and not d.props[k] then error("impossible d'écrire l'événement " .. k .. " de " .. d.classe, 2) end
	verifierType(d.classe, k, v)
	if typeof(v) == "string" and (k == "Material" or k == "Font" or k == "Face" or k == "Shape") then
		-- conversion des noms d'Enum
		local noms = { Material = "Material", Font = "Font", Face = "NormalId", Shape = "PartType" }
		v = Enum[noms[k]][v]
	end
	local ecrire = chercher(ECRITURES, d.classe, k)
	if ecrire then
		ecrire(inst, v)
	else
		if k == "Text" and type(v) == "number" then v = tostring(v) end
		d.props[k] = v
	end
	signalSiExiste(inst, "Changed", k)
	local s = d.signauxProp[k]
	if s then s:Fire() end
end
Instmt.__tostring = function(inst) return donnees[inst].props.Name end

-- ===== méthodes communes =====
methode("Instance", "IsA", function(self, nom) return estA(donnees[self].classe, nom) end)
methode("Instance", "GetChildren", function(self)
	local t = {}
	for i, e in ipairs(donnees[self].enfants) do t[i] = e end
	return t
end)
local function descendants(inst, t)
	for _, e in ipairs(donnees[inst].enfants) do
		table.insert(t, e)
		descendants(e, t)
	end
	return t
end
banc.descendants = function(inst) return descendants(inst, {}) end
methode("Instance", "GetDescendants", function(self) return descendants(self, {}) end)
methode("Instance", "FindFirstChild", function(self, nom, recursif)
	if type(nom) ~= "string" then error("FindFirstChild : nom (texte) attendu", 2) end
	for _, e in ipairs(donnees[self].enfants) do
		if donnees[e].props.Name == nom then return e end
	end
	if recursif then
		for _, e in ipairs(donnees[self].enfants) do
			local r = e:FindFirstChild(nom, true)
			if r then return r end
		end
	end
	return nil
end)
methode("Instance", "FindFirstChildOfClass", function(self, classe)
	for _, e in ipairs(donnees[self].enfants) do if donnees[e].classe == classe then return e end end
	return nil
end)
methode("Instance", "FindFirstChildWhichIsA", function(self, classe, recursif)
	for _, e in ipairs(donnees[self].enfants) do if estA(donnees[e].classe, classe) then return e end end
	if recursif then
		for _, e in ipairs(donnees[self].enfants) do
			local r = e:FindFirstChildWhichIsA(classe, true)
			if r then return r end
		end
	end
	return nil
end)
methode("Instance", "FindFirstDescendant", function(self, nom) return self:FindFirstChild(nom, true) end)
methode("Instance", "FindFirstAncestor", function(self, nom)
	local p = donnees[self].parent
	while p do
		if donnees[p].props.Name == nom then return p end
		p = donnees[p].parent
	end
	return nil
end)
methode("Instance", "FindFirstAncestorOfClass", function(self, classe)
	local p = donnees[self].parent
	while p do
		if donnees[p].classe == classe then return p end
		p = donnees[p].parent
	end
	return nil
end)
methode("Instance", "FindFirstAncestorWhichIsA", function(self, classe)
	local p = donnees[self].parent
	while p do
		if estA(donnees[p].classe, classe) then return p end
		p = donnees[p].parent
	end
	return nil
end)
methode("Instance", "IsDescendantOf", function(self, a) return estDescendantDe(self, a) end)
methode("Instance", "IsAncestorOf", function(self, d) return estDescendantDe(d, self) end)
methode("Instance", "WaitForChild", function(self, nom, delai)
	if type(nom) ~= "string" then error("WaitForChild : nom (texte) attendu", 2) end
	local e = self:FindFirstChild(nom)
	if e then return e end
	local debut = banc.maintenant()
	local signale = false
	while true do
		banc.attendre(0.1)
		e = self:FindFirstChild(nom)
		if e then return e end
		local ecoule = banc.maintenant() - debut
		if delai and ecoule >= delai then return nil end
		if not delai and ecoule >= 5 and not signale then
			signale = true
			local ou = debug.traceback("", 2)
			table.insert(banc.attentes, { chemin = self:GetFullName() .. "." .. nom, trace = ou, source = banc.sourceDe(ou) })
		end
	end
end)
methode("Instance", "GetFullName", function(self)
	local noms = {}
	local p = self
	while p and donnees[p].classe ~= "DataModel" do
		table.insert(noms, 1, donnees[p].props.Name)
		p = donnees[p].parent
	end
	return table.concat(noms, ".")
end)
local function detruire(inst)
	local d = donnees[inst]
	if d.detruite then return end
	signalSiExiste(inst, "Destroying")
	for _, e in ipairs(inst:GetChildren()) do detruire(e) end
	detacher(inst)
	d.detruite = true
	for _, s in pairs(d.signaux) do s.connexions = {} end
	if banc.surDestruction then banc.surDestruction(inst) end
end
methode("Instance", "Destroy", function(self) detruire(self) end)
methode("Instance", "Remove", function(self) self.Parent = nil end)
methode("Instance", "ClearAllChildren", function(self)
	for _, e in ipairs(self:GetChildren()) do detruire(e) end
end)
methode("Instance", "SetAttribute", function(self, nom, valeur)
	if type(nom) ~= "string" then error("SetAttribute : nom (texte) attendu", 2) end
	local t = typeof(valeur)
	local OK = { ["nil"] = true, string = true, boolean = true, number = true, UDim = true, UDim2 = true, BrickColor = true,
		Color3 = true, Vector2 = true, Vector3 = true, CFrame = true, NumberSequence = true, ColorSequence = true,
		NumberRange = true, Rect = true, Font = true, EnumItem = true }
	if not OK[t] then error("SetAttribute : type non pris en charge pour « " .. nom .. " » : " .. t, 2) end
	local d = donnees[self]
	if d.attributs[nom] == valeur then return end
	d.attributs[nom] = valeur
	local s = d.signauxAttr[nom]
	if s then s:Fire() end
	signalSiExiste(self, "AttributeChanged", nom)
end)
methode("Instance", "GetAttribute", function(self, nom) return donnees[self].attributs[nom] end)
methode("Instance", "GetAttributes", function(self)
	local t = {}
	for k, v in pairs(donnees[self].attributs) do t[k] = v end
	return t
end)
methode("Instance", "GetAttributeChangedSignal", function(self, nom)
	local d = donnees[self]
	d.signauxAttr[nom] = d.signauxAttr[nom] or banc.signal("Attr:" .. nom)
	return d.signauxAttr[nom]
end)
methode("Instance", "GetPropertyChangedSignal", function(self, nom)
	local d = donnees[self]
	d.signauxProp[nom] = d.signauxProp[nom] or banc.signal("Prop:" .. nom)
	return d.signauxProp[nom]
end)
methode("Instance", "AddTag", function(self, tag) donnees[self].tags[tag] = true end)
methode("Instance", "RemoveTag", function(self, tag) donnees[self].tags[tag] = nil end)
methode("Instance", "HasTag", function(self, tag) return donnees[self].tags[tag] == true end)
methode("Instance", "GetTags", function(self) local t = {} for k in pairs(donnees[self].tags) do table.insert(t, k) end return t end)
methode("Instance", "GetActor", function() return nil end)

local REFERENCES = { "PrimaryPart", "Adornee", "Attachment0", "Attachment1", "Part0", "Part1", "Value", "SoundGroup", "CurrentCamera" }
methode("Instance", "Clone", function(self)
	if donnees[self].props.Archivable == false then return nil end
	local correspondances = {}
	local function copier(inst)
		local d = donnees[inst]
		local c = nouvelle(d.classe)
		local dc = donnees[c]
		for k, v in pairs(d.props) do dc.props[k] = v end
		for k, v in pairs(d.attributs) do dc.attributs[k] = v end
		for k, v in pairs(d.tags) do dc.tags[k] = v end
		dc.source = d.source
		correspondances[inst] = c
		for _, e in ipairs(d.enfants) do
			if donnees[e].props.Archivable ~= false then
				local ce = copier(e)
				donnees[ce].parent = c
				table.insert(dc.enfants, ce)
			end
		end
		return c
	end
	local copie = copier(self)
	for ancien, nouveau in pairs(correspondances) do
		local dn = donnees[nouveau]
		for _, r in ipairs(REFERENCES) do
			local v = dn.props[r]
			if typeof(v) == "Instance" and correspondances[v] then dn.props[r] = correspondances[v] end
		end
	end
	return copie
end)

-- ===== BasePart =====
lecture("BasePart", "Position", function(p) return p.CFrame.Position end)
ecriture("BasePart", "Position", function(p, v)
	local c = p.CFrame
	donnees[p].props.CFrame = CFrame.new(v) * c.Rotation
end)
lecture("BasePart", "Orientation", function(p)
	local rx, ry, rz = p.CFrame:ToOrientation()
	return v3(math.deg(rx), math.deg(ry), math.deg(rz))
end)
ecriture("BasePart", "Orientation", function(p, v)
	donnees[p].props.CFrame = CFrame.new(p.CFrame.Position) * CFrame.fromOrientation(math.rad(v.X), math.rad(v.Y), math.rad(v.Z))
end)
lecture("BasePart", "Rotation", function(p)
	local rx, ry, rz = p.CFrame:ToEulerAnglesXYZ()
	return v3(math.deg(rx), math.deg(ry), math.deg(rz))
end)
ecriture("BasePart", "Rotation", function(p, v)
	donnees[p].props.CFrame = CFrame.new(p.CFrame.Position) * CFrame.Angles(math.rad(v.X), math.rad(v.Y), math.rad(v.Z))
end)
ecriture("BasePart", "Size", function(p, v)
	if v.X < 0 or v.Y < 0 or v.Z < 0 then error("Size négative", 3) end
	-- Roblox borne la taille minimale des parts à 0,001
	donnees[p].props.Size = v3(math.max(v.X, 0.001), math.max(v.Y, 0.001), math.max(v.Z, 0.001))
end)
lecture("BasePart", "ExtentsSize", function(p) return p.Size end)
lecture("BasePart", "AssemblyRootPart", function(p) return p end)
methode("BasePart", "GetPivot", function(self) return self.CFrame * self.PivotOffset end)
methode("BasePart", "PivotTo", function(self, c)
	if typeof(c) ~= "CFrame" then error("PivotTo : CFrame attendu", 2) end
	self.CFrame = c * self.PivotOffset:Inverse()
end)
methode("BasePart", "GetMass", function() return 1 end)
methode("BasePart", "GetTouchingParts", function() return {} end)
methode("BasePart", "ApplyImpulse", function() end)
methode("BasePart", "ApplyAngularImpulse", function() end)
methode("BasePart", "SetNetworkOwner", function() end)
methode("BasePart", "GetNetworkOwner", function() return nil end)
methode("BasePart", "CanSetNetworkOwnership", function() return true end)
methode("BasePart", "SetNetworkOwnershipAuto", function() end)
methode("BasePart", "GetConnectedParts", function(self) return { self } end)
methode("BasePart", "GetJoints", function() return {} end)
methode("BasePart", "BreakJoints", function() end)
methode("BasePart", "GetVelocityAtPosition", function() return Vector3.zero end)
methode("BasePart", "GetClosestPointOnSurface", function(self, p) return p end)

-- ===== Model =====
local function partsDe(m)
	local t = {}
	for _, e in ipairs(descendants(m, {})) do
		if estA(donnees[e].classe, "BasePart") then table.insert(t, e) end
	end
	return t
end
banc.partsDe = partsDe
local function boite(parts)
	local mn, mx
	for _, p in ipairs(parts) do
		local c, s = p.CFrame, p.Size
		for _, sx in ipairs({ -1, 1 }) do
			for _, sy in ipairs({ -1, 1 }) do
				for _, sz in ipairs({ -1, 1 }) do
					local w = c * v3(sx * s.X / 2, sy * s.Y / 2, sz * s.Z / 2)
					if not mn then mn, mx = w, w else mn, mx = mn:Min(w), mx:Max(w) end
				end
			end
		end
	end
	return mn, mx
end
banc.boite = boite
lecture("Model", "WorldPivot", function(m)
	local d = donnees[m]
	local pp = d.props.PrimaryPart
	if pp and pp.Parent then return pp:GetPivot() end
	if d.props.WorldPivot then return d.props.WorldPivot end
	local mn, mx = boite(partsDe(m))
	if not mn then return CFrame.new() end
	return CFrame.new((mn + mx) / 2)
end)
ecriture("Model", "WorldPivot", function(m, v)
	local d = donnees[m]
	local pp = d.props.PrimaryPart
	if pp and pp.Parent then
		donnees[pp].props.PivotOffset = pp.CFrame:ToObjectSpace(v)
	else
		d.props.WorldPivot = v
	end
end)
ecriture("Model", "PrimaryPart", function(m, v)
	if v ~= nil and not (typeof(v) == "Instance" and v:IsA("BasePart")) then error("PrimaryPart : BasePart attendue", 3) end
	if v ~= nil and not v:IsDescendantOf(m) then
		-- Roblox accepte seulement une part descendante du modèle
		table.insert(banc.avertissements, { t = banc.maintenant(), cote = banc.cote(), texte = "PrimaryPart hors du modèle " .. m.Name, source = "?" })
	end
	donnees[m].props.PrimaryPart = v
end)
methode("Model", "GetPivot", function(self) return self.WorldPivot end)
methode("Model", "PivotTo", function(self, c)
	if typeof(c) ~= "CFrame" then error("PivotTo : CFrame attendu, reçu " .. typeof(c), 2) end
	local ancien = self.WorldPivot
	local delta = c * ancien:Inverse()
	for _, p in ipairs(partsDe(self)) do
		donnees[p].props.CFrame = delta * p.CFrame
	end
	local d = donnees[self]
	if not (d.props.PrimaryPart and d.props.PrimaryPart.Parent) then d.props.WorldPivot = c end
end)
methode("Model", "SetPrimaryPartCFrame", function(self, c)
	if not self.PrimaryPart then error("Model:SetPrimaryPartCFrame() failed because no PrimaryPart has been set", 2) end
	self:PivotTo(c * self.PrimaryPart.PivotOffset)
end)
methode("Model", "GetPrimaryPartCFrame", function(self)
	if not self.PrimaryPart then error("Model:GetPrimaryPartCFrame() failed because no PrimaryPart has been set", 2) end
	return self.PrimaryPart.CFrame
end)
methode("Model", "GetBoundingBox", function(self)
	local mn, mx = boite(partsDe(self))
	if not mn then return self.WorldPivot, Vector3.zero end
	return CFrame.new((mn + mx) / 2), mx - mn
end)
methode("Model", "GetExtentsSize", function(self)
	local mn, mx = boite(partsDe(self))
	if not mn then return Vector3.zero end
	return mx - mn
end)
methode("Model", "MoveTo", function(self, p)
	local c = self.WorldPivot
	self:PivotTo(CFrame.new(p) * c.Rotation)
end)
methode("Model", "TranslateBy", function(self, v) self:PivotTo(self.WorldPivot + v) end)
methode("Model", "GetScale", function(self) return donnees[self].echelle or 1 end)
methode("Model", "ScaleTo", function(self, e)
	if type(e) ~= "number" or e <= 0 then error("ScaleTo : facteur positif attendu", 2) end
	local d = donnees[self]
	local f = e / (d.echelle or 1)
	local pivot = self.WorldPivot
	for _, p in ipairs(partsDe(self)) do
		local local_ = pivot:ToObjectSpace(p.CFrame)
		local pos = local_.Position * f
		donnees[p].props.CFrame = pivot * (CFrame.new(pos) * local_.Rotation)
		donnees[p].props.Size = p.Size * f
	end
	-- comme Roblox : le pivot reste en place (le décalage de pivot de la PrimaryPart est mis à l'échelle)
	local pp = d.props.PrimaryPart
	if pp and donnees[pp] and donnees[pp].props.PivotOffset then
		local o = donnees[pp].props.PivotOffset
		donnees[pp].props.PivotOffset = CFrame.new(o.Position * f) * o.Rotation
	end
	d.echelle = e
end)
methode("Model", "BreakJoints", function() end)
methode("Model", "MakeJoints", function() end)
methode("Model", "GetModelCFrame", function(self) return self.WorldPivot end)

-- ===== Attachment =====
lecture("Attachment", "Position", function(a) return a.CFrame.Position end)
ecriture("Attachment", "Position", function(a, v) donnees[a].props.CFrame = CFrame.new(v) * a.CFrame.Rotation end)
lecture("Attachment", "WorldCFrame", function(a)
	local p = donnees[a].parent
	if p and p:IsA("BasePart") then return p.CFrame * a.CFrame end
	return a.CFrame
end)
lecture("Attachment", "WorldPosition", function(a) return a.WorldCFrame.Position end)
ecriture("Attachment", "WorldPosition", function(a, v)
	local p = donnees[a].parent
	if p and p:IsA("BasePart") then donnees[a].props.CFrame = CFrame.new(p.CFrame:PointToObjectSpace(v)) else donnees[a].props.CFrame = CFrame.new(v) end
end)
ecriture("Attachment", "WorldCFrame", function(a, v)
	local p = donnees[a].parent
	if p and p:IsA("BasePart") then donnees[a].props.CFrame = p.CFrame:ToObjectSpace(v) else donnees[a].props.CFrame = v end
end)
lecture("Attachment", "Orientation", function(a) local x, y, z = a.CFrame:ToOrientation() return v3(math.deg(x), math.deg(y), math.deg(z)) end)
ecriture("Attachment", "Orientation", function(a, v) donnees[a].props.CFrame = CFrame.new(a.CFrame.Position) * CFrame.fromOrientation(math.rad(v.X), math.rad(v.Y), math.rad(v.Z)) end)

-- ===== interfaces =====
local function tweenGui(self, props)
	for k, v in pairs(props) do self[k] = v end
	return true
end
methode("GuiObject", "TweenPosition", function(self, p) return tweenGui(self, { Position = p }) end)
methode("GuiObject", "TweenSize", function(self, s) return tweenGui(self, { Size = s }) end)
methode("GuiObject", "TweenSizeAndPosition", function(self, s, p) return tweenGui(self, { Size = s, Position = p }) end)
methode("TextBox", "CaptureFocus", function() end)
methode("TextBox", "ReleaseFocus", function() end)
methode("TextBox", "IsFocused", function() return false end)
methode("GuiObject", "IsA", function(self, nom) return estA(donnees[self].classe, nom) end)
methode("ScrollingFrame", "ScrollToTop", function() end)

-- ===== sons, particules =====
methode("Sound", "Play", function(self)
	donnees[self].props.Playing = true
	donnees[self].props.IsPlaying = true
	banc.sons = (banc.sons or 0) + 1
	signalSiExiste(self, "Played", self.SoundId)
	if not self.Looped then
		task.delay(self.TimeLength, function()
			if donnees[self].detruite then return end
			donnees[self].props.Playing = false
			donnees[self].props.IsPlaying = false
			signalSiExiste(self, "Ended", self.SoundId)
		end)
	end
end)
methode("Sound", "Stop", function(self) donnees[self].props.Playing = false donnees[self].props.IsPlaying = false signalSiExiste(self, "Stopped", self.SoundId) end)
methode("Sound", "Pause", function(self) donnees[self].props.Playing = false donnees[self].props.IsPlaying = false end)
methode("Sound", "Resume", function(self) donnees[self].props.Playing = true donnees[self].props.IsPlaying = true end)
methode("ParticleEmitter", "Emit", function(self, n) banc.particules = (banc.particules or 0) + (n or 16) end)
methode("ParticleEmitter", "Clear", function() end)

-- ===== événements réseau et locaux =====
local joueursClients = function() return banc.joueurs end
methode("RemoteEvent", "FireServer", function(self, ...)
	if banc.cote() ~= "client" then error("FireServer ne peut être appelé que depuis le client", 2) end
	banc.compter("remote:" .. self.Name)
	banc.envoyer(function(...) obtenirSignal(self, "OnServerEvent"):Fire(...) end, "serveur", banc.joueurLocal, ...)
end)
methode("RemoteEvent", "FireClient", function(self, joueur, ...)
	if banc.cote() ~= "serveur" then error("FireClient ne peut être appelé que depuis le serveur", 2) end
	if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then error("FireClient : Player attendu en premier argument", 2) end
	banc.compter("remote:" .. self.Name)
	if joueur == banc.joueurLocal then
		banc.envoyer(function(...) obtenirSignal(self, "OnClientEvent"):Fire(...) end, "client", ...)
	end
end)
methode("RemoteEvent", "FireAllClients", function(self, ...)
	if banc.cote() ~= "serveur" then error("FireAllClients ne peut être appelé que depuis le serveur", 2) end
	banc.compter("remote:" .. self.Name)
	if banc.joueurLocal then
		banc.envoyer(function(...) obtenirSignal(self, "OnClientEvent"):Fire(...) end, "client", ...)
	end
end)
PARENTS.UnreliableRemoteEvent = "RemoteEvent"
methode("RemoteFunction", "InvokeServer", function(self, ...)
	local f = donnees[self].props.OnServerInvoke
	if not f then error("OnServerInvoke non défini", 2) end
	return f(banc.joueurLocal, ...)
end)
methode("RemoteFunction", "InvokeClient", function(self, j, ...)
	local f = donnees[self].props.OnClientInvoke
	if not f then return nil end
	return f(...)
end)
methode("BindableEvent", "Fire", function(self, ...) obtenirSignal(self, "Event"):Fire(...) end)
methode("BindableFunction", "Invoke", function(self, ...)
	local f = donnees[self].props.OnInvoke
	if not f then error("OnInvoke non défini", 2) end
	return f(...)
end)
EVENEMENTS.OnServerInvoke = nil

-- ===== humanoïde =====
methode("Humanoid", "TakeDamage", function(self, n)
	self.Health = math.max(0, self.Health - n)
	signalSiExiste(self, "HealthChanged", self.Health)
	if self.Health <= 0 then signalSiExiste(self, "Died") end
end)
methode("Humanoid", "MoveTo", function(self, p) signalSiExiste(self, "MoveToFinished", true) end)
methode("Humanoid", "ChangeState", function() end)
methode("Humanoid", "GetState", function() return Enum.HumanoidStateType.Running end)
methode("Humanoid", "SetStateEnabled", function() end)
methode("Humanoid", "Move", function() end)
methode("Humanoid", "UnequipTools", function() end)
methode("Humanoid", "EquipTool", function() end)
methode("Humanoid", "GetPlayingAnimationTracks", function() return {} end)
local function piste()
	local t = { Length = 1, IsPlaying = false, Speed = 1, Looped = false, Priority = Enum.AnimationPriority.Action, TimePosition = 0, WeightCurrent = 1 }
	t.Play = function(s) s.IsPlaying = true end
	t.Stop = function(s) s.IsPlaying = false end
	t.AdjustSpeed = function() end
	t.AdjustWeight = function() end
	t.GetMarkerReachedSignal = function() return banc.signal("Marker") end
	t.Stopped = banc.signal("Stopped")
	t.Ended = banc.signal("Ended")
	t.KeyframeReached = banc.signal("KeyframeReached")
	t.DidLoop = banc.signal("DidLoop")
	return t
end
methode("Humanoid", "LoadAnimation", function() return piste() end)
methode("Animator", "LoadAnimation", function() return piste() end)

-- ===== Instance.new =====
Instance = {}
function Instance.new(classe, parent)
	if type(classe) ~= "string" then error("Instance.new : nom de classe attendu", 2) end
	if not CREABLES[classe] then error("Unable to create an Instance of type \"" .. classe .. "\"", 2) end
	local inst = nouvelle(classe)
	if classe == "Model" then
		-- rien de plus
	end
	if parent ~= nil then inst.Parent = parent end
	banc.compter("new:" .. classe)
	return inst
end
function Instance.fromExisting(i) return i:Clone() end
