
<%@ page import="com.k_int.kbplus.Cluster" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="semanticUI">
		<g:set var="entityName" value="${message(code: 'cluster.label', default: 'Cluster')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div>
				

					<h1 class="ui left aligned icon header"><semui:headerIcon /><g:message code="default.list.label" args="[entityName]" /></h1>


			<semui:messages data="${flash}" />
				
				<table class="ui sortable celled la-table table">
					<thead>
						<tr>
						
							<g:sortableColumn property="definition" title="${message(code: 'cluster.definition.label', default: 'Definition')}" />
						
							<g:sortableColumn property="name" title="${message(code: 'cluster.name.label', default: 'Name')}" />
						
							<th class="header">${com.k_int.kbplus.RefdataCategory.findByDesc('Cluster Type').getI10n('desc')}</th>
						
							<th></th>
						</tr>
					</thead>
					<tbody>
					<g:each in="${clusterInstanceList}" var="clusterInstance">
						<tr>
						
							<td>${fieldValue(bean: clusterInstance, field: "definition")}</td>
						
							<td>${fieldValue(bean: clusterInstance, field: "name")}</td>
						
							<td>${fieldValue(bean: clusterInstance, field: "type")}</td>
						
							<td class="link">
								<g:link action="show" id="${clusterInstance.id}" class="ui tiny button">${message('code':'default.button.show.label')}</g:link>
								<g:link action="edit" id="${clusterInstance.id}" class="ui tiny button">${message('code':'default.button.edit.label')}</g:link>
							</td>
						</tr>
					</g:each>
					</tbody>
				</table>

					<semui:paginate total="${clusterInstanceTotal}" />


		</div>
	</body>
</html>
