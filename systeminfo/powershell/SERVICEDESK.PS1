Add-Type -AssemblyName PresentationFramework

function Get-SystemInfo {
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $processor = Get-CimInstance -ClassName Win32_Processor
    $bios = Get-CimInstance -ClassName Win32_BIOS
	$networkAdapter = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

	$ipAddress = if ($networkAdapter) { $networkAdapter.IPAddress[0] } else { "Não disponível" }
	$macAddress = if ($networkAdapter) { $networkAdapter.MACAddress } else { "Não disponível" }

    $buildNumber = [int]$operatingSystem.BuildNumber
    $windowsVersion = switch ($buildNumber) {
        {$_ -ge 19044 -and $_ -lt 19045} { "21H2" }
        {$_ -ge 19045 -and $_ -lt 22631} { "22H2" }
        {$_ -ge 22631 -and $_ -lt 26000} { "23H2" }
        {$_ -ge 26000} { "24H2" }
        default { "Versão desconhecida" }
    }

    $wmiOperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $lastBootUpTime = $wmiOperatingSystem.ConvertToDateTime($wmiOperatingSystem.LastBootUpTime)
    $lastBootUpTimeFormatted = $lastBootUpTime.ToString("dd 'de' MMMM 'de' yyyy 'às' HH:mm:ss", [System.Globalization.CultureInfo]::GetCultureInfo("pt-BR"))

    $totalMemoryMB = [math]::Round($computerSystem.TotalPhysicalMemory / 1MB)
    $totalMemoryGB = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB)

    $systemInfo = @{
        ComputerName = $computerSystem.Name
        Model = $computerSystem.Model
        CurrentUser = ($computerSystem.UserName -split '\\')[-1]
        TotalMemoryMB = $totalMemoryMB
        TotalMemoryGB = $totalMemoryGB
        IPAddress = $ipAddress
		MACAddress = $macAddress
        CPU = $processor.Name
        Cores = $processor.NumberOfCores
        LogicalProcessors = $processor.NumberOfLogicalProcessors
        OS = "$($operatingSystem.Caption) - $($operatingSystem.Version) ($buildNumber) - $windowsVersion"
        LastBootUpTime = $lastBootUpTimeFormatted
        SerialNumber = $bios.SerialNumber
    }
    return $systemInfo
}

function Show-SystemInfo {
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Informações do Sistema" WindowStartupLocation="CenterScreen">
    <ScrollViewer Name="MainScrollViewer" VerticalScrollBarVisibility="Auto">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <Image Name="LogoImage" Stretch="Uniform" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10"/>
            <StackPanel Grid.Row="1" Margin="10">
                <TextBlock Text="Nome do Computador:" FontWeight="Bold"/>
                <TextBlock Name="ComputerNameText" Margin="0,0,0,10" FontSize="16" Foreground="Blue" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Endereço IP:" FontWeight="Bold"/>
                <TextBlock Name="IPAddressText" Margin="0,0,0,10" FontSize="16" Foreground="Blue" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Usuário Atual:" FontWeight="Bold"/>
                <TextBlock Name="CurrentUserText" Margin="0,0,0,10" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Modelo do Equipamento:" FontWeight="Bold"/>
                <TextBlock Name="ModelText" Margin="0,0,0,10" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Service Tag:" FontWeight="Bold"/>
                <TextBlock Name="SerialNumberText" Margin="0,0,0,10" FontSize="16" Foreground="Blue" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Processador:" FontWeight="Bold"/>
                <TextBlock Name="CPUText" Margin="0,0,0,10" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Memória Total:" FontWeight="Bold"/>
                <TextBlock Name="MemoryText" Margin="0,0,0,10" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Sistema Operacional:" FontWeight="Bold"/>
                <TextBlock Name="OSText" Margin="0,0,0,10" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Última Reinicialização:" FontWeight="Bold"/>
                <TextBlock Name="LastBootUpTimeTextBlock" Margin="0,0,0,10" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <TextBlock Text="Endereço MAC:" FontWeight="Bold"/>
                <TextBlock Name="MACAddressText" Margin="0,0,0,10" Text="Carregando..." TextWrapping="Wrap" TextTrimming="CharacterEllipsis"/>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="10">
                    <Button Name="CopyData" Content="Copiar" Width="75" Margin="5"/>
                    <Button Name="SendEmail" Content="Enviar por E-Mail" Width="125" Margin="5"/>
                    <Button Name="CloseWindow" Content="Fechar" Width="75" Margin="5"/>
                </StackPanel>
            </StackPanel>
        </Grid>
    </ScrollViewer>
</Window>
"@

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    $window.Width = 600
    $window.Height = [System.Windows.SystemParameters]::PrimaryScreenHeight * 0.95

    $iconPath = "$env:PUBLIC\Documents\support-2.ico"
    if (Test-Path $iconPath) {
        $iconUri = New-Object System.Uri("file:///$iconPath")
        $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create($iconUri)
    } else {
        Write-Warning "Ícone não encontrado em $iconPath"
    }

    $logoImage = $window.FindName("LogoImage")
    $imagePath = "$env:PUBLIC\Documents\service-desk-ti.png"
    if (Test-Path $imagePath) {
        $logoImage.Source = [System.Windows.Media.Imaging.BitmapImage]::new((New-Object System.Uri($imagePath)))
    } else {
        $logoImage.Source = $null
    }

    $null = $window.Dispatcher.InvokeAsync({
        $systemInfo = Get-SystemInfo
        $window.FindName("ComputerNameText").Text = $systemInfo.ComputerName
        $window.FindName("IPAddressText").Text = $systemInfo.IPAddress
        $window.FindName("CurrentUserText").Text = $systemInfo.CurrentUser
        $window.FindName("ModelText").Text = $systemInfo.Model
        $window.FindName("SerialNumberText").Text = $systemInfo.SerialNumber
        $window.FindName("CPUText").Text = "$($systemInfo.CPU) ($($systemInfo.Cores) Cores, $($systemInfo.LogicalProcessors) Processadores Lógicos)"
        $window.FindName("MemoryText").Text = "$($systemInfo.TotalMemoryMB) MB / $($systemInfo.TotalMemoryGB) GB"
        $window.FindName("OSText").Text = $systemInfo.OS
        $window.FindName("LastBootUpTimeTextBlock").Text = $systemInfo.LastBootUpTime
        $window.FindName("MACAddressText").Text = $systemInfo.MACAddress

		# Check and style IP Address
		$ipAddressTextBlock = $window.FindName("IPAddressText")
		if ($systemInfo.IPAddress -eq "Não disponível") {
			$ipAddressTextBlock.Foreground = [System.Windows.Media.Brushes]::Red
			$ipAddressTextBlock.FontSize = 16
		}

		# Check and style MAC Address
		$macAddressTextBlock = $window.FindName("MACAddressText")
		if ($systemInfo.MACAddress -eq "Não disponível") {
			$macAddressTextBlock.Foreground = [System.Windows.Media.Brushes]::Red
			$macAddressTextBlock.FontSize = 16
		}

        try {
            $lastBootUpTime = [DateTime]::ParseExact($systemInfo.LastBootUpTime, "dd 'de' MMMM 'de' yyyy 'às' HH:mm:ss", [System.Globalization.CultureInfo]::GetCultureInfo("pt-BR"))
            if (([DateTime]::Now - $lastBootUpTime).Days -gt 10) {
                $textBlock = $window.FindName("LastBootUpTimeTextBlock")
                $textBlock.Foreground = [System.Windows.Media.Brushes]::Red
                $textBlock.FontSize = 16
            }
        } catch {
            Write-Warning "Falha ao analisar LastBootUpTime formatado: $_"
        }
    })

    # Adicionando eventos aos botões
    $copyButton = $window.FindName("CopyData")
    $copyButton.Add_Click({
        $content = @"
Nome do Computador: $($window.FindName("ComputerNameText").Text)
Endereço IP: $($window.FindName("IPAddressText").Text)
Usuário Atual: $($window.FindName("CurrentUserText").Text)
Modelo do Equipamento: $($window.FindName("ModelText").Text)
Service Tag: $($window.FindName("SerialNumberText").Text)
Processador: $($window.FindName("CPUText").Text)
Memória Total: $($window.FindName("MemoryText").Text)
Sistema Operacional: $($window.FindName("OSText").Text)
Última Reinicialização: $($window.FindName("LastBootUpTimeTextBlock").Text)
Endereço MAC: $($window.FindName("MACAddressText").Text)
"@
        [System.Windows.Clipboard]::SetText($content)
        [System.Windows.MessageBox]::Show("Dados copiados para a área de transferência!", "Informação", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
    })

    $sendEmailButton = $window.FindName("SendEmail")
    $sendEmailButton.Add_Click({
        $content = @"
Nome do Computador: $($window.FindName("ComputerNameText").Text)
Endereço IP: $($window.FindName("IPAddressText").Text)
Usuário Atual: $($window.FindName("CurrentUserText").Text)
Modelo do Equipamento: $($window.FindName("ModelText").Text)
Service Tag: $($window.FindName("SerialNumberText").Text)
Processador: $($window.FindName("CPUText").Text)
Memória Total: $($window.FindName("MemoryText").Text)
Sistema Operacional: $($window.FindName("OSText").Text)
Última Reinicialização: $($window.FindName("LastBootUpTimeTextBlock").Text)
Endereço MAC: $($window.FindName("MACAddressText").Text)

*** Descreva a sua solicitação aqui ***
"@
        $mailto = "mailto:helpdesk@teste.com?subject=Informações do Sistema&body=$([System.Uri]::EscapeDataString($content))"
        Start-Process $mailto
    })

    $closeButton = $window.FindName("CloseWindow")
    $closeButton.Add_Click({
        $window.Close()
    })

    $window.ShowDialog() | Out-Null
}

Show-SystemInfo