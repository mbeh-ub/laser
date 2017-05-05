<%@ page
import="com.k_int.kbplus.Org"  
import="com.k_int.kbplus.Person" 
import="com.k_int.kbplus.PersonRole"
import="com.k_int.kbplus.RefdataValue" 
import="com.k_int.kbplus.RefdataCategory" 
%>

<!doctype html>
<r:require module="annotations" />

<html>
  <head>
    <meta name="layout" content="mmbootstrap"/>
    <title>KB+ ${institution.name} - Addressbook</title>
  </head>
  <body>

    <div class="container">
      <ul class="breadcrumb">
        <li>
        	<g:link controller="home" action="index">Home</g:link>
        	<span class="divider">/</span>
        </li>
        <li>
        	<g:link controller="myInstitutions" action="dashboard" params="${[shortcode:params.shortcode]}">${institution.name}</g:link>
        	<span class="divider">/</span>
        </li>
		<li>
			<g:link controller="myInstitutions" action="addressbook" params="${[shortcode:params.shortcode]}">Addressbook</g:link>
		</li>
      </ul>
    </div>

   <g:if test="${flash.message}">
      <div class="container">
        <bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
      </div>
    </g:if>

    <g:if test="${flash.error}">
      <div class="container">
        <bootstrap:alert class="error-info">${flash.error}</bootstrap:alert>
      </div>
    </g:if>

    <div class="container">

      <h1>${institution?.name} - Addressbook</h1>

    </div>

    <div class="container">
		
		<div> 
			<g:link controller="person" action="create" params="['owner.id': institution?.id, 'isPublic': RefdataValue.findByOwnerAndValue(RefdataCategory.findByDesc('YN'), 'No').id ]">
				${message(code: 'default.add.label', args: [message(code: 'person.label', default: 'Person')])}
			</g:link>	
		</div>
		
		<p>These persons are visible to you due your membership ..</p>
		
        <dl>
			<g:if test="${visiblePersons}">
				<dt><g:message code="org.prsLinks.label" default="Persons" /></dt>
				<g:each in="${visiblePersons}" var="p">
					<dd><g:link controller="person" action="show" id="${p?.id}">${p?.encodeAsHTML()}</g:link></dd>
					<dl>
						<g:each in="${p?.contacts}" var="c">
							<dd>
								- <g:link controller="contact" action="show" id="${c?.id}">${c?.encodeAsHTML()}</g:link>
							</dd>
						</g:each>
						<g:each in="${p?.addresses}" var="a">
							<dd>
								- <g:link controller="address" action="show" id="${a?.id}">${a?.encodeAsHTML()}</g:link>
							</dd>
						</g:each>
					</dl>
				</g:each>
			</g:if>
				
		</dl>
		

      </div>

  </body>
</html>