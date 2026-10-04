# PlanHome Mobile

App Flutter do TCC PlanHome — app do **cliente**. Agora ele conversa com a
**API do site** (`tcc-web`, Laravel + Sanctum): login, cadastro, catálogo, pedidos e
conta vêm do mesmo banco de dados do site.

> Analogia: antes o app era um caderninho dentro do celular (só ele sabia o que
> estava escrito). Agora ele é um balcão de atendimento ligado à loja: pergunta
> ao site o que tem no estoque e manda os pedidos para lá. O caderninho ainda
> existe, mas só como "cópia de segurança" para quando faltar internet.

## O que o app faz

| Tela do app | Equivalente no site | Chamada da API |
|---|---|---|
| Login | Entrar | `POST /api/v1/login` |
| Cadastro / editar perfil | Criar conta | `POST /api/v1/register`, `PUT /api/v1/me` |
| Perfil (logout, excluir conta) | Sair | `POST /api/v1/logout`, `DELETE /api/v1/me` |
| Catálogo + detalhes (com imagem) | Produtos | `GET /api/v1/produtos` |
| Carrinho → Finalizar compra | Carrinho | `POST /api/v1/pedidos` |
| Meus pedidos (cancelar pendente) | Meus Pedidos | `GET /api/v1/pedidos`, `DELETE /api/v1/pedidos/{id}` |

- O carrinho continua só no app (como no site, que guarda o carrinho na sessão);
  ele só vai para o servidor quando o cliente toca em **Finalizar compra**.
- **Favoritos** ficam só no aparelho (o site não tem favoritos).
- As telas de **empresa** não existem no app, então o app **não cadastra, edita
  nem exclui produtos**: isso é feito pelas empresas no site (inclusive o envio
  das imagens). O app só mostra o catálogo.
- **Pedidos** funcionam como no site: cada unidade comprada vira um pedido com
  status (pendente, pago, enviado, concluído). Só pedidos **pendentes** podem ser
  cancelados.

## Funciona sem internet?

Parcialmente. Toda vez que o app consegue falar com o servidor, ele guarda uma
cópia do catálogo, dos pedidos e do perfil no aparelho (`shared_preferences`).
Sem internet:

- você **vê** o catálogo, os pedidos e o perfil (aparece uma faixa avisando);
- você **não consegue** logar pela primeira vez, cadastrar, finalizar compra
  nem cancelar pedido (isso precisa do servidor) — o app mostra uma mensagem.

## Estrutura de pastas (padrão MVC)

```
lib/
  main.dart
  modelo/                  <- os "dados" do app
    classes/
      cliente.dart
      produto.dart
      pedido.dart
      item_pedido.dart
    config_api.dart            <- ENDEREÇO DA API (troque aqui se precisar)
    api_service.dart           <- faz as chamadas HTTP e trata os erros
    local_storage_service.dart <- token de login + cópia dos dados no aparelho
  controle/                <- as regras (cada um chama a API)
    cliente_controller.dart
    produto_controller.dart
    pedido_controller.dart
  visao/                   <- as telas, agrupadas por assunto
    splash_screen.dart
    home_screen.dart
    cores_app.dart
    cliente/
      login_screen.dart
      cadastro_cliente_screen.dart
      perfil_tab.dart
    produto/
      catalogo_tab.dart
      produto_detalhes_screen.dart
      imagem_produto.dart
    carrinho/
      carrinho_tab.dart
    pedido/
      pedidos_tab.dart
      pedido_detalhes_screen.dart
```

## Como rodar (passo a passo)

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install).
2. **Deixe a API do site no ar** (veja o README do `tcc-web`, seção "API para o app mobile": é preciso rodar `php artisan install:api` e `php artisan migrate`).
   Sem isso o app não consegue entrar nem listar produtos.
3. Abra o arquivo `lib/modelo/config_api.dart` e confira o endereço:
   - site publicado: `https://tcc-web.sao.dom.my.id/api/v1` (já vem assim)
   - testando no PC com emulador Android: `http://10.0.2.2:8000/api/v1`
     (`10.0.2.2` é como o emulador "enxerga" o seu computador; rode o site com
     `php artisan serve`)
   - testando no celular de verdade: `http://IP-DO-SEU-PC:8000/api/v1`
     (celular e PC na mesma rede Wi-Fi; rode `php artisan serve --host=0.0.0.0`)
4. No terminal, dentro da pasta do app:
   ```
   flutter pub get
   flutter run
   ```
5. Na tela de login, toque em **"Não tem conta? Cadastre-se"** para criar uma
   conta de cliente — ou entre com `cliente@email.com` / `123456` (conta criada
   pelo seeder do site).

> Contas de **empresa** não entram no app (a API recusa): elas só usam o site.
> O login devolve um token do Sanctum; o app o guarda no aparelho e o envia em cada
> chamada protegida (`Authorization: Bearer <token>`).

## Observação sobre o modal antigo

As telas de produto abrem em tela cheia (`ProdutoDetalhesScreen`) em vez do
`showModalBottomSheet` antigo.
