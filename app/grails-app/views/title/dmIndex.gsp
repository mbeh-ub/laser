<!doctype html>
<html>
  <head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code:'laser', default:'LAS:eR')} ${message(code:'title.plural', default:'Titles')} - ${message(code:'default.search.label', default:'Search')}</title>
  </head>

  <body>
    <semui:breadcrumbs>
      <semui:crumb controller="title" action="list" message="menu.public.all_titles" />
      <semui:crumb text="${message(code:'datamanager.titleView.label', default:'Data Manager Titles View')}" class="active"/>
    </semui:breadcrumbs>
    <h1 class="ui left aligned icon header"><semui:headerIcon /><g:message code="datamanager.titleView.label"/>
      <semui:totalNumber total="${totalHits}"/>
    </h1>
    <semui:filter>
      <g:form action="dmIndex" method="get" params="${params}" role="form" class="ui form">

        <input type="hidden" name="offset" value="${params.offset}"/>
        <div class="three fields">
          <div class="field">
              <label for="q">${message(code:'title.label', default:'Title')} (${message(code:'datamanager.titleView.search.note', default:'Search on title text and identifiers')})</label>
              <input id="q" name="q" placeholder="${message(code:'default.search_for.label', args:[message(code:'title.label')], default:'Search title')}" value="${params.q}"/>
          </div>
          <div class="field">
              <label for="status">${message(code:'default.status.label', default:'Status')}</label>
              <g:select id="status" name="status"  class="ui dropdown"
                    from="${availableStatuses}"
                    optionKey="${{it.value}}"
                    optionValue="${{it.getI10n('value')}}"
                    noSelection="${['null': message(code:'datamanager.titleView.status.ph', default:'-Any Status-')]}"
                    />
          </div>
          <div class="field la-field-right-aligned">
              <a href="${request.forwardURI}" class="ui reset primary button">${message(code:'default.button.filterreset.label')}</a>
              <button class="ui secondary button" type="submit" name="search" value="yes">${message(code:'default.button.filter.label', default:'Filter')}</button>
          </div>
        </div>
      </g:form>
    </semui:filter>

             <g:if test="${hits}" >
                <div class="paginateButtons" style="text-align:center">
                  <g:if test="${params.int('offset')}">
                   ${message(code:'default.search.offset.text', args:[( params.int('offset') + 1 ),( totalHits < ((params.int('max') ?: max) + params.int('offset')) ? totalHits : ( (params.int('max') ?: max ) + params.int('offset')) ),totalHits])}
                  </g:if>
                  <g:elseif test="${totalHits && totalHits > 0}">
                    ${message(code:'default.search.no_offset.text', args:[(totalHits < (params.int('max') ?: max) ? totalHits : (params.int('max') ?: max)),totalHits])}
                  </g:elseif>
                  <g:else>
                    ${message(code:'default.search.no_pagiantion.text', args:[totalHits])}
                  </g:else>
                </div>

                <div id="resultsarea">
                  <table class="ui celled la-table table">
                    <thead>
                      <tr>
                      <th style="white-space:nowrap">${message(code:'title.label', default:'Title')}</th>
                      <th style="white-space:nowrap">${message(code:'title.publisher.label', default:'Publisher')}</th>
                      <th style="white-space:nowrap">${message(code:'indentifier.plural', default:'Identifiers')}</th>
                      <th style="white-space:nowrap">${message(code:'default.status.label', default:'Status')}</th>
                      </tr>
                    </thead>
                    <tbody>
                      <g:each in="${hits}" var="hit">
                        <tr>
                          <td>
                            <g:link controller="title" action="show" id="${hit.id}">${hit.title}</g:link>
                            <g:if test="${editable}">
                              <g:link controller="title" action="show" id="${hit.id}">(Edit)</g:link>
                            </g:if>
                          </td>
                          <td>
                            ${hit.publisher?.name}
                          </td>
                          <td>
                            <ul>
                              <g:each in="${hit.ids?.sort{it?.identifier?.ns?.ns}}" var="id">
                                  <li>${id.identifier.ns.ns}: ${id.identifier.value}</li>
                              </g:each>
                            </ul>
                          </td>
                          <td>
                            ${hit.status?.getI10n('value')}
                          </td>
                        </tr>
                      </g:each>
                    </tbody>
                  </table>
                </div>
             </g:if>

            <semui:paginate total="${totalHits}" />

    <!-- ES Query: ${es_query} -->
  </body>
</html>
