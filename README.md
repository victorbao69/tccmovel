# PlanHome Mobile

App Flutter do TCC PlanHome — app único do cliente (a área de empresa
foi removida). Funciona totalmente offline: tudo é salvo no
armazenamento interno do aparelho com `shared_preferences`.

## Funcionalidades

- **Login / Cadastro de cliente** (nome, e-mail, senha, telefone, endereço)
- **Logout** e **exclusão da própria conta** (na aba Perfil)
- **CRUD completo de Produtos** (catálogo): cadastrar, listar, editar,
  favoritar e excluir — tudo pela aba Catálogo / tela de detalhes
- **CRUD completo de Pedidos**: o carrinho vira um pedido ao finalizar a
  compra; dá pra editar a quantidade de cada item do pedido depois, ou
  excluir o pedido
- **Funciona sem internet**: clientes, produtos e pedidos ficam salvos
  no aparelho (SharedPreferences) e continuam lá mesmo fechando o app
  ou sem conexão nenhuma

## O que foi corrigido nesta versão

- **Removida a área de empresa** (login separado, dashboard e conta de
  teste `empresa@planhome.com`). O CRUD de produtos (criar/editar/excluir)
  agora fica direto na aba Catálogo e na tela de detalhes do produto,
  disponível para o próprio cliente.
- **Corrigido o bug dos Pedidos que só apareciam depois de reiniciar o
  app**: a tela de Pedidos ficava viva o tempo todo (por causa do
  `IndexedStack` do `HomeScreen`), então ela só buscava os dados salvos
  uma única vez, no `initState`. Depois de finalizar uma compra, a lista
  não era atualizada até o app reiniciar. Agora o `HomeScreen` força a
  tela de Pedidos a recarregar os dados: tanto ao finalizar uma compra
  quanto toda vez que o usuário abre a aba Pedidos.

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
    local_storage_service.dart   <- salva/lê tudo no armazenamento do aparelho
  controle/                <- as regras de negócio (o "C" do CRUD)
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
      produto_form_screen.dart
    carrinho/
      carrinho_tab.dart
    pedido/
      pedidos_tab.dart
      pedido_detalhes_screen.dart
```

## Como rodar

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install) (se ainda não tiver)
2. Descompacte este projeto e abra a pasta no terminal
3. Instale as dependências:
   ```
   flutter pub get
   ```
4. Rode o app (com um emulador aberto ou celular conectado):
   ```
   flutter run
   ```

## Primeiro uso

Como não existe um usuário pré-cadastrado, na primeira vez abra o app e
toque em **"Não tem conta? Cadastre-se"** na tela de login pra criar sua
conta de cliente. O catálogo já vem com 5 produtos de exemplo pra
facilitar os testes. Depois de logado, use o ícone **"+"** na aba
Catálogo (ou o botão dentro da tela de detalhes de cada produto) para
cadastrar, editar ou excluir produtos.

## Como testar a funcionalidade offline

1. Coloque o celular/emulador em **modo avião**
2. Cadastre um cliente, um produto e finalize uma compra (gerando um pedido)
3. Feche o app completamente e abra de novo, ainda em modo avião
4. Os dados cadastrados continuam aparecendo normalmente — tudo é lido
   direto do armazenamento interno do aparelho (`shared_preferences`),
   sem nenhuma chamada de rede em nenhum lugar do app

## Observação sobre o modal antigo

As telas de produto anteriormente abriam um `showModalBottomSheet` ao
tocar em "Detalhes". Isso foi substituído por uma tela cheia
(`ProdutoDetalhesScreen`), o que deixa mais fácil incluir os botões de
editar/excluir/favoritar e mantém a navegação mais clara.
