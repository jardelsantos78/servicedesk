# 📦 Criação de Imagem Personalizada no MDT (`Sysprep and Capture`)

## 🎯 Objetivo

Permitir a criação de uma imagem `.WIM` personalizada que contenha os aplicativos corporativos, configurações de sistema, drivers e personalizações visuais, tornando o processo de implantação do Windows mais rápido, padronizado e eficiente.

---

## 🧭 Etapas

### 1. 🖥️ Preparar a Máquina de Referência

A "referência" será o modelo base da imagem.

- Instale o Windows manualmente (de preferência a ISO limpa e não modificada);
- Acesse o sistema em modo de auditoria. Para saber mais acesse: https://learn.microsoft.com/pt-br/windows-hardware/manufacture/desktop/boot-windows-to-audit-mode-or-oobe?view=windows-11);
- Aplique todos os aplicativos corporativos, atualizações de segurança e configurações padrão desejadas;
- Verifique se todos os drivers estão instalados corretamente;
- Execute limpeza do sistema (`cleanmgr`, `temp`, `Downloads`, etc.);
- Evite deixar perfis de usuário, logs ou credenciais salvas.

### 2. 🧹 Executar o Sysprep

O Sysprep generaliza o sistema, removendo informações exclusivas de hardware e preparando o Windows para ser capturado.

```cmd
sysprep /oobe /generalize /shutdown
```

> ⚠️ **Atenção:** use a opção `/shutdown` (não `/reboot`). A máquina será desligada após o Sysprep.

### 3. 📸 Capturar a Imagem com o MDT

1. Ligue a máquina via PXE ou use um pendrive de boot MDT;
2. No menu LiteTouch, selecione a Task Sequence de tipo `Sysprep and Capture`;
3. Escolha o nome do arquivo `.WIM` de saída e o caminho para salvamento (ex: `\\SRV\DeploymentShare$\Captures\Win11-CorpoTecnico.wim`);
4. Aguarde o processo de captura e upload da imagem.

### 4. 💾 Armazenar e Utilizar a Imagem

- A imagem capturada estará disponível para uso em futuras implantações;
- Agora, basta criar uma Task Sequence no MDT do tipo “Standard Client Task Sequence” e, no passo **"Install Operating System"**, apontar para o arquivo `.WIM` personalizado.

---

## ✅ Vantagens

| Benefício | Descrição |
|----------|----------|
| ⏱️ Redução de tempo | Instalações futuras serão mais rápidas, pois já incluem apps e configurações. |
| 📦 Padronização | Garante consistência entre estações de trabalho em diferentes setores. |
| 👩‍💻 Menos interação manual | Menor necessidade de configurações e instalações pós-deploy. |
| 💡 Ótima para ambientes offline | Útil em redes isoladas sem SCCM/Intune. |

---

## ⚠️ Desvantagens

| Limitação | Descrição |
|-----------|-----------|
| 🔄 Manutenção periódica | É necessário recriar a imagem frequentemente para manter apps e patches atualizados. |
| 💾 Tamanho | Imagens muito personalizadas tendem a ser maiores. |
| 🔐 Segurança | Pode haver risco de vazamento se credenciais ou dados sensíveis forem deixados na imagem. |
| 🧪 Complexidade no troubleshooting | Problemas herdados da imagem podem se replicar em todos os dispositivos. |

---

## 🔒 Boas Práticas

- Remova perfis de usuário com `delprof2` ou limpeza manual.
- Utilize ferramentas como `Dism /Cleanup-Image` antes do sysprep para reduzir o tamanho.
- Audite com scripts ou checklists antes de executar a captura.
- Armazene versões anteriores da imagem por segurança.

---

## ⚠️ Observações Importantes

- Embora funcional, o processo de captura de imagem é praticamente **obsoleto** no cenário atual diante das soluções de automação de instalação de aplicativos como os recursos nativos no próprio MDT ou ferramentas mais avançadas de gerenciamento, como o **Microsoft Intune**.
- A inclusão deste procedimento tem caráter **estritamente ilustrativo**, para contextualizar e facilitar a comparação com abordagens mais robustas que serão apresentadas ao longo deste repositório.

---

## 🤝 Contribuições

Sinta-se à vontade para usar, adaptar e sugerir melhorias.  
Este repositório é um ponto de troca de experiências entre profissionais de TI.

> 🗓 Documento criado em: **24/06/2025**  
> 💼 **Licença:** [MIT](../../LICENSE)  
> 🙋‍♂️ **Autor:** [Jardel Santos](https://www.linkedin.com/in/jardel-santos-2012)

---

[Voltar para MDT](../README.md) | [Voltar para a página principal](../../README.md)
