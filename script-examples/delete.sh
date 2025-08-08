#!/bin/bash

# Variaveis de teste
CONFIRM_DELETE="true"
DELETE_TYPE="hard"
CCLOUD_BASE_URL="https://xxxxxxxxxxxxxxxxx.aws.confluent.cloud"
SUBJECT_TO_DELETE="topico-teste-pubsub-value"
CONFLUENT_CREDENTIALS_USR="xxxxxxxxxxxxxxxxx"
CONFLUENT_CREDENTIALS_PSW="xxxxxxxxxxxxxxxxx"

# Habilita a falha imediata em caso de erro e em pipelines
set -e
set -o pipefail

# --- 1. LEITURA E VALIDAÇÃO DOS PARÂMETROS DO JENKINS ---
# A caixa de confirmação é a nossa trava de segurança mais importante.
if [ "$CONFIRM_DELETE" != "true" ]; then
    echo "⛔️  ERRO FATAL: A caixa de confirmação de exclusão não foi marcada."
    echo "Processo abortado por segurança."
    exit 1
fi

# Valida se os parâmetros essenciais foram preenchidos
if [ -z "$CCLOUD_BASE_URL" ] || [ -z "$SUBJECT_TO_DELETE" ]; then
    echo "⛔️  ERRO FATAL: Os parâmetros 'CCLOUD_BASE_URL' ou 'SUBJECT_TO_DELETE' estão vazios."
    exit 1
fi

# O plugin de credenciais do Jenkins injeta as variáveis com _USR e _PSW
API_KEY="${CONFLUENT_CREDENTIALS_USR}"
API_SECRET="${CONFLUENT_CREDENTIALS_PSW}"

if [ -z "$API_KEY" ]; then
    echo "⛔️  ERRO FATAL: A API Key não foi encontrada. Verifique a configuração de credenciais."
    exit 1
fi

# Monta a string de autenticação para o curl
USERPASS="${API_KEY}:${API_SECRET}"

echo "--------------------------------------------------"
echo "Confirmação de segurança verificada."
echo "URL do Schema Registry: ${CCLOUD_BASE_URL}"
echo "Iniciando processo para o subject: '${SUBJECT_TO_DELETE}'"
echo "--------------------------------------------------"

# --- 2. VALIDAÇÃO: VERIFICAR SE O SUBJECT EXISTE ---
echo -e "Validando a existência e buscando versões do subject..."

# Usamos -s para modo silencioso e -w para escrever o código de status HTTP no final
# Isso nos permite capturar tanto o corpo da resposta quanto o status
response=$(curl -s -w "%{http_code}" -u "$USERPASS" "${CCLOUD_BASE_URL}/subjects/${SUBJECT_TO_DELETE}/versions")

# Extrai o código de status (os últimos 3 caracteres da resposta)
http_status=$(echo "$response" | tail -c 4)
# Extrai o corpo da resposta (tudo menos os últimos 3 caracteres)
body=$(echo "$response" | sed '$ s/...$//')

if [ "$http_status" -eq 404 ]; then
    echo "⚠️  ERRO: O subject '${SUBJECT_TO_DELETE}' não foi encontrado (HTTP 404)."
    echo "Processo abortado."
    exit 1
elif [ "$http_status" -ne 200 ]; then
    echo "❌ ERRO na API ao buscar versões. Status: ${http_status}"
    echo "Resposta: ${body}"
    exit 1
fi

# A linha abaixo usa 'jq' para formatar o JSON. Se 'jq' não estiver instalado, ela apenas imprimirá o JSON bruto.
echo "Subject encontrado! Versões que serão afetadas: $body" | (jq . 2>/dev/null || cat)

# --- 3. EXECUÇÃO DA EXCLUSÃO ---

# Define o parâmetro 'permanent' com base na escolha do usuário
if [ "$DELETE_TYPE" == "hard" ]; then
    IS_PERMANENT="true"
    echo -e "\nExecutando HARD DELETE (exclusão permanente)..."
else
    IS_PERMANENT="false"
    echo -e "\nExecutando SOFT DELETE (exclusão lógica)..."
fi

delete_response=$(curl -s -w "%{http_code}" -X DELETE -u "$USERPASS" "${CCLOUD_BASE_URL}/subjects/${SUBJECT_TO_DELETE}?permanent=${IS_PERMANENT}")
delete_status=$(echo "$delete_response" | tail -c 4)
delete_body=$(echo "$delete_response" | sed '$ s/...$//')

# Resposta: {"error_code":40405,"message":"Subject 'topico-teste-pubsub-value' was not deleted first before being permanently deleted; error code: 40405"}

# --- 4. RESULTADO FINAL ---

echo -e "\nResultado da exclusão:"

if [ "$delete_status" -ne 200 ]; then
    echo "❌ FALHA! A exclusão do subject '${SUBJECT_TO_DELETE}' não foi concluída."
    echo "Status da API: ${delete_status}"
    echo "Resposta: ${delete_body}"
    exit 1
fi

echo "SUCESSO! O subject '${SUBJECT_TO_DELETE}' foi excluído."
echo "Versões que foram afetadas pela exclusão: $delete_body" | (jq . 2>/dev/null || cat)
echo "--------------------------------------------------"
echo "Processo finalizado com sucesso."