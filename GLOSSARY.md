# Glossário do Forger — vibe coding sem jargão

> Travou numa palavra? Está no lugar certo. Aqui cada termo que costuma assustar quem está começando vem explicado em uma ou duas frases, em português de gente, com um exemplo curto. Sem definição que usa a própria palavra pra se explicar.

Se você nunca programou, não precisa decorar nada disto. Comece por `/dev-start`, fale sua ideia, e volte aqui só quando aparecer um termo que você não reconhece. O Forger faz o trabalho pesado — este glossário é só pra você não se sentir perdido enquanto ele trabalha.

Índice:

- [Código](#código)
- [Git & GitHub](#git--github)
- [Infra & deploy](#infra--deploy)
- [Forger (os termos do seu projeto)](#Forger-os-termos-do-seu-projeto)

---

## Código

**Frontend**
A parte do seu app que a pessoa vê e clica: telas, botões, cores, formulários. Roda no navegador (ou no celular) de quem usa.
*Exemplo:* a tela de login que você vê quando abre um site é frontend.

**Backend**
A parte do seu app que a pessoa não vê: o que guarda os dados, faz as contas e decide quem pode o quê. Roda num servidor, longe do navegador.
*Exemplo:* quando você digita a senha e o sistema confere se ela está certa, isso acontece no backend.

**Framework**
Um kit pronto que já resolve o trabalho repetido (montar telas, organizar arquivos, lidar com endereços), pra você só escrever a parte que é a sua ideia. Em vez de começar do zero, começa de um ponto já adiantado.
*Exemplo:* Next.js e React são frameworks de frontend; você ganha estrutura de graça e foca no que o app faz.

**Banco de dados**
O lugar organizado onde seu app guarda informação pra não esquecer quando alguém fecha o navegador: usuários, pedidos, mensagens. É a memória de longo prazo do projeto.
*Exemplo:* a lista de tarefas que continua lá quando você volta amanhã está num banco de dados.

**ORM**
Um tradutor entre o seu código e o banco de dados, pra você falar com os dados em linguagem normal de programação em vez de escrever comandos crus de banco. Menos chance de errar, mais fácil de ler.
*Exemplo:* com um ORM você escreve algo como `usuario.salvar()` e ele cuida de conversar com o banco por baixo.

**API**
Uma porta de entrada pra um programa conversar com outro: você manda um pedido num formato combinado e recebe uma resposta. É como um cardápio de coisas que um serviço sabe fazer.
*Exemplo:* seu app pede "qual o clima em São Paulo?" pra uma API de previsão do tempo e recebe a temperatura de volta.

**API key (chave de API)**
Uma senha que identifica o seu app quando ele usa a API de outro serviço — prova que é você e mede quanto você usou. Por isso é segredo: quem tem a chave usa no seu nome (e na sua conta).
*Exemplo:* pra usar a API da Anthropic, você pega uma `ANTHROPIC_API_KEY` no painel deles e cola no seu projeto.

**Variável de ambiente (.env)**
Um jeito de guardar configurações e segredos (como API keys) num arquivo separado, fora do código, pra não vazar e pra trocar fácil entre o seu computador e o servidor. O arquivo costuma se chamar `.env` ou `.env.local`.
*Exemplo:* em vez de escrever a senha do banco no meio do código, você põe `DATABASE_URL=...` no `.env` e o código lê dali.

**Endpoint**
Um endereço específico de uma API — uma porta pra uma ação certa. Uma mesma API tem vários endpoints, um pra cada coisa que ela faz.
*Exemplo:* `/usuarios` lista as pessoas, `/pedidos` lista os pedidos; cada um é um endpoint.

**SDK**
Um pacotinho pronto que a empresa entrega pra facilitar o uso da API dela — já vem com as funções prontas, você não monta os pedidos na mão. SDK = "kit de desenvolvimento".
*Exemplo:* em vez de montar a chamada de API do Stripe do zero, você instala o SDK do Stripe e chama `stripe.cobrar(...)`.

**Webhook**
O contrário de uma API normal: em vez de você perguntar "já aconteceu?", o outro serviço te avisa sozinho quando algo acontece, mandando um aviso pro seu app. É um "me chama quando der".
*Exemplo:* quando alguém paga, o Stripe dispara um webhook pro seu app pra avisar "pagamento aprovado".

**Auth (autenticação)**
O sistema que descobre quem é a pessoa (login) e o que ela pode fazer (permissões). Sem isso, qualquer um vê tudo de qualquer um.
*Exemplo:* a tela de "entrar com e-mail e senha" e o fato de você só ver os seus dados — isso é auth.

**Lint**
Um corretor automático que lê seu código e aponta erros bobos, descuidos e coisas fora do padrão, antes mesmo de rodar. Pega o problema cedo, quando ainda é barato consertar.
*Exemplo:* o lint avisa "você esqueceu de usar essa variável" ou "falta um ponto e vírgula aqui".

**Teste unitário**
Um mini-teste que confere uma peça pequena do código sozinha — uma função, um cálculo — pra garantir que ela faz o certo. Roda rápido e em grande quantidade.
*Exemplo:* um teste unitário confere que `somar(2, 2)` devolve `4`.

**Teste e2e (ponta a ponta)**
Um teste que finge ser um usuário de verdade e passa pelo app inteiro, do clique até o resultado, pra ver se tudo funciona junto. É mais lento que o unitário, então roda menos vezes.
*Exemplo:* um teste e2e abre a tela de login, digita e-mail e senha, clica em entrar e confere se caiu no painel.

---

## Git & GitHub

**Repositório (repo)**
A pasta do seu projeto com superpoderes: além dos arquivos, ela guarda o histórico inteiro de todas as mudanças. "Repo" é o apelido curto.
*Exemplo:* `github.com/Marcelover777/crucible` é o repositório deste projeto.

**Commit**
Uma foto salva do seu projeto num momento, com um bilhetinho dizendo o que mudou. É o ponto pra onde você pode voltar se algo der errado depois.
*Exemplo:* depois de fazer a tela de login funcionar, você dá um commit com a mensagem "adiciona tela de login".

**Branch**
Uma linha do tempo paralela do projeto, pra você mexer numa ideia sem bagunçar a versão que está funcionando. Quando fica boa, você junta de volta.
*Exemplo:* você cria uma branch `nova-busca`, testa à vontade, e a versão principal continua intacta enquanto isso.

**Merge**
Juntar duas branches numa só — pegar o que você fez na sua linha do tempo paralela e trazer de volta pra principal. "Merge" = mesclar.
*Exemplo:* terminou a `nova-busca`, faz o merge e agora a busca está na versão principal.

**Pull request (PR)**
Um pedido formal de "olha o que eu fiz nessa branch, posso juntar na principal?". Vira um lugar pra revisar a mudança e rodar as conferências automáticas antes de aceitar.
*Exemplo:* você abre um PR com a `nova-busca`; o CI roda os testes; se passar tudo, você faz o merge.

**GitHub**
O site onde os repositórios moram na nuvem — pra ter backup, compartilhar e rodar automações. É o "lugar oficial" do seu código fora do seu computador.
*Exemplo:* você sobe o projeto pro GitHub e ele fica seguro mesmo se o seu notebook quebrar.

**CI/CD**
O robô que, sozinho, confere e publica o seu código toda vez que você sobe uma mudança. CI confere (roda lint e testes); CD entrega (publica). Junto, dá pra mexer no projeto sem medo.
*Exemplo:* você dá push, o CI roda os testes e avisa em verde "pode juntar" ou em vermelho "tem erro aqui".

**GitHub Actions**
A ferramenta do próprio GitHub que executa esse robô do CI/CD. Você descreve o que ele deve fazer num arquivo, e o GitHub roda pra você de graça.
*Exemplo:* o arquivo `.github/workflows/ci.yml` diz "a cada push, rode o lint e os testes" — isso é uma GitHub Action.

---

## Infra & deploy

**Deploy**
Colocar o seu app no ar pra outras pessoas usarem pela internet — sair do "só roda no meu computador" pra "qualquer um acessa pelo link". É o momento de publicar.
*Exemplo:* você faz deploy na Vercel e ganha um endereço tipo `meu-app.vercel.app` pra mandar pros amigos.

**Build**
O passo que pega o seu código e o prepara, empacotado e otimizado, pra rodar de verdade — como montar o móvel a partir das peças antes de usar. Quase sempre acontece logo antes do deploy.
*Exemplo:* antes de publicar, a Vercel roda o build; se der erro no build, o deploy não acontece.

**localhost**
O seu próprio computador funcionando como servidor, só pra você testar enquanto desenvolve. O endereço costuma ser `localhost:3000` e ninguém de fora consegue ver.
*Exemplo:* você roda o projeto e abre `http://localhost:3000` no navegador pra ver como ficou antes de fazer deploy.

**Serverless**
Um jeito de rodar o seu backend sem você cuidar de servidor nenhum: o provedor liga o código quando chega um pedido e desliga quando termina, e você paga só pelo uso. "Sem servidor" pra você — tem servidor, mas é problema deles.
*Exemplo:* funções serverless na Vercel sobem sozinhas quando alguém usa o app e somem quando ninguém está usando.

**Free-tier (camada grátis)**
A faixa gratuita de um serviço — até certo limite de uso, você não paga nada. Ótimo pra começar e testar; quando o projeto cresce, aí você decide se vale pagar.
*Exemplo:* o Supabase tem um free-tier que dá pra rodar um projeto pequeno sem custo. *(Limites e preços mudam — o `/dev-stack` sempre te manda pra página oficial em vez de cravar um número.)*

**npm / npx**
Duas ferramentas que vêm com o Node.js. `npm` instala e gerencia os pacotes (bibliotecas prontas) do seu projeto; `npx` roda uma ferramenta uma vez sem precisar instalar pra sempre.
*Exemplo:* `npm install` baixa tudo que o projeto precisa; `npx shadcn@latest init` roda um setup uma única vez.

**Scaffold**
Gerar a estrutura inicial de um projeto ou de uma parte dele automaticamente — paredes, encanamento e fiação prontos, pra você só decorar por dentro. Evita começar com a pasta vazia e o medo da página em branco.
*Exemplo:* `npx create-next-app` faz o scaffold de um app Next.js completo em segundos; o `/dev-design` faz o scaffold da aparência.

---

## Forger (os termos do seu projeto)

Estes são os termos que o **Forger** usa. Você vai vê-los o tempo todo enquanto trabalha — então vale conhecer.

**"executa o passo 0X"**
O único comando que o iniciante precisa decorar. Depois que o `ROADMAP.md` existe, você só pede "executa o passo 01" e o Forger faz aquele passo inteiro pra você, sozinho. Quando termina, ele te diz qual é o próximo.
*Exemplo:* você digita `executa o passo 03` e o Forger implementa o passo 3, marca como feito e avisa "próximo: executa o passo 04".

**ROADMAP.md**
A lista numerada de passos do seu projeto, do começo ao fim, em um arquivo que você consegue ler. Cada passo é uma fatia que dá pra ver funcionando, não uma micro-tarefa. É o seu mapa: você executa um passo de cada vez.
*Exemplo:* o `/dev-roadmap` cria o `ROADMAP.md` com `## 01 — Tela de login`, `## 02 — Cadastro`, e por aí vai.

**Gate (trava de pré-requisito)**
Uma trava esperta antes de um passo: se aquele passo precisa de uma chave ou configuração que ainda não existe, o Forger **para** e te dá o link exato pra resolver, em vez de seguir quebrado. É o que evita você travar sem saber por quê.
*Exemplo:* o passo de pagamentos precisa da chave do Stripe; faltando, o gate avisa "falta a `STRIPE_SECRET_KEY` — pegue aqui: [link]" e só destrava quando você resolve.

**CONTEXT.md**
A memória de vocabulário do seu projeto: o que ele é, como está organizado, como as coisas se chamam e o que nunca se deve fazer. As outras skills leem este arquivo pra falar a língua do seu projeto desde o primeiro momento.
*Exemplo:* o `/dev-context` escreve o `CONTEXT.md` uma vez; daí em diante o brainstorm e o plano já sabem que você chama de "pedido" o que o código chama de "order".

**STACK.md**
O registro da sua escolha de tecnologia e do *porquê*: qual banco, onde hospedar, qual auth — com a explicação de cada peça e as alternativas que você descartou. Escrito pelo `/dev-stack`.
*Exemplo:* o `STACK.md` diz "banco: Supabase, porque cobre auth e dados num lugar só no free-tier".

**SETUP.md / .env.example**
A dupla que cuida das chaves e configurações. O `SETUP.md` é o passo a passo com o link de onde pegar cada chave; o `.env.example` é o modelo do seu arquivo `.env`, explicando o que cada variável é. Escritos pelo `/dev-setup`.
*Exemplo:* você copia o `.env.example` pra `.env.local`, segue o `SETUP.md` pra pegar cada chave, e cola no lugar certo.

**DESIGN.md**
O registro da identidade visual do projeto: cores, fontes, componentes instalados e como nomear as coisas. Garante que o app sai bonito e com cara própria, não cara de template genérico. Escrito pelo `/dev-design`.

**GITHUB.md**
Um guia curtinho que explica, em um parágrafo cada, o que são Actions, PR, CI, issue e branch — pra você entender o que o git está fazendo sem precisar estudar git. Escrito pelo `/dev-ops`, que cuida do git no automático pra você.

**.forge/ (PROGRESS.md e STATUS.md)**
A pasta onde o Forger guarda a memória e o estado do seu projeto entre as sessões. O `PROGRESS.md` é o diário do que já rolou; o `STATUS.md` é o painel de "o que está pronto, o que tem erro e o que falta". Você não precisa editar — o Forger escreve e atualiza sozinho.
*Exemplo:* a qualquer hora você pede `/dev-status` e ele te mostra o painel; o `PROGRESS.md` faz o projeto lembrar de si mesmo amanhã sem você reexplicar nada.

**BRIEF.md / PLAN.md / SUMMARY.md**
O trio de uma feature, dentro de `.plans/<nome-da-feature>/`. O `BRIEF.md` guarda o que foi decidido; o `PLAN.md` é o plano de tarefas (a memória externa que sobrevive a um reset de conversa); o `SUMMARY.md` é o fechamento do que foi entregue.
*Exemplo:* o `/dev-brainstorm` escreve o `BRIEF.md`, o `/dev-plan` vira `PLAN.md`, e o `/dev-ship` fecha com o `SUMMARY.md`.

---

<sub>Sentiu falta de algum termo? Abra uma issue no <a href="https://github.com/Marcelover777/crucible">repositório</a>. Glossário é porta de entrada — quanto menos jargão sobrar, melhor.</sub>
