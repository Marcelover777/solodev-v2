# GITHUB.md — git e GitHub em português de gente

Você **não precisa entender git** pra usar este projeto. O Crucible cuida disso.
Mas se quiser saber o que está acontecendo quando vê essas palavras, aqui está
cada uma em um parágrafo. Sem jargão escondido.

## Repositório ("repo")

É a pasta do seu projeto, com superpoder: ela guarda **todo o histórico** de
cada mudança. Pense num "salvar" que nunca apaga as versões anteriores — dá pra
voltar no tempo pra qualquer ponto. O repo vive na sua máquina e tem uma cópia
no GitHub (na nuvem), pra não sumir se o computador morrer.

## Branch ("ramo")

Uma linha de trabalho paralela. A linha principal chama `main` e é a versão
"oficial" do projeto. Quando você vai mexer em algo, o trabalho acontece num
branch separado, pra não bagunçar a `main` enquanto está pela metade. Quando
fica pronto e testado, esse trabalho "volta" pra `main`. Você quase nunca cria
branch na mão — as ferramentas fazem.

## Commit

Um "salvar" com etiqueta. Cada commit é um pacote de mudanças com uma frase
explicando o que mudou (ex.: `feat: adiciona login`). É a unidade do histórico:
se algo quebrar, você descobre **qual commit** quebrou e volta só ele. O Crucible
pode fazer commits sozinho pra você (auto-commit, se você ligar) — aí você nunca
digita `git commit`.

## PR (Pull Request)

Um "pedido pra juntar". Quando o trabalho de um branch está pronto, você abre um
PR: é uma página no GitHub que mostra **exatamente o que muda** e deixa o robô
(CI) testar tudo antes de virar oficial. É o portão de qualidade. Quando o PR
está verde e revisado, você faz **merge** (junta na `main`). No Crucible, o
comando `/dev-ship` abre o PR pra você com `gh pr create --fill`.

## CI (Integração Contínua — "o robô que testa")

Um robô que mora no GitHub e roda os testes do seu projeto **automaticamente**
toda vez que você empurra código ou abre um PR. Se algo quebrou, ele pinta de
vermelho e te avisa **antes** de o código virar oficial — então a `main` fica
sempre funcionando. É o `.github/workflows/ci.yml`. O que ele roda e quando está
no `TESTING.md`.

## Actions

O nome da plataforma do GitHub que faz o CI (e outras automações) acontecer.
"GitHub Actions" = o motor; "CI" = o uso mais comum dele (rodar testes). Cada
automação é descrita num arquivo em `.github/workflows/`. Você lê os resultados
na aba **Actions** do seu repo no GitHub.

## Issue

Um "ticket": um registro de algo a fazer ou consertar. Bug encontrado, ideia de
melhoria, tarefa pendente — vira uma issue pra não esquecer. O
`.github/ISSUE_TEMPLATE/bug_report.md` deixa o formulário de bug pronto pra você
só preencher.

## E o que VOCÊ realmente faz no dia a dia?

Quase nada disso na mão:

- **Salvar trabalho** → o auto-commit cuida (se você ligar), ou peça "commita".
- **Subir e abrir PR** → `/dev-ship`.
- **Ver se está tudo verde** → `/dev-status`, ou a aba Actions no GitHub.
- **Reportar um bug** → abra uma issue (o template já guia).

O resto — branch, merge, CI — o Crucible e o GitHub fazem por baixo. Você fala a
ideia e executa os passos do `ROADMAP.md`.
