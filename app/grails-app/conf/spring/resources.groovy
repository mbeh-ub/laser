import org.springframework.security.web.authentication.session.ConcurrentSessionControlStrategy
import org.springframework.security.web.session.ConcurrentSessionFilter
import org.springframework.security.core.session.SessionRegistryImpl
import grails.plugin.springsecurity.SpringSecurityUtils
import de.laser.dbm.MigrationCallbacks

beans = {

    migrationCallbacks(MigrationCallbacks) {
        grailsApplication = ref('grailsApplication')
    }

    // [ user counter ..
    sessionRegistry(SessionRegistryImpl)

    sessionAuthenticationStrategy(ConcurrentSessionControlStrategy, sessionRegistry) {
        maximumSessions = -1
    }

    concurrentSessionFilter(ConcurrentSessionFilter){
        sessionRegistry = sessionRegistry
        expiredUrl = '/login/concurrentSession'
    }
    // .. ]

    // [ supporting initMandatorySettings for users ..
    authenticationSuccessHandler(de.laser.helper.AuthSuccessHandler) {
        // Reusing the security configuration
        def conf = SpringSecurityUtils.securityConfig
        // Configuring the bean ..
        requestCache = ref('requestCache')
        redirectStrategy = ref('redirectStrategy')
        defaultTargetUrl = conf.successHandler.defaultTargetUrl
        alwaysUseDefaultTargetUrl = conf.successHandler.alwaysUseDefault
        targetUrlParameter = conf.successHandler.targetUrlParameter
        ajaxSuccessUrl = conf.successHandler.ajaxSuccessUrl
        useReferer = conf.successHandler.useReferer
    }
    // .. ]

    //localeResolver(org.springframework.web.servlet.i18n.SessionLocaleResolver) {
    //    defaultLocale = new java.util.Locale('de', 'DE')
    //}

    userDetailsService(grails.plugin.springsecurity.userdetails.GormUserDetailsService) { // 2.0
        //userDetailsService(org.codehaus.groovy.grails.plugins.springsecurity.GormUserDetailsService) {
        grailsApplication = ref('grailsApplication')
    }
  
    userDetailsByNameServiceWrapper(org.springframework.security.core.userdetails.UserDetailsByNameServiceWrapper) {
        userDetailsService = ref('userDetailsService')
    }

    preAuthenticatedAuthenticationProvider(org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationProvider) {
        preAuthenticatedUserDetailsService = ref('userDetailsByNameServiceWrapper')
    }

    securityContextPersistenceFilter(org.springframework.security.web.context.SecurityContextPersistenceFilter){}

    // [ controls api access via hmac ..
    apiFilter(com.k_int.kbplus.filter.ApiFilter){}
    // .. ]

    //ediAuthTokenMap(java.util.HashMap) {
    //}

    //ediauthFilter(com.k_int.kbplus.filter.EdiauthFilter){
    //    grailsApplication = ref('grailsApplication')
    //    authenticationManager = ref('authenticationManager')
    //    ediAuthTokenMap = ref('ediAuthTokenMap')
    //}

    //apiauthFilter(com.k_int.kbplus.filter.ApiauthFilter){
    //   authenticationManager = ref("authenticationManager")
    //   rememberMeServices = ref("rememberMeServices")
    //   springSecurityService = ref("springSecurityService")
    //}

    //preAuthFilter(org.springframework.security.web.authentication.preauth.RequestHeaderAuthenticationFilter) {
    //  principalRequestHeader = 'remoteUser'
    //  authenticationManager = ref('authenticationManager')
    //}
}
