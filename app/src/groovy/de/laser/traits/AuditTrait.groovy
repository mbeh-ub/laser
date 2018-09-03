package de.laser.traits

import com.k_int.kbplus.RefdataValue
import com.k_int.kbplus.abstract_domain.CustomProperty
import com.k_int.kbplus.abstract_domain.PrivateProperty
import de.laser.AuditConfig

import javax.persistence.Transient

trait AuditTrait {

    /**
     * IMPORTANT:
     *
     * Declare auditable and controlledProperties in implementing classes.
     *
     * Overwrite onChange() and/or notifyDependencies() if needed ..
     *
     */

    // def changeNotificationService

    // static auditable = [ ignore: ['version', 'lastUpdated', 'pendingChanges'] ]

    // static controlledProperties = ['name', 'date', 'etc']

    def getWatchedProperties() {
        def cp = getAuditConfig().collect{ it ->
            it.referenceField
        }

        if (controlledProperties) {
            cp.addAll(controlledProperties)
            cp.unique()
        }

        /*
        if (defaultControlledProperties) {
            cp.addAll(defaultControlledProperties).unique()
        }
        */
        cp
    }

    @Transient
    def onChange = { oldMap, newMap ->

        log?.debug("onChange(): ${oldMap} => ${newMap}")

        getWatchedProperties()?.each { cp ->
            if (oldMap[cp] != newMap[cp]) {
                def event
                def clazz = this."${cp}".getClass().getName()

                log?.debug("notifyChangeEvent() for property class " + clazz)

                if (this instanceof CustomProperty || this instanceof PrivateProperty) {

                    event = [
                            OID        : "${this.owner.class.name}:${this.owner.id}",
                            event      : "${this.class.simpleName}.updated",
                            prop       : cp,
                            name       : type.name,
                            type       : this."${cp}".getClass().toString(),
                            old        : oldMap[cp] instanceof RefdataValue ? oldMap[cp].toString() : oldMap[cp],
                            new        : newMap[cp] instanceof RefdataValue ? newMap[cp].toString() : newMap[cp],
                            propertyOID: "${this.class.name}:${this.id}"
                    ]
                } else {

                    if (clazz.equals("com.k_int.kbplus.RefdataValue")) {

                        def old_oid = oldMap[cp] ? "${oldMap[cp].class.name}:${oldMap[cp].id}" : null
                        def new_oid = newMap[cp] ? "${newMap[cp].class.name}:${newMap[cp].id}" : null

                        event = [
                                OID     : "${this.class.name}:${this.id}",
                                event   : "${this.class.simpleName}.updated",
                                prop    : cp,
                                old     : old_oid,
                                oldLabel: oldMap[cp]?.toString(),
                                new     : new_oid,
                                newLabel: newMap[cp]?.toString()
                        ]
                    } else {

                        event = [
                                OID  : "${this.class.name}:${this.id}",
                                event: "${this.class.simpleName}.updated",
                                prop : cp,
                                old  : oldMap[cp],
                                new  : newMap[cp]
                        ]
                    }
                }

                if (event) {
                    if (! changeNotificationService) {
                        log?.error("changeNotificationService not implemented @ ${it}")
                    } else {
                        changeNotificationService.notifyChangeEvent(event)
                    }
                }
            }
        }
    }

    @Transient
    def onDelete = { oldMap ->
        log?.debug("onDelete() ${this}")
    }

    @Transient
    def onSave = {
        log?.debug("onSave() ${this}")
    }

    @Transient
    def notifyDependencies(changeDocument) {
        log?.debug("notifyDependencies() not implemented => ${changeDocument}")
    }

    @Transient
    def getAuditConfig() {
        AuditConfig.getConfig(this)
    }

    @Transient
    def getAuditConfig(String field) {
        AuditConfig.getConfig(this, field)
    }
}