package de.laser

import com.k_int.kbplus.Org
import com.k_int.kbplus.Subscription
import com.k_int.kbplus.SurveyInfo
import com.k_int.kbplus.Task
import com.k_int.kbplus.abstract_domain.AbstractProperty
import com.k_int.kbplus.auth.User
import grails.util.Holders
import groovy.util.logging.Log4j

import java.sql.Timestamp


@Log4j
class DashboardDueDate {
    String attribut
    Date date
    /** Subscription, CustomProperty, PrivateProperty oder Task*/
    String oid
    User responsibleUser
    Org  responsibleOrg
    boolean isDone
    boolean isHide
    Timestamp lastUpdated

    DashboardDueDate(Subscription obj, boolean isManualCancellationDate, User responsibleUser, Org responsibleOrg, boolean isDone, boolean isHide){
        this(
                isManualCancellationDate? 'Kündigungsdatum' : 'Enddatum',
                isManualCancellationDate? obj.manualCancellationDate : obj.endDate,
                obj,
                responsibleUser,
                responsibleOrg,
                isDone,
                isHide
        )
    }
    DashboardDueDate(AbstractProperty obj, User responsibleUser, Org responsibleOrg, boolean isDone, boolean isHide){
        this(obj.type?.name?: obj.class.simpleName, obj.dateValue, obj, responsibleUser, responsibleOrg, isDone, isHide)
    }
    DashboardDueDate(Task obj, User responsibleUser, Org responsibleOrg, boolean isDone, boolean isHide){
        this('Fälligkeitsdatum', obj.endDate, obj, responsibleUser, responsibleOrg, isDone, isHide)
    }
    DashboardDueDate(SurveyInfo obj, User responsibleUser, Org responsibleOrg, boolean isDone, boolean isHide){
        this('Enddatum', obj.endDate, obj, responsibleUser, responsibleOrg, isDone, isHide)
    }
    private DashboardDueDate(attribut, date, object, responsibleUser, responsibleOrg, isDone, isHide){
        this.attribut = attribut
        this.date = date
        this.oid = "${object.class.name}:${object.id}"
        this.responsibleUser = responsibleUser
        this.responsibleOrg = responsibleOrg
        this.isDone = isDone
        this.isHide = isHide
    }

    static mapping = {
        id                      column: 'das_id'
        attribut                column: 'das_attribut'
        date                    column: 'das_date'
        oid                     column: 'das_oid'
        responsibleUser         column: 'das_responsible_user_fk', index: 'das_responsible_user_fk_idx'
        responsibleOrg          column: 'das_responsible_org_fk',  index: 'das_responsible_org_fk_idx'
        isDone                  column: 'das_is_done'
        isHide                  column: 'das_is_hide'
        autoTimestamp true
    }

    static constraints = {
        attribut                (nullable:false, blank:false)
        date                    (nullable:false, blank:false)
        oid                     (nullable:false, blank:false)//,unique: ['date', 'oid', 'responsibleOrg'])
        responsibleUser         (nullable:true, blank:false)
        responsibleOrg          (nullable:true, blank:false)
        isDone                  (nullable:false, blank:false)
        isHide                  (nullable:false, blank:false)
        lastUpdated             (nullable:true, blank:false)
    }

    private static String getPropertyValue(String messageKey) {
        def messageSource = Holders.grailsApplication.mainContext.getBean('messageSource')
        def locale = org.springframework.context.i18n.LocaleContextHolder.getLocale()
        String value = messageSource.getMessage(messageKey, null, locale)
        value
    }

}
