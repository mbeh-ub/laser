package com.k_int.kbplus

import com.k_int.kbplus.auth.User
import com.k_int.properties.PropertyDefinition
import de.laser.domain.IssueEntitlementCoverage
import de.laser.helper.RDStore
import de.laser.interfaces.AbstractLockableService
import grails.converters.JSON
import org.codehaus.groovy.grails.web.binding.DataBindingUtils
import org.springframework.transaction.TransactionStatus

import java.text.SimpleDateFormat

class PendingChangeService extends AbstractLockableService {

    def genericOIDService
    def grailsApplication
    def springSecurityService

    final static EVENT_OBJECT_NEW = 'New Object'
    final static EVENT_OBJECT_UPDATE = 'Update Object'

    final static EVENT_TIPP_EDIT = 'TIPPEdit'
    final static EVENT_TIPP_DELETE = 'TIPPDeleted'

    final static EVENT_COVERAGE_ADD = 'CoverageAdd'
    final static EVENT_COVERAGE_UPDATE = 'CoverageUpdate'
    final static EVENT_COVERAGE_DELETE = 'CoverageDeleted'

    final static EVENT_PROPERTY_CHANGE = 'PropertyChange'

    boolean performMultipleAcceptsForJob(List<PendingChange> subscriptionChanges, List<PendingChange> licenseChanges, User user) {
        log.debug('performMultipleAcceptsFromJob')

        if (!running) {
            running = true

            subscriptionChanges.each {
                pendingChangeService.performAccept(it, user)
            }
            licenseChanges.each {
                pendingChangeService.performAccept(it, user)
            }

            running = false
            return true
        }
        else {
            return false
        }
    }

    def performAccept(change, User user) {

        log.debug('performAccept')
        def result = true

        PendingChange.withNewTransaction { TransactionStatus status ->
            PendingChange pendingChange = (change instanceof PendingChange) ? change : PendingChange.get(change)

            boolean saveWithoutError = false

            try {
                def event = JSON.parse(pendingChange.changeDoc)
                log.debug("Process change ${event}");
                switch ( event.changeType ) {

                    case EVENT_TIPP_DELETE :
                        // "changeType":"TIPPDeleted","tippId":"com.k_int.kbplus.TitleInstancePackagePlatform:6482"}
                        def sub_to_change = pendingChange.subscription
                        def tipp = genericOIDService.resolveOID(event.tippId)
                        def ie_to_update = IssueEntitlement.findBySubscriptionAndTipp(sub_to_change,tipp)
                        if ( ie_to_update != null ) {
                            ie_to_update.status = RDStore.TIPP_DELETED

                            if( ie_to_update.save())
                            {

                                saveWithoutError = true
                            }

                        }
                        break;

                    case EVENT_PROPERTY_CHANGE :  // Generic property change
                        if ( ( event.changeTarget != null ) && ( event.changeTarget.length() > 0 ) ) {
                            def target_object = genericOIDService.resolveOID(event.changeTarget);
                            target_object.refresh()
                            if ( target_object ) {
                                // Work out if parsed_change_info.changeDoc.prop is an association - If so we will need to resolve the OID in the value
                                def domain_class = grailsApplication.getArtefact('Domain',target_object.class.name);
                                def prop_info = domain_class.getPersistentProperty(event.changeDoc.prop)
                                if(prop_info == null){
                                    log.debug("We are dealing with custom properties: ${event}")
                                    processCustomPropertyChange(event)
                                }
                                else if ( prop_info.name == 'status' ) {
                                    RefdataValue oldStatus = RefdataValue.get(event.changeDoc.old.id)
                                    RefdataValue newStatus = RefdataValue.get(event.changeDoc.new.id)
                                    log.debug("Updating status from ${oldStatus.getI10n('value')} to ${newStatus.getI10n('value')}")
                                    target_object.status = newStatus
                                }
                                else if ( prop_info.isAssociation() ) {
                                    log.debug("Setting association for ${event.changeDoc.prop} to ${event.changeDoc.new}");
                                    target_object[event.changeDoc.prop] = genericOIDService.resolveOID(event.changeDoc.new)
                                }
                                else if ( prop_info.getType() == java.util.Date ) {
                                    log.debug("Date processing.... parse \"${event.changeDoc.new}\"");
                                    if ( ( event.changeDoc.new != null ) && ( event.changeDoc.new.toString() != 'null' ) ) {
                                        //if ( ( parsed_change_info.changeDoc.new != null ) && ( parsed_change_info.changeDoc.new != 'null' ) ) {
                                        def df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // yyyy-MM-dd'T'HH:mm:ss.SSSZ 2013-08-31T23:00:00Z
                                        def d = df.parse(event.changeDoc.new)
                                        target_object[event.changeDoc.prop] = d
                                    }
                                    else {
                                        target_object[event.changeDoc.prop] = null
                                    }
                                }
                                else {
                                    log.debug("Setting value for ${event.changeDoc.prop} to ${event.changeDoc.new}");
                                    target_object[event.changeDoc.prop] = event.changeDoc.new
                                }

                                if(target_object.save())
                                {

                                    saveWithoutError = true
                                }

                                //FIXME: is this needed anywhere?
                                /*def change_audit_object = null
                                if ( change?.license ) change_audit_object = pendingChange?.license;
                                if ( change?.subscription ) change_audit_object = pendingChange?.subscription;
                                if ( change?.pkg ) change_audit_object = pendingChange?.pkg;
                                def change_audit_id = change_audit_object.id
                                def change_audit_class_name = change_audit_object.class.name*/
                            }
                        }
                        break;

                    case EVENT_TIPP_EDIT :
                        // A tipp was edited, the user wants their change applied to the IE
                        break;

                    case EVENT_OBJECT_NEW :
                        def new_domain_class = grailsApplication.getArtefact('Domain',event.newObjectClass);
                        if ( new_domain_class != null ) {
                            def new_instance = new_domain_class.getClazz().newInstance()
                            // like bindData(destination, map), that only exists in controllers

                            def sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss.S")
                            if(event.changeDoc?.startDate || event.changeDoc?.endDate)
                            {
                                event.changeDoc?.startDate = ((event.changeDoc?.startDate != null) && (event.changeDoc?.startDate.length() > 0)) ? sdf.parse(event.changeDoc?.startDate) : null
                                event.changeDoc?.endDate = ((event.changeDoc?.endDate != null) && (event.changeDoc?.endDate.length() > 0)) ? sdf.parse(event.changeDoc?.endDate) : null
                            }
                            if(event.changeDoc?.accessStartDate || event.changeDoc?.accessEndDate) {
                                event.changeDoc?.accessStartDate = ((event.changeDoc?.accessStartDate != null) && (event.changeDoc?.accessStartDate.length() > 0)) ? sdf.parse(event.changeDoc?.accessStartDate) : null
                                event.changeDoc?.accessEndDate = ((event.changeDoc?.accessEndDate != null) && (event.changeDoc?.accessEndDate.length() > 0)) ? sdf.parse(event.changeDoc?.accessEndDate) : null
                            }

                            DataBindingUtils.bindObjectToInstance(new_instance, event.changeDoc)
                            if(new_instance.save())
                            {
                                saveWithoutError = true
                            }
                        }
                        break;

                    case EVENT_OBJECT_UPDATE :
                        if ( ( event.changeTarget != null ) && ( event.changeTarget.length() > 0 ) ) {
                            def target_object = genericOIDService.resolveOID(event.changeTarget);
                            if ( target_object ) {
                                def sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss.S")
                                if(event.changeDoc?.startDate || event.changeDoc?.endDate)
                                {
                                    event.changeDoc?.startDate = ((event.changeDoc?.startDate != null) && (event.changeDoc?.startDate.length() > 0)) ? sdf.parse(event.changeDoc?.startDate) : null
                                    event.changeDoc?.endDate = ((event.changeDoc?.endDate != null) && (event.changeDoc?.endDate.length() > 0)) ? sdf.parse(event.changeDoc?.endDate) : null
                                }
                                if(event.changeDoc?.accessStartDate || event.changeDoc?.accessEndDate) {
                                    event.changeDoc?.accessStartDate = ((event.changeDoc?.accessStartDate != null) && (event.changeDoc?.accessStartDate.length() > 0)) ? sdf.parse(event.changeDoc?.accessStartDate) : null
                                    event.changeDoc?.accessEndDate = ((event.changeDoc?.accessEndDate != null) && (event.changeDoc?.accessEndDate.length() > 0)) ? sdf.parse(event.changeDoc?.accessEndDate) : null
                                }

                                if(event.changeDoc?.status) //continue here: reset DB, perform everything, then check process at this line - status of retired TIPPs goes miraculously to null
                                {
                                    event.changeDoc?.status = event.changeDoc?.status?.id
                                }

                                DataBindingUtils.bindObjectToInstance(target_object, event.changeDoc)

                                if(target_object.save())
                                {
                                    saveWithoutError = true
                                }
                                else {
                                    log.error(target_object.getErrors())
                                }
                            }
                        }
                        break

                    case EVENT_COVERAGE_ADD: IssueEntitlement target = genericOIDService.resolveOID(event.changeTarget)
                        if(target) {
                            Map newCovData = event.changeDoc
                            IssueEntitlementCoverage cov = new IssueEntitlementCoverage(newCovData)
                            cov.issueEntitlement = target
                            if(cov.save())
                                saveWithoutError = true
                            else log.error(cov.getErrors())
                        }
                        else {
                            log.error("Target issue entitlement with OID ${event.changeTarget} not found")
                        }
                        break
                    case EVENT_COVERAGE_UPDATE: SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
                        IssueEntitlementCoverage target = genericOIDService.resolveOID(event.changeTarget)
                        Map changeAttrs = event.changeDoc
                        if(target) {
                            if(changeAttrs.prop in ['startDate','endDate'])
                                target[changeAttrs.prop] = sdf.parse(changeAttrs.new)
                            else
                                target[changeAttrs.prop] = changeAttrs.new
                            if(target.save())
                                saveWithoutError = true
                            else log.error(target.getErrors())
                        }
                        else log.error("Target coverage object does not exist! The erroneous OID is: ${event.changeTarget}")
                        break
                    case EVENT_COVERAGE_DELETE: IssueEntitlementCoverage cov = genericOIDService.resolveOID(event.changeTarget)
                        if(cov) {
                            if(cov.delete())
                                saveWithoutError = true
                            else log.error("Error on deleting issue entitlement coverage statement with id ${cov.id}")
                        }
                        else log.error("Target coverage object does not exist! The erroneous OID is: ${event.changeTarget}")
                        break

                    default:
                        log.error("Unhandled change type : ${pc.changeDoc}");
                        break;
                }

                if(saveWithoutError && pendingChange instanceof PendingChange) {
                    /*if(pendingChange.pkg?.pendingChanges) pendingChange.pkg?.pendingChanges?.remove(pendingChange)
                    pendingChange.pkg?.save();
                    if(pendingChange.license?.pendingChanges) pendingChange.license?.pendingChanges?.remove(pendingChange)
                    pendingChange.license?.save();
                    if(pendingChange.subscription?.pendingChanges) pendingChange.subscription?.pendingChanges?.remove(pendingChange)
                    pendingChange.subscription?.save();*/
                    pendingChange.status = RefdataValue.getByValueAndCategory("Accepted", "PendingChangeStatus")
                    pendingChange.actionDate = new Date()
                    pendingChange.user = user
                    pendingChange.save()
                    def x = pendingChange
                    log.debug("Pending change accepted and saved")
                }
            }
            catch ( Exception e ) {
                log.error("Problem accepting change",e)
                result = false
            }
            return result
        }
    }

    def performReject(change, User user) {
        PendingChange.withNewTransaction { TransactionStatus status ->
            change = PendingChange.get(change)
            change.license?.pendingChanges?.remove(change)
            change.license?.save();
            change.subscription?.pendingChanges?.remove(change)
            change.subscription?.save();
            change.actionDate = new Date()
            change.user = user
            change.status = RefdataValue.getByValueAndCategory("Rejected","PendingChangeStatus")
            change.save()
           /* def change_audit_object = null
            if ( change.license ) change_audit_object = change.license;
            if ( change.subscription ) change_audit_object = change.subscription;
            if ( change.pkg ) change_audit_object = change.pkg;
            def change_audit_id = change_audit_object.id
            def change_audit_class_name = change_audit_object.class.name*/
        }
    }

    private def processCustomPropertyChange(event) {
        def changeDoc = event.changeDoc

        if ((event.changeTarget != null) && (event.changeTarget.length() > 0)) {

            def changeTarget = genericOIDService.resolveOID(event.changeTarget)
            if (changeTarget) {
                if(! changeTarget.hasProperty('customProperties')) {
                    log.error("Custom property change, but owner doesnt have the custom props: ${event}")
                    return
                }

                //def srcProperty = genericOIDService.resolveOID(changeDoc.propertyOID)
                def srcObject = genericOIDService.resolveOID(changeDoc.OID)

                // A: get existing targetProperty by instanceOf
                def targetProperty = srcObject.getClass().findByOwnerAndInstanceOf(changeTarget, srcObject)

                def setInstanceOf

                // B: get existing targetProperty by name if not multiple allowed
                if (! targetProperty) {
                    if (! srcObject.type.multipleOccurrence) {
                        targetProperty = srcObject.getClass().findByOwnerAndType(changeTarget, srcObject.type)
                        setInstanceOf = true
                    }
                }
                // C: create new targetProperty
                if (! targetProperty) {
                    targetProperty = PropertyDefinition.createGenericProperty(PropertyDefinition.CUSTOM_PROPERTY, changeTarget, srcObject.type)
                    setInstanceOf = true
                }

                //def updateProp = target_object.customProperties.find{it.type.name == changeDoc.name}
                if (targetProperty) {
                    // in case of C or B set instanceOf
                    if (setInstanceOf && targetProperty.hasProperty('instanceOf')) {
                        targetProperty.instanceOf = srcObject
                        targetProperty.save(flush: true)
                    }

                    if (changeDoc.event.endsWith('CustomProperty.deleted')) {

                        log.debug("Deleting property ${targetProperty.type.name} from ${event.changeTarget}")
                        changeTarget.customProperties.remove(targetProperty)
                        targetProperty.delete()
                    }
                    else if (changeDoc.event.endsWith('CustomProperty.updated')) {

                        log.debug("Update custom property ${targetProperty.type.name}")

                        if (changeDoc.type == RefdataValue.toString()){
                            def newProp = genericOIDService.resolveOID(changeDoc.new instanceof String ?: (changeDoc.new.class + ':' + changeDoc.new.id))

                            // Backward compatible
                            if (!newProp) {
                                def propDef = targetProperty.type
                                newProp = RefdataValue.getByValueAndCategory(changeDoc.newLabel, propDef.refdataCategory)
                                // Fallback
                                if (! newProp) {
                                    newProp = RefdataCategory.lookupOrCreate(propDef.refdataCategory, changeDoc.newLabel)
                                }
                            }
                            targetProperty."${changeDoc.prop}" = newProp
                        }
                        else {
                            targetProperty."${changeDoc.prop}" = targetProperty.parseValue("${changeDoc.new}", changeDoc.type)
                        }

                        log.debug("Setting value for ${changeDoc.name}.${changeDoc.prop} to ${changeDoc.new}")
                        targetProperty.save()
                    }
                    else {
                        log.error("ChangeDoc event '${changeDoc.event}'' not recognized.")
                    }
                }
                else {
                    log.error("Custom property changed, but no derived property found: ${event}")
                }
            }
        }
    }

}
