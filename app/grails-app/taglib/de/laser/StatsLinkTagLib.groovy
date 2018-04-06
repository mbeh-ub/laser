package de.laser

class StatsLinkTagLib {

    def springSecurityService

    static namespace = 'laser'
    static encodeAsForTags = [statsLink: [taglib:'none']]

    def statsLink = {attrs, body ->
        if (attrs.module) {
            attrs.base += "/${attrs.module}"
            attrs.remove('module')
        }
        def cleanLink = g.link(attrs, body)
        out << cleanLink.replaceAll("(?<!(http:|https:))[//]+", "/")
    }
}