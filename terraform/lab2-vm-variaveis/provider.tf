provider "azurerm" {
  features {

  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0" ## aceita qualquer versão 3.0 pra cima
    }
  }
  required_version = ">= 1.0" ## aceita qualquer versão 1.0 acima do terraform
}
## Boa prática é definir a versão, evitando quebras em produção,
## ainda mais que outras pessoas também vão utilizar aquele arquivo
## ele vai rodar em pipelines e etc.