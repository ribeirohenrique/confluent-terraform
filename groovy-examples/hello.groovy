import groovyx.net.http.RESTClient
import groovy.json.JsonSlurper
import java.lang.String
import groovy.transform.Field
import java.io.File

@Grab(group='org.codehaus.groovy.modules.http-builder', module='http-builder', version='0.7.1')


@groovy.transform.Field
String confluent_cloud_api_key    = ***REMOVED***
String confluent_cloud_api_secret = ***REMOVED***
String organization_id            = ***REMOVED***
String environment_id             = ***REMOVED***
String cluster_id                 = ***REMOVED***
String topic_name                 = "terraform-topic"
String rest_endpoint              = ***REMOVED***
String gcp_dataset_name           = "negc_cartoes_123"
String gcp_project_id             = "confluent-project"

def jsonInput = {
  "type": "service_account_123",
  "project_id": "confluent-project",
  "private_key_id": "xxxxxxxxxxxxxxxxxxxxx",
  "private_key": "\n-----BEGIN PRIVATE KEY-----\nxxxx\nyyyy\naaa\nbbb\nccc\n-----END PRIVATE KEY-----\n",
  "client_email": "confluent-service-account@gserviceaccount.com",
  "client_id": "1111111111111111",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/confluent-service-account2gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

def outputLines = [
    "confluent_cloud_api_key = \"$confluent_cloud_api_key\"",
    "confluent_cloud_api_secret = \"$confluent_cloud_api_secret\"",
    "organization_id = \"$organization_id\"",
    "environment_id = \"$environment_id\"",
    "cluster_id = \"$cluster_id\"",
    "topic_name = \"$topic_name\"",
    "rest_endpoint = \"$rest_endpoint\"",
    "gcp_dataset_name = \"$gcp_dataset_name\"",
    "gcp_project_id = \"$gcp_project_id\"",
    "keyfile = $jsonInput"
]

def outputFileName = '/home/developer/terraform-rbac-example/groovy-examples/terra.tfvars'
new File(outputFileName).withWriter { writer ->
    outputLines.each { line ->
        writer.writeLine line
    }
}