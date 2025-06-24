# 📦 Instalação Silenciosa de Aplicativos via MDT

Este documento tem como objetivo passar algumas sugestões sobre o processo de instalação de softwares durante o deploy do Windows, sem interação do usuário, garantindo padronização e agilidade.

---

## 🧭 Etapas

### 1. Adicionar o Aplicativo ao MDT

> 📌 Para exemplo, utilizaremos o [Adobe Acrobat Reader DC](https://get.adobe.com/br/reader/enterprise/) como referência, mas os passos apresentados são aplicáveis a qualquer outro aplicativo que permita instalação silenciosa, bastando ajustar os arquivos e os parâmetros de instalação conforme a necessidade do ambiente.  

1. Abra o **Deployment Workbench**;
2. Navegue até `Deployment Share > Applications`;
3. Clique com o botão direito em **Applications** e selecione **New Application**;
4. Escolha a opção `Application with source files`;
5. Preencha os campos:
   - **Publisher:** Adobe (campo opcional)
   - **Application Name:** Adobe Acrobat Reader DC (campo obrigatório)
   - **Version:** (campo opcional)
6. Em **Source directory**, selecione a pasta onde está o instalador `.exe`.
   - O instalador deve ser o único arquivo na pasta de origem caso contrário, todos os arquivos contidos na pasta serão copiados para `DeploymentShare$\Applications`.
7. Em **Command line**, insira:

   ```cmd
   AcroRdrDC_MUI.exe /sAll /rs /msi EULA_ACCEPT=YES
   ```

   > 💡 Esses parâmetros realizam a instalação silenciosa, suprimem reinicialização e aceitam os termos de uso.  
   > 💡 Padronize o nome dos instaladores e mantenha uma documentação para consulta. Ao padronizar os nomes, o processo para atualização dos aplicativos posteriormente torna-se mais fácil e rápido.

9. Finalize o assistente.

---

### 2. Associar à Task Sequence (opcional)

1. Edite a Task Sequence desejada;
2. Vá até a fase **State Restore**;
3. Adicione um passo do tipo **Install Application**;
4. Selecione o Adobe Reader DC ou use a opção de instalar todos os aplicativos definidos.

---

### 3. Validar em Ambiente de Testes

- Execute o deploy em uma VM de homologação;
- Verifique se o Adobe Reader foi instalado corretamente e sem prompts;
- Confirme se o aplicativo aparece no menu Iniciar e está funcional.

---

## 🔄 Atualização do Aplicativo

Quando uma nova versão do Adobe Reader for lançada:

1. **Baixe o novo instalador do site oficial**;
2. **No MDT**, substitua o instalador antigo:
   - Localize a pasta do aplicativo dentro do caminho `DeploymentShare$\Applications\NomeDoAplicativo`;
   - Substitua o arquivo antigo pelo novo, mantendo o mesmo nome (ex: `AcroRdrDC_MUI.exe`);
   - Certifique-se de que o comando de instalação permanece compatível;
   - A Task Sequence continuará utilizando automaticamente o mesmo GUID e estrutura.
3. (Opcional) Caso queira manter histórico de versões:
   - Crie uma nova entrada de aplicativo no MDT com o nome e versão atualizados;
   - Atualize a Task Sequence para apontar para a nova versão;
   - Mantenha a anterior inativa ou exclua-a conforme necessário.

> 💡 **Dica:** a substituição do instalador mantém o GUID interno do aplicativo, evitando ajustes manuais na Task Sequence. No entanto, em ambientes com controle de mudanças mais rígido, a criação de uma nova entrada pode facilitar o rastreamento de versões e rollback, se necessário.

---

## 🔒 Boas Práticas

- Sempre verifique a documentação oficial do fornecedor para descobrir os parâmetros corretos de instalação silenciosa (/S, /quiet, /sAll, -silent, etc.);
	> **Dica:** consulte os sites [SilentInstalHQ](https://silentinstallhq.com/) ou [Manage Engine Endpoint Central](https://www.manageengine.com/products/desktop-central/software-installation/latest-software.html) para descobrir os parâmetros de instalação silenciosa.
- Teste o instalador com os parâmetros em um equipamento ou VM de homologação antes de integrá-lo ao MDT;
- Cada aplicação adicionada ao MDT deve ter uma breve documentação contendo:
	- Nome, versão
	- Origem do instalador
	- Comando silencioso utilizado
	- Data de entrada ou atualização
- Prefira comandos que não dependam de caminhos relativos ou temporários;
- Se usar scripts `.bat` ou `.ps1`, trate erros com mensagens claras no log;
- Crie uma Task Sequence de homologação com a instalação dos aplicativos;
	- Valide que a instalação ocorre sem janelas visíveis, sem prompts e que o software funciona corretamente após o deploy;
- Instale os aplicativos em ordem lógica (ex: .NET Framework antes do app que o exige).

---

## 🤝 Contribuições

Sinta-se à vontade para usar, adaptar e sugerir melhorias.  
Este repositório é um ponto de troca de experiências entre profissionais de TI.

> 🗓 Documento criado em: **24/06/2025**  
> 💼 **Licença:** [MIT](../../LICENSE)  
> 🙋‍♂️ **Autor:** [Jardel Santos](https://www.linkedin.com/in/jardel-santos-2012)

---

[Voltar para MDT](../README.md) | [Voltar para a página principal](../../README.md)
