<br>

<semui:filter>
    <g:form action="surveyParticipants" method="post" class="ui form"
            params="[id: surveyInfo.id, surveyConfigID: params.surveyConfigID, tab: 'consortiaMembers']">
        <g:render template="/templates/filter/orgFilter"
                  model="[
                          tmplConfigShow      : [['name', 'libraryType'], ['federalState', 'libraryNetwork', 'property'], ['customerType']],
                          tmplConfigFormFilter: true,
                          useNewLayouter      : true
                  ]"/>
    </g:form>
</semui:filter>


<g:form action="addSurveyParticipants" controller="survey" method="post" class="ui form"
        params="[id: surveyInfo.id, surveyConfigID: params.surveyConfigID, tab: params.tab]">

    <g:render template="/templates/filter/orgFilterTable"
              model="[orgList          : consortiaMembers,
                      tmplShowCheckbox : editable,
                      tmplDisableOrgIds: surveyConfig?.orgs?.org?.id,
                      tmplConfigShow   : ['lineNumber', 'sortname', 'name', 'libraryType', 'surveySubInfo']
              ]"/>

    <br/>
    <g:if test="${editable}">
        <input type="submit" class="ui button" value="${message(code: 'default.button.add.label', default: 'Add')}"/>
    </g:if>

</g:form>
