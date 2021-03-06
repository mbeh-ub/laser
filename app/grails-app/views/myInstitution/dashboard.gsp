<%@ page import="de.laser.AccessService; de.laser.helper.SqlDateUtils; com.k_int.kbplus.*; com.k_int.kbplus.RefdataValue; com.k_int.kbplus.abstract_domain.AbstractProperty; com.k_int.kbplus.UserSettings; de.laser.DashboardDueDate" %>
<g:set var="simpleDateFormat" value="${new java.text.SimpleDateFormat("yyyyMMdd")}"/>
<!doctype html>
<html>
    <head>
        <meta name="layout" content="semanticUI"/>
        <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'myinst.title', default:'Institutional Dash')}</title>
    </head>
    <body>

        <laser:serviceInjection />

        <semui:breadcrumbs>
            <semui:crumb text="${institution?.getDesignation()}" class="active" />
        </semui:breadcrumbs>

        <h1 class="ui left aligned icon header"><semui:headerIcon />${institution.name}</h1>

        <div class="ui equal width grid">
            <div class="row">

                <div class="column">
                    <div class="ui divided relaxed list">
                        <div class="item">
                            <g:link controller="myInstitution" action="currentSubscriptions">${message(code:'menu.my.subscriptions')}</g:link>
                        </div>
                        <div class="item">
                            <g:link controller="myInstitution" action="currentLicenses">${message(code:'menu.my.licenses')}</g:link>
                        </div>
                        <div class="item">
                            <g:link controller="myInstitution" action="currentTitles">${message(code:'menu.my.titles')}</g:link>
                        </div>
                    </div>
                </div>

                <div class="column">
                    <div class="ui divided relaxed list">
                        <div class="item">
                            <g:link controller="myInstitution" action="changes">${message(code: 'myinst.todo.label', default: 'To Do')}</g:link>
                        </div>
                        <semui:securedMainNavItem specRole="ROLE_ADMIN" controller="myInstitution" action="announcements" message="announcement.plural" />
                        <%--<div class="item">
                            <g:link controller="myInstitution" action="announcements">${message(code: 'announcement.plural', default: 'Announcements')}</g:link>
                        </div>--%>
                        <g:if test="${grailsApplication.config.feature_finance}">
                            <semui:securedMainNavItem affiliation="INST_EDITOR" controller="myInstitution" action="finance" message="menu.institutions.finance" />
                        </g:if>
                    </div>
                </div>

                <div class="column">
                    <div class="ui divided relaxed list">
                        <semui:securedMainNavItem orgPerm="ORG_INST,ORG_CONSORTIUM" controller="myInstitution" action="tasks" message="task.plural" />
                        <semui:securedMainNavItem orgPerm="ORG_INST,ORG_CONSORTIUM" controller="myInstitution" action="addressbook" message="menu.institutions.myAddressbook" />

                        <semui:securedMainNavItem orgPerm="ORG_INST,ORG_CONSORTIUM" affiliation="INST_EDITOR" controller="myInstitution" action="managePrivateProperties" message="menu.institutions.manage_props" />
                    </div>
                </div>
            </div>
        </div>

        <semui:messages data="${flash}" />

        <br />

    <%-- should be made overridable by pagination setting --%>
    <%
        def US_DASHBOARD_TAB
        switch(params.view) {
            case "announcementsView": US_DASHBOARD_TAB = RefdataValue.getByValueAndCategory('Announcements','User.Settings.Dashboard.Tab')
            break
            default: US_DASHBOARD_TAB = user.getSetting(UserSettings.KEYS.DASHBOARD_TAB, RefdataValue.getByValueAndCategory('Due Dates', 'User.Settings.Dashboard.Tab'))
            break
        }
    %>
    <div class="ui secondary pointing tabular menu">
        <a class="${US_DASHBOARD_TAB.getValue().value=='Due Dates' || US_DASHBOARD_TAB.getValue()=='Due Dates' ? 'active item':'item'}" data-tab="first">
            <i class="checked alarm end icon large"></i>
            ${dueDatesCount}
            ${message(code:'myinst.dash.due_dates.label')}
        </a>
        <a class="${US_DASHBOARD_TAB.getValue().value == 'Changes' || US_DASHBOARD_TAB.getValue() == 'Changes' ? 'active item':'item'}" data-tab="second">
            <i class="history icon large"></i>
            <%
                def countChanges = 0
                changes?.collect { c ->
                    countChanges += c[1]
                }
            %>
            ${countChanges}
            ${message(code:'myinst.todo.label', default:'To Do')}
        </a>

       %{-- <sec:ifAnyGranted roles="ROLE_ADMIN">
        <a class="${US_DASHBOARD_TAB.getValue().value=='Announcements' || US_DASHBOARD_TAB.getValue() == 'Announcements' ? 'active item':'item'}" data-tab="third" id="jsFallbackAnnouncements">
            <i class="warning circle icon large"></i>
            ${recentAnnouncementsCount}
            ${message(code:'announcement.plural', default:'Announcements')}
        </a>
        </sec:ifAnyGranted>--}%

        <g:if test="${accessService.checkPerm('ORG_INST,ORG_CONSORTIUM')}">
            <a class="${US_DASHBOARD_TAB.getValue().value=='Tasks' || US_DASHBOARD_TAB.getValue()=='Tasks' ? 'active item':'item'}" data-tab="forth">
                <i class="checked calendar icon large"></i>
                ${tasksCount}
                ${message(code:'myinst.dash.task.label')}
            </a>
        </g:if>

        <g:if test="${accessService.checkPerm('ORG_BASIC_MEMBER')}">

            <g:if test="${grailsApplication.config.featureSurvey}">
            <a class="${US_DASHBOARD_TAB.getValue().value=='Surveys' || US_DASHBOARD_TAB.getValue()=='Surveys' ? 'active item':'item'}" data-tab="fifth">
                <i class="checked tasks icon large"></i>
                ${surveys?.size()}
                ${message(code:'myinst.dash.survey.label')}
            </a>
            </g:if>
        </g:if>

       %{-- <g:if test="${accessService.checkPerm('ORG_CONSORTIUM')}">
            <a class="${US_DASHBOARD_TAB.getValue().value=='Surveys' || US_DASHBOARD_TAB.getValue()=='Surveys' ? 'active item':'item'}" data-tab="six">
                <i class="checked tasks icon large"></i>
                ${surveysConsortia?.size()}
                ${message(code:'myinst.dash.surveyConsortia.label')}
            </a>
        </g:if>--}%


    </div><!-- secondary -->

        <div class="ui bottom attached tab segment ${US_DASHBOARD_TAB.getValue().value == 'Due Dates' || US_DASHBOARD_TAB.getValue()=='Due Dates' ? 'active':''}" data-tab="first" style="border-top: 1px solid #d4d4d5; ">
            <div>
                <g:render template="/user/dueDatesView"
                          model="[user: user, dueDates: dueDates, dueDatesCount: dueDatesCount]"/>
            </div>
        </div>

        <div class="ui bottom attached tab segment ${US_DASHBOARD_TAB.getValue().value == 'Changes' || US_DASHBOARD_TAB.getValue() == 'Changes' ? 'active':''}" data-tab="second" style="border-top: 1px solid #d4d4d5; ">
            <g:if test="${editable}">
                <div class="pull-right">
                    <g:link action="changes" class="ui button">${message(code:'myinst.todo.submit.label', default:'View To Do List')}</g:link>
                </div>
            </g:if>

            <g:message code="profile.dashboardItemsTimeWindow"
                       default="You see events from the last {0} days."
                       args="${user.getSettingsValue(UserSettings.KEYS.DASHBOARD_ITEMS_TIME_WINDOW, 14)}" />

            <br />

            <div class="ui relaxed list" style="clear:both;padding-top:1rem;">
                <g:each in="${changes}" var="changeSet">
                    <g:set var="change" value="${changeSet[0]}" />
                    <div class="item">

                       <div class="ui internally celled grid">
                           <div class="row">
                               <div class="three wide column">
                                   <a class="ui green circular label">${changeSet[1]}</a>
                                </div><!-- .column -->
                                <div class="thirteen wide column">

                                <g:if test="${change instanceof Subscription}">
                                    <strong>${message(code:'subscription')}</strong>
                                    <br />
                                    <g:link controller="subscription" action="changes" id="${change.id}">${change.toString()}</g:link>
                                </g:if>
                                <g:if test="${change instanceof License}">
                                    <strong>${message(code:'license')}</strong>
                                    <br />
                                    <g:link controller="license" action="changes" id="${change.id}">${change.toString()}</g:link>
                                </g:if>
                               <g:if test="${change instanceof PendingChange && change.costItem}">
                                   <strong>${message(code:'financials.costItem')}</strong>
                                   <br>
                                   ${raw(change.desc)}
                                   <g:link class="ui green button" controller="finance" action="acknowledgeChange" id="${change.id}"><g:message code="pendingChange.acknowledge"/></g:link>
                               </g:if>
                           </div><!-- .column -->
                           </div><!-- .row -->
                       </div><!-- .grid -->

                    </div>
                    <%--
                    <div class="item">
                        <div class="icon">
                            <i class="alarm outline icon"></i>
                            <div class="ui yellow circular label">${change.num_changes}</div>
                        </div>
                        <div class="message">
                            <p>
                                <g:if test="${change.item_with_changes instanceof com.k_int.kbplus.Subscription}">
                                    <g:link controller="subscription" action="changes" id="${change.item_with_changes.id}">${change.item_with_changes.toString()}</g:link>
                                </g:if>
                                <g:else>
                                    <g:link controller="license" action="changes" id="${change.item_with_changes.id}">${change.item_with_changes.toString()}</g:link>
                                </g:else>
                            </p>
                            <p>
                                ${message(code:'myinst.change_from', default:'Changes between')}
                                <g:formatDate date="${change.earliest}" formatName="default.date.format"/>
                                ${message(code:'myinst.change_to', default:'and')}
                                <g:formatDate date="${change.latest}" formatName="default.date.format"/>
                            </p>
                        </div>
                    </div>
                    --%>
                </g:each>
            </div>
        </div>

        %{--<sec:ifAnyGranted roles="ROLE_ADMIN">
        <div class="ui bottom attached tab segment ${US_DASHBOARD_TAB.getValue().value=='Announcements' || US_DASHBOARD_TAB.getValue() == 'Announcements' ? 'active':''}" data-tab="third" style="border-top: 1px solid #d4d4d5; ">
            <g:if test="${editable}">
                <div class="pull-right">
                    <g:link action="announcements" class="ui button">${message(code:'myinst.ann.view.label', default:'View All Announcements')}</g:link>
                </div>
            </g:if>

            <g:message code="profile.dashboardItemsTimeWindow"
                       default="You see events from the last {0} days."
                       args="${user.getSettingsValue(UserSettings.KEYS.DASHBOARD_ITEMS_TIME_WINDOW, 14)}" />

            <br />

            <div class="ui relaxed list" style="clear:both;padding-top:1rem;">
                <g:each in="${recentAnnouncements}" var="ra">
                    <div class="item">

                        <div class="ui internally celled grid">
                            <div class="row">
                                <div class="three wide column">

                                    <strong>${message(code:'myinst.ann.posted_by', default:'Posted by')}</strong>
                                    <g:link controller="user" action="show" id="${ra.user?.id}">${ra.user?.displayName}</g:link>
                                    <br /><br />
                                    <g:formatDate date="${ra.dateCreated}" formatName="default.date.format.noZ"/>

                                </div><!-- .column -->
                                <div class="thirteen wide column">

                                    <div class="header" style="margin:0 0 1em 0">
                                        <g:set var="ann_nws" value="${ra.title?.replaceAll(' ', '')}"/>
                                        ${message(code:"announcement.${ann_nws}", default:"${ra.title}")}
                                    </div>
                                    <div>
                                        <div class="widget-content"><% print ra.content; /* avoid auto encodeAsHTML() */ %></div>
                                    </div>

                                </div><!-- .column -->
                            </div><!-- .row -->
                        </div><!-- .grid -->

                    </div>
                </g:each>
            </div>
            <div>
                <semui:paginate offset="${announcementOffset ? announcementOffset : '0'}" max="${contextService.getUser().getDefaultPageSizeTMP()}" params="${[view:'announcementsView']}" total="${recentAnnouncementsCount}"/>
            </div>
        </div>
        </sec:ifAnyGranted>--}%

        <g:if test="${accessService.checkPerm('ORG_INST,ORG_CONSORTIUM')}">

        <div class="ui bottom attached tab ${US_DASHBOARD_TAB.getValue().value=='Tasks' || US_DASHBOARD_TAB.getValue() == 'Tasks' ? 'active':''}" data-tab="forth">

            <g:if test="${editable}">
                <div class="ui right aligned grid">
                    <div class="right floated right aligned sixteen wide column">
                        <input type="submit" class="ui button" value="${message(code:'task.create.new')}" data-semui="modal" data-href="#modalCreateTask" />
                    </div>
                </div>
            </g:if>

            <div class="ui cards">
                <g:each in="${tasks}" var="tsk">
                    <div class="ui card">

                        <div class="ui label">
                            <div class="right floated author">
                                Status:
                                <span>
                                <semui:xEditableRefData config="Task Status" owner="${tsk}" field="status" />
                                </span>
                            </div>
                        </div>

                        <div class="content">
                            <div class="meta">
                                <div class="">Fällig: <strong><g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${tsk?.endDate}"/></strong></div>
                            </div>
                            <a class="header" onclick="taskedit(${tsk?.id});">${tsk?.title}</a>

                            <div class="description">
                                <g:if test="${tsk.description}">
                                    <span><em>${tsk.description}</em></span> <br />
                                </g:if>
                            </div>
                        </div>
                        <div class="extra content">
                            <g:if test="${tsk.getObjects()}">
                                <g:each in="${tsk.getObjects()}" var="tskObj">
                                    <div class="item">
                                        <span  class="la-popup-tooltip la-delay" data-content="${message(code: 'task.' + tskObj.controller)}" data-position="left center" data-variation="tiny">
                                            <g:if test="${tskObj.controller == 'organisation'}">
                                                <i class="university icon"></i>
                                            </g:if>
                                            <g:if test="${tskObj.controller.contains('subscription')}">
                                                <i class="folder open icon"></i>
                                            </g:if>
                                            <g:if test="${tskObj.controller.contains('package')}">
                                                <i class="gift icon"></i>
                                            </g:if>
                                            <g:if test="${tskObj.controller.contains('license')}">
                                                <i class="book icon"></i>
                                            </g:if>
                                            <g:if test="${tskObj.controller.contains('survey')}">
                                                <i class="chart pie icon"></i>
                                            </g:if>
                                        </span>
                                    <g:if test="${tskObj.controller.contains('survey')}">
                                        <g:link controller="${tskObj.controller}" action="surveyConfigsInfo" params="${[id: tskObj.object?.surveyInfo?.id, surveyConfigID:tskObj.object?.id]}">${tskObj.object}</g:link>
                                    </g:if>
                                        <g:else>
                                            <g:link controller="${tskObj.controller}" action="show" params="${[id:tskObj.object?.id]}">${tskObj.object}</g:link>
                                        </g:else>
                                    </div>
                                </g:each>
                            </g:if>
                            <g:else>
                                <i class="checked calendar icon"></i>
                                ${message(code: 'task.general')}
                            </g:else>
                        </div>
                    </div>
                </g:each>
            </div>
        </div>

        </g:if>

        <g:if test="${accessService.checkPerm('ORG_BASIC_MEMBER')}">
            <g:if test="${grailsApplication.config.featureSurvey}">
            <div class="ui bottom attached tab segment ${US_DASHBOARD_TAB.getValue().value == 'Surveys' || US_DASHBOARD_TAB.getValue()=='Surveys' ? 'active':''}" data-tab="fifth" style="border-top: 1px solid #d4d4d5; ">
                <div class="pull-right">
                    <g:link action="currentSurveys" class="ui button">${message(code:'menu.my.surveys')}</g:link>
                </div>
                    <g:render template="surveys"/>
            </div>
            </g:if>
        </g:if>

    %{--<g:if test="${accessService.checkPerm('ORG_CONSORTIUM')}">

        <div class="ui bottom attached tab segment ${US_DASHBOARD_TAB.getValue().value == 'Surveys' || US_DASHBOARD_TAB.getValue()=='Surveys' ? 'active':''}" data-tab="six" style="border-top: 1px solid #d4d4d5; ">
            <div>
                <g:render template="surveysConsortia"/>
            </div>
        </div>
    </g:if>
--}%
        <g:render template="/templates/tasks/modal_create" />

    <g:javascript>
        function taskedit(id) {

            $.ajax({
                url: '<g:createLink controller="ajax" action="TaskEdit"/>?id='+id,
                success: function(result){
                    $("#dynamicModalContainer").empty();
                    $("#modalEditTask").remove();

                    $("#dynamicModalContainer").html(result);
                    $("#dynamicModalContainer .ui.modal").modal({
                        onVisible: function () {
                            r2d2.initDynamicSemuiStuff('#modalEditTask');
                            r2d2.initDynamicXEditableStuff('#modalEditTask');

                            ajaxPostFunc()
                        }
                    }).modal('show');
                }
            });
        }
    </g:javascript>
        <r:script>
            $(document).ready( function(){
                $('.tabular.menu .item').tab()
                $('.item .widget-content').readmore({
                    speed: 250,
                    collapsedHeight: 21,
                    startOpen: false,
                    moreLink: '<a href="#">[ ${message(code:'default.button.show.label')} ]</a>',
                    lessLink: '<a href="#">[ ${message(code:'default.button.hide.label')} ]</a>'
                });
                $('.xEditableManyToOne').editable({
                }).on('hidden', function() {
                        location.reload();
                 });


            })
        </r:script>

        <style>
            .item .widget-content {
                overflow: hidden;
                line-height: 20px;
            }
        </style>

    </body>
</html>
