package templater

import (
	"fmt"
	"github.com/GoComply/fedramp/bundled"
	"github.com/GoComply/fedramp/pkg/fedramp/common"
	"github.com/docker/oscalkit/pkg/oscal/constants"
	"github.com/docker/oscalkit/pkg/oscal_source"
)

func Convert(sspSource *oscal_source.OSCALSource, template string) error {
	o := sspSource.OSCAL()
	if o.DocumentType() != constants.SSPDocument {
		return fmt.Errorf("Provided OSCAL file is not system-security-plan")
	}
	docx, err := bundled.TemplateDOCX(common.LevelModerate)
	if err != nil {
		return err
	}
	defer docx.Close()

	return nil
}

func ConvertFile(oscalSSPFilePath, template, outputPath string) error {
	source, err := oscal_source.Open(oscalSSPFilePath)
	if err != nil {
		return nil
	}
	defer source.Close()
	return Convert(source, template)
}
