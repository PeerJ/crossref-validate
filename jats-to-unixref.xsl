<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:fr="http://www.crossref.org/fundref.xsd"
                xmlns="http://www.crossref.org/schema/4.3.6"
                xsi:schemaLocation="http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schema/deposit/crossref4.3.6.xsd http://www.crossref.org/fundref.xsd http://www.crossref.org/schema/deposit/fundref.xsd"
                exclude-result-prefixes="xlink">

	<xsl:output method="xml" indent="yes" encoding="UTF-8" standalone="yes"/>

	<xsl:strip-space elements="aff"/>

	<xsl:variable name="doi" select="/article/front/article-meta/article-id[@pub-id-type='doi']"/>
	<xsl:variable name="url" select="/article/front/article-meta/self-uri/@xlink:href"/>

    <xsl:param name="timestamp"/>
	<xsl:param name="depositorName"/>
	<xsl:param name="depositorEmail"/>

	<xsl:param name="batchId" select="$doi"/>

	<!-- root element -->

	<xsl:template match="/">
		<doi_batch version="4.3.6" xsi:schemaLocation="http://www.crossref.org/schema/4.3.6 http://www.crossref.org/schema/deposit/crossref4.3.6.xsd">
			<head>
				<xsl:call-template name="deposition"/>
			</head>
			<body>
				<xsl:apply-templates select="article"/>
			</body>
		</doi_batch>
	</xsl:template>

	<!-- deposition metadata -->

	<xsl:template name="deposition">
		<doi_batch_id>
			<xsl:value-of select="$batchId"/>
		</doi_batch_id>

		<timestamp>
			<xsl:value-of select="$timestamp"/>
		</timestamp>

		<depositor>
			<depositor_name>
				<xsl:value-of select="$depositorName"/>
			</depositor_name>
			<email_address><xsl:value-of select="$depositorEmail"/></email_address>
		</depositor>

		<registrant>
			<xsl:value-of select="$depositorName"/>
		</registrant>
	</xsl:template>

	<!-- item metadata -->

	<xsl:template match="article">
        <xsl:variable name="meta" select="front/article-meta"/>
        <xsl:variable name="pub-date" select="$meta/pub-date[@date-type='pub'][@pub-type='epub']|$meta/pub-date[@date-type='preprint'][@pub-type='epreprint']"/>
		<journal>
			<!-- journal -->
			<journal_metadata language="en">
				<full_title>
					<xsl:value-of select="front/journal-meta/journal-title-group/journal-title"/>
				</full_title>

				<issn media_type="electronic">
					<xsl:value-of select="front/journal-meta/issn"/>
				</issn>
			</journal_metadata>

			<!-- journal issue -->
			<journal_issue>
				<publication_date media_type="online">
					<year><xsl:value-of select="$pub-date/year/@iso-8601-date"/></year>
				</publication_date>

				<journal_volume>
					<volume>
						<xsl:value-of select="$meta/volume"/>
					</volume>
				</journal_volume>
			</journal_issue>

			<!-- article -->
			<journal_article publication_type="full_text">
				<!-- article metadata -->
				<xsl:apply-templates select="front/article-meta"/>

				<!-- references -->
				<!-- note: only uses the first reference list -->
				<xsl:apply-templates select="back/ref-list[1]"/>

				<!-- components -->
				<component_list>
					<xsl:apply-templates select="body//fig[object-id[@pub-id-type='doi']]" mode="component"/>
					<xsl:apply-templates select="body//table-wrap[object-id[@pub-id-type='doi']]" mode="component"/>
					<xsl:apply-templates select="body//supplementary-material[object-id[@pub-id-type='doi']]" mode="component"/>
				</component_list>
			</journal_article>
		</journal>
	</xsl:template>

	<!-- article metadata -->

	<xsl:template match="article-meta">
		<titles>
			<xsl:apply-templates select="title-group/article-title" mode="title"/><!-- TODO: markup? -->
		</titles>

		<contributors>
			<xsl:apply-templates select="contrib-group/contrib[@contrib-type='author']"/>
		</contributors>

		<publication_date media_type="online">
            <xsl:variable name="pub-date" select="pub-date[@date-type='pub'][@pub-type='epub']|pub-date[@date-type='preprint'][@pub-type='epreprint']"/>
            <month>
                <xsl:apply-templates select="$pub-date/month" mode="zero-pad-date"/>
            </month>
            <day>
                <xsl:apply-templates select="$pub-date/day" mode="zero-pad-date"/>
            </day>
            <year>
                <xsl:value-of select="$pub-date/year/@iso-8601-date"/>
            </year>
		</publication_date>

        <pages>
            <first_page>
                <xsl:value-of select="elocation-id"/>
            </first_page>
        </pages>

		<publisher_item>
			<identifier id_type="doi">
				<xsl:value-of select="$doi"/>
			</identifier>
		</publisher_item>

        <!--
        <xsl:call-template name="fundref"/>
        -->

		<doi_data>
			<doi>
				<xsl:value-of select="$doi"/>
			</doi>
			<resource>
				<xsl:value-of select="self-uri/@xlink:href"/>
			</resource>
		</doi_data>
	</xsl:template>

    <!-- zero-pad a month or day number -->
    <xsl:template match="month | day" mode="zero-pad-date">
        <xsl:variable name="text" select="text()"/>
        <xsl:if test="string-length($text) = 1">
            <xsl:text>0</xsl:text>
        </xsl:if>
        <xsl:value-of select="$text"/>
    </xsl:template>

	<!-- article title -->

	<xsl:template match="article-title" mode="title">
		<title>
			<xsl:apply-templates mode="title"/>
		</title>
	</xsl:template>

	<!-- style markup for title -->

	<xsl:template match="bold" mode="title">
		<b><xsl:apply-templates mode="title"/></b>
	</xsl:template>

	<xsl:template match="italic" mode="title">
		<i><xsl:apply-templates mode="title"/></i>
	</xsl:template>

	<xsl:template match="underline" mode="title">
		<u><xsl:apply-templates mode="title"/></u>
	</xsl:template>

	<xsl:template match="overline" mode="title">
		<ovl><xsl:apply-templates mode="title"/></ovl>
	</xsl:template>

	<xsl:template match="sup" mode="title">
		<sup><xsl:apply-templates mode="title"/></sup>
	</xsl:template>

	<xsl:template match="sub" mode="title">
		<sub><xsl:apply-templates mode="title"/></sub>
	</xsl:template>

	<xsl:template match="sc" mode="title">
		<scp><xsl:apply-templates mode="title"/></scp>
	</xsl:template>

	<xsl:template match="monospace" mode="title">
		<tt><xsl:apply-templates mode="title"/></tt>
	</xsl:template>

	<!-- TODO: math markup -->

	<!-- publication date -->

	<xsl:template match="pub-date">
		<month><xsl:value-of select="month"/></month>
		<day><xsl:value-of select="day"/></day>
		<year><xsl:value-of select="year"/></year>
	</xsl:template>

	<!-- contributors -->

	<xsl:template match="contrib">
		<xsl:choose>
			<xsl:when test="name">
				<person_name contributor_role="author" sequence="additional">
					<xsl:call-template name="contributor-sequence"/>
					<xsl:apply-templates select="name" mode="contrib"/>
					<xsl:apply-templates select="xref[@ref-type='aff']" mode="contrib"/>
					<!--<xsl:apply-templates select="contrib-id" mode="contrib"/>-->
				</person_name>
			</xsl:when>
			<xsl:when test="collab">
				<organization contributor_role="author" sequence="additional">
					<xsl:call-template name="contributor-sequence"/>
					<xsl:value-of select="collab"/><!-- string value -->
				</organization>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="contributor-sequence">
		<xsl:choose>
			<xsl:when test="position() = 1">
				<xsl:attribute name="sequence">first</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="sequence">additional</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- contributor name -->

	<xsl:template match="name" mode="contrib">
		<!-- there must be a surname, so use given-names as surname if needed -->
		<xsl:choose>
			<xsl:when test="surname">
				<xsl:if test="given-names">
					<given_name>
						<xsl:value-of select="given-names"/>
					</given_name>
				</xsl:if>

				<surname>
					<xsl:value-of select="surname"/>
				</surname>
			</xsl:when>

			<xsl:otherwise>
				<surname>
					<xsl:value-of select="given-names"/>
				</surname>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="suffix">
			<suffix>
				<xsl:apply-templates select="suffix"/>
			</suffix>
		</xsl:if>
	</xsl:template>

	<!--
	<xsl:template match="contrib-id[@contrib-id-type='orcid']" mode="contrib">
		<ORCID authenticated="false">
			<xsl:value-of select="."></xsl:value-of>
		</ORCID>
	</xsl:template>
	-->

	<!-- affiliation -->

	<xsl:template match="xref[@ref-type='aff']" mode="contrib">
		<xsl:apply-templates select="//aff[@id=current()/@rid]" mode="contrib"/>
	</xsl:template>

	<xsl:template match="aff" mode="contrib">
		<affiliation>
			<xsl:apply-templates select="node()" mode="aff"/>
		</affiliation>
	</xsl:template>

	<!-- include most elements in affiliations -->
	<xsl:template match="*" mode="aff">
		<xsl:value-of select="."/>
		<xsl:if test="position() != last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- don't include the label in affiliations -->
	<xsl:template match="label" mode="aff"/>

    <!-- ignore text nodes (commas) in affiliations -->
    <xsl:template match="text()" mode="aff"/>

    <!-- fundref assertions -->
    <xsl:template name="fundref">
        <xsl:variable name="award-group" select="funding-group/award-group"/>

        <xsl:if test="$award-group/funding-source and $award-group/award-id">
            <fr:program>
                <fr:assertion name="fundgroup">
                    <fr:assertion name="funder_name">
                        <xsl:value-of select="funding-source"/>
                    </fr:assertion>
                    <fr:assertion name="funding_identifier">
                        <xsl:value-of select="award-id"/>
                    </fr:assertion>
                </fr:assertion>
            </fr:program>
        </xsl:if>
    </xsl:template>

	<!-- reference list -->

	<xsl:template match="ref-list">
		<citation_list>
			<xsl:apply-templates select="ref"/>
		</citation_list>
	</xsl:template>

	<!-- citation -->

	<xsl:template match="ref">
		<xsl:apply-templates select="element-citation">
			<xsl:with-param name="key" select="concat($doi, '/ref-', position())"/>
		</xsl:apply-templates>
	</xsl:template>

    <!-- citation -->
    <xsl:template match="element-citation">
		<xsl:param name="key"/>
		<citation key="{$key}">
			<xsl:apply-templates select="issn" mode="citation"/>
            <xsl:apply-templates select="source" mode="citation"/>
			<xsl:call-template name="citation-author"/>
            <xsl:apply-templates select="volume" mode="citation"/>
			<xsl:apply-templates select="issue" mode="citation"/>
			<xsl:apply-templates select="edition" mode="citation"/>
			<xsl:apply-templates select="fpage | elocation-id" mode="citation"/>
			<xsl:apply-templates select="year" mode="citation"/>
            <xsl:apply-templates select="pub-id[@pub-id-type='doi'][1]" mode="citation"/>
            <xsl:apply-templates select="article-title" mode="citation"/>

            <!-- unstructured citations -->
            <xsl:if test="not(article-title) and not(source)">
                <xsl:apply-templates select="comment" mode="citation"/>
            </xsl:if>
		</citation>
	</xsl:template>

    <xsl:template match="pub-id[@pub-id-type='doi']" mode="citation">
        <doi>
            <xsl:apply-templates/>
        </doi>
    </xsl:template>

	<xsl:template match="issn" mode="citation">
		<issn>
			<xsl:apply-templates/>
		</issn>
	</xsl:template>

	<xsl:template match="source" mode="citation">
		<journal_title>
			<xsl:apply-templates/>
		</journal_title>
	</xsl:template>

	<xsl:template match="source[../@publication-type='book']" mode="citation">
		<volume_title>
			<xsl:apply-templates/>
		</volume_title>
	</xsl:template>

	<xsl:template match="edition" mode="citation">
		<edition_number>
			<xsl:choose>
				<xsl:when test="@designator">
					<xsl:value-of select="@designator"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</edition_number>
	</xsl:template>

	<xsl:template match="fpage" mode="citation">
		<first_page>
			<xsl:apply-templates/>
		</first_page>
	</xsl:template>

    <xsl:template match="elocation-id" mode="citation">
        <first_page>
            <xsl:apply-templates/>
        </first_page>
    </xsl:template>

	<xsl:template match="article-title" mode="citation">
		<article_title>
			<xsl:apply-templates/>
		</article_title>
	</xsl:template>

	<xsl:template match="volume" mode="citation">
		<volume>
			<xsl:apply-templates/>
		</volume>
	</xsl:template>

	<xsl:template match="issue" mode="citation">
		<issue>
			<xsl:apply-templates/>
		</issue>
	</xsl:template>

    <xsl:template match="comment" mode="citation">
        <unstructured_citation>
            <xsl:value-of select="."/>
        </unstructured_citation>
    </xsl:template>

	<xsl:template match="year" mode="citation">
		<cYear>
			<xsl:choose>
				<xsl:when test="@iso-8601-date">
					<xsl:value-of select="@iso-8601-date"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</cYear>
	</xsl:template>

	<!-- citation author names -->

	<xsl:template name="citation-author">
        <xsl:variable name="people" select="person-group[@person-group-type='author']"/>
		<xsl:choose>
			<xsl:when test="collab">
				<xsl:apply-templates select="collab[1]" mode="citation"/>
			</xsl:when>
			<xsl:when test="$people/name">
				<xsl:apply-templates select="$people/name[1]" mode="citation"/>
			</xsl:when>
			<xsl:when test="$people/collab">
				<xsl:apply-templates select="$people/collab[1]" mode="citation"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="name" mode="citation">
		<author>
			<xsl:apply-templates select="surname"/>
		</author>
	</xsl:template>

	<xsl:template match="collab" mode="citation">
		<author>
			<xsl:apply-templates/>
		</author>
	</xsl:template>

	<!-- figure component -->

	<xsl:template match="fig" mode="component">
		<component parent_relation="isPartOf">
			<description>
				<b><xsl:value-of select="label"/>:</b>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="caption/title" mode="title"/>
			</description>
			<xsl:if test="graphic/@mimetype and graphic/@mime-subtype">
				<format mime_type="{graphic/@mimetype}/{graphic/@mime-subtype}"/>
			</xsl:if>
			<doi_data>
				<doi><xsl:value-of select="object-id[@pub-id-type='doi']"/></doi>
				<resource><xsl:value-of select="concat($url, '/', @id)"/></resource>
			</doi_data>
		</component>
	</xsl:template>

	<!-- table component -->

	<xsl:template match="table-wrap" mode="component">
		<component parent_relation="isPartOf">
			<description>
				<b><xsl:value-of select="label"/>:</b>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="caption/title" mode="title"/>
			</description>
			<format mime_type="text/html"/>
			<doi_data>
				<doi><xsl:value-of select="object-id[@pub-id-type='doi']"/></doi>
				<resource><xsl:value-of select="concat($url, '/', @id)"/></resource>
			</doi_data>
		</component>
	</xsl:template>

	<!-- supplementary material component -->

	<xsl:template match="supplementary-material" mode="component">
		<component parent_relation="isPartOf">
			<description>
				<b><xsl:value-of select="label"/>:</b>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="caption/title" mode="title"/>
			</description>
			<xsl:if test="@mimetype and @mime-subtype">
				<format mime_type="{@mimetype}/{@mime-subtype}"/>
			</xsl:if>
			<doi_data>
				<doi><xsl:value-of select="object-id[@pub-id-type='doi']"/></doi>
				<resource><xsl:value-of select="concat($url, '/', @id)"/></resource>
			</doi_data>
		</component>
	</xsl:template>

</xsl:stylesheet>
