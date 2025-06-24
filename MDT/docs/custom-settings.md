# 📘 Montando um `CustomSettings.ini` eficiente

Este documento tem como objetivo orientar profissionais de TI sobre a estrutura, função e manutenção segura do arquivo `CustomSettings.ini` utilizado no Microsoft Deployment Toolkit (MDT).

---

## 📌 O que é o `CustomSettings.ini`?

O `CustomSettings.ini` é um dos principais arquivos de configuração do MDT. Ele define como os deployments devem se comportar, aplicando regras e parâmetros automaticamente durante a instalação do sistema operacional, aplicativos e configurações personalizadas.

Neste documento, exploraremos o arquivo `CustomSettings.ini` que utilizo em meu ambiente de testes. Acredito que contempla uma configuração abrangente, repleta de recursos e ajustes que refletem boas práticas e melhorias implementadas que podem servir como referência útil e adaptável para aprimorar também o seu ambiente de implantação:

```CustomSettings.ini
[Settings]
Priority=Init, ByDesktop, ByLaptop, ByVirtual, Default
Properties=MyCustomProperty, ComputerSerialNumber, ComputerTypeName, ComputerPrefix, VMPlatform

[Init]
ComputerSerialNumber=#Right("%SerialNumber%",9)#

[ByLaptop]
Subsection=Laptop-%IsLaptop%

[ByDesktop]
Subsection=Desktop-%IsDesktop%

[ByVirtual]
Subsection=Virtual-%IsVM%

[Virtual-True]
Subsection=VM-%VMPlatform%

[VMPlatform]
VMPlatform=Unknown
VMPlatform=#IfStrIEquals("%Model%", "VMware Virtual Platform") Then "VMware" ElseIfStrIEquals("%Model%", "VirtualBox") Then "VirtualBox" ElseIfStrIEquals("%Model%", "Virtual Machine") Then "Hyper-V" Else "Unknown"#

[VM-VMware]
ComputerTypeName=V
ComputerPrefix=VMW

[VM-VirtualBox]
ComputerTypeName=V
ComputerPrefix=VBX

[VM-Unknown]
ComputerTypeName=V
ComputerPrefix=VMU

[Desktop-True]
ComputerTypeName=D
ComputerPrefix=DSK

[Laptop-True]
ComputerTypeName=L
ComputerPrefix=NTB

[Default]
OSInstall=Y
_SMSTSOrgName=SUPORTE TI
_SMSTSPackageName=%TaskSequenceID% on %OSDComputername%
SkipCapture=YES
SkipAdminPassword=YES
AdminPassword=Teste@123
SkipDeploymentType=YES
SkipProductKey=YES
SkipComputerBackup=YES
SkipBitLocker=YES
SkipComputerName=NO
SkipTaskSequence=NO
SkipUserData=YES
OSDComputerName=%ComputerPrefix%-%ComputerSerialNumber%
SkipPackageDisplay=NO
SkipLocaleSelection=NO
KeyboardLocale=0416:00010416
SkipTimeZone=YES
TimeZone=065
TimeZoneName=E. South America Standard Time
BitsPerPel=32
VRefresh=60
XResolution=1
YResolution=1
SkipSummary=YES
SkipFinalSummary=NO
SLShareDynamicLogging=\\SRV-2025-RJ\deploymentshare$\DeploymentLogs
SLShare=\\SRV-2025-RJ\deploymentshare$\CompletedDeployments
EventService=http://SRV-2025-RJ:9800
WSUSServer=http://SRV-2025-RJ:8530
FinishAction=REBOOT
```

---

## 🧱 Estrutura Geral do Arquivo

O arquivo está organizado por seções com regras de prioridade e subseções específicas. Abaixo estão os principais elementos:

### `[Settings]`
Define a ordem de prioridade da aplicação das regras:
```ini
Priority=Init, ByDesktop, ByLaptop, ByVirtual, Default
```
**Essa ordem é importante** — regras em `Init` têm prioridade sobre as seguintes.

---

## 🔍 Seções Explicadas

### `Init`
Executa no início da execução do MDT. Aqui, é calculado o número de série personalizado:
```ini
ComputerSerialNumber=#Right("%SerialNumber%",9)#
```
**Ideal** para otimizar ambientes corporativos em que o nome da estação de trabalho utiliza o serial number ou service tag (Dell) do equipamento.

---

### `ByLaptop` / `ByDesktop` / `ByVirtual`
Define subseções baseadas no tipo de hardware detectado.

- `IsLaptop=True` → seção `Laptop-True`
- `IsDesktop=True` → seção `Desktop-True`
- `IsVM=True` → seção `Virtual-True`

**Evite editar a lógica dessas seções.** Apenas altere caso novos cenários de hardware sejam incluídos no ambiente.

---

### `Virtual-True` + `VMPlatform`
Aponta para a plataforma de virtualização detectada:
```ini
VMPlatform=#IfStrIEquals("%Model%", "VMware Virtual Platform") Then "VMware" ElseIfStrIEquals("%Model%", "VirtualBox") Then "VirtualBox" ElseIfStrIEquals("%Model%", "Virtual Machine") Then "Hyper-V" Else "Unknown"#
```

- Detecta automaticamente se é VMware, VirtualBox ou Hyper-V.
- Com base nisso, aplica prefixos e nomes de computador diferentes.

**Ideal** para ambientes de testes padronizando assim, o nome das máquinas virtuais criadas.

---

### `VM-<Plataforma>`
Define prefixos para máquinas virtuais:
```ini
[VM-VMware]
ComputerTypeName=V
ComputerPrefix=VMW
```

Você pode **editar os prefixos**, caso queira padronizar com outros códigos.

---

### `Desktop-True` / `Laptop-True`
Define configurações de nomenclatura:
```ini
ComputerPrefix=DSK  ; para desktops
ComputerPrefix=NTB  ; para notebooks
```

**Edite apenas os sufixos `DSK`, `NTB`, etc., se necessário.** Isso impacta diretamente o nome dos computadores gerados.

---

### `Default`
Contém as configurações padrão aplicadas se nenhuma outra regra se encaixar.

Entre elas, destaco:
- **Senha de administrador (⚠️ cuidado!)**
> - **EVITE** definir a senha de administrador diretamente no arquivo `CustomSettings.ini`. O método mais seguro e recomendável é configurar essa credencial durante a criação da `Task Sequence` (conforme imagem a seguir). Essa prática contribui significativamente para o cumprimento das diretrizes de segurança e compliance da organização.
> - No arquivo `CustomSettings.ini` apresentado neste documento, a definição da senha de administrador foi mantida **intencionalmente** com o propósito de destacar este ponto crítico.

<p align="center">  
  <kbd><img src="../imagens/MDT-ADMIN-PASSWORD.png" alt="Tela da Task Sequence Admin Password"></kbd>  
</p>


| Linha | Descrição |
|-------|----------|
| `OSInstall=Y` | Indica que o sistema operacional será instalado. |
| `_SMSTSOrgName=SUPORTE TI` | Nome exibido durante o processo de implantação (branding corporativo). |
| `_SMSTSPackageName=%TaskSequenceID% on %OSDComputername%` | Mostra dinamicamente o nome da Task Sequence e o equipamento alvo. |
| `SkipCapture=YES` | Oculta a etapa de captura de imagem personalizada. |
| `SkipAdminPassword=YES` | Oculta o campo de senha de administrador no assistente. |
| `AdminPassword=Teste@123` | Define a senha local do administrador. ⚠️ Uso apenas para demonstração/testes. |
| `SkipDeploymentType=YES` | Pula a escolha entre nova instalação ou atualização. |
| `SkipProductKey=YES` | O assistente ignora a inserção de chave de produto do Windows. |
| `SkipComputerBackup=YES` | Não realiza backup dos arquivos existentes. |
| `SkipBitLocker=YES` | Ignora a configuração do BitLocker. 💡Tratarei esta opção em outro documento de forma mais detalhada.  |
| `SkipComputerName=NO` | Permite que o técnico defina um nome de computador, se necessário. |
| `SkipTaskSequence=NO` | Exibe a tela de seleção de Task Sequence para o usuário. |
| `SkipUserData=YES` | Ignora o processo de migração de dados do usuário. |
| `OSDComputerName=%ComputerPrefix%-%ComputerSerialNumber%` | Define o nome do computador automaticamente, combinando prefixo e sufixo definidos por regras. |
| `SkipPackageDisplay=NO` | Mostra pacotes adicionais (se configurados). |
| `SkipLocaleSelection=NO` | Permite escolha de idioma/localização. |
| `KeyboardLocale=0416:00010416` | Define o layout do teclado para Português Brasil (ABNT2). |
| `SkipTimeZone=YES` | Ignora a seleção de fuso horário. |
| `TimeZone=065` | Código para "E. South America Standard Time". |
| `TimeZoneName=E. South America Standard Time` | Nome do fuso horário usado para exibição e logs. |
| `BitsPerPel=32` | Profundidade de cor da tela: 32 bits. |
| `VRefresh=60` | Frequência de atualização da tela: 60 Hz. |
| `XResolution=1` / `YResolution=1` | Valor `1` indica que será usada a resolução nativa do monitor. |
| `SkipSummary=YES` | Oculta o resumo das configurações antes da instalação. |
| `SkipFinalSummary=NO` | Exibe o resumo final após a conclusão da instalação. |
| `SLShareDynamicLogging=\\SRV-2025-RJ\deploymentshare$\DeploymentLogs` | Caminho de rede para os logs gerados em tempo real durante a implantação. |
| `SLShare=\\SRV-2025-RJ\deploymentshare$\CompletedDeployments` | Pasta de destino para os logs finais após a instalação. |
| `EventService=http://SRV-2025-RJ:9800` | Endereço do serviço de eventos do MDT, útil para monitoramento em tempo real. |
| `WSUSServer=http://SRV-2025-RJ:8530` | Define o servidor WSUS usado para atualizações. |
| `FinishAction=REBOOT` | Reinicia automaticamente a máquina após finalizar a Task Sequence. |

---

## 🛑 O que **não editar** sem aprovação técnica

- Qualquer linha que use `#IfStrIEquals(...)#` (lógica condicional)
- Variáveis como `%SerialNumber%`, `%Model%`, `%IsVM%`, `%TaskSequenceID%`
- Seções de log (`SLShareDynamicLogging`, `SLShare`) e serviços (`EventService`)
- Sequência de prioridade (`Priority=`)

---

## ✅ O que **pode ser customizado**

- Prefixos (`ComputerPrefix=`)
- Nome da organização (`_SMSTSOrgName`)
- Resolução, idioma do teclado, fuso horário

---

## 🔒 Boas Práticas

- Faça backup do arquivo antes de qualquer alteração.
- Comente qualquer linha alterada usando `;` e adicione data + responsável.
- Teste sempre as mudanças em ambiente isolado (VM de homologação).
- Verifique logs de execução no compartilhamento definido por `SLShareDynamicLogging`.

---
