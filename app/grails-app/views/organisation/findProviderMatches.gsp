<%@ page import="com.k_int.kbplus.Org" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="semanticUI">
		<g:set var="entityName" value="${message(code: 'default.provider.label', default: 'Provider')}" />
		<title>${message(code:'laser', default:'LAS:eR')} : <g:message code="default.create.label" args="[entityName]" /></title>
	</head>
	<body>
	<semui:breadcrumbs>
		<semui:crumb message="menu.public.all_provider" controller="organisation" action="listProvider"  />
		<semui:crumb text="${message(code:"default.create.label",args:[entityName])}" class="active"/>
	</semui:breadcrumbs>

		<h1 class="ui left aligned icon header"><semui:headerIcon /><g:message code="default.create.label" args="[entityName]" /></h1>

		<semui:messages data="${flash}" />

		<semui:errors bean="${orgInstance}" />

		<p>${message(code:'org.findProviderMatches.note')}</p>

		<semui:searchSegment controller="organisation" action="findProviderMatches" method="get">
			<div class="field">
				<label for="proposedProvider">${message(code:'org.findProviderMatches.proposed')}</label>
				<input type="text" id="proposedProvider" name="proposedProvider" value="${params.proposedProvider}" />
			</div>
			<div class="field la-field-right-aligned">
				<a href="${request.forwardURI}" class="ui reset primary button">${message(code:'default.button.searchreset.label')}</a>
				<input type="submit" value="${message(code:'default.button.search.label', default:'Filter')}" class="ui secondary button">
			</div>
		</semui:searchSegment>



				<g:if test="${providerMatches != null}">
					<g:if test="${providerMatches.size()>0}">
						<table class="ui celled la-table table">
							<thead>
							<tr>
								<th>${message(code:'org.name.label', default:'Name')}</th>
								<th>${message(code:'indentifier.plural', default:'Identifiers')}</th>
								<th>${message(code:'org.shortname.label', default:'Shortname')}</th>
								<th>${message(code:'org.country.label', default:'Country')}</th>
							</tr>
							</thead>
							<tbody>
							<g:each in="${providerMatches}" var="providerInstance">
								<tr>
									<td>${providerInstance.name} <g:link controller="organisation" action="show" id="${providerInstance.id}">(${message(code:'default.button.edit.label', default:'Edit')})</g:link></td>
									<td><ul>
											<li><g:message code="org.globalUID.label" default="Global UID" />: <g:fieldValue bean="${providerInstance}" field="globalUID"/></li>
											<g:if test="${providerInstance.impId}">
												<li><g:message code="org.impId.label" default="Import ID" />: <g:fieldValue bean="${providerInstance}" field="impId"/></li>
											</g:if>
											<g:each in="${providerInstance.ids?.sort{it?.identifier?.ns?.ns}}" var="id"><li>${id.identifier.ns.ns}: ${id.identifier.value}</li></g:each>
									</ul></td>
									<td>${providerInstance.shortname}</td>
									<td>${providerInstance.country}</td>
								</tr>
							</g:each>
							</tbody>
						</table>
						<bootstrap:alert class="alert-info">
							${message(code:'org.findProviderMatches.match', args:[params.proposedProvider])}
						</bootstrap:alert>
						<g:link controller="organisation" action="createProvider" class="ui negative button" params="${[provider:params.proposedProvider]}">${message(code:'org.findProviderMatches.matches.create', default:'Create New Provider with the Name', args: [params.proposedProvider])}</g:link>
					</g:if>
					<g:else>
						<bootstrap:alert class="alert-info">${message(code:'org.findProviderMatches.no_match', args:[params.proposedProvider])}</bootstrap:alert>
						<g:link controller="organisation" action="createProvider" class="ui positive button" params="${[provider:params.proposedProvider]}">${message(code:'org.findProviderMatches.no_matches.create', default:'Create New Provider with the Name', args: [params.proposedProvider])}</g:link>
					</g:else>
				</g:if>


	</body>
</html>
