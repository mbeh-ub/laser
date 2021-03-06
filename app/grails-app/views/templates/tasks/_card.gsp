<laser:serviceInjection />

<%-- OVERWRITE editable for INST_EDITOR: ${editable} -&gt; ${accessService.checkMinUserOrgRole(user, contextOrg, 'INST_EDITOR')} @ ${contextOrg} --%>
<g:set var="overwriteEditable" value="${editable || accessService.checkMinUserOrgRole(user, contextOrg, 'INST_EDITOR')}" />

<semui:card message="task.plural" class="notes la-js-hideable ${css_class}" href="#modalCreateTask" editable="${overwriteEditable}">
    <g:each in="${tasks}" var="tsk">
        <div class="ui grid">
            <div id="summary" class="twelve wide column summary">
                <a onclick="taskedit(${tsk?.id});">${tsk?.title}</a>
                <br />
                <div class="content">
                    ${message(code:'task.endDate.label')}
                    <g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${tsk.endDate}"/>
                </div>
            </div>
            <div class="right aligned four wide column la-column-left-lessPadding">
                <g:link action="tasks" class="ui mini icon negative button"
                        params='[deleteId:tsk?.id, id: params.id, returnToShow: true]'>
                    <i class="trash alternate icon"></i>
                </g:link>
            </div>
        </div>
    </g:each>
</semui:card>

<r:script>
    function taskedit(id) {

        $.ajax({
            url: '<g:createLink controller="ajax" action="TaskEdit"/>?id='+id,
            success: function(result){
                $("#dynamicModalContainer").empty();
                $("#modalEditTask").remove();

                $("#dynamicModalContainer").html(result);
                $("#dynamicModalContainer .ui.modal").modal({
                    onVisible: function() {
                        $(this).find('.datepicker').calendar(r2d2.configs.datepicker);
                        ajaxPostFunc();
                    }
                }).modal('show')
            }
        });
    }
</r:script>
