package de.laser

import com.k_int.kbplus.Org
import com.k_int.kbplus.auth.User

// Semantic UI

class SemanticUiDropdownTagLib {

    def springSecurityService

    //static defaultEncodeAs = [taglib:'html']
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]

    static namespace = "semui"

    // <semui:exportDropdown params="${params}" transforms="${transforms}" />

    def controlButtons = { attrs, body ->

        out << '<div class="ui icon buttons la-ctrls la-float-right la-js-dont-hide-button">'
        out <<   body()
        out << '</div><br>'
    }

    def exportDropdown = { attrs, body ->

        out << '<div class="ui simple dropdown button la-js-dont-hide-button">'
        out <<   '<i class="download icon"></i>'
        out <<   '<div class="menu">'

        out <<       body()

        out <<  '</div>'
        out << '</div>'
    }

    // <semui:exportDropdownItem> LINK <semui:exportDropdownItem>

    def exportDropdownItem = { attrs, body ->

        out << body()
    }

    // <semui:signedDropdown name="xyz" noSelection="Bitte auswählen .." from="${orgList}" signedIds="${signedOrgIdList}" />

    def signedDropdown = { attrs, body ->

        String id = ''
        if (attrs.name) {
            id = ' id="' + attrs.name + '" name="' + attrs.name + '" '
        }
        out << '<select class="ui fluid labeled search dropdown' + id + '">'

        if (attrs.noSelection) {
            out << '<option value="">' + attrs.noSelection + '</option>'
        }

        attrs.from?.each { item ->
            out << '<option value="' + (item.class.name + ':' + item.id) + '">'

            if (item instanceof Org) {
                out << item.name

                if (item.shortname) {
                    out << ' (' + item.shortname + ') '
                }
            }
            else {
                out << item.toString()
            }

            if (attrs.signedIds?.contains(item.id)) {
                out << '&nbsp; &#10004;'
            }
            out << '</option>'
        }
        out << '</select>'
    }

    // <semui:actionsDropdown params="${params}"  />

    def actionsDropdown = { attrs, body ->

        out << '<div class="ui simple dropdown button la-js-dont-hide-button">'
        out <<  '<i class="magic icon"></i>'
        out <<  '<div class="menu">'

        out <<          body()

        out <<  '</div>'
        out << '</div>'
    }

    def actionsDropdownItem = { attrs, body ->

        def text      = attrs.text ? attrs.text : ''
        def message   = attrs.message ? "${message(code: attrs.message)}" : ''
        def linkBody  = (text && message) ? text + " - " + message : text + message
        def aClass    = 'item'
        def href      = attrs.href ? attrs.href : '#'

        def tooltip = attrs.tooltip ?: ""

        if(tooltip != "")
        {
            linkBody = '<div data-tooltip="'+tooltip+'">'+linkBody+'</div>'
        }

        if (this.pageScope.variables?.actionName == attrs.action) {
            aClass = 'item active'
        }
        if (attrs.controller) {
            out << g.link(linkBody,
                    class: aClass,
                    controller: attrs.controller,
                    action: attrs.action,
                    params: attrs.params
            )
        }
        else {
            out << '<a href="' + href + '" class="item"'
            if (attrs.id) { // e.g. binding js events
                out << ' id="' + attrs.id + '">'
            }
            if (attrs.'data-semui') { // e.g. binding modals
                out << ' data-semui="' + attrs.'data-semui' + '">'
            }
            out << linkBody + '</a>'
        }
    }

    def actionsDropdownItemDisabled = { attrs, body ->
        def message = attrs.message ? "${message(code: attrs.message)}" : ''
        def tooltip = attrs.tooltip ?: "Die Funktion \'"+message+"\' ist zur Zeit nicht verfügbar!"

        out << '<a href="#" class="item"><div class="disabled" data-tooltip="'+tooltip+'">'+message+'</div></a>'

    }

    def dropdownWithI18nExplanations = { attrs, body ->
        if (!attrs.name) {
            throwTagError("Tag [semui:dropdownWithI18nExplanations] is missing required attribute [name]")
        }
        if (!attrs.containsKey('from')) {
            throwTagError("Tag [semui:dropdownWithI18nExplanations] is missing required attribute [from]")
        }


        out << "<div class='ui dropdown selection ${attrs.class}' id='${attrs.id}'>"
        out << "<input type='hidden' name='${attrs.name}' "
        if(attrs.value)
            out << "value='${attrs.value}'"
        out << ">"
        out << '<i class="dropdown icon"></i>'
        out << "<div class='default text'>${attrs.noSelection}</div>"
        out << '<div class="menu">'
        attrs.from?.each { el ->
            out << '<div class="item" data-value="'
            if(attrs.optionKey)
                out << el[attrs.optionKey]
            out << '">'
            out << '<span class="description">'+el[attrs.optionExpl]+'</span>'
            out << '<span class="text">'+el[attrs.optionValue].toString().encodeAsHTML()+'</span>'
            out << '</div>'
        }
        out << '</div>'
        out << '</div>'

    }

    def menuDropdown = { attrs, body ->

        out << '<div class="ui secondary stackable menu">'

        out <<          body()

        out << '</div>'
    }

    def menuDropdownItems = { attrs, body ->
        def text      = attrs.text ? attrs.text : ''
        def message   = attrs.message ? "${message(code: attrs.message)}" : ''
        def textMessage  = (text && message) ? text + " - " + message : text + message
        out << '<div class="ui pointing dropdown link item">'
        out << textMessage
        out << '<i class="dropdown icon"></i> '
        out <<  '<div class="menu">'

        out <<          body()

        out << '</div>'
        out << '</div>'
    }

    def menuDropdownItem = { attrs, body ->
        def text      = attrs.text ? attrs.text : ''
        def message   = attrs.message ? "${message(code: attrs.message)}" : ''
        def linkBody  = (text && message) ? text + " - " + message : text + message
        def aClass    = ('item') + (attrs.class ? ' ' + attrs.class : '')


        if (attrs.disabled) {
            out << '<div class="item disabled">' + linkBody + '</div>'
        }
        else if (attrs.controller) {
            out << g.link(linkBody,
                    class: aClass,
                    controller: attrs.controller,
                    action: attrs.action,
                    params: attrs.params
            )
        }
        else {
            out << '<div class="item">'
            out << linkBody
            out << '</div>'
        }

        out << '<div class="divider"></div>'
    }


}

