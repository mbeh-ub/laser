
<%@ page import="com.k_int.kbplus.Contact" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="mmbootstrap">
		<g:set var="entityName" value="${message(code: 'contact.label', default: 'Contact')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			
			<div class="span3">
				<div class="well">
					<ul class="nav nav-list">
						<li class="nav-header">${entityName}</li>
						<li class="active">
							<g:link class="list" action="list">
								<i class="icon-list icon-white"></i>
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
				
				<div class="page-header">
					<h1><g:message code="default.list.label" args="[entityName]" /></h1>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				
				<table class="table table-striped">
					<thead>
						<tr>
						
							<g:sortableColumn property="mail" title="${message(code: 'contact.mail.label', default: 'Mail')}" />
						
							<g:sortableColumn property="phone" title="${message(code: 'contact.phone.label', default: 'Phone')}" />
						
							<th class="header"><g:message code="contact.type.label" default="Type" /></th>
						
							<th class="header"><g:message code="contact.prs.label" default="Prs" /></th>
						
							<th class="header"><g:message code="contact.org.label" default="Org" /></th>
						
							<th></th>
						</tr>
					</thead>
					<tbody>
					<g:each in="${contactInstanceList}" var="contactInstance">
						<tr>
						
							<td>${fieldValue(bean: contactInstance, field: "mail")}</td>
						
							<td>${fieldValue(bean: contactInstance, field: "phone")}</td>
						
							<td>${fieldValue(bean: contactInstance, field: "type")}</td>
						
							<td>${fieldValue(bean: contactInstance, field: "prs")}</td>
						
							<td>${fieldValue(bean: contactInstance, field: "org")}</td>
						
							<td class="link">
								<g:link action="show" id="${contactInstance.id}" class="btn btn-small">Show &raquo;</g:link>
							</td>
						</tr>
					</g:each>
					</tbody>
				</table>
				<div class="pagination">
					<bootstrap:paginate total="${contactInstanceTotal}" />
				</div>
			</div>

		</div>
	</body>
</html>