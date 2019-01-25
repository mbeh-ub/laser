package de.laser.helper

import com.k_int.kbplus.RefdataValue
import org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsHibernateUtil

class RDStore {

    static final OR_LICENSING_CONSORTIUM    = getRefdataValue('Licensing Consortium', 'Organisational Role')
    static final OR_LICENSEE                = getRefdataValue('Licensee','Organisational Role')
    static final OR_LICENSEE_CONS           = getRefdataValue('Licensee_Consortial','Organisational Role')
    static final OR_SUBSCRIPTION_CONSORTIA  = getRefdataValue('Subscription Consortia','Organisational Role')
    static final OR_SUBSCRIBER              = getRefdataValue('Subscriber','Organisational Role')
    static final OR_SUBSCRIBER_CONS         = getRefdataValue('Subscriber_Consortial','Organisational Role')

    static final ORT_TYPE_CONSORTIUM        = getRefdataValue('Consortium', 'OrgRoleType')
    static final ORT_PROVIDER               = getRefdataValue('Provider', 'OrgRoleType')
    static final ORT_AGENCY                 = getRefdataValue('Agency', 'OrgRoleType')

    static final O_DELETED           = getRefdataValue('Deleted', 'OrgStatus')

    static final SUBSCRIPTION_DELETED  = getRefdataValue('Deleted', 'Subscription Status')
    static final SUBSCRIPTION_CURRENT  = getRefdataValue('Current', 'Subscription Status')
    static final SUBSCRIPTION_INTENDED = getRefdataValue('Intended', 'Subscription Status')
    static final SUBSCRIPTION_EXPIRED  = getRefdataValue('Expired', 'Subscription Status')
  
    static final LICENSE_DELETED = getRefdataValue('Deleted', 'License Status')

    static final YN_YES = getRefdataValue('Yes','YN')
    static final YN_NO  = getRefdataValue('No','YN')

    static final CIEC_POSITIVE  = getRefdataValue('positive','Cost configuration')
    static final CIEC_NEGATIVE  = getRefdataValue('negative','Cost configuration')
    static final CIEC_NEUTRAL   = getRefdataValue('neutral','Cost configuration')

    static final PRS_FUNC_GENERAL_CONTACT_PRS = getRefdataValue('General contact person', 'Person Function')
    static final CCT_EMAIL =                    getRefdataValue('E-Mail','ContactContentType')
    static final PRS_RESP_SPEC_SUB_EDITOR =     getRefdataValue('Specific subscription editor', 'Person Responsibility')

    static getRefdataValue(String value, String category) {
        GrailsHibernateUtil.unwrapIfProxy( RefdataValue.getByValueAndCategory(value,category))
    }
}
