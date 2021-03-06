GO=GO111MODULE=on go
GOBUILD=$(GO) build

all: build

build: bundled/pkged.go
	$(GOBUILD) ./cli/gocomply_fedramp

bundled/pkged.go: pkger README.md
	pkger -o bundled

.PHONY: pkger vendor
pkger:
ifeq ("$(wildcard $(GOPATH)/bin/pkger)","")
	go get -u -v github.com/markbates/pkger/cmd/pkger
endif

ci-update-bundled-deps: ci-update-fedramp-templates ci-update-fedramp-profiles ci-update-fedramp-catalogs

ci-update-fedramp-templates:
	rm bundled/templates/FedRAMP-SSP-*-Baseline-Template.docx
	wget -P bundled/templates/ https://www.fedramp.gov/assets/resources/templates/FedRAMP-SSP-High-Baseline-Template.docx https://www.fedramp.gov/assets/resources/templates/FedRAMP-SSP-Moderate-Baseline-Template.docx https://www.fedramp.gov/assets/resources/templates/FedRAMP-SSP-Low-Baseline-Template.docx

XMLFORMAT=XMLLINT_INDENT='	' xmllint --format --nsclean
ci-update-fedramp-profiles:
	rm bundled/profiles/FedRAMP_*-baseline_profile.xml
	wget -P bundled/profiles https://raw.githubusercontent.com/usnistgov/OSCAL/master/content/fedramp.gov/xml/FedRAMP_LOW-baseline_profile.xml https://raw.githubusercontent.com/usnistgov/OSCAL/master/content/fedramp.gov/xml/FedRAMP_MODERATE-baseline_profile.xml https://raw.githubusercontent.com/usnistgov/OSCAL/master/content/fedramp.gov/xml/FedRAMP_HIGH-baseline_profile.xml
	$(XMLFORMAT) -o bundled/profiles/FedRAMP_HIGH-baseline_profile.xml bundled/profiles/FedRAMP_HIGH-baseline_profile.xml
	$(XMLFORMAT) -o bundled/profiles/FedRAMP_MODERATE-baseline_profile.xml bundled/profiles/FedRAMP_MODERATE-baseline_profile.xml
	$(XMLFORMAT) -o bundled/profiles/FedRAMP_LOW-baseline_profile.xml bundled/profiles/FedRAMP_LOW-baseline_profile.xml

ci-update-fedramp-catalogs:
	rm bundled/catalogs/FedRAMP_*baseline-resolved-profile_catalog.xml
	wget -P bundled/catalogs https://raw.githubusercontent.com/usnistgov/OSCAL/master/content/fedramp.gov/xml/FedRAMP_HIGH-baseline-resolved-profile_catalog.xml https://raw.githubusercontent.com/usnistgov/OSCAL/master/content/fedramp.gov/xml/FedRAMP_LOW-baseline-resolved-profile_catalog.xml https://raw.githubusercontent.com/usnistgov/OSCAL/master/content/fedramp.gov/xml/FedRAMP_MODERATE-baseline-resolved-profile_catalog.xml
	$(XMLFORMAT) -o bundled/catalogs/FedRAMP_HIGH-baseline-resolved-profile_catalog.xml bundled/catalogs/FedRAMP_HIGH-baseline-resolved-profile_catalog.xml
	$(XMLFORMAT) -o bundled/catalogs/FedRAMP_MODERATE-baseline-resolved-profile_catalog.xml bundled/catalogs/FedRAMP_MODERATE-baseline-resolved-profile_catalog.xml
	$(XMLFORMAT) -o bundled/catalogs/FedRAMP_LOW-baseline-resolved-profile_catalog.xml bundled/catalogs/FedRAMP_LOW-baseline-resolved-profile_catalog.xml

vendor:
	$(GO) mod tidy
	$(GO) mod vendor
	$(GO) mod verify
