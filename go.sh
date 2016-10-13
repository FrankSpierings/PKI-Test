#!/bin/bash

#Clean out
rm -rf OfflineRootCA/{*.crl,*.pem,*.crt,*.csr,*.key,db}
rm -rf IssuingCA/{*.crl,*.pem,*.crt,*.csr,*.key,db}
rm -rf Request/{*.pem,*.crt,*.key,db}
rm -rf Output/*

#Setup Offline Root CA
mkdir -p OfflineRootCA/db/
touch OfflineRootCA/db/certindex
echo 1000 > OfflineRootCA/db/certserial
echo 1000 > OfflineRootCA/db/crlnumber

openssl genrsa -out OfflineRootCA/OfflineRootCA.key 2048
openssl req -config OfflineRootCA/OfflineRootCA.req.conf -sha256 -new -x509 -days 1826 -key  OfflineRootCA/OfflineRootCA.key -out OfflineRootCA/OfflineRootCA.crt
openssl x509 -in OfflineRootCA/OfflineRootCA.crt -text

#Setup Issuing CA
mkdir -p IssuingCA/db/
touch IssuingCA/db/certindex
echo 1000 > IssuingCA/db/certserial
echo 1000 > IssuingCA/db/crlnumber

openssl genrsa -out IssuingCA/IssuingCA.key 2048
openssl req -config IssuingCA/IssuingCA.req.conf -sha256 -new -key IssuingCA/IssuingCA.key -out IssuingCA/IssuingCA.csr
#Sign Issuing CA with Offline Root CA
openssl ca -batch -config OfflineRootCA/OfflineRootCA.conf -in IssuingCA/IssuingCA.csr -out IssuingCA/IssuingCA.crt

#Sign Request CA with Issuing CA
openssl ca -batch -config IssuingCA/IssuingCA.conf -in Request/Request.csr -out Request/Request.crt

#Publish Offline Root CRL
openssl ca -config OfflineRootCA/OfflineRootCA.conf -gencrl -crlexts crl_ext -out OfflineRootCA/OfflineRootCA.crl

#Publish Issuing CA CRL
openssl ca -config IssuingCA/IssuingCA.conf -gencrl -crlexts crl_ext -out IssuingCA/IssuingCA.crl

#Setup the output
mkdir -p Output

cp OfflineRootCA/{*.crl,*.crt} Output
cp IssuingCA/{*.crl,*.crt} Output
cp Request/{*.crl,*.crt} Output

#Show the magic
openssl x509 -in Output/OfflineRootCA.crt -text
openssl x509 -in Output/IssuingCA.crt -text
openssl x509 -in Output/Request.crt -text
