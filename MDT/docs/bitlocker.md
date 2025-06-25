# 🔐 Ativação do BitLocker no Microsoft Deployment Toolkit (MDT)

Este documento tem como objetivo falar um pouco sobre o processo de ativação do **BitLocker Drive Encryption** em estações implantadas via MDT, garantindo criptografia de disco durante ou logo após o processo de deploy do sistema operacional.

---

## 🧭 Pré-requisitos

Antes de configurar a ativação do BitLocker no MDT, certifique-se de:

- ✅ Hardware com **TPM 1.2 ou 2.0** ativado e operacional;
- ✅ Inicialização em **modo UEFI** com partições GPT;
- ✅ Sistema operacional compatível com BitLocker (Windows Pro, Enterprise ou Education);
- ✅ MDT atualizado e integração com AD (recomendado para escopo corporativo);
- ✅ Configuração adequada de partições no MDT (partição do sistema + partição do SO).

---

## 🔧 Etapas de Configuração no MDT

### 1. Verifique o Layout de Partições

Certifique-se de que sua Task Sequence inclui o passo **Format and Partition Disk** com as partições abaixo:

- **Sistema** (100–500 MB, NTFS, tipo `Boot`, sem letra)
- **Windows (OS)** (restante do disco, NTFS, letra `C:`)

> O BitLocker exige uma partição do sistema separada e sem letra atribuída.

---

### 2. Adicione o Passo “Enable BitLocker” à Task Sequence

1. No **Deployment Workbench**, edite a Task Sequence desejada;
2. Vá até a fase **State Restore** (geralmente após os aplicativos e configurações);
3. Clique com o botão direito > **Add > New Group** e nomeie como “Enable BitLocker”;
4. Dentro do grupo, adicione um passo:  
   `Add > General > Enable BitLocker`;
5. Configure os parâmetros:

   - **Wait for BitLocker to complete**: `No` (ativação assíncrona é recomendada)
   - **Skip this step if computer does not have a TPM**: `Yes`
   - **Recovery key storage**: escolha entre:
     - `Save BitLocker recovery key to AD DS`
     - `Save BitLocker recovery key to a file`
     - `Do not save key`

> 💡 Se sua máquina será ingressada no domínio, o ideal é armazenar a chave no Active Directory.

---

### 3. Configure a GPO de Backup de Chaves (recomendado)

Se estiver usando AD tradicional:

1. Abra o Group Policy Management Console (GPMC);
2. Edite ou crie uma GPO em:  
   `Configuração do Computador > Políticas > Componentes do Windows > BitLocker Drive Encryption`;
3. Habilite as opções de:
   - Backup automático da chave de recuperação;
   - Proibição de criptografar sem backup da chave.

---

## 🛠️ Logs e Troubleshooting

- Os logs relevantes estão localizados em:
  - `C:\Windows\Panther\UnattendGC\setupact.log`
  - `C:\MININT\SMSOSD\OSDLOGS\`
- Para forçar a reinicialização e testar a proteção, execute:

```cmd
manage-bde -status C:
```

---

# 🧾 Comparativo: Ativação do BitLocker — MDT vs GPO

Abaixo segue tabela comparativa das principais diferenças entre ativar o BitLocker durante o processo de deploy (via MDT) e utilizar políticas de grupo (GPO) após o ingresso da máquina no domínio.

| Critério                            | Via MDT/SCCM                                             | Via GPO                                                  |
|-------------------------------------|----------------------------------------------------------|-----------------------------------------------------------|
| **Momento da ativação**             | Durante ou ao final do deploy                            | Após ingresso no domínio e aplicação da GPO              |
| **Tempo sem proteção do disco**     | Nenhum – criptografia pode ocorrer antes do primeiro boot| Pode haver uma janela onde o disco está descriptografado |
| **Controle de ativação**            | Total — ativação explícita na Task Sequence              | GPO define a política, mas depende da aplicação da GPO   |
| **Complexidade de configuração**    | Moderada – envolve particionamento, TPM e passo específico| Simples – basta aplicar a GPO correta ao OU               |
| **Armazenamento da chave**          | Pode ser configurado para salvar no AD ou localmente     | Armazenamento automático no AD (com GPO configurada)     |
| **Pré-requisitos de hardware**      | Partição do sistema, TPM habilitado e UEFI ativo         | Os mesmos – mas aplicados posteriormente                 |
| **Visibilidade e logs**             | Integração com logs da Task Sequence                     | Visível apenas via Event Viewer e gerenciamento do AD    |
| **Resiliência em ambientes híbridos** | Requer adaptação para Azure AD/Intune                   | Suporte nativo via Microsoft Entra ID                    |
| **Indicado para**                   | Ambientes com deploy controlado e segurança crítica      | Ambientes com GPOs maduras e foco em escalabilidade      |

---

## 🎯 Recomendação Híbrida

A melhor estratégia pode ser combinada:
- Ativar o BitLocker **durante o deploy via MDT**, garantindo proteção imediata;
- Utilizar a **GPO como reforço** para monitoramento, reativação e padronização contínua.

---

## 📋 Boas Práticas

- Use o passo “Enable BitLocker” após todos os drivers críticos estarem instalados;
- Valide a presença do chip TPM antes do início do processo;
- Teste o comportamento em notebooks, VMs com TPM virtual e estações físicas;
- Habilite logs estendidos no MDT para investigar falhas (`SLShareDynamicLogging`);
- Garanta que a BIOS/UEFI esteja configurada com `Secure Boot` ativado.

---
