-- ⚠️ Script educacional para estudo de automação no Roblox - Blox Fruits

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Tela de carregamento
local loadingScreen = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
loadingScreen.Name = "LoadingScreen"

local loadingFrame = Instance.new("Frame", loadingScreen)
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local loadingText = Instance.new("TextLabel", loadingFrame)
loadingText.Size = UDim2.new(1, 0, 0, 50)
loadingText.Position = UDim2.new(0, 0, 0, 0)
loadingText.Text = "GPT Hub"
loadingText.TextColor3 = Color3.new(1, 1, 1)
loadingText.TextSize = 36
loadingText.BackgroundTransparency = 1
loadingText.TextScaled = true
loadingText.TextAlignment = Enum.TextAlignment.Center
loadingText.Font = Enum.Font.GothamBold

-- Remover a tela de carregamento após 5 segundos
wait(5)
loadingScreen:Destroy()

-- A seguir, o código do script original

getgenv().config = getgenv().config or {
    frutaSelecionada = "Flame",
    delayEntreRaids = 10,
    girarIntervalo = 60  -- Intervalo em segundos para girar as frutas automaticamente
}

local frutaValores = {
    ["Spin-Spin"] = 180000,
    ["Bomb-Bomb"] = 50000,
    ["Chop-Chop"] = 30000,
    ["Magma-Magma"] = 850000,
    ["Dark-Dark"] = 500000,
    ["Light-Light"] = 650000,
    ["Ice-Ice"] = 350000,
    ["Flame-Flame"] = 250000,
    ["Buddha-Buddha"] = 1200000
}

local raidsDisponiveis = {"Flame", "Ice", "Light", "Magma", "Dark"}
local raidRodando = false
local modoAuto = false
local girarFrutasAtivo = false

-- 🖥 GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "AutoRaidGui"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 360, 0, 500)
frame.Position = UDim2.new(0.5, -180, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local titulo = Instance.new("TextLabel", frame)
titulo.Size = UDim2.new(1, 0, 0, 40)
titulo.Text = "🌀 Auto Raid System"
titulo.TextColor3 = Color3.new(1, 1, 1)
titulo.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titulo.TextScaled = true

local dropdownBtn = Instance.new("TextButton", frame)
dropdownBtn.Size = UDim2.new(1, -20, 0, 40)
dropdownBtn.Position = UDim2.new(0, 10, 0, 50)
dropdownBtn.Text = "Selecionar Raid: " .. getgenv().config.frutaSelecionada
dropdownBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
dropdownBtn.TextColor3 = Color3.new(1, 1, 1)
dropdownBtn.TextScaled = true

local dropdownFrame = Instance.new("Frame", frame)
dropdownFrame.Size = UDim2.new(1, -20, 0, #raidsDisponiveis * 30)
dropdownFrame.Position = UDim2.new(0, 10, 0, 90)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownFrame.Visible = false
dropdownFrame.ClipsDescendants = true

for i, fruitName in ipairs(raidsDisponiveis) do
    local option = Instance.new("TextButton", dropdownFrame)
    option.Size = UDim2.new(1, 0, 0, 30)
    option.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
    option.Text = fruitName
    option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    option.TextColor3 = Color3.new(1, 1, 1)
    option.TextScaled = true
    option.MouseButton1Click:Connect(function()
        getgenv().config.frutaSelecionada = fruitName
        dropdownBtn.Text = "Selecionar Raid: " .. fruitName
        dropdownFrame.Visible = false
    end)
end

dropdownBtn.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Log
local logFrame = Instance.new("ScrollingFrame", frame)
logFrame.Size = UDim2.new(1, -20, 0, 120)
logFrame.Position = UDim2.new(0, 10, 0, dropdownFrame.Position.Y.Offset + dropdownFrame.Size.Y.Offset + 10)
logFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
logFrame.ScrollBarThickness = 5
logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local function log(txt)
    local label = Instance.new("TextLabel", logFrame)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, #logFrame:GetChildren() * 20)
    label.Text = "• " .. txt
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextScaled = false
    label.TextXAlignment = Enum.TextXAlignment.Left
    logFrame.CanvasSize = UDim2.new(0, 0, 0, label.Position.Y.Offset + 25)
end

-- Botões
local yBase = logFrame.Position.Y.Offset + logFrame.Size.Y.Offset + 10
local function criarBotao(txt, y, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local btnDescartar = criarBotao("🗑️ Descartar Frutas < 1M", yBase, function()
    local frutas = ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventoryFruits")
    for _, fruta in pairs(frutas) do
        local nome = fruta[1]
        local valor = frutaValores[nome] or 0
        if valor < 1000000 then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("RemoveFromInventory", nome)
            log("Descartado: " .. nome)
            wait(0.5)
        end
    end
end)

local btnRaid = criarBotao("▶️ Iniciar Raid", btnDescartar.Position.Y.Offset + 50, function()
    if not raidRodando then
        coroutine.wrap(function()
            raidRodando = true
            repeat
                log("Iniciando raid de " .. getgenv().config.frutaSelecionada)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", getgenv().config.frutaSelecionada)
                wait(3)

                while #workspace.Enemies:GetChildren() > 0 and raidRodando do
                    for _, inimigo in pairs(workspace.Enemies:GetChildren()) do
                        if inimigo:FindFirstChild("Humanoid") and inimigo.Humanoid.Health > 0 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = inimigo.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Skill", "Z")
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Skill", "X")
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Skill", "C")
                        end
                        wait(0.3)
                    end
                    wait(1)
                end

                log("Raid finalizada. Aguardando " .. getgenv().config.delayEntreRaids .. "s...")
                wait(getgenv().config.delayEntreRaids)

            until not modoAuto or not raidRodando
            log("Loop de raid encerrado.")
        end)()
    end
end)

local btnParar = criarBotao("⏹️ Parar Raid", btnRaid.Position.Y.Offset + 50, function()
    raidRodando = false
    modoAuto = false
    log("Raid interrompida.")
end)

local btnAuto = criarBotao("🔁 Modo Auto: OFF", btnParar.Position.Y.Offset + 50, function()
    modoAuto = not modoAuto
    btnAuto.Text = "🔁 Modo Auto: " .. (modoAuto and "ON" or "OFF")
    log("Modo automático " .. (modoAuto and "ativado." or "desativado."))
end)

local btnFechar = criarBotao("❌ Fechar GUI", btnAuto.Position.Y.Offset + 50, function()
    raidRodando = false
    modoAuto = false
    girarFrutasAtivo = false
    gui:Destroy()
end)

-- 🌀 Função para girar as frutas automaticamente
local function girarFrutas()
    while girarFrutasAtivo do
        local frutas = ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventoryFruits")
        for _, fruta in pairs(frutas) do
            local nome = fruta[1]
            local valor = frutaValores[nome] or 0
            if valor >= 1000000 then
                log("Girando fruta: " .. nome)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("GirarFruta", nome)
                wait(1)  -- Ajuste o intervalo entre os giros, se necessário
            end
        end
        wait(getgenv().config.girarIntervalo)  -- Intervalo entre os ciclos de giro
    end
end

-- Botão para iniciar/ativar o giro automático
local btnGirarFrutas = criarBotao("🔄 Girar Frutas Automático: OFF", btnFechar.Position.Y.Offset + 50, function()
    girarFrutasAtivo = not girarFrutasAtivo
    btnGirarFrutas.Text = "🔄 Girar Frutas Automático: " .. (girarFrutasAtivo and "ON" or "OFF")
    if girarFrutasAtivo then
        log("Giro automático de frutas ativado.")
        coroutine.wrap(girarFrutas)()  -- Inicia o ciclo de girar frutas
    else
        log("Giro automático de frutas desativado.")
    end
end)

-- 🍇 Detector automático de frutas no mapa (frutas raras)
coroutine.wrap(function()
    while gui and gui.Parent do
        if not raidRodando then
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Tool") and obj:FindFirstChild("Handle") and obj.Name:lower():find("fruit") then
                    local nomeFruta = obj.Name:gsub(" Fruit", ""):gsub("-", " ")
                    local valor = frutaValores[nomeFruta] or 0

                    if valor >= 1000000 then
                        log("Fruta encontrada: " .. obj.Name .. ". Indo coletar...")
                        local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                        root.CFrame = obj.Handle.CFrame + Vector3.new(0, 1, 0)
                        wait(2)
                        firetouchinterest(root, obj.Handle, 0)
                        firetouchinterest(root, obj.Handle, 1)
                        log("Fruta coletada!")
                        wait(10)
                    else
                        log("Fruta ignorada: " .. obj.Name .. " (< 1M)")
                    end
                end
            end
        end
        wait(5)
    end
end)()

-- 🏞️ Função para fazer o jogador andar sobre a água
local function andarSobreAgua()
    -- Definindo a altura do "flutuador" do jogador
    local alturaFlutuante = 5  -- Ajuste esse valor conforme necessário

    -- Verificando se o jogador está na água
    local function verificarAgua()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -10, 0))  -- Raycast para baixo

            -- Verificar se atingiu a água
            if raycastResult and raycastResult.Instance and raycastResult.Instance.Name:lower():find("water") then
                -- Se estiver na água, força o jogador a flutuar acima da água
                local aguaNivel = raycastResult.Position.Y
                if rootPart.Position.Y < aguaNivel + alturaFlutuante then
                    -- Ajusta a posição do jogador para não afundar
                    rootPart.CFrame = rootPart.CFrame + Vector3.new(0, alturaFlutuante, 0)
                end
            end
        end
    end

    -- Verificação contínua
    while true do
    verificarAgua()
    wait(0.5) -- Verifica a cada 0.5 segundos
       end
    end

    -- Iniciar a função de andar sobre a água
    coroutine.wrap(andarSobreAgua)()