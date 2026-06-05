terraform {
  required_version = ">= 1.5.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.70"
    }
  }
}

# El API key se inyecta automáticamente cuando se ejecuta desde
# IBM Cloud Schematics, por lo que NO se hardcodea aquí.
# En ejecución local, exporta: export IC_API_KEY="tu_api_key"
provider "ibm" {
  region = var.region
}
