# Laboratório de Infraestrutura como Código — Terraform, Ansible e Docker

Este repositório contém os arquivos utilizados no laboratório prático da aula de **Gerência de Configurações e Automação**, com foco em **Infraestrutura como Código (IaC)** utilizando Terraform, Docker e Ansible.

A apresentação em PowerPoint utilizada para acompanhar a aula será disponibilizada pelo professor no **Moodle**.

---

## Objetivo do laboratório

O objetivo desta atividade é demonstrar como ferramentas de automação podem ser utilizadas para provisionar infraestrutura, configurar ambientes e realizar o deploy de uma aplicação.

Ao final do laboratório, teremos o seguinte fluxo:

```text
Terraform
    |
    v
Docker
    |
    v
Container Ubuntu
    |
    v
Ansible
    |
    +--> Python
    +--> Node.js
    +--> npm
    +--> PM2
    |
    v
API Node.js
    |
    v
http://localhost:3000
```

Cada ferramenta possui uma responsabilidade específica:

* **Terraform:** provisionamento da infraestrutura;
* **Docker:** execução do ambiente isolado;
* **Ansible:** configuração automatizada do ambiente;
* **Node.js:** execução da aplicação;
* **PM2:** gerenciamento do processo da API.

---

# 1. Estrutura do projeto

```text
iac-lab/
│
├── README.md
├── .gitignore
│
├── api/
│   ├── package.json
│   ├── package-lock.json
│   └── src/
│       └── server.js
│
├── terraform/
│   └── main.tf
│
└── ansible/
    ├── inventory.ini
    ├── preparar-container.yml
    └── instalar-api.yml
```

## Diretório `api`

Contém uma API desenvolvida em Node.js e Express.

A rota padrão:

```text
GET /
```

retorna a data e a hora atuais.

Após o laboratório, a aplicação poderá ser acessada em:

```text
http://localhost:3000
```

---

## Diretório `terraform`

Contém a definição da infraestrutura utilizada pelo laboratório.

O Terraform será responsável por:

* utilizar o provider Docker;
* baixar a imagem Ubuntu;
* criar o container `ubuntu-server`;
* manter o container em execução;
* publicar a porta `3000` do container na máquina física.

---

## Diretório `ansible`

Contém os arquivos utilizados para configurar automaticamente o container criado pelo Terraform.

O Ansible será responsável por:

* preparar o container;
* instalar Python;
* instalar Node.js;
* instalar npm;
* copiar a API para o container;
* instalar as dependências da aplicação;
* configurar o PM2;
* iniciar a API;
* testar o funcionamento do serviço.

---

# 2. Pré-requisitos

Antes de iniciar o laboratório, certifique-se de possuir:

* Windows 10 ou Windows 11;
* WSL2;
* distribuição Ubuntu no WSL;
* Docker Desktop;
* Terraform;
* Ansible;
* Git.

Verifique se o Docker está funcionando:

```bash
docker --version
```

Verifique o Terraform:

```bash
terraform --version
```

Verifique o Ansible:

```bash
ansible --version
```

Verifique o Git:

```bash
git --version
```

---

# 3. Clonando o laboratório

Abra o terminal do WSL.

Acesse o diretório onde deseja armazenar o projeto:

```bash
cd /mnt/c/
```

Clone o repositório:

```bash
git clone URL_DO_REPOSITORIO
```

Depois:

```bash
cd iac-lab
```

> Substitua `URL_DO_REPOSITORIO` pelo endereço disponibilizado pelo professor.

---

# 4. Provisionamento com Terraform

Acesse o diretório:

```bash
cd terraform
```

Inicialize o Terraform:

```bash
terraform init
```

Visualize o plano de execução:

```bash
terraform plan
```

Crie a infraestrutura:

```bash
terraform apply
```

Confirme a execução quando solicitado.

Depois verifique:

```bash
docker ps
```

O container:

```text
ubuntu-server
```

deverá estar em execução.

A porta deverá apresentar um mapeamento semelhante a:

```text
0.0.0.0:3000->3000/tcp
```

---

# 5. Configuração com Ansible

Volte para a raiz do projeto:

```bash
cd ..
```

Entre no diretório:

```bash
cd ansible
```

Caso ainda não possua a collection Docker do Ansible:

```bash
ansible-galaxy collection install community.docker
```

---

# 6. Verificando o inventário

Execute:

```bash
ansible-inventory -i inventory.ini --graph
```

O resultado deverá apresentar aproximadamente:

```text
@all:
  |--@containers:
  |  |--ubuntu-server
```

O arquivo `inventory.ini` informa ao Ansible qual ambiente será gerenciado.

---

# 7. Preparando o container

Containers Ubuntu mínimos normalmente não possuem Python instalado.

Como os módulos do Ansible dependem de Python no nó gerenciado, inicialmente utilizamos o módulo `raw`, que permite executar comandos antes da instalação do Python.

Execute:

```bash
ansible-playbook -i inventory.ini preparar-container.yml
```

Depois teste:

```bash
ansible -i inventory.ini containers -m ping
```

Resultado esperado:

```text
ubuntu-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Isso confirma que o Ansible consegue gerenciar o container.

---

# 8. Instalando a API

Execute:

```bash
ansible-playbook -i inventory.ini instalar-api.yml
```

O playbook realizará automaticamente as etapas necessárias para preparar o ambiente da aplicação.

Fluxo:

```text
Ansible
   |
   +--> instala Node.js
   |
   +--> instala npm
   |
   +--> copia ../api
   |
   +--> npm install
   |
   +--> instala PM2
   |
   +--> inicia a API
   |
   +--> testa a porta 3000
   |
   +--> testa o endpoint HTTP
```

---

# 9. Verificando a aplicação

Confira os processos gerenciados pelo PM2:

```bash
docker exec ubuntu-server pm2 list
```

A aplicação deverá aparecer com status:

```text
online
```

Teste pelo terminal:

```bash
curl http://localhost:3000
```

A API deverá retornar uma resposta JSON contendo a data e a hora atuais.

---

# 10. Acessando pela máquina física

Abra o navegador no Windows e acesse:

```text
http://localhost:3000
```

O caminho da requisição será:

```text
Navegador
Windows
    |
    | localhost:3000
    v
Docker Desktop
    |
    | porta 3000
    v
ubuntu-server
    |
    v
Node.js / Express
    |
    v
API
```

---

# 11. Alterando a aplicação

O código-fonte está no diretório:

```text
api/
```

O arquivo principal é:

```text
api/src/server.js
```

Após realizar uma alteração no código, execute novamente:

```bash
cd ansible
ansible-playbook -i inventory.ini instalar-api.yml
```

O Ansible realizará novamente o processo de implantação.

---

# 12. Comandos úteis

Listar containers:

```bash
docker ps
```

Listar todos os containers:

```bash
docker ps -a
```

Entrar no container:

```bash
docker exec -it ubuntu-server bash
```

Consultar a versão do Node.js:

```bash
docker exec ubuntu-server node --version
```

Consultar processos do PM2:

```bash
docker exec ubuntu-server pm2 list
```

Consultar logs:

```bash
docker exec ubuntu-server pm2 logs api-data-hora
```

Testar a API:

```bash
curl http://localhost:3000
```

---

# 13. Destruindo a infraestrutura

Ao finalizar o laboratório, a infraestrutura criada pelo Terraform pode ser removida.

Entre no diretório:

```bash
cd terraform
```

Execute:

```bash
terraform destroy
```

Confirme quando solicitado.

Depois:

```bash
docker ps
```

O container `ubuntu-server` não deverá mais existir.

---

# Conceitos trabalhados

Durante este laboratório são aplicados conceitos de:

* Infraestrutura como Código (IaC);
* provisionamento automatizado;
* gerência de configuração;
* containers;
* automação de ambientes;
* infraestrutura declarativa;
* idempotência;
* deploy automatizado;
* gerenciamento de processos;
* separação entre infraestrutura e configuração.

---

# Terraform x Ansible

Embora Terraform e Ansible possam realizar algumas tarefas semelhantes, neste laboratório cada ferramenta possui uma responsabilidade bem definida.

```text
TERRAFORM
Infraestrutura
     |
     +--> imagem Docker
     +--> container
     +--> portas
     +--> recursos
     
        ↓

ANSIBLE
Configuração
     |
     +--> pacotes
     +--> Node.js
     +--> arquivos
     +--> dependências
     +--> aplicação
```

Essa separação permite compreender dois aspectos importantes da automação de infraestrutura:

**Terraform:** define **o que deve existir**.

**Ansible:** define **como o ambiente deve ser configurado**.

---

# Material da aula

A apresentação em **PowerPoint** utilizada para acompanhar este laboratório está disponível no **Moodle** da disciplina.

Recomenda-se realizar as etapas deste README acompanhando simultaneamente a apresentação disponibilizada pelo professor.

---

# Resultado esperado

Ao concluir o laboratório:

```text
Código
  +
Terraform
  +
Docker
  +
Ansible
  +
Node.js
  ↓
Ambiente provisionado
e configurado automaticamente
  ↓
API disponível em
http://localhost:3000
```
