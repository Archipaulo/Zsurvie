-- Banc d'essai : export de l'interface (ScreenGui du joueur local) avec une mise en page calculée
-- comme Roblox (UDim2, AnchorPoint, UIListLayout, UIGridLayout, UIPadding, contraintes) pour l'aperçu HTML.
local banc = BANC

local ECRAN = { 0, 0, 1280, 720 }

local function hex(c)
	if typeof(c) ~= "Color3" then return nil end
	return "#" .. c:ToHex()
end

local function enfantDeClasse(o, classe)
	for _, e in ipairs(o:GetChildren()) do
		if e.ClassName == classe then return e end
	end
	return nil
end

local function udim(u, total) return u.Scale * total + u.Offset end

local function degrade(o)
	local g = enfantDeClasse(o, "UIGradient")
	if not g or g.Enabled == false then return nil end
	local pts = {}
	for _, k in ipairs(g.Color.Keypoints) do table.insert(pts, { k.Time, hex(k.Value) }) end
	return { rotation = g.Rotation, points = pts, anime = g:GetAttribute("Anime") }
end

local function contours(o)
	local texte, bord
	for _, e in ipairs(o:GetChildren()) do
		if e.ClassName == "UIStroke" and e.Enabled ~= false then
			local d = { couleur = hex(e.Color), epaisseur = e.Thickness, transparence = e.Transparency }
			if e.ApplyStrokeMode == Enum.ApplyStrokeMode.Border then bord = d
			elseif o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then texte = d
			else bord = d end
		end
	end
	return texte, bord
end

local function echelle(o)
	local s = 1
	for _, e in ipairs(o:GetChildren()) do
		if e.ClassName == "UIScale" then s = s * e.Scale end
	end
	return s
end

-- taille propre d'un objet dans un rectangle parent (sans position)
local function taille(o, pw, ph)
	local s = o.Size
	local w, h = udim(s.X, pw), udim(s.Y, ph)
	local ar = enfantDeClasse(o, "UIAspectRatioConstraint")
	if ar and ar.AspectRatio > 0 then
		if w / math.max(h, 1) > ar.AspectRatio then w = h * ar.AspectRatio else h = w / ar.AspectRatio end
	end
	local sc = enfantDeClasse(o, "UISizeConstraint")
	if sc then
		w = math.max(sc.MinSize.X, math.min(sc.MaxSize.X, w))
		h = math.max(sc.MinSize.Y, math.min(sc.MaxSize.Y, h))
	end
	return w, h
end

local function visible(o)
	if o:IsA("GuiObject") then return o.Visible end
	if o:IsA("LayerCollector") then return o.Enabled end
	return true
end

local function tailleTexte(o, w, h)
	local texte = tostring(o.Text or "")
	texte = string.gsub(texte, "<[^>]+>", "")
	local n = math.max(utf8.len(texte) or #texte, 1)
	local lignes = 1
	for _ in string.gmatch(texte, "\n") do lignes = lignes + 1 end
	if o.TextScaled then
		local max = 100
		local c = enfantDeClasse(o, "UITextSizeConstraint")
		if c then max = c.MaxTextSize end
		local parLigne = math.ceil(n / lignes)
		local t = math.min(h / lignes * 0.9, w / (parLigne * 0.56))
		return math.max(6, math.min(max, t))
	end
	return o.TextSize
end

local noeud
noeud = function(o, px, py, pw, ph)
	-- (px, py, pw, ph) : rectangle absolu du contenu du parent ; renvoie la description de o
	local w, h = taille(o, pw, ph)
	local x = px + udim(o.Position.X, pw) - o.AnchorPoint.X * w
	local y = py + udim(o.Position.Y, ph) - o.AnchorPoint.Y * h
	return x, y, w, h
end

local function decrire(o, x, y, w, h)
	local s = echelle(o)
	if s ~= 1 then
		local cx, cy = x + w / 2, y + h / 2
		w, h = w * s, h * s
		x, y = cx - w / 2, cy - h / 2
	end
	local d = { c = o.ClassName, n = o.Name, x = x, y = y, w = w, h = h, z = o.ZIndex or 1, e = {} }
	d.bg = hex(o.BackgroundColor3)
	d.bgT = o.BackgroundTransparency
	local coin = enfantDeClasse(o, "UICorner")
	if coin then d.rayon = coin.CornerRadius.Scale * math.min(w, h) + coin.CornerRadius.Offset end
	d.grad = degrade(o)
	local ct, cb = contours(o)
	d.contourTexte, d.bordure = ct, cb
	if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
		d.texte = tostring(o.Text or "")
		d.couleurTexte = hex(o.TextColor3)
		d.tt = o.TextTransparency
		d.police = o.Font and o.Font.Name or "SourceSans"
		d.taille = tailleTexte(o, w, h)
		d.ax = o.TextXAlignment and o.TextXAlignment.Name or "Center"
		d.ay = o.TextYAlignment and o.TextYAlignment.Name or "Center"
		d.wrap = o.TextWrapped or o.TextScaled
		if o.TextStrokeTransparency < 1 and not ct then
			d.contourTexte = { couleur = hex(o.TextStrokeColor3), epaisseur = 1.5, transparence = o.TextStrokeTransparency }
		end
	end
	if o:IsA("ImageLabel") or o:IsA("ImageButton") then
		d.image = o.Image
		d.imageCouleur = hex(o.ImageColor3)
	end
	if o.ClipsDescendants or o:IsA("ScrollingFrame") then d.clip = true end
	return d
end

local function exporterEnfants(parent, dParent, cx, cy, cw, ch)
	-- rectangle de contenu après UIPadding
	local pad = enfantDeClasse(parent, "UIPadding")
	if pad then
		local l, r = udim(pad.PaddingLeft, cw), udim(pad.PaddingRight, cw)
		local t, b = udim(pad.PaddingTop, ch), udim(pad.PaddingBottom, ch)
		cx, cy, cw, ch = cx + l, cy + t, cw - l - r, ch - t - b
	end
	if parent:IsA("ScrollingFrame") then
		local cs = parent.CanvasSize
		ch = math.max(ch, udim(cs.Y, ch))
	end
	local enfants = {}
	for _, e in ipairs(parent:GetChildren()) do
		if e:IsA("GuiObject") and visible(e) then table.insert(enfants, e) end
	end
	local liste = enfantDeClasse(parent, "UIListLayout")
	local grille = enfantDeClasse(parent, "UIGridLayout")
	local layout = liste or grille
	if layout then
		table.sort(enfants, function(a, b)
			if layout.SortOrder == Enum.SortOrder.Name then return a.Name < b.Name end
			if a.LayoutOrder ~= b.LayoutOrder then return a.LayoutOrder < b.LayoutOrder end
			return a.Name < b.Name
		end)
	end
	local rects = {}
	if liste then
		local vertical = liste.FillDirection ~= Enum.FillDirection.Horizontal
		local pad2 = udim(liste.Padding, vertical and ch or cw)
		local total = 0
		local tailles = {}
		for i, e in ipairs(enfants) do
			local w, h = taille(e, cw, ch)
			tailles[i] = { w, h }
			total = total + (vertical and h or w) + (i > 1 and pad2 or 0)
		end
		local curseur
		if vertical then
			curseur = cy
			if liste.VerticalAlignment == Enum.VerticalAlignment.Center then curseur = cy + (ch - total) / 2
			elseif liste.VerticalAlignment == Enum.VerticalAlignment.Bottom then curseur = cy + ch - total end
		else
			curseur = cx
			if liste.HorizontalAlignment == Enum.HorizontalAlignment.Center then curseur = cx + (cw - total) / 2
			elseif liste.HorizontalAlignment == Enum.HorizontalAlignment.Right then curseur = cx + cw - total end
		end
		for i, e in ipairs(enfants) do
			local w, h = tailles[i][1], tailles[i][2]
			local x, y
			if vertical then
				y = curseur
				x = cx
				if liste.HorizontalAlignment == Enum.HorizontalAlignment.Center then x = cx + (cw - w) / 2
				elseif liste.HorizontalAlignment == Enum.HorizontalAlignment.Right then x = cx + cw - w end
				curseur = curseur + h + pad2
			else
				x = curseur
				y = cy
				if liste.VerticalAlignment == Enum.VerticalAlignment.Center then y = cy + (ch - h) / 2
				elseif liste.VerticalAlignment == Enum.VerticalAlignment.Bottom then y = cy + ch - h end
				curseur = curseur + w + pad2
			end
			rects[i] = { x, y, w, h }
		end
	elseif grille then
		local cwid, chei = udim(grille.CellSize.X, cw), udim(grille.CellSize.Y, ch)
		local pxp, pyp = udim(grille.CellPadding.X, cw), udim(grille.CellPadding.Y, ch)
		local parLigne = math.max(1, math.floor((cw + pxp) / (cwid + pxp)))
		if grille.FillDirectionMaxCells and grille.FillDirectionMaxCells > 0 then parLigne = math.min(parLigne, grille.FillDirectionMaxCells) end
		local largeurLigne = parLigne * cwid + (parLigne - 1) * pxp
		local x0 = cx
		if grille.HorizontalAlignment == Enum.HorizontalAlignment.Center then x0 = cx + (cw - largeurLigne) / 2
		elseif grille.HorizontalAlignment == Enum.HorizontalAlignment.Right then x0 = cx + cw - largeurLigne end
		for i, e in ipairs(enfants) do
			local col = (i - 1) % parLigne
			local lig = math.floor((i - 1) / parLigne)
			rects[i] = { x0 + col * (cwid + pxp), cy + lig * (chei + pyp), cwid, chei }
		end
	else
		for i, e in ipairs(enfants) do
			local x, y, w, h = noeud(e, cx, cy, cw, ch)
			rects[i] = { x, y, w, h }
		end
	end
	for i, e in ipairs(enfants) do
		local r = rects[i]
		local d = decrire(e, r[1], r[2], r[3], r[4])
		table.insert(dParent.e, d)
		exporterEnfants(e, d, d.x, d.y, d.w, d.h)
	end
end

function EXPORTER_UI(nom)
	local j = banc.joueurLocal
	if not j then return end
	local pg = j:FindFirstChild("PlayerGui")
	if not pg then return end
	local racine = { c = "Ecran", x = 0, y = 0, w = ECRAN[3], h = ECRAN[4], e = {} }
	for _, g in ipairs(pg:GetChildren()) do
		if g:IsA("ScreenGui") and g.Enabled then
			local d = { c = "ScreenGui", n = g.Name, x = 0, y = 0, w = ECRAN[3], h = ECRAN[4], z = g.DisplayOrder or 0, e = {} }
			local inset = g.IgnoreGuiInset and 0 or 36
			exporterEnfants(g, d, 0, inset, ECRAN[3], ECRAN[4] - inset)
			table.insert(racine.e, d)
		end
	end
	__ecrire("ui-" .. nom, banc.json(racine))
end
