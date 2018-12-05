package com.k_int.kbplus

import de.laser.controller.AbstractDebugController
import grails.converters.*
import grails.plugin.springsecurity.annotation.Secured
import grails.converters.*
import org.elasticsearch.groovy.common.xcontent.*
import groovy.xml.MarkupBuilder
import com.k_int.kbplus.auth.*;

@Secured(['IS_AUTHENTICATED_FULLY'])
class AlertController extends AbstractDebugController {

    def springSecurityService

    @Secured(['ROLE_USER'])
    def commentsFragment() {
        def result = [:]
        if (params.id) {
            result.alert = Alert.get(params.id)
        }
        result
    }

    @Secured(['ROLE_USER'])
    def addComment() {
        log.debug("Adding comment ${params.newcomment} on alert ${params.alertid}")

        def user = User.get(springSecurityService.principal.id)
        if (params.alertid) {
            def alert = Alert.get(params.alertid)
            Comment c = new Comment(commentDate: new Date(), comment: params.newcomment, by: user, alert: alert)
            if (! c.save(flush: true)) {
                c.errors.each { ce ->
                    log.error("Problem saving commentk ${ce}")
                }
            }
        }
        redirect(url: request.getHeader('referer'))
    }
}
