<%@ page import="com.k_int.kbplus.Task" %>
<laser:serviceInjection />

<semui:modal id="modalEditTask" message="task.edit" isEditModal="true" >

    <g:form class="ui form" id="edit_task" url="[controller:'task',action:'edit',id:taskInstance?.id]" method="post">
        <g:hiddenField name="version" value="${taskInstance?.version}" />

        <div class="field fieldcontain ${hasErrors(bean: taskInstance, field: 'title', 'error')} required">
            <label for="title">
                <g:message code="task.title.label" default="Title" />
            </label>
            <g:textField name="title" required="" value="${taskInstance?.title}"/>
        </div>

        <div class="field fieldcontain ${hasErrors(bean: taskInstance, field: 'description', 'error')}">
            <label for="description">
                <g:message code="task.description.label" default="Description" />
            </label>
            <g:textArea name="description" value="${taskInstance?.description}" rows="5" cols="40"/>
        </div>

        <div class="field fieldcontain ${hasErrors(bean: taskInstance, field: 'description', 'error')}">
            <strong>Betrifft:</strong>
            <g:if test="${taskInstance.getObjects()}">
                <g:each in="${taskInstance.getObjects()}" var="tskObj">
                    <br />
                    - ${message(code: 'task.' + tskObj.controller)}:
                    <g:link controller="${tskObj.controller}" action="show" params="${[id:tskObj.object?.id]}">${tskObj.object}</g:link>
                </g:each>
            </g:if>
            <g:else>
                <br />
                - ${message(code: 'task.general')}
            </g:else>
        </div>
        %{--<g:if test="${params.owntp == 'license' || enableMyInstFormFields}">
            <div class="field fieldcontain ${hasErrors(bean: taskInstance, field: 'license', 'error')} ">
                <label for="license">
                    <g:message code="task.license.label" default="License" />
                </label>
                <g:select id="license" name="license.id" from="${validLicenses}" optionKey="id" value="${taskInstance?.license.id}" class="many-to-one" noSelection="['null': '']"/>
            </div>
        </g:if>

        <g:if test="${params.owntp == 'organisation'}">
            <div class="field fieldcontain ${hasErrors(bean: taskInstance, field: 'org', 'error')} ">
                <label for="org">
                    <g:message code="task.org.label" default="Org" />
                </label>
                <g:select id="org" name="org.id" from="${validOrgs}" optionKey="id" value="${taskInstance?.org.id}" class="many-to-one" noSelection="['null': '']"/>
            </div>
        </g:if>

        <g:if test="${params.owntp == 'package' || enableMyInstFormFields}">
            <div class="field fieldcontain ${hasErrors(bean: taskInstance, field: 'pkg', 'error')} ">
                <label for="pkg">
                    <g:message code="task.pkg.label" default="Pkg" />
                </label>
                <g:select id="pkg" name="pkg.id" from="${validPackages}" optionKey="id" value="${taskInstance?.pkg.id}" class="many-to-one" noSelection="['null': '']"/>
            </div>
        </g:if>

        <g:if test="${params.owntp == 'subscription' || enableMyInstFormFields}">
            <div class="field fieldcontain ${hasErrors(bean: taskInstance, field: 'subscription', 'error')} ">
                <label for="subscription">
                    <g:message code="task.subscription.label" default="Subscription" />
                </label>
                <g:select id="subscription" name="subscription.id" from="${validSubscriptions}" optionKey="id" value="${taskInstance?.subscription.id}" class="many-to-one" noSelection="['null': '']"/>
            </div>
        </g:if>--}%

        <div class="field">
            <div class="two fields">

                <div class="field wide eight fieldcontain ${hasErrors(bean: taskInstance, field: 'status', 'error')} required">
                    <label for="status">
                        <g:message code="task.status.label" default="Status" />
                    </label>
                    <laser:select id="status" name="status.id" from="${com.k_int.kbplus.RefdataCategory.getAllRefdataValues('Task Status')}" optionValue="value" optionKey="id" required="" value="${taskInstance?.status?.id ?: com.k_int.kbplus.RefdataValue.findByValueAndOwner("Open", com.k_int.kbplus.RefdataCategory.findByDesc('Task Status')).id}" class="ui dropdown many-to-one"/>
                </div>

                <semui:datepicker class="wide eight" label="task.endDate.label" id="endDate" name="endDate" placeholder="default.date.label" value="${formatDate(format:message(code:'default.date.format.notime', default:'yyyy-MM-dd'), date:taskInstance?.endDate)}" required bean="${taskInstance}" />

            </div>
        </div>

        <div class="field">
            <div class="two fields">
                <div class="field wide eight fieldcontain ${hasErrors(bean: taskInstance, field: 'responsible', 'error')}">
                    <label for="responsible">
                        <g:message code="task.responsible.label" default="Responsible" />
                    </label>
                    <g:if test="${taskInstance?.responsibleOrg?.id}"><g:set var="checked" value="checked" /></g:if><g:else> <g:set var="checked" value="" /></g:else>

                    <div class="field">
                        <div class="ui radio checkbox">
                            <input id="radioresponsibleOrgEdit" type="radio" value="Org" name="responsible" tabindex="0" class="hidden" ${checked}>
                            <label for="radioresponsibleOrgEdit">${message(code: 'task.responsibleOrg.label')} <strong>${contextService?.org?.getDesignation()}</strong></label>
                        </div>
                    </div>
                    <g:if test="${taskInstance?.responsibleUser?.id}"><g:set var="checked" value="checked" /></g:if><g:else> <g:set var="checked" value="" /></g:else>
                    <div class="field">
                        <div class="ui radio checkbox">
                            <input id="radioresponsibleUserEdit" type="radio" value="User" name="responsible" tabindex="0" class="hidden" ${checked}>
                            <label for="radioresponsibleUserEdit">${message(code: 'task.responsibleUser.label')}</label>
                        </div>
                    </div>
                </div>
                <div id="responsibleUserEdit" class="field wide eight fieldcontain ${hasErrors(bean: taskInstance, field: 'responsibleUser', 'error')}">
                    <label for="responsibleUser">
                        <g:message code="task.responsibleUser.label" default="Responsible User" />
                    </label>
                    <g:select id="responsibleUser" name="responsibleUser.id" from="${validResponsibleUsers}" optionKey="id" optionValue="display" value="${taskInstance?.responsibleUser?.id}" class="ui dropdown many-to-one" noSelection="['null': '']"/>
                </div>
            </div>
        </div>

    </g:form>


    <script>
        var ajaxPostFunc = function () {

            $("#radioresponsibleOrgEdit").change(function () {
                $("#responsibleUserEdit").hide();
            });

            $("#radioresponsibleUserEdit").change(function () {
                $("#responsibleUserEdit").show();
            });

            if ($("#radioresponsibleUserEdit").is(':checked')) {
                $("#responsibleUserEdit").show();
            } else {
                $("#responsibleUserEdit").hide();
            }

            $('#edit_task')
                .form({
                    on: 'blur',
                    inline: true,
                    fields: {
                        title: {
                            identifier: 'title',
                            rules: [
                                {
                                    type: 'empty',
                                    prompt: '{name} <g:message code="validation.needsToBeFilledOut" default=" muss ausgefüllt werden" />'
                                }
                            ]
                        },

                        endDate: {
                            identifier: 'endDate',
                            rules: [
                                {
                                    type: 'empty',
                                    prompt: '{name} <g:message code="validation.needsToBeFilledOut" default=" muss ausgefüllt werden" />'
                                }
                            ]
                        }
                    }
                });
        }
    </script>
</semui:modal>

