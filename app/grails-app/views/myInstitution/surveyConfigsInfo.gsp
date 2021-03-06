<%@ page import="com.k_int.kbplus.RefdataCategory;com.k_int.kbplus.SurveyProperty;com.k_int.kbplus.RefdataValue;de.laser.helper.RDStore" %>
<laser:serviceInjection/>

<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code: 'laser', default: 'LAS:eR')} : ${message(code: 'survey.label')}</title>
</head>

<body>

<semui:breadcrumbs>
    <semui:crumb controller="myInstitution" action="dashboard" text="${institution?.getDesignation()}"/>
    <semui:crumb controller="myInstitution" action="currentSurveys" message="currentSurveys.label"/>
    <semui:crumb controller="myInstitution" action="surveyInfos" id="${surveyInfo.id}" text="${surveyInfo.name}"/>
    <semui:crumb message="survey.label" class="active"/>
</semui:breadcrumbs>

<h1 class="ui left aligned icon header"><semui:headerIcon/>
${message(code: 'survey.label')} -

<g:link controller="myInstitution" action="surveyInfos" id="${surveyInfo.id}">${surveyInfo.name}</g:link>
<semui:surveyStatus object="${surveyInfo}"/>
</h1>

<g:if test="${navigation}">
    <%--
    <br>

    <div class="ui center aligned grid">
        <div class='ui big label la-annual-rings'>

            <g:if test="${navigation?.prev}">
                <g:link controller="myInstitution" action="surveyConfigsInfo" id="${surveyInfo?.id}"
                        params="[surveyConfigID: navigation?.prev?.id]" class="item"
                        title="${message(code: 'surveyConfigsInfo.prevSurveyConfig')}">
                    <i class='arrow left icon'></i>
                </g:link>
            </g:if>
            <g:else>
                <i class=' icon'></i>
            </g:else>
            <g:message code="surveyConfigsInfo.totalSurveyConfig"
                       args="[surveyConfig?.configOrder, navigation?.total]"/>
            <g:if test="${navigation?.next}">
                <g:link controller="myInstitution" action="surveyConfigsInfo" id="${surveyInfo?.id}"
                        params="[surveyConfigID: navigation?.next?.id]" class="item"
                        title="${message(code: 'surveyConfigsInfo.nextSurveyConfig')}">
                    <i class='arrow right icon'></i>
                </g:link>
            </g:if>
            <g:else>
                <i class=' icon'></i>
            </g:else>
        </div>
    </div>
    --%>
</g:if>

<br>

<semui:messages data="${flash}"/>


<g:link controller="myInstitution" action="surveyInfos" id="${surveyInfo.id}">Zur Übersicht</g:link>

<br>

<g:if test="${!editable}">
    <div class="ui icon positive message">
        <i class="info icon"></i>

        <div class="content">
            <div class="header"></div>

            <p>
                <%-- <g:message code="surveyInfo.finishOrSurveyCompleted"/> --%>
                <g:message code="surveyResult.finish.info" />.
            </p>
        </div>
    </div>
</g:if>


<g:if test="${ownerId}">
    <g:set var="choosenOrg" value="${com.k_int.kbplus.Org.findById(ownerId)}"/>
    <g:set var="choosenOrgCPAs" value="${choosenOrg?.getGeneralContactPersons(false)}"/>

    <semui:form>
        <h3><g:message code="surveyInfo.owner.label"/>:</h3>

        <table class="ui table la-table la-table-small">
            <tbody>
            <tr>
                <td>
                    <p><strong>${choosenOrg?.name} (${choosenOrg?.shortname})</strong></p>

                    ${choosenOrg?.libraryType?.getI10n('value')}
                </td>
                <td>
                    <g:if test="${choosenOrgCPAs}">
                        <g:set var="oldEditable" value="${editable}"/>
                        <g:set var="editable" value="${false}" scope="request"/>
                        <g:each in="${choosenOrgCPAs}" var="gcp">
                            <g:render template="/templates/cpa/person_details"
                                      model="${[person: gcp, tmplHideLinkToAddressbook: true]}"/>
                        </g:each>
                        <g:set var="editable" value="${oldEditable ?: false}" scope="request"/>

                    </g:if>
                </td>
            </tr>
            </tbody>
        </table>
    </semui:form>
</g:if>

<br>

<g:if test="${surveyConfig?.type == 'Subscription'}">

    <g:if test="${!subscriptionInstance}">
        <g:set var="gascoView" value="true"/>
        <h2 class="ui icon header"><semui:headerIcon/>

            <i class="icon clipboard outline la-list-icon"></i>
        <g:link controller="public" action="gasco" params="[q: surveyConfig?.subscription?.name]">
            ${surveyConfig?.subscription?.name}
        </g:link>
        </h2>
    </g:if>
    <g:else>

        <h2 class="ui icon header"><semui:headerIcon/>
        <g:link controller="subscription" action="show" id="${subscriptionInstance?.id}">
            ${subscriptionInstance?.name}
        </g:link>
        </h2>
        <semui:auditInfo auditable="[subscriptionInstance, 'name']"/>
    </g:else>

</g:if>
<g:else>
    <h2><g:message code="surveyConfigsInfo.surveyConfig.info" args="[surveyConfig?.getConfigNameShort()]"/></h2>
</g:else>

<div class="ui stackable grid">
    <div class="twelve wide column">
        <div class="la-inline-lists">
            <g:if test="${surveyConfig?.type == 'Subscription' && !gascoView}">
                <div class="ui card">
                    <div class="content">
                        <dl>
                            <dt class="control-label">${message(code: 'subscription.details.status')}</dt>
                            <dd>${subscriptionInstance?.status?.getI10n('value')}</dd>
                            <dd><semui:auditInfo auditable="[subscriptionInstance, 'status']"/></dd>
                        </dl>
                        <dl>
                            <dt class="control-label">${message(code: 'subscription.details.type')}</dt>
                            <dd>${subscriptionInstance?.type?.getI10n('value')}</dd>
                            <dd><semui:auditInfo auditable="[subscriptionInstance, 'type']"/></dd>
                        </dl>
                        <dl>
                            <dt class="control-label">${message(code: 'subscription.form.label')}</dt>
                            <dd>${subscriptionInstance?.form?.getI10n('value')}</dd>
                            <dd><semui:auditInfo auditable="[subscriptionInstance, 'form']"/></dd>
                        </dl>
                        <dl>
                            <dt class="control-label">${message(code: 'subscription.resource.label')}</dt>
                            <dd>${subscriptionInstance?.resource?.getI10n('value')}</dd>
                            <dd><semui:auditInfo auditable="[subscriptionInstance, 'resource']"/></dd>
                        </dl>
                        <g:if test="${subscriptionInstance?.instanceOf && (contextOrg?.id == subscriptionInstance?.getConsortia()?.id)}">
                            <dl>
                                <dt class="control-label">${message(code: 'subscription.isInstanceOfSub.label')}</dt>
                                <dd>
                                    <g:link controller="subscription" action="show"
                                            id="${subscriptionInstance?.instanceOf.id}">${subscriptionInstance?.instanceOf}</g:link>
                                </dd>
                            </dl>

                            <dl>
                                <dt class="control-label">
                                    ${message(code: 'license.details.linktoLicense.pendingChange', default: 'Automatically Accept Changes?')}
                                </dt>
                                <dd>
                                    ${subscriptionInstance?.isSlaved ? RDStore.YN_YES.getI10n('value') : RDStore.YN_NO.getI10n('value')}
                                </dd>
                            </dl>
                        </g:if>
                        <dl>
                            <dt class="control-label">
                                <g:message code="default.identifiers.label"/>
                            </dt>
                            <dd>
                                <g:each in="${subscriptionInstance?.ids?.sort { it?.identifier?.ns?.ns }}"
                                        var="id">
                                    <span class="ui small teal image label">
                                        ${id.identifier.ns.ns}: <div class="detail">${id.identifier.value}</div>
                                    </span>
                                </g:each>
                            </dd>
                        </dl>

                    </div>
                </div>

                <g:if test="${subscriptionInstance?.packages}">
                    <div class="ui card la-js-hideable">
                        <div class="content">
                            <table class="ui three column la-selectable table">
                                <g:each in="${subscriptionInstance?.packages.sort { it.pkg.name }}" var="sp">
                                    <tr>
                                        <th scope="row"
                                            class="control-label la-js-dont-hide-this-card">${message(code: 'subscription.packages.label')}</th>
                                        <td>
                                            <g:link controller="package" action="show"
                                                    id="${sp.pkg.id}">${sp?.pkg?.name}</g:link>

                                            <g:if test="${sp.pkg?.contentProvider}">
                                                (${sp.pkg?.contentProvider?.name})
                                            </g:if>
                                        </td>
                                        <td class="right aligned">
                                        </td>

                                    </tr>
                                </g:each>
                            </table>

                        </div><!-- .content -->
                    </div>
                </g:if>

                <div class="ui card la-js-hideable">
                    <div class="content">

                        <g:render template="/templates/links/orgLinksAsList"
                                  model="${[roleLinks    : visibleOrgRelations,
                                            roleObject   : subscriptionInstance,
                                            roleRespValue: 'Specific subscription editor',
                                            editmode     : false,
                                            showPersons: false
                                  ]}"/>

                    </div>
                </div>

                <div class="ui card la-js-hideable">
                    <div class="content">
                        <g:set var="derivedPropDefGroups"
                               value="${subscriptionInstance?.owner?.getCalculatedPropDefGroups(contextService.getOrg())}"/>

                        <div class="ui la-vertical buttons">
                            <g:if test="${derivedPropDefGroups?.global || derivedPropDefGroups?.local || derivedPropDefGroups?.member || derivedPropDefGroups?.fallback}">

                                <button id="derived-license-properties-toggle"
                                        class="ui button la-js-dont-hide-button">Vertragsmerkmale anzeigen</button>
                                <script>
                                    $('#derived-license-properties-toggle').on('click', function () {
                                        $('#derived-license-properties').toggleClass('hidden')
                                        if ($('#derived-license-properties').hasClass('hidden')) {
                                            $(this).text('Vertragsmerkmale anzeigen')
                                        } else {
                                            $(this).text('Vertragsmerkmale ausblenden')
                                        }
                                    })
                                </script>

                            </g:if>

                            <button id="subscription-properties-toggle"
                                    class="ui button la-js-dont-hide-button">Lizenzmerkmale anzeigen</button>
                            <script>
                                $('#subscription-properties-toggle').on('click', function () {
                                    $('#subscription-properties').toggleClass('hidden')
                                    if ($('#subscription-properties').hasClass('hidden')) {
                                        $(this).text('Lizenzmerkmale anzeigen')
                                    } else {
                                        $(this).text('Lizenzmerkmale ausblenden')
                                    }
                                })
                            </script>
                        </div>

                    </div><!-- .content -->
                </div>

                <g:if test="${derivedPropDefGroups?.global || derivedPropDefGroups?.local || derivedPropDefGroups?.member || derivedPropDefGroups?.fallback}">
                    <div id="derived-license-properties" class="hidden" style="margin: 1em 0">

                        <g:render template="/subscription/licProp" model="${[
                                license             : subscriptionInstance?.owner,
                                derivedPropDefGroups: derivedPropDefGroups
                        ]}"/>
                    </div>
                </g:if>

                <g:set var="oldEditable" value="${editable}"/>
                <div id="subscription-properties" class="hidden" style="margin: 1em 0">
                    <g:set var="editable" value="${false}" scope="request"/>
                    <g:set var="editable" value="${false}" scope="page"/>
                    <g:render template="/subscription/properties" model="${[
                            subscriptionInstance: subscriptionInstance,
                            authorizedOrgs      : authorizedOrgs
                    ]}"/>

                    <g:set var="editable" value="${oldEditable ?: false}" scope="page"/>
                    <g:set var="editable" value="${oldEditable ?: false}" scope="request"/>

                </div>

            </g:if>



            <g:if test="${surveyConfig?.type == 'Subscription'}">
                <div class="ui card ">
                    <div class="content">

                        <dl>
                            <dt class="control-label">
                                <div class="ui icon la-popup-tooltip la-delay"
                                     data-content="${message(code: "surveyConfig.scheduledStartDate.comment")}">
                                    ${message(code: 'surveyConfig.scheduledStartDate.label')}
                                </div>
                            </dt>
                            <dd><g:formatDate format="${message(code: 'default.date.format.notime')}"
                                              date="${surveyConfig?.scheduledStartDate}"/></dd>
                        </dl>
                        <dl>
                            <dt class="control-label">
                                <div class="ui icon la-popup-tooltip la-delay"
                                     data-content="${message(code: "surveyConfig.scheduledEndDate.comment")}">
                                    ${message(code: 'surveyConfig.scheduledEndDate.label')}
                                </div>
                            </dt>
                            <dd><g:formatDate format="${message(code: 'default.date.format.notime')}"
                                              date="${surveyConfig?.scheduledEndDate}"/></dd>
                        </dl>

                    </div>
                </div>
            </g:if>

            <div class="ui card la-time-card">
                <div class="content">
                    <div class="header"><g:message code="surveyConfigsInfo.comment"/></div>
                </div>

                <div class="content">
                    <g:if test="${surveyConfig?.comment}">
                        ${surveyConfig?.comment}
                    </g:if><g:else>
                        <g:message code="surveyConfigsInfo.comment.noComment"/>
                    </g:else>
                </div>
            </div>

            <g:if test="${surveyConfig?.type == 'Subscription'}">
                <div class="ui card la-time-card">

                    <div class="content">
                        <div class="header"><g:message code="surveyConfigsInfo.costItems"/></div>
                    </div>

                    <div class="content">

                        <g:set var="costItemSurvey"
                               value="${com.k_int.kbplus.CostItem.findBySurveyOrg(com.k_int.kbplus.SurveyOrg.findBySurveyConfigAndOrg(surveyConfig, institution))}"/>
                        <g:set var="costItemsSub"
                               value="${subscriptionInstance?.costItems?.findAll {
                                   it?.costItemElement?.id == costItemSurvey?.costItemElement?.id
                               }}"/>

                        <%
                            // ERMS-1521 HOTFIX
                            if (! costItemsSub) {
                                costItemsSub = subscriptionInstance?.costItems.findAll{
                                    it.costItemElement?.id == RefdataValue.getByValueAndCategory('price: consortial price', 'CostItemElement')?.id
                                }
                            }
                        %>

                        <table class="ui celled la-table-small la-table-inCard table">
                            <thead>
                            <tr>
                                <th>
                                    <g:message code="surveyConfigsInfo.oldPrice"/>
                                </th>
                                <th>
                                    <g:message code="surveyConfigsInfo.newPrice"/>
                                </th>
                            </tr>
                            </thead>
                            <tbody class="top aligned">
                            <tr>
                                <td>
                                    <g:if test="${costItemsSub}">
                                        <g:each in="${costItemsSub}" var="costItemSub">
                                            ${costItemSub?.costItemElement?.getI10n('value')}
                                            <b><g:formatNumber
                                                    number="${consCostTransfer ? costItemSub?.costInBillingCurrencyAfterTax : costItemSub?.costInBillingCurrency}"
                                                    minFractionDigits="2" maxFractionDigits="2" type="number"/></b>

                                            ${(costItemSub?.billingCurrency?.getI10n('value').split('-')).first()}

                                            <g:if test="${costItemSub?.startDate || costItemSub?.endDate}">
                                                <br>(${formatDate(date: costItemSub?.startDate, format: message(code: 'default.date.format.notime'))} - ${formatDate(date: costItemSub?.endDate, format: message(code: 'default.date.format.notime'))})
                                            </g:if>
                                            <br>

                                        </g:each>
                                    </g:if>
                                </td>
                                <td>
                                    <g:if test="${costItemSurvey}">
                                        ${costItemSurvey?.costItemElement?.getI10n('value')}
                                        <b><g:formatNumber
                                                number="${consCostTransfer ? costItemSurvey?.costInBillingCurrencyAfterTax : costItemSurvey?.costInBillingCurrency}"
                                                minFractionDigits="2" maxFractionDigits="2" type="number"/></b>

                                        ${(costItemSurvey?.billingCurrency?.getI10n('value').split('-')).first()}

                                        <g:if test="${costItemSurvey?.startDate || costItemSurvey?.endDate}">
                                            <br>(${formatDate(date: costItemSurvey?.startDate, format: message(code: 'default.date.format.notime'))} - ${formatDate(date: costItemSurvey?.endDate, format: message(code: 'default.date.format.notime'))})
                                        </g:if>

                                        <g:if test="${costItemSurvey?.costDescription}">
                                            <br>

                                            <div class="ui icon la-popup-tooltip la-delay" data-position="right center" data-variation="tiny"
                                                 data-content="${costItemSurvey?.costDescription}">
                                                <i class="question small circular inverted icon"></i>
                                            </div>
                                        </g:if>

                                    </g:if>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </g:if>
        </div>
    </div>

    <aside class="four wide column la-sidekick">
        <div id="container-documents">
            <g:render template="/survey/cardDocuments"
                      model="${[ownobj: surveyConfig, owntp: 'surveyConfig', css_class: '']}"/>
        </div>
    </aside><!-- .four -->

</div><!-- .grid -->


<semui:form>
    <h3><g:message code="surveyConfigsInfo.properties"/>
    <semui:totalNumber
            total="${surveyResults?.size()}"/>
    </h3>

    <table class="ui celled sortable table la-table">
        <thead>
        <tr>
            <th class="center aligned">${message(code: 'sidewide.number')}</th>
            <th>${message(code: 'surveyProperty.label')}</th>
            <th>${message(code: 'surveyProperty.type.label')}</th>
            <th>${message(code: 'surveyResult.result')}</th>
            <th>${message(code: 'surveyResult.commentParticipant')}</th>
            <th>
                ${message(code: 'surveyResult.commentOnlyForParticipant')}
                <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="right center"
                      data-content="${message(code: 'surveyResult.commentOnlyForParticipant.info')}">
                    <i class="question circle icon"></i>
                </span>
            </th>
        </tr>
        </thead>
        <g:each in="${surveyResults}" var="surveyResult" status="i">

            <tr>
                <td class="center aligned">
                    ${i + 1}
                </td>
                <td>
                    ${surveyResult?.type?.getI10n('name')}

                    <g:if test="${surveyResult?.type?.getI10n('explain')}">
                        <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="bottom center"
                              data-content="${surveyResult?.type?.getI10n('explain')}">
                            <i class="question circle icon"></i>
                        </span>
                    </g:if>

                </td>
                <td>
                    ${surveyResult?.type?.getLocalizedType()}

                </td>
                <g:set var="surveyOrg"
                       value="${com.k_int.kbplus.SurveyOrg.findBySurveyConfigAndOrg(surveyResult?.surveyConfig, institution)}"/>

                <g:if test="${!surveyOrg?.existsMultiYearTerm()}">

                    <td>
                        <g:if test="${surveyResult?.type?.type == Integer.toString()}">
                            <semui:xEditable owner="${surveyResult}" type="text" field="intValue"/>
                        </g:if>
                        <g:elseif test="${surveyResult?.type?.type == String.toString()}">
                            <semui:xEditable owner="${surveyResult}" type="text" field="stringValue"/>
                        </g:elseif>
                        <g:elseif test="${surveyResult?.type?.type == BigDecimal.toString()}">
                            <semui:xEditable owner="${surveyResult}" type="text" field="decValue"/>
                        </g:elseif>
                        <g:elseif test="${surveyResult?.type?.type == Date.toString()}">
                            <semui:xEditable owner="${surveyResult}" type="date" field="dateValue"/>
                        </g:elseif>
                        <g:elseif test="${surveyResult?.type?.type == URL.toString()}">
                            <semui:xEditable owner="${surveyResult}" type="url" field="urlValue"
                                             overwriteEditable="${overwriteEditable}"
                                             class="la-overflow la-ellipsis"/>
                            <g:if test="${surveyResult?.urlValue}">
                                <semui:linkIcon/>
                            </g:if>
                        </g:elseif>
                        <g:elseif test="${surveyResult?.type?.type == RefdataValue.toString()}">

                            <g:if test="${surveyResult?.type?.name in ["Participation"] && surveyResult?.owner?.id != institution?.id}">
                                <semui:xEditableRefData owner="${surveyResult}" field="refValue" type="text"  id="participation" config="${surveyResult.type?.refdataCategory}" />
                            </g:if>
                            <g:else>
                            <semui:xEditableRefData owner="${surveyResult}" type="text" field="refValue"
                                                    config="${surveyResult.type?.refdataCategory}"/>
                            </g:else>
                        </g:elseif>
                    </td>
                    <td>
                        <semui:xEditable owner="${surveyResult}" type="textarea" field="comment"/>
                    </td>
                    <td>
                        <semui:xEditable owner="${surveyResult}" type="textarea" field="participantComment"/>
                    </td>
                </g:if>
                <g:else>
                    <td>
                        <g:message code="surveyOrg.perennialTerm.available"/>
                    </td>
                    <td>

                    </td>
                    <td>

                    </td>
                </g:else>

            </tr>
        </g:each>
    </table>

</semui:form>



<br />
<g:link controller="myInstitution" action="surveyInfos" id="${surveyInfo.id}">Zur Übersicht</g:link>



<r:script>
                                    $('body #participation').editable({
                                        validate: function (value) {
                                            if (value == "com.k_int.kbplus.RefdataValue:${de.laser.helper.RDStore.YN_NO.id}") {
                                                var r = confirm("Wollen Sie wirklich im nächstem Jahr nicht mehr bei dieser Lizenz teilnehmen?  " );
                                                if (r == false) {
                                                   return "Sie haben die Nicht-Teilnahme an der Lizenz für das nächste Jahr nicht zugestimmt!"
                                                }
                                            }
                                        },
                                        tpl: '<select class="ui dropdown"></select>'
                                    }).on('shown', function() {
                                        $(".table").trigger('reflow');
                                        $('.ui.dropdown')
                                                .dropdown({
                                            clearable: true
                                        })
                                        ;
                                    }).on('hidden', function() {
                                        $(".table").trigger('reflow')
                                    });
</r:script>

</body>
</html>
