## 🖼️ SystemInfo.HTA - Informações do Sistema via Aplicativo HTML (HTA)

Este utilitário desenvolvido em **HTML Application (HTA)** exibe informações da estação de trabalho em uma interface gráfica amigável, ideal para equipes de Service Desk em empresas de pequeno e médio porte. É uma alternativa para ambientes mais restritivos ou estações com políticas de execução limitadas.

### 🧰 Informações exibidas

- Nome do Computador  
- Endereço IP e MAC  
- Usuário Atual  
- Modelo do Equipamento  
- Service Tag (Serial Number)  
- Processador (nome, núcleos e threads)  
- Memória Total (MB e GB)  
- Sistema Operacional (nome, versão e build)  
- Data da Última Reinicialização  
- Tempo de Atividade da Sessão (uptime)  
- Informações de contato do Suporte Técnico (telefone, VOIP, e-mail, sistema de chamados)

### 📋 Recursos

- **Interface amigável**: similar a formulários de help desk, sem linha de comando  
- **Executável via duplo clique**: sem dependência externa ou instalação  
- **Personalizável**: os dados e layout podem ser adaptados à identidade visual da empresa  
- **Alerta de reinicialização**: datas com mais de 10 dias são destacadas em vermelho, incentivando boas práticas de uso  

### 🚀 Como usar

1. Salve o arquivo `systeminfo.hta` em uma pasta pública da estação ou rede compartilhada  
2. Crie um atalho na área de trabalho pública (ex: `C:\Users\Public\Desktop`)  
3. Instrua os colaboradores a executar o atalho sempre que solicitado pelo suporte técnico  

> 💡 *Dica:* o arquivo `.hta` pode ser distribuído via GPO como script de logon ou copiado via scripts de deploy.

### 🧩 Quando usar esta versão?

- Quando o endpoint está em um domínio com restrições severas de execução de scripts  
- Em ambientes legados ou onde o PowerShell está desabilitado por política de segurança  
- Para usuários finais que não possuem conhecimento técnico e precisam apenas executar e relatar os dados

---

