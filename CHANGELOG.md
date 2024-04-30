## 0.5.0 (2024-04-30)

### Novos Recursos

- Adicionados os seguintes métodos:
  - `setUser()`: Método para salvar os dados do usuário antes de um identify.
  - `removeMobileToken()`: Método para remover o token de um usuário.
  - `initializePushNotificationService()`: Método para inicializar o serviço de mobile push notification.
  - `setAndroidDetails()`: Método para personalizar o serviço de mobile push notification no Android.
  - `setIosDetails()`: Método para personalizar o serviço de mobile push notification no iOS.

### Mudanças

- Depreciado método `setUserId`.
- Removido método `setUserAgent` que agora é gerado automaticamente.

## 0.4.0 (2023-11-23)

### Novos Recursos

- Adicionados os seguintes métodos:
  - `registryMobileToken()`: Método para cadastrar o token do mobile para o usuário.
  - `openNotification()`: Método para notificar da abertura de uma notificação mobile.

### Mudanças

- Removido atributo `encoding` de todas requisições.
- Removido `json.encode` do atributo `data` no método `identifyUser()`.
- Método `identifyUser()` retornando o resultado da requisição. (alterado para `Future<http.Response>`).

### Correções de Bugs

- Nenhuma correção de bugs nessa versão.

### Notas Adicionais

- Nenhuma nota adicional nessa versão.

## 0.3.0 (2023-10-26)

### Novos Recursos

- Armazenamento de eventos enquanto não estiver com um userID registrado.
- Envio dos eventos armazenados assim que registrar um userID.

### Mudanças

- Nenhuma mudança nessa versão.

### Correções de Bugs

- Nenhuma correção de bugs nessa versão.

### Notas Adicionais

- Nenhuma nota adicional nessa versão.

## 0.2.0 (2023-10-10)

### Novos Recursos

- Nenhum novo recurso nessa versão.

### Mudanças

- Renomeado o método `registerUser()` para `identifyUser()`.
- Feito melhorias na documentação.

### Correções de Bugs

- Nenhuma correção de bugs nessa versão.

### Notas Adicionais

- Nenhuma nota adicional nessa versão.

## 0.1.1 (2023-10-02)

### Novos Recursos

- Nenhum novo recurso nessa versão.

### Mudanças

- Removido `print` dos métodos.
- Feito a tratativa de exceções nos métodos que contem requisição.

### Correções de Bugs

- Nenhuma correção de bugs nessa versão.

### Notas Adicionais

- Nenhuma nota adicional nessa versão.

## 0.1.0 (2023-10-02)

### Novos Recursos

- Adicionados os seguintes métodos:
  - `initialize`: Método para inicializar a biblioteca.
  - `identify`: Permite guardar dados do usuário.
  - `registerUser`: Possibilita o registro do usuário.
  - `trackEvent`: Permite o registro de evento.
  - `setUserId`: Permite definir o ID do usuário.
  - `setUserAgent`: Permite definir o User-Agent.

### Mudanças

- Nenhuma mudança significativa nessa versão.

### Correções de Bugs

- Nenhuma correção de bugs nessa versão.

### Outras Alterações

- Nenhuma outra alteração nessa versão.

### Notas Adicionais

- Esta é a primeira versão do nosso package Flutter.
