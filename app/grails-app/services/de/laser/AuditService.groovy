package de.laser


import de.laser.traits.AuditableTrait
import org.codehaus.groovy.grails.commons.GrailsApplication

//@CompileStatic
class AuditService {

    GrailsApplication grailsApplication


    def getWatchedProperties(AuditableTrait auditable) {
        def result = []

        if (getAuditConfig(auditable, AuditConfig.COMPLETE_OBJECT)) {
            auditable.controlledProperties.each { cp ->
                result << cp
            }
        }
        else {
            auditable.controlledProperties.each { cp ->
                if (getAuditConfig(auditable, cp)) {
                    result << cp
                }
            }
        }

        result
    }

    AuditConfig getAuditConfig(AuditableTrait auditable) {
        AuditConfig.getConfig(auditable)
    }

    AuditConfig getAuditConfig(AuditableTrait auditable, String field) {
        AuditConfig.getConfig(auditable, field)
    }
}
