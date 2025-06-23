# 📊 SystemInfo - Informações do Sistema via PowerShell

Este script PowerShell exibe informações detalhadas da máquina em uma interface gráfica amigável, ideal para equipes de Service Desk em empresas de pequeno e médio porte.

## 🧰 Informações exibidas

- Nome do Computador
- Endereço IP e MAC
- Usuário Atual
- Modelo do Equipamento
- Service Tag (Serial Number)
- Processador (nome, núcleos, threads)
- Memória Total (em MB e GB)
- Sistema Operacional (nome, versão, build)
- Data da Última Reinicialização

## 🖼️ Interface Gráfica

A interface foi criada com XAML e apresenta botões úteis:

- **Copiar:** copia os dados para a área de transferência
- **Enviar por E-mail:** abre o cliente de e-mail com os dados no corpo da mensagem
- **Fechar:** encerra a janela

## 🚀 Como usar

1. Certifique-se de ter permissão para executar scripts PowerShell (.ps1);
2. Coloque os arquivos `.ps1`, `service-desk-ti.png` e `support-2.ico` em `C:\Users\Public\Documents`;
3. Altere o atributo destes arquivos para `oculto`;
4. Crie um atalho na Área de Trabalho Pública utilizando a linha de comando:
```powershell
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Users\Public\Documents\SERVICEDESK.PS1"
```
5. Execute o script (não é necessário executar como administrador).

> 🔐 *Dica:* pode ser necessário configurar a política de execução do PowerShell:  
> `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

## 🛠️ Requisitos

- Windows 10 ou superior
- PowerShell 5.1 ou mais recente
- Permissão para acessar WMI/CIM

## 📬 Contribua

Sinta-se à vontade para abrir *issues*, enviar *pull requests* ou sugerir melhorias.  
Este projeto é colaborativo!

---

**Contato:** [Jardel Santos](https://www.linkedin.com/in/jardel-santos-2012)  
**Licença:** [MIT](LICENSE)
