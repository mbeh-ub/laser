package com.k_int.kbplus.filter

import com.k_int.kbplus.Org
import com.k_int.kbplus.OrgSettings
import de.laser.helper.Constants
import grails.converters.JSON
import grails.transaction.Transactional
import org.apache.commons.io.IOUtils
import org.springframework.web.filter.GenericFilterBean

import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
import javax.servlet.FilterChain
import javax.servlet.ServletException
import javax.servlet.ServletRequest
import javax.servlet.ServletResponse
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import java.security.SignatureException

class ApiFilter extends GenericFilterBean {

    @Transactional
    @Override
    void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest
        HttpServletResponse response = (HttpServletResponse) servletResponse

        // ignore non api calls
        if (request.getServletPath().startsWith('/api/v')) {
            // ignore api spec calls
            if (! (request.getServletPath() =~ /api\/v\d+\/spec/)) {

                def isAuthorized = false
                def checksum

                def method = request.getMethod()
                def path = request.getServletPath()
                def query = request.getQueryString()
                def body = IOUtils.toString(request.getInputStream())

                String authorization = request.getHeader('X-Authorization')
                try {
                    if (authorization) {
                        def p1 = authorization.split(' ')
                        def authMethod = p1[0]

                        if (authMethod == 'hmac') {
                            def p2 = p1[1].split(',')
                            def load = p2[0].split(':')
                            def algorithm = p2[1]

                            def key = load[0]
                            def timestamp = load[1]
                            def nounce = load[2]
                            def digest = load[3]

                            // checking digest

                            Org apiOrg = OrgSettings.executeQuery(
                                    'SELECT os.org FROM OrgSettings os WHERE os.key = :key AND os.strValue = :value',
                                    [key: OrgSettings.KEYS.API_KEY, value: key]
                            )?.get(0)

                            String apiSecret = OrgSettings.get(apiOrg, OrgSettings.KEYS.API_PASSWORD)?.getValue()

                            checksum = hmac(
                                        method +    // http-method
                                        path +      // uri
                                        timestamp + // timestamp
                                        nounce +    // nounce
                                        (query ? URLDecoder.decode(query) : '') + // parameter
                                        body,         // body
                                        apiSecret)

                            isAuthorized = (checksum == digest)
                            if (isAuthorized) {
                                request.setAttribute('authorizedApiOrg', apiOrg)
                                request.setAttribute('authorizedApiPostBody', body)
                            }
                        }
                    }
                } catch (Exception e) {
                    isAuthorized = false
                }

                if (isAuthorized) {
                    //println "VALID authorization: " + authorization
                    request.getRequestDispatcher(path).forward(servletRequest, servletResponse)
                    return
                } else {
                    //println "INVALID authorization: " + authorization + " < " + checksum
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED)
                    response.setContentType(Constants.MIME_APPLICATION_JSON)

                    def result = new JSON([
                            "message"      : "unauthorized access",
                            "authorization": authorization,
                            "path"         : path,
                            "query"        : query,
                            "method"       : method
                            //"_httpStatus": HttpStatus.UNAUTHORIZED.value()
                    ])
                    response.getWriter().print(result.toString(true))
                    return
                }
            }
        }
        filterChain.doFilter(servletRequest, servletResponse)
    }

    def hmac(String data, String secret) throws SignatureException {
        String result
        try {
            SecretKeySpec signingKey = new SecretKeySpec(secret.getBytes(), "HmacSHA256")
            Mac mac = Mac.getInstance("HmacSHA256")
            mac.init(signingKey)

            byte[] rawHmac = mac.doFinal(data.getBytes())
            result = rawHmac.encodeHex()
        }
        catch (Exception e) {
            throw new SignatureException("failed to generate HMAC : " + e.getMessage());
        }
        return result
    }
}