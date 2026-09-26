-- Bus d'événements local (une copie côté serveur, une autre côté client) : les modules communiquent sans se connaître.
-- Bus.ecouter(nom, fn) / Bus.emettre(nom, ...) : notifications.
-- Bus.repondre(nom, fn) / Bus.demander(nom, ...) : questions (un seul répondeur par nom).
local Bus = {}
local ecouteurs = {}
local repondeurs = {}

function Bus.ecouter(nom, fn)
	ecouteurs[nom] = ecouteurs[nom] or {}
	table.insert(ecouteurs[nom], fn)
	return {
		Disconnect = function()
			local liste = ecouteurs[nom]
			for i = #liste, 1, -1 do
				if liste[i] == fn then table.remove(liste, i) end
			end
		end,
	}
end

function Bus.emettre(nom, ...)
	local liste = ecouteurs[nom]
	if not liste then return end
	local copie = {}
	for i, fn in ipairs(liste) do copie[i] = fn end
	for _, fn in ipairs(copie) do
		local ok, err = pcall(fn, ...)
		if not ok then warn("[Zsurvie] écouteur de « " .. nom .. " » : " .. tostring(err)) end
	end
end

function Bus.repondre(nom, fn)
	repondeurs[nom] = fn
end

function Bus.demander(nom, ...)
	local fn = repondeurs[nom]
	if not fn then return nil end
	local resultat = table.pack(pcall(fn, ...))
	if not resultat[1] then
		warn("[Zsurvie] répondeur de « " .. nom .. " » : " .. tostring(resultat[2]))
		return nil
	end
	return table.unpack(resultat, 2, resultat.n)
end

return Bus
