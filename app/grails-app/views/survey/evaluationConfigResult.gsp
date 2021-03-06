<%@ page import="de.laser.helper.RDStore; com.k_int.kbplus.SurveyProperty;com.k_int.kbplus.RefdataCategory;com.k_int.kbplus.RefdataValue;" %>
<laser:serviceInjection/>
<!doctype html>



<html>
<head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code: 'laser', default: 'LAS:eR')} : ${message(code: 'myinst.currentSubscriptions.label', default: 'Current Subscriptions')}</title>
</head>

<body>

<semui:breadcrumbs>
    <semui:crumb controller="survey" action="currentSurveysConsortia" text="${message(code: 'menu.my.surveys')}"/>

    <g:if test="${surveyInfo}">
        <semui:crumb controller="survey" action="show" id="${surveyInfo.id}" text="${surveyInfo.name}"/>
    </g:if>
    <semui:crumb message="myinst.currentSubscriptions.label" class="active"/>
</semui:breadcrumbs>

<semui:controlButtons>
    <g:render template="actions"/>
</semui:controlButtons>

<br>

<h1 class="ui icon header"><semui:headerTitleIcon type="Survey"/>
<semui:xEditable owner="${surveyInfo}" field="name"/>
<semui:surveyStatus object="${surveyInfo}"/>
</h1>

<g:render template="nav"/>


<semui:messages data="${flash}"/>


<h2><g:message code="surveyEvaluation.surveyConfig.info" args="[surveyConfig?.getConfigNameShort()]"/></h2>

<g:if test="${surveyConfig}">

    <div class="la-inline-lists">
        <div class="ui two stackable cards">

            <div class="ui card">
                <div class="content">
                    <dl>
                        <dt class="control-label">${message(code: 'surveyConfig.type.label')}</dt>
                        <dd>
                            ${surveyConfig.getTypeInLocaleI10n()}

                            <g:if test="${surveyConfig?.surveyProperty}">

                                <b>${message(code: 'surveyProperty.type.label')}: ${surveyConfig?.surveyProperty?.getLocalizedType()}

                                </b>
                            </g:if>

                        </dd>

                    </dl>
                    <dl>
                        <dt class="control-label">${message(code: 'surveyConfig.orgs.label')}</dt>
                        <dd>
                            <g:link controller="survey" action="surveyParticipants" id="${surveyInfo.id}"
                                    params="[surveyConfigID: surveyConfig?.id]" class="ui icon"><div
                                    class="ui circular label">${surveyConfig?.orgs?.size() ?: 0}</div></g:link>
                        </dd>

                    </dl>

                    <dl>
                        <dt class="control-label">${message(code: 'surveyConfig.documents.label')}</dt>
                        <dd>
                            <g:link controller="survey" action="surveyConfigDocs" id="${surveyInfo.id}"
                                    params="[surveyConfigID: surveyConfig?.id]" class="ui icon"><div
                                    class="ui circular label">${surveyConfig?.getCurrentDocs()?.size()}</div></g:link>
                        </dd>

                    </dl>
                </div>
            </div>

            <div class="ui card ">
                <div class="content">
                    <dl>
                        <dt class="control-label">${message(code: 'surveyConfig.header.label')}</dt>
                        <dd>
                            ${surveyConfig?.header}
                        </dd>

                    </dl>
                    <dl>
                        <dt class="control-label">${message(code: 'surveyConfig.comment.label')}</dt>
                        <dd>
                            ${surveyConfig?.comment}
                        </dd>

                    </dl>

                </div>
            </div>

        </div>
    </div>
</g:if>

<br>

<div>

    <h3 class="ui left aligned icon header">

        <g:message code="surveyProperty.label"/>:
        ${surveyProperty?.getI10n('name')}

        <g:if test="${surveyProperty?.getI10n('explain')}">
            <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="right center"
                  data-content="${surveyProperty?.getI10n('explain')}">
                <i class="question circle icon"></i>
            </span>
        </g:if>

        (${surveyProperty?.getLocalizedType()})
    </h3>


    <semui:form>
        <h4 class="ui left aligned icon header">${message(code: 'surveyParticipants.label')} <semui:totalNumber
                total="${surveyResult?.size()}"/></h4>

        <h4><g:message code="surveyParticipants.hasAccess"/></h4>


        <g:set var="surveyParticipantsHasAccess"
               value="${surveyResult?.findAll { !it.participant.hasAccessOrg() }.sort {
                   it?.participant.sortname
               }}"/>

        <div class="four wide column">
            <g:link onclick="copyEmailAdresses(${surveyParticipantsHasAccess?.participant?.id})"
                    class="ui icon button right floated trigger-modal">
                <g:message
                        code="survey.copyEmailaddresses.participantsHasAccess"/>
            </g:link>
        </div>

        <br>
        <br>

        <table class="ui celled sortable table la-table">
            <thead>
            <tr>
                <th class="center aligned">${message(code: 'sidewide.number')}</th>
                <th>${message(code: 'org.sortname.label')}</th>
                <th>${message(code: 'org.name.label')}</th>
                <th>${message(code: 'surveyResult.result')}</th>
                <th>${message(code: 'surveyResult.commentParticipant')}</th>
            </tr>
            </thead>
            <g:each in="${surveyResult?.findAll { it.participant.hasAccessOrg() }.sort { it?.participant.sortname }}"
                    var="result" status="i">

                <tr>
                    <td class="center aligned">
                        ${i + 1}
                    </td>
                    <td>

                        <g:link controller="myInstitution" action="manageParticipantSurveys" id="${result?.participant?.id}">
                            ${result?.participant?.sortname}
                        </g:link>

                    </td>
                    <td>
                        <g:link controller="organisation" action="show" id="${result?.participant.id}">
                            ${fieldValue(bean: result?.participant, field: "name")}
                        </g:link>
                    </td>

                    <g:set var="surveyOrg"
                           value="${com.k_int.kbplus.SurveyOrg.findBySurveyConfigAndOrg(result?.surveyConfig, result?.participant)}"/>

                    <g:if test="${!surveyOrg?.existsMultiYearTerm()}">

                        <td>
                            <g:if test="${result?.type?.type == Integer.toString()}">
                                <semui:xEditable owner="${result}" type="text" field="intValue"/>
                            </g:if>
                            <g:elseif test="${result?.type?.type == String.toString()}">
                                <semui:xEditable owner="${result}" type="text" field="stringValue"/>
                            </g:elseif>
                            <g:elseif test="${result?.type?.type == BigDecimal.toString()}">
                                <semui:xEditable owner="${result}" type="text" field="decValue"/>
                            </g:elseif>
                            <g:elseif test="${result?.type?.type == Date.toString()}">
                                <semui:xEditable owner="${result}" type="date" field="dateValue"/>
                            </g:elseif>
                            <g:elseif test="${result?.type?.type == URL.toString()}">
                                <semui:xEditable owner="${result}" type="url" field="urlValue"
                                                 overwriteEditable="${overwriteEditable}"
                                                 class="la-overflow la-ellipsis"/>
                                <g:if test="${result?.urlValue}">
                                    <semui:linkIcon/>
                                </g:if>
                            </g:elseif>
                            <g:elseif test="${result?.type?.type == RefdataValue.toString()}">
                                <semui:xEditableRefData owner="${result}" type="text" field="refValue"
                                                        config="${result.type?.refdataCategory}"/>
                            </g:elseif>
                        </td>
                        <td>
                            ${result?.comment}
                        </td>
                    </g:if>
                    <g:else>
                        <td>
                            <g:message code="surveyOrg.perennialTerm.available"/>
                        </td>
                        <td>

                        </td>
                    </g:else>
                </tr>
            </g:each>
        </table>


        <h4><g:message code="surveyParticipants.hasNotAccess"/></h4>

        <g:set var="surveyParticipantsHasNotAccess"
               value="${surveyResult?.findAll { !it.participant.hasAccessOrg() }.sort {
                   it?.participant.sortname
               }}"/>

        <div class="four wide column">
        <g:link onclick="copyEmailAdresses(${surveyParticipantsHasNotAccess?.participant?.id})"
                class="ui icon button right floated trigger-modal">
            <g:message
                    code="survey.copyEmailaddresses.participantsHasNoAccess"/>
        </g:link>
        </div>

        <br>
        <br>

        <table class="ui celled sortable table la-table">
            <thead>
            <tr>
                <th class="center aligned">${message(code: 'sidewide.number')}</th>
                <th>${message(code: 'org.sortname.label')}</th>
                <th>${message(code: 'org.name.label')}</th>
                <th>${message(code: 'surveyResult.result')}</th>
                <th>${message(code: 'surveyResult.commentParticipant')}</th>
            </tr>
            </thead>
            <g:each in="${surveyParticipantsHasNotAccess}"
                    var="result" status="i">

                <tr>
                    <td class="center aligned">
                        ${i + 1}
                    </td>
                    <td>
                        <g:link controller="myInstitution" action="manageParticipantSurveys" id="${result?.participant?.id}">
                            ${result?.participant?.sortname}
                        </g:link>
                    </td>
                    <td>
                        <g:link controller="organisation" action="show" id="${result?.participant.id}">
                            ${fieldValue(bean: result?.participant, field: "name")}
                        </g:link>
                    </td>

                    <g:set var="surveyOrg"
                           value="${com.k_int.kbplus.SurveyOrg.findBySurveyConfigAndOrg(result?.surveyConfig, result?.participant)}"/>

                    <g:if test="${!surveyOrg?.existsMultiYearTerm()}">

                        <td>
                            <g:if test="${result?.type?.type == Integer.toString()}">
                                <semui:xEditable owner="${result}" type="text" field="intValue"/>
                            </g:if>
                            <g:elseif test="${result?.type?.type == String.toString()}">
                                <semui:xEditable owner="${result}" type="text" field="stringValue"/>
                            </g:elseif>
                            <g:elseif test="${result?.type?.type == BigDecimal.toString()}">
                                <semui:xEditable owner="${result}" type="text" field="decValue"/>
                            </g:elseif>
                            <g:elseif test="${result?.type?.type == Date.toString()}">
                                <semui:xEditable owner="${result}" type="date" field="dateValue"/>
                            </g:elseif>
                            <g:elseif test="${result?.type?.type == URL.toString()}">
                                <semui:xEditable owner="${result}" type="url" field="urlValue"
                                                 overwriteEditable="${overwriteEditable}"
                                                 class="la-overflow la-ellipsis"/>
                                <g:if test="${result?.urlValue}">
                                    <semui:linkIcon/>
                                </g:if>
                            </g:elseif>
                            <g:elseif test="${result?.type?.type == RefdataValue.toString()}">
                                <semui:xEditableRefData owner="${result}" type="text" field="refValue"
                                                        config="${result.type?.refdataCategory}"/>
                            </g:elseif>
                        </td>
                        <td>
                            ${result?.comment}
                        </td>
                    </g:if>
                    <g:else>
                        <td>
                            <g:message code="surveyOrg.perennialTerm.available"/>
                        </td>
                        <td>

                        </td>
                    </g:else>
                </tr>
            </g:each>
        </table>
    </semui:form>
</div>

<g:javascript>

var isClicked = false;

function copyEmailAdresses(orgListIDs) {
            event.preventDefault();
            $.ajax({
                url: "<g:createLink controller='survey' action='copyEmailaddresses'/>",
                                data: {
                                    orgListIDs: orgListIDs.join(' '),
                                }
            }).done( function(data) {
                $('.ui.dimmer.modals > #copyEmailaddresses_ajaxModal').remove();
                $('#dynamicModalContainer').empty().html(data);

                $('#dynamicModalContainer .ui.modal').modal({
                    onVisible: function () {
                        r2d2.initDynamicSemuiStuff('#copyEmailaddresses_ajaxModal');
                        r2d2.initDynamicXEditableStuff('#copyEmailaddresses_ajaxModal');
                    }
                    ,
                    detachable: true,
                    autofocus: false,
                    closable: false,
                    transition: 'scale',
                    onApprove : function() {
                        $(this).find('.ui.form').submit();
                        return false;
                    }
                }).modal('show');
            })
        };

</g:javascript>

</body>
</html>
