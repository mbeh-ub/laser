<%@ page import="com.k_int.kbplus.Identifier" %>
<!doctype html>
<r:require module="scaffolding" />
<html>
	<head>
		<meta name="layout" content="semanticUI">
		<g:set var="entityName" value="${message(code: 'identifier.label', default: 'Identifier')}" />
		<title><g:message code="default.edit.label" args="[entityName]" /></title>
	</head>
	<body>
		<div>

			<div class="span3">
				<div class="well">
					<ul class="nav nav-list">
						<li class="nav-header">${entityName}</li>
						<li>
							<g:link class="list" action="list">
								<i class="icon-list"></i>
								<g:message code="default.list.label" args="[entityName]" />
							</g:link>
						</li>
						<li>
							<g:link class="create" action="create">
								<i class="icon-plus"></i>
								<g:message code="default.create.label" args="[entityName]" />
							</g:link>
						</li>
					</ul>
				</div>
			</div>
			
			<div class="span9">

					<h1 class="ui left aligned icon header"><semui:headerIcon /><g:message code="default.edit.label" args="[entityName]" /></h1>

				<semui:messages data="${flash}" />

				<semui:errors bean="${identifierInstance}" />

				<fieldset>
					<g:form class="ui form" action="edit" id="${identifierInstance?.id}" >
						<g:hiddenField name="version" value="${identifierInstance?.version}" />
						<fieldset>
							<f:all bean="identifierInstance"/>
							<div class="ui form-actions">
								<button type="submit" class="ui button">
									<i class="checkmark icon"></i>
									<g:message code="default.button.update.label" default="Update" />
								</button>
								<button type="submit" class="ui negative button" name="_action_delete" formnovalidate>
									<i class="trash alternate icon"></i>
									<g:message code="default.button.delete.label" default="Delete" />
								</button>
							</div>
						</fieldset>
					</g:form>
				</fieldset>

			</div>

		</div>
	</body>
</html>
