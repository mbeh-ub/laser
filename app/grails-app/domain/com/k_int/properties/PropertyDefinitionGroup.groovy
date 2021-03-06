package com.k_int.properties

import com.k_int.kbplus.GenericOIDService
import com.k_int.kbplus.Org
import com.k_int.kbplus.RefdataValue
import de.laser.CacheService
import de.laser.domain.I10nTranslation
import de.laser.helper.EhcacheWrapper
import de.laser.helper.RefdataAnnotation
import grails.util.Holders
import groovy.util.logging.Log4j
import org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsHibernateUtil
import org.springframework.context.i18n.LocaleContextHolder

@Log4j
class PropertyDefinitionGroup {

    String name
    String description
    Org    tenant
    String ownerType // PropertyDefinition.[LIC_PROP, SUB_PROP, ORG_PROP]

    boolean isVisible // default value: will be overwritten by existing bindings

    static hasMany = [
            items: PropertyDefinitionGroupItem,
            bindings: PropertyDefinitionGroupBinding
    ]
    static mappedBy = [
            items:    'propDefGroup',
            bindings: 'propDefGroup'
    ]

    static mapping = {
        id          column: 'pdg_id'
        version     column: 'pdg_version'
        name        column: 'pdg_name'
        description column: 'pdg_description',  type: 'text'
        tenant      column: 'pdg_tenant_fk',    index: 'pdg_tenant_idx'
        ownerType   column: 'pdg_owner_type'
        isVisible   column: 'pdg_is_visible'

        items       cascade: 'all', batchSize: 10
        bindings    cascade: 'all', batchSize: 10
    }

    static constraints = {
        name        (nullable: false, blank: false)
        description (nullable: true,  blank: true)
        tenant      (nullable: true, blank: false)
        ownerType   (nullable: false, blank: false)
        isVisible   (nullable: false, blank: false)
    }

    def getPropertyDefinitions() {

        PropertyDefinition.executeQuery(
            "SELECT pd from PropertyDefinition pd, PropertyDefinitionGroupItem pdgi WHERE pdgi.propDef = pd AND pdgi.propDefGroup = ?",
            [this]
        )
    }

    def getCurrentProperties(def currentObject) {

        def result = []
        def givenIds = getPropertyDefinitions().collect{ it -> it.id }

        currentObject?.customProperties?.each{ cp ->
            if (cp.type.id in givenIds) {
                result << GrailsHibernateUtil.unwrapIfProxy(cp)
            }
        }
        result
    }

    static getAvailableGroups(Org tenant, String ownerType) {
        def result = []
        def global  = findAllWhere( tenant: null, ownerType: ownerType)
        def context = findAllByTenantAndOwnerType(tenant, ownerType)

        result.addAll(global)
        result.addAll(context)

        result
    }

    static refdataFind(params) {
        def result = []

        def genericOIDService = grails.util.Holders.applicationContext.getBean('genericOIDService') as GenericOIDService
        def currentObject = genericOIDService.resolveOID(params.oid)

        CacheService cacheService = (CacheService) Holders.grailsApplication.mainContext.getBean('cacheService')
        EhcacheWrapper cache

        cache = cacheService.getTTL300Cache("PropertyDefinitionGroup/refdataFind/${params.desc}/pdgid/${currentObject.id}/${LocaleContextHolder.getLocale()}/")

        if (! cache.get('propDefs')) {
            def propDefs = currentObject.getPropertyDefinitions()

            List matches = I10nTranslation.refdataFindHelper(
                    'com.k_int.properties.PropertyDefinition',
                    'name',
                    '',
                    LocaleContextHolder.getLocale()
            ).collect{ it.id }

            propDefs.each { it ->
                if (it.id in matches) {
                    if (it.getDescr() == params.desc) {
                        result.add([id: "${it.id}", text: "${it.getI10n('name')}"])
                    }
                }
            }
            cache.put('propDefs', result)
        }
        else {
            log.debug ('reading from cache .. ')
            cache.get('propDefs').each { it ->
                if (params.q == '*' || it.text?.toLowerCase()?.contains(params.q?.toLowerCase())) {
                    result.add(it)
                }
            }
        }

        /*
        def matches = I10nTranslation.refdataFindHelper(
                'com.k_int.properties.PropertyDefinition',
                'name',
                params.q,
                LocaleContextHolder.getLocale()
        )?.collect{ it.id }

        propDefs.each { it ->
            if (it.id in matches) {
                if (params.desc && params.desc != "*") {
                    if (it.getDescr() == params.desc) {
                        result.add([id: "${it.id}", text: "${it.getI10n('name')}"])
                    }
                } else {
                    result.add([id: "${it.id}", text: "${it.getI10n('name')}"])
                }
            }
        }
        */
        result
    }
}

