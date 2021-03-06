package de.laser.helper

import grails.util.Holders

import java.text.DateFormat
import java.text.SimpleDateFormat

class DateUtil {

    static Date toDate_NoTime(String value) {
        getSimpleDateFormat_NoTime().parseObject(value)
    }
    static DateFormat getSimpleDateFormat_NoTime(){
        def messageSource = Holders.grailsApplication.mainContext.getBean('messageSource')
        def locale = org.springframework.context.i18n.LocaleContextHolder.getLocale()
        def format = messageSource.getMessage('default.date.format.notime', null, locale)
        new SimpleDateFormat(format)
    }

    static DateFormat getSimpleDateFormat_NoZ(){
        def messageSource = Holders.grailsApplication.mainContext.getBean('messageSource')
        def locale = org.springframework.context.i18n.LocaleContextHolder.getLocale()
        def format = messageSource.getMessage('default.date.format.noZ', null, locale)
        new SimpleDateFormat(format)
    }
}
