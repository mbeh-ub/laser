package com.k_int.kbplus

import com.k_int.properties.PropertyDefinition

class SurveyOrg {


    SurveyConfig surveyConfig
    Org org

    String priceComment
    Date dateCreated
    Date lastUpdated

    Date finishDate


    static constraints = {
        priceComment(nullable: true, blank: false)
        finishDate (nullable:true, blank:false)
    }

    static mapping = {
        id column: 'surorg_id'
        version column: 'surorg_version'

        surveyConfig column: 'surorg_surveyconfig_fk'
        org column: 'surorg_org_fk'
        priceComment column: 'surorg_pricecomment', type: 'text'
        dateCreated column: 'surorg_date_created'
        lastUpdated column: 'surorg_last_updated'
        finishDate  column: 'surorg_finish_date'
    }

    boolean existsMultiYearTerm() {
        boolean existsMultiYearTerm = false
        def sub = surveyConfig.subscription
        if (sub) {
            def subChild = sub?.getDerivedSubscriptionBySubscribers(org)
            def property = PropertyDefinition.findByName("Mehrjahreslaufzeit ausgewählt")

            if (subChild?.isCurrentMultiYearSubscription()) {
                existsMultiYearTerm = true
                return existsMultiYearTerm
            }

            if (property?.type == 'class com.k_int.kbplus.RefdataValue') {
                if (subChild?.customProperties?.find {
                    it?.type?.id == property?.id
                }?.refValue == RefdataValue.getByValueAndCategory('Yes', property?.refdataCategory)) {
                    existsMultiYearTerm = true
                    return existsMultiYearTerm
                }
            }
        }
        return existsMultiYearTerm
    }

    def hasOrgSubscription() {
        def hasOrgSubscription = false
        if (surveyConfig.subscription) {
            Subscription.findAllByInstanceOf(surveyConfig.subscription).each { s ->
                def ors = OrgRole.findAllWhere(sub: s, org: this.org)
                ors.each { or ->
                    if (or.roleType?.value in ['Subscriber', 'Subscriber_Consortial']) {
                        hasOrgSubscription = true
                    }
                }
            }
        }
        return hasOrgSubscription

    }
}
