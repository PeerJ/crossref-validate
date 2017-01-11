Convert a JATS XML document to CrossRef's Deposit Schema, and validate against the schema.

## Usage

1. Run `./build.sh` to fetch the schema files from CrossRef's web server.
2. Run `php validate.php file-to-validate.xml` to validate a JATS XML file.

`jats-to-unixref.xsl` is copied from https://github.com/PeerJ/jats-conversion/blob/master/src/data/xsl/jats-to-unixref.xsl
