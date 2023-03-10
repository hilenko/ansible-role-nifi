#!/bin/bash

# Run export-certificate to obtain an ACM certificate and save it to a file
aws acm export-certificate --certificate-arn ${CERTIFICATE_ARN} --region=${REGION} --passphrase ${PASSPHRASE} | jq -r '"\(.Certificate)\(.CertificateChain)\(.PrivateKey)"' > ${STORE_PATH}/${DOMAIN_NAME}.pem

# To split a certificate and a private key into two separate files
openssl rsa -in ${STORE_PATH}/${DOMAIN_NAME}.pem -out ${STORE_PATH}/${DOMAIN_NAME}.key -passin pass:${PASSPHRASE}
openssl x509 -in ${STORE_PATH}/${DOMAIN_NAME}.pem -out ${STORE_PATH}/${DOMAIN_NAME}.crt

# Create certification
openssl pkcs12 -export -in ${STORE_PATH}/${DOMAIN_NAME}.crt -inkey ${STORE_PATH}/${DOMAIN_NAME}.key -out ${STORE_PATH}/${DOMAIN_NAME}.p12 -name ${DOMAIN_NAME} -password pass:${KEYSTORE_PASSWORD}
# Create keystore
keytool -importkeystore -deststorepass ${KEYSTORE_PASSWORD} -destkeypass ${KEYSTORE_PASSWORD} -destkeystore ${STORE_PATH}/${KEYSTORE_NAME}.jks -srckeystore ${STORE_PATH}/${DOMAIN_NAME}.p12 -srcstoretype PKCS12 -srcstorepass ${KEYSTORE_PASSWORD} -alias ${DOMAIN_NAME}

# Create trustore and add to trustore
keytool -import -file ${DOMAIN_NAME}.pem -alias ${DOMAIN_NAME} -storepass ${TRUSTORE_PASSWORD} -keystore ${STORE_PATH}/${TRUSTORE_NAME}.jks -noprompt

# Delete certification files
rm $STORE_PATH/${DOMAIN_NAME}.pem
rm $STORE_PATH/${DOMAIN_NAME}.p12
rm $STORE_PATH/${DOMAIN_NAME}.crt
rm $STORE_PATH/${DOMAIN_NAME}.key

# Clear the variables with passwords, region, keystore and truststore names, and path for saving files
unset KEYSTORE_PASSWORD
unset TRUSTORE_PASSWORD
unset PASSPHRASE
unset REGION
unset KEYSTORE_NAME
unset TRUSTORE_NAME
unset STORE_PATH
unset DOMAIN_NAME
unset CERTIFICATE_ARN
## Clear the variables with the Vault address and token
unset VAULT_ADDR
unset VAULT_SKIP_VERIFY

# check $ keytool -v -list -keystore keystore.jks
