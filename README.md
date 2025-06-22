# INN‑Web

**Web Viewer para o ERP TOTVS Protheus com HTML + Bootstrap**

INN‑Web é uma solução desenvolvida em ADVPL que permite a criação de interfaces web responsivas com HTML puro e tema Bootstrap, diretamente integradas ao Protheus. Ideal para criar visualizações, formulários, relatórios, uploads e interações ricas com o usuário sem depender de tecnologias externas como Angular ou React.

---

## 🚀 Instalação

### 1. Clonar o repositório

```bash
git clone https://github.com/InnoviosBR/INN-Web.git
```

### 2. Compilação dos fontes

- Copie os arquivos da pasta `lib/` para seu projeto.
- Compile normalmente usando o VS Code com o plugin da TOTVS.
- Caso necessário, consulte [a documentação oficial da TOTVS](https://tdn.totvs.com/pages/releaseview.action?pageId=725719501).

### 3. Arquivos estáticos

- Crie uma pasta chamada `innweb` dentro do diretório `protheus_data`.
- Descompacte o arquivo `innweb.zip` dentro dessa pasta.
  > Essa pasta conterá CSS, imagens, ícones e arquivos auxiliares usados pela interface.

---

## ⚙️ Configuração do `appserver.ini`

> ⚠️ Recomendamos uma instância de AppServer exclusiva para o INN‑Web.

```ini
[HTTP]
ENABLE=1
PORT=PORTA

[JOB_WS]
TYPE=WEBEX
ENVIRONMENT=AMBIENTE
INSTANCES=5,50
onstart=STARTWEBEX
onconnect=CONNECTWEBEX

[URL_DO_SERVIDOR:PORTA/innweb]
ENABLE=1
UploadPath=CAMINHO_DO_PROTHEUS_DATA\innweb\upload
PATH=CAMINHO_DO_PROTHEUS_DATA\innweb
environment=AMBIENTE
INSTANCENAME=webservices
RESPONSEJOB=JOB_WS
DEFAULTPAGE=u_wIndex.apw
SessionTimeOut=1800
RPCTimeOut=3600

[INNWEB]
DEBUG=0
INNWEBDIR01=\innweb\temp\
INNWEBDIR02=/innweb/temp/
INNWEBDIR03=\innweb\upload\
INNWEBDIR04=\innweb\repositorio\
INNWEBDIR05=CAMINHO_DO_PROTHEUS_DATA\innweb\repositorio
INNWEBDIR06=repositorio/
```

**Notas importantes:**
- A tag `[HTTP]` habilita a interface HTTP.
- A seção `[JOB_WS]` configura o job que processa as requisições.
- Em `[URL_DO_SERVIDOR...]` ajuste o caminho físico para os arquivos da interface.
- A seção `[INNWEB]` define caminhos temporários e nível de debug (`DEBUG=1` para desenvolvimento).

---

## ✅ Execução

Após iniciar o AppServer:

- Acesse a URL configurada.
- A interface de login do INN‑Web deverá ser exibida.

---

## 🔧 Fontes obrigatórios por ambiente

Você deve compilar ao menos estes arquivos para o sistema funcionar corretamente:

```text
inn-web-paginas-de-exemplo/Config/INNConfig.prw
inn-web-paginas-de-exemplo/Config/INNMenu.prw
inn-web-paginas-de-exemplo/Paginas/wStart.prw
```

### Sobre os arquivos:

- **INNConfig.prw** – Define os diretórios da aplicação.
- **INNMenu.prw** – Controla o menu lateral e acesso às páginas. A função recebe:
  ```advpl
  aMenu := ParamIXB[1]
  cUserID := ParamIXB[2]
  cIdPgn := ParamIXB[3]
  ```
- **wStart.prw** – Página inicial após login (personalizável).

---

## 📄 Páginas e funções principais

| Arquivo              | Descrição |
|----------------------|-----------|
| **wIndex.prw**       | Página de entrada. Valida login e direciona chamadas. |
| **ClsINNWeb.prw**    | Classe principal de geração de HTML. |
| **INNAnexo.prw**     | Interface de anexos via `U_INNAnexo(cTipo, cDoc)`. |
| **INNOpen.prw**      | Abre uma página INN‑Web diretamente no Protheus. |
| **INNWebAnexo.prw**  | Classe de manipulação de arquivos anexos. |
| **INNWebBrowse.prw** | Geração de browser com `SetTabela()` e `SetRec()`. |
| **INNWebCls.prw**    | Limpeza de diretórios temporários. |
| **INNWebImgPod.prw** | Exibição de imagens de produto. |
| **INNWebParam.prw**  | Geração de parâmetros para filtros. |
| **INNWebTable.prw**  | Criação de tabelas exportáveis em Excel. |
| **w404.prw**         | Página de recurso não encontrado. |
| **wINNConfig.prw**   | Página de debug dos caminhos configurados. |

---

## 💡 Recursos adicionais

- **Crie um fonte `Criadb.prw`** se deseja gerar tabelas dinamicamente. Ele será chamado automaticamente.
- **Token de autenticação (`IN_TOKEN`)**: permite abrir páginas INN‑Web diretamente no Protheus sem login manual.

```advpl
RPCSetEnv(HttpSession->WsEmp, HttpSession->WsFil, , , , "INN web", , , ,)
RPCSetType(3)
```

---

## 📦 Exemplos inclusos

O repositório inclui **12 exemplos de páginas** reais:

- Formulários
- Relatórios
- Browsers
- Upload de arquivos
- Tabelas dinâmicas
- Filtros

---

## 📄 Licença

Projeto licenciado sob a [GNU GPL versão 2.0](LICENSE).  
Você pode redistribuí-lo e/ou modificá-lo nos termos da GNU General Public License conforme publicada pela Free Software Foundation, versão 2.

> Este software é distribuído na esperança de que seja útil, mas **sem qualquer garantia**; sem mesmo a garantia implícita de **comercialização ou adequação a um propósito específico**.
> ⚠️ **Atenção:** A utilização deste projeto implica em concordância com os termos da licença.  
> O autor e os distribuidores **não se responsabilizam por quaisquer impactos** causados ao ambiente onde for utilizado, tampouco por **prejuízos financeiros, operacionais ou de qualquer outra natureza** decorrentes do seu uso.


---

## ✉️ Suporte e contribuição

- Dúvidas ou sugestões: [Abra uma issue](https://github.com/InnoviosBR/INN-Web/issues)

---

**Desenvolvido por [INNOVIOS](https://github.com/InnoviosBR) — Conectando o Protheus à Web.**
