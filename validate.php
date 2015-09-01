<?php

// edit this to update to a newer schema
define('CROSSREF_SCHEMA', __DIR__  . '/crossref/crossref4.3.6.xsd');

if (!isset($argv[1])) {
	exit("Usage: {$argv[0]} file-to-validate.xml\n");
}

$file = $argv[1];

$doc = new DOMDocument;
$doc->load($file);

$stylesheet = new DOMDocument;
$stylesheet->load('jats-to-unixref.xsl');

$processor = new XSLTProcessor;
$processor->importStylesheet($stylesheet);

$now = new \DateTime();
$processor->setParameter(null, 'timestamp', $now->getTimestamp());
$processor->setParameter(null, 'depositorName', 'PeerJ');
$processor->setParameter(null, 'depositorEmail', 'test@peerj.com');

$output = $processor->transformToDoc($doc);

libxml_use_internal_errors(true);
if ($output->schemaValidate(CROSSREF_SCHEMA)) {
	print "The document is valid\n";
} else {
	$errors = libxml_get_errors();

	foreach ($errors as $error) {
		printf('Line %d: %s', $error->line, $error->message);
    }
}
libxml_use_internal_errors(false);
