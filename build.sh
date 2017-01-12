#!/bin/bash

# re-fetch XSL file
rm 'jats-to-unixref.xsl'
wget 'https://raw.githubusercontent.com/PeerJ/jats-conversion/master/src/data/xsl/jats-to-unixref.xsl'

# fetch CrossRef schema files
mkdir -p crossref
wget --recursive --level=1 --directory-prefix=crossref --no-directories --timestamping --accept xsd http://doi.crossref.org/schemas/

# fetch and compile CrossRef Schematron rules
# mkdir /tmp/crossref
# wget -P /tmp/crossref http://www.crossref.org/schematron/CrossRef_Schematron_Rules.zip
# unzip /tmp/crossref/CrossRef_Schematron_Rules.zip -d /tmp/crossref
# xsltproc -output crossref/schematron.xsl /tmp/crossref/CrossRef_Schematron_Rules/iso_svrl.xsl /tmp/crossref/CrossRef_Schematron_Rules/deposit.sch
