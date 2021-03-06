package de.laser.interfaces

interface TemplateSupport {

    static CALCULATED_TYPE_TEMPLATE         = 'Template'
    static CALCULATED_TYPE_LOCAL            = 'Local'
    static CALCULATED_TYPE_CONSORTIAL       = 'Consortial'
    static CALCULATED_TYPE_COLLECTIVE       = 'Collective'
    static CALCULATED_TYPE_ADMINISTRATIVE   = 'Administrative'
    static CALCULATED_TYPE_PARTICIPATION    = 'Participation'
    static CALCULATED_TYPE_UNKOWN           = 'Unknown'
    static CALCULATED_TYPE_PARTICIPATION_AS_COLLECTIVE = 'Participation as Collective'

    boolean isTemplate()

    boolean hasTemplate()

    String getCalculatedType()

}
