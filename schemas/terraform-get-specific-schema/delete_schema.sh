#!/bin/bash

# Verifica se todos os argumentos foram passados
if [ "$#" -ne 5 ]; then
    echo "Uso: $0 <base_url> <api_key> <api_secret> <subject_name> <version>"
    exit 1
fi

# Variáveis de entrada
BASE_URL=$1
API_KEY=$2
API_SECRET=$3
SUBJECT_NAME=$4
VERSION=$5

# Requisição para deletar a versão do schema
RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
    --location --request DELETE \
    --header "Authorization: Basic $(echo -n ${API_KEY}:${API_SECRET} | base64)" \
    "${BASE_URL}/subjects/${SUBJECT_NAME}/versions/${VERSION}")

# Extrai o corpo e o código de status da resposta
BODY=$(echo "$RESPONSE" | sed -e 's/HTTPSTATUS\:.*//g')
HTTP_STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

# Verifica o código de status HTTP
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Schema ${SUBJECT_NAME} versão ${VERSION} deletado com sucesso."
else
    echo "Erro ao deletar schema. HTTP Status: $HTTP_STATUS. Resposta: $BODY"
    exit 1
fi
