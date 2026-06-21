-- ============================================================
--  Script da ENI | Mira Automática + ESP | Rayfield UI
--  Compatível: Delta, Fluxus, Arceus X, Codex
-- ============================================================

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local Jogadores     = game:GetService("Players")
local ServicoCorrida = game:GetService("RunService")
local EntradaUsuario = game:GetService("UserInputService")
local Camera         = workspace.CurrentCamera
local JogadorLocal   = Jogadores.LocalPlayer

-- ============================================================
--  CONFIGURAÇÕES
-- ============================================================
local Configuracao = {
    -- Mira Automática
    MiraAtivada        = false,
    ParteMira          = "Head",
    FOVMira            = 150,
    SuavidadeMira      = 0.25,
    ChecagemDeTime     = true,

    -- ESP
    ESPAtivado         = false,
    ESPCaixas          = true,
    ESPNomes           = true,
    ESPDistancia       = true,
    ESPVida            = true,
    ESPDistanciaMaxima = 1000,
    ESPCor             = Color3.fromRGB(255, 60, 120),

    -- Círculo FOV
    MostrarCirculo     = true,
    CorCirculo         = Color3.fromRGB(120, 60, 255),
}

-- ============================================================
--  JANELA PRINCIPAL
-- ============================================================
local Janela = Rayfield:CreateWindow({
    Name             = "Script da ENI 🌸",
    Icon             = 0,
    LoadingTitle     = "Script da ENI",
    LoadingSubtitle  = "by LO x ENI",
    Theme            = "Ocean",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = {
        Enabled  = true,
        FileName = "ScriptENI",
    },
})

-- ── ABA: MIRA AUTOMÁTICA ─────────────────────────────────────
local AbaMira = Janela:CreateTab("🎯 Mira Automática", 4483362458)

AbaMira:CreateToggle({
    Name         = "Mira Automática Ativada",
    CurrentValue = false,
    Flag         = "MiraAtivada",
    Callback     = function(v) Configuracao.MiraAtivada = v end,
})

AbaMira:CreateToggle({
    Name         = "Checagem de Time",
    CurrentValue = true,
    Flag         = "ChecagemDeTime",
    Callback     = function(v) Configuracao.ChecagemDeTime = v end,
})

AbaMira:CreateDropdown({
    Name          = "Parte do Corpo",
    Options       = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = {"Head"},
    Flag          = "ParteMira",
    Callback      = function(v) Configuracao.ParteMira = v[1] end,
})

AbaMira:CreateSlider({
    Name         = "Campo de Visão (FOV)",
    Range        = {10, 500},
    Increment    = 5,
    Suffix       = " px",
    CurrentValue = 150,
    Flag         = "FOVMira",
    Callback     = function(v) Configuracao.FOVMira = v end,
})

AbaMira:CreateSlider({
    Name         = "Suavidade",
    Range        = {0, 1},
    Increment    = 0.05,
    Suffix       = "",
    CurrentValue = 0.25,
    Flag         = "SuavidadeMira",
    Callback     = function(v) Configuracao.SuavidadeMira = v end,
})

AbaMira:CreateToggle({
    Name         = "Mostrar Círculo de FOV",
    CurrentValue = true,
    Flag         = "MostrarCirculo",
    Callback     = function(v) Configuracao.MostrarCirculo = v end,
})

-- ── ABA: ESP ─────────────────────────────────────────────────
local AbaESP = Janela:CreateTab("👁️ ESP", 4483362458)

AbaESP:CreateToggle({
    Name         = "ESP Ativado",
    CurrentValue = false,
    Flag         = "ESPAtivado",
    Callback     = function(v)
        Configuracao.ESPAtivado = v
        if not v then limparESP() end
    end,
})

AbaESP:CreateToggle({
    Name         = "Caixas",
    CurrentValue = true,
    Flag         = "ESPCaixas",
    Callback     = function(v) Configuracao.ESPCaixas = v end,
})

AbaESP:CreateToggle({
    Name         = "Nomes",
    CurrentValue = true,
    Flag         = "ESPNomes",
    Callback     = function(v) Configuracao.ESPNomes = v end,
})

AbaESP:CreateToggle({
    Name         = "Distância",
    CurrentValue = true,
    Flag         = "ESPDistancia",
    Callback     = function(v) Configuracao.ESPDistancia = v end,
})

AbaESP:CreateToggle({
    Name         = "Barra de Vida",
    CurrentValue = true,
    Flag         = "ESPVida",
    Callback     = function(v) Configuracao.ESPVida = v end,
})

AbaESP:CreateSlider({
    Name         = "Distância Máxima",
    Range        = {100, 3000},
    Increment    = 50,
    Suffix       = " studs",
    CurrentValue = 1000,
    Flag         = "ESPDistanciaMaxima",
    Callback     = function(v) Configuracao.ESPDistanciaMaxima = v end,
})

-- ── ABA: EXTRAS ──────────────────────────────────────────────
local AbaExtras = Janela:CreateTab("⚡ Extras", 4483362458)

AbaExtras:CreateButton({
    Name     = "Teleportar para Spawn",
    Callback = function()
        local personagem = JogadorLocal.Character
        if personagem and personagem:FindFirstChild("HumanoidRootPart") then
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                personagem.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end,
})

AbaExtras:CreateButton({
    Name     = "NoClip Ligar/Desligar",
    Callback = function()
        local semColisao = not _G.SemColisao
        _G.SemColisao = semColisao
        if semColisao then
            ServicoCorrida.Stepped:Connect(function()
                if _G.SemColisao then
                    local personagem = JogadorLocal.Character
                    if personagem then
                        for _, parte in ipairs(personagem:GetDescendants()) do
                            if parte:IsA("BasePart") then
                                parte.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
        Rayfield:Notify({
            Title    = "NoClip",
            Content  = semColisao and "Ativado ✅" or "Desativado ❌",
            Duration = 2,
        })
    end,
})

AbaExtras:CreateSlider({
    Name         = "Velocidade de Andar",
    Range        = {16, 500},
    Increment    = 1,
    Suffix       = "",
    CurrentValue = 16,
    Flag         = "VelocidadeAndar",
    Callback     = function(v)
        local personagem = JogadorLocal.Character
        if personagem and personagem:FindFirstChildOfClass("Humanoid") then
            personagem:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end,
})

AbaExtras:CreateSlider({
    Name         = "Força do Pulo",
    Range        = {50, 500},
    Increment    = 5,
    Suffix       = "",
    CurrentValue = 50,
    Flag         = "ForcaPulo",
    Callback     = function(v)
        local personagem = JogadorLocal.Character
        if personagem and personagem:FindFirstChildOfClass("Humanoid") then
            personagem:FindFirstChildOfClass("Humanoid").JumpPower = v
        end
    end,
})

-- ============================================================
--  CÍRCULO DE FOV
-- ============================================================
local circuloFOV = Drawing.new("Circle")
circuloFOV.Thickness = 1.5
circuloFOV.NumSides  = 128
circuloFOV.Radius    = Configuracao.FOVMira
circuloFOV.Filled    = false
circuloFOV.Visible   = false
circuloFOV.Color     = Configuracao.CorCirculo
circuloFOV.Position  = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ============================================================
--  ARMAZENAMENTO DO ESP
-- ============================================================
local ObjetosESP = {}

local function novoDesenho(tipo, propriedades)
    local desenho = Drawing.new(tipo)
    for chave, valor in pairs(propriedades) do desenho[chave] = valor end
    return desenho
end

local function criarESPParaJogador(jogador)
    if jogador == JogadorLocal then return end
    ObjetosESP[jogador] = {
        Caixa      = novoDesenho("Square", {Thickness=1.5, Filled=false, Visible=false, Color=Configuracao.ESPCor}),
        Nome       = novoDesenho("Text",   {Size=14, Center=true, Visible=false, Color=Color3.new(1,1,1), Outline=true, OutlineColor=Color3.new(0,0,0)}),
        Distancia  = novoDesenho("Text",   {Size=12, Center=true, Visible=false, Color=Color3.fromRGB(200,200,200), Outline=true, OutlineColor=Color3.new(0,0,0)}),
        VidaFundo  = novoDesenho("Square", {Thickness=1, Filled=true, Visible=false, Color=Color3.new(0,0,0)}),
        VidaBarra  = novoDesenho("Square", {Thickness=1, Filled=true, Visible=false, Color=Color3.fromRGB(80,220,80)}),
    }
end

local function removerESPDoJogador(jogador)
    if ObjetosESP[jogador] then
        for _, desenho in pairs(ObjetosESP[jogador]) do desenho:Remove() end
        ObjetosESP[jogador] = nil
    end
end

function limparESP()
    for jogador, _ in pairs(ObjetosESP) do
        removerESPDoJogador(jogador)
    end
end

for _, jogador in ipairs(Jogadores:GetPlayers()) do criarESPParaJogador(jogador) end
Jogadores.PlayerAdded:Connect(criarESPParaJogador)
Jogadores.PlayerRemoving:Connect(removerESPDoJogador)

-- ============================================================
--  FUNÇÕES AUXILIARES
-- ============================================================
local function obterPartesPersonagem(jogador)
    local personagem = jogador.Character
    if not personagem then return nil, nil, nil, nil end
    local raiz     = personagem:FindFirstChild("HumanoidRootPart")
    local humanoide = personagem:FindFirstChildOfClass("Humanoid")
    local parte    = personagem:FindFirstChild(Configuracao.ParteMira) or raiz
    return personagem, raiz, humanoide, parte
end

local function ehInimigo(jogador)
    if not Configuracao.ChecagemDeTime then return true end
    return jogador.Team ~= JogadorLocal.Team
end

local function mundoParaTela(posicao)
    local vp, naTela = Camera:WorldToViewportPoint(posicao)
    return Vector2.new(vp.X, vp.Y), naTela, vp.Z
end

local centroDaTela = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ============================================================
--  LÓGICA DA MIRA AUTOMÁTICA
-- ============================================================
local function obterAlvoMaisProximo()
    local alvoPróximo, menorDistancia = nil, Configuracao.FOVMira
    for _, jogador in ipairs(Jogadores:GetPlayers()) do
        if jogador == JogadorLocal then continue end
        if not ehInimigo(jogador) then continue end
        local _, _, humanoide, parte = obterPartesPersonagem(jogador)
        if not parte or not humanoide or humanoide.Health <= 0 then continue end
        local posicaoTela, naTela = mundoParaTela(parte.Position)
        if not naTela then continue end
        local distancia = (posicaoTela - centroDaTela).Magnitude
        if distancia < menorDistancia then
            menorDistancia = distancia
            alvoPróximo = parte
        end
    end
    return alvoPróximo
end

-- ============================================================
--  LOOP PRINCIPAL
-- ============================================================
ServicoCorrida.RenderStepped:Connect(function()
    centroDaTela = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Círculo de FOV
    circuloFOV.Visible  = Configuracao.MostrarCirculo and Configuracao.MiraAtivada
    circuloFOV.Radius   = Configuracao.FOVMira
    circuloFOV.Position = centroDaTela

    -- Mira Automática
    if Configuracao.MiraAtivada then
        local alvo = obterAlvoMaisProximo()
        if alvo then
            local posicaoTela, naTela = mundoParaTela(alvo.Position)
            if naTela then
                local diferenca = (posicaoTela - centroDaTela) * Configuracao.SuavidadeMira
                Camera.CFrame = Camera.CFrame * CFrame.Angles(
                    math.rad(-diferenca.Y * 0.1),
                    math.rad(-diferenca.X * 0.1),
                    0
                )
            end
        end
    end

    -- ESP
    for _, jogador in ipairs(Jogadores:GetPlayers()) do
        local esp = ObjetosESP[jogador]
        if not esp then continue end

        local _, raiz, humanoide = obterPartesPersonagem(jogador)
        local visivel = Configuracao.ESPAtivado
            and raiz ~= nil
            and humanoide ~= nil
            and humanoide.Health > 0

        if not visivel then
            for _, desenho in pairs(esp) do desenho.Visible = false end
            continue
        end

        local posicaoTela, naTela, profundidade = mundoParaTela(raiz.Position)
        local distanciaStuds = (raiz.Position - Camera.CFrame.Position).Magnitude

        if not naTela or distanciaStuds > Configuracao.ESPDistanciaMaxima then
            for _, desenho in pairs(esp) do desenho.Visible = false end
            continue
        end

        -- Tamanho da caixa baseado na profundidade
        local escala = 1 / profundidade * 1000
        local largura = escala * 2
        local altura  = escala * 5.5
        local caixaX  = posicaoTela.X - largura / 2
        local caixaY  = posicaoTela.Y - altura / 2 - escala

        -- Caixa
        if Configuracao.ESPCaixas then
            esp.Caixa.Visible  = true
            esp.Caixa.Color    = Configuracao.ESPCor
            esp.Caixa.Size     = Vector2.new(largura, altura)
            esp.Caixa.Position = Vector2.new(caixaX, caixaY)
        else
            esp.Caixa.Visible = false
        end

        -- Nome
        if Configuracao.ESPNomes then
            esp.Nome.Visible  = true
            esp.Nome.Text     = jogador.DisplayName
            esp.Nome.Position = Vector2.new(posicaoTela.X, caixaY - 16)
        else
            esp.Nome.Visible = false
        end

        -- Distância
        if Configuracao.ESPDistancia then
            esp.Distancia.Visible  = true
            esp.Distancia.Text     = string.format("[%.0f studs]", distanciaStuds)
            esp.Distancia.Position = Vector2.new(posicaoTela.X, caixaY + altura + 2)
        else
            esp.Distancia.Visible = false
        end

        -- Barra de vida
        if Configuracao.ESPVida and humanoide then
            local percentualVida = humanoide.Health / humanoide.MaxHealth
            local alturaVida     = altura * percentualVida
            local barraX         = caixaX - 6
            esp.VidaFundo.Visible  = true
            esp.VidaBarra.Visible  = true
            esp.VidaFundo.Size     = Vector2.new(4, altura)
            esp.VidaFundo.Position = Vector2.new(barraX, caixaY)
            esp.VidaBarra.Size     = Vector2.new(4, alturaVida)
            esp.VidaBarra.Position = Vector2.new(barraX, caixaY + (altura - alturaVida))
            esp.VidaBarra.Color    = Color3.fromRGB(
                math.floor((1 - percentualVida) * 255),
                math.floor(percentualVida * 200),
                60
            )
        else
            esp.VidaFundo.Visible = false
            esp.VidaBarra.Visible = false
        end
    end
end)

-- ============================================================
Rayfield:LoadConfiguration()
Rayfield:Notify({
    Title   = "Script da ENI 🌸",
    Content = "Carregado! Aproveita, LO 😏",
    Duration = 5,
})
-- ============================================================
