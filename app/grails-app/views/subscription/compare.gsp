<%@ page import ="com.k_int.kbplus.Subscription" %>
<laser:serviceInjection />

<!doctype html>
<html>
	<head>
		<meta name="layout" content="semanticUI">
		<g:set var="entityName" value="${message(code: 'subscription.label')}"/>
		<title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'subscription.compare.label')}</title>
	</head>

    <body>
        <g:render template="breadcrumb" model="${[ params:params ]}"/>

        <g:if test="${institutionName}">
            <h1 class="ui header">${message(code:'menu.my.comp_sub')}</h1>
        </g:if>
        <g:else>
            <h2 class="ui header">${message(code:'subscription.compare.label')}</h2>
        </g:else>

        <semui:messages data="${flash}" />

				<g:form action="compare" controller="subscription" method="GET" class="ui form">
					<g:set var="subs_message" value="${message(code:'subscription.plural', default:'Subscriptions')}" />
					<g:set var="sub_message" value="${message(code:'subscription.label', default:'Subscription')}" />

					<table class="ui celled la-table table">
						<thead>
							<tr>
								<th></th>
								<th> ${message(code:'subscription.label', default:'Subscription')} A </th>
								<th> ${message(code:'subscription.label', default:'Subscription')} B </th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td> ${message(code:'subscription.compare.name', default:'Subscription name')} </td>
								<td>${message(code:'default.compare.restrict.after', args:[subs_message] )}
									<semui:simpleHiddenValue id="startA" name="startA" type="date" value="${params.startA}"/>
									${message(code:'default.compare.restrict.before', default:'and/or ending before-')}
									<semui:simpleHiddenValue id="endA" name="endA" type="date" value="${params.endA}"/><br/>
									<div class="ui search selection dropdown">
										<input type="hidden" name="subA" id="subSelectA" value="${subA}">
										<i class="dropdown icon"></i>
										<div class="default text">${message(code:'default.compare.select.first', args:[sub_message] )}</div>
										<div class="menu"></div>
									</div>
								</td>
								<td>
									${message(code:'default.compare.restrict.after', args:[subs_message] )}
									<semui:simpleHiddenValue id="startB" name="startB" type="date" value="${params.startB}"/>
									${message(code:'default.compare.restrict.before', default:'and/or ending before-')}
									<semui:simpleHiddenValue id="endB" name="endB" type="date" value="${params.endB}"/><br/>
									<div class="ui search selection dropdown">
										<input type="hidden" name="subB" id="subSelectB" value="${subB}">
										<i class="dropdown icon"></i>
										<div class="default text">${message(code:'default.compare.select.second', args:[sub_message] )}</div>
										<div class="menu"></div>
									</div>
								</td>
							</tr>
							<tr>
								<td> ${message(code:'subscription.compare.snapshot', default:'Subscriptions on Date')}</td>
								<td>
									<semui:datepicker id="dateA" name="dateA" placeholder ="default.date.label" value="${dateA ? dateA : ''}" >
									</semui:datepicker>
								</td>
								<td>
									<semui:datepicker id="dateB" name="dateB" placeholder ="default.date.label" value="${dateB ? dateB : ''}" >
									</semui:datepicker>
								</td>
							</tr>
								<tr>
									<td> ${message(code:'default.compare.filter.add', default:'Add Filter')}</td>
									<td colspan="2">

										<div class="ui checkbox">
											<g:checkBox name="insrt" id="insrt" checked="${insrt ? insrt:true}"/>
											<label for="insrt">${message(code:'default.compare.filter.insert')}</label>
										</div>
										<div class="ui checkbox">
											<g:checkBox name="dlt" id="dlt" checked="${dlt ? dlt:true}"/>
											<label for="dlt">${message(code:'default.compare.filter.delete')}</label>
										</div>
										<div class="ui checkbox">
											<g:checkBox name="updt" id="updt" checked="${updt ? updt:true}"/>
											<label for="updt">${message(code:'default.compare.filter.update')}</label>
										</div>
										<div class="ui checkbox">
											<g:checkBox name="nochng" id="nochng" checked="${nochng ? nochng:false}"/>
											<label for="nochng">${message(code:'default.compare.filter.no_change')}</label>
										</div>

									</td>
								</tr>
						</tbody>
					</table>
					<div class="fields">
                  		<div class="field">
                  			<a href="${request.forwardURI}" class="ui button">${message(code:'default.button.comparereset.label')}</a>
                    	</div>
						<div class="field">
							<input type="submit" class="ui button" value="${message(code:'default.button.compare.label')}" />
						</div>
					</div>
				</g:form>


			<g:if test="${subInsts?.get(0) && subInsts?.get(1)}">
                                <g:set var="subs_message" value="${message(code:'subscription.plural')}" />
				<div class="row">
				<h3 class="ui header">${message(code:'default.compare.overview', args:[subs_message])}</h3>
				<table class="ui celled la-table table">
					<thead>
						<tr>
							<th>${message(code:'default.compare.overview.value', default:'Value')}</th>
							<th>${subInsts.get(0).name}</th>
							<th>${subInsts.get(1).name}</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>${message(code:'default.dateCreated.label', default:'Date Created')}</td>
							<td><g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${subInsts.get(0).dateCreated}"/></td>
							<td><g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${subInsts.get(1).dateCreated}"/></td>
						</tr>
						<tr>
							<td>${message(code:'default.startDate.label', default:'Start Date')}</td>
							<td><g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${subInsts.get(0).startDate}"/></td>
							<td><g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${subInsts.get(1).startDate}"/></td>
						</tr>
						<tr>
							<td>${message(code:'default.endDate.label', default:'End Date')}</td>
							<td><g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${subInsts.get(0).endDate}"/></td>
							<td><g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${subInsts.get(1).endDate}"/></td>
						</tr>
						<tr>
							<td>${message(code:'subscription.compare.overview.ies', default:'Number of IEs')}</td>
							<td>${params.countA}</td>
							<td>${params.countB}</td>
						</tr>
					</tbody>
				</table>
				</div>
				<div class="row">
				<g:form action="compare" method="GET" class="ui form">
					<input type="hidden" name="subA" value="${params.subA}"/>
					<input type="hidden" name="subB" value="${params.subB}"/>
					<input type="hidden" name="dateA" value="${params.dateA}"/>
					<input type="hidden" name="dateB" value="${params.dateB}"/>
					<input type="hidden" name="insrt" value="${params.insrt}"/>
					<input type="hidden" name="dlt" value="${params.dlt}"/>
					<input type="hidden" name="updt" value="${params.updt}"/>
					<input type="hidden" name="nochng" value="${params.nochng}"/>
					<input type="hidden" name="countA" value="${params.countA}"/>
					<input type="hidden" name="countB" value="${params.countB}"/>
					 <table class="ui celled la-table table">
						<tr>
							<td>
								${message(code:'subscription.compare.filter.title', default:'Filters - Title')}: <input name="filter" value="${params.filter}">
							</td>
							<td> <input type="submit" class="ui button" value="Filter Results" /> </td>
							<td> <input id="resetFilters" type="submit" class="ui button" value="${message(code:'default.button.clear.label', default:'Clear')}" /> </td>
						</tr>
					</table>
				</g:form>

				<div>
					<dt class="center">${message(code:'subscription.compare.results.pagination', args: [offset+1,offset+comparisonMap.size(),unionListSize])}</dt>
				</div>
				<table class="ui celled la-table table">
					<thead>
						<tr>
							<th> ${message(code:'title.label', default:'Title')} </th>
							<th> ${subInsts.get(0).name} ${message(code:'default.on', default:'on')} ${subDates.get(0)}</th>
							<th> ${subInsts.get(1).name} ${message(code:'default.on', default:'on')} ${subDates.get(1)}</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><strong>${message(code:'subscription.compare.results.ies.total', default:'Total IEs for query')}</strong></td>
							<td><strong>${listACount}</strong></td>
							<td><strong>${listBCount}</strong></td>
						<tr>
						<g:each in="${comparisonMap}" var="entry">
							<g:set var="subAIE" value="${entry.value[0]}"/>
							<g:set var="subBIE" value="${entry.value[1]}"/>
							<g:set var="currentTitle" value="${subAIE?.tipp?.title ?:subBIE?.tipp?.title}"/>
							<g:set var="highlight" value="${entry.value[2]}"/>
							<tr>
								
								<td><semui:listIcon type="${currentTitle?.type?.value}"/>
								<strong><g:link action="show" controller="title" id="${currentTitle.id}">${entry.key}</g:link></strong>
								<i onclick="showMore('${currentTitle.id}')" class="icon-info-sign"></i>

								<g:each in="${currentTitle?.ids?.sort{it?.identifier?.ns?.ns}}" var="id">
				                    <br>${id.identifier.ns.ns}: ${id.identifier.value}
				                </g:each>
								</td>
							
								<g:if test="${subAIE}">		
									<td class="${highlight }"><g:render template="compare_cell" model="[obj:subAIE]"/></td>
								</g:if>
								<g:else><td></td></g:else>
								
								<g:if test="${subBIE}">			
									<td class="${highlight }"><g:render template="compare_cell" model="[obj:subBIE]"/></td>
								</g:if>
								<g:else><td></td></g:else>
							</tr>							
						</g:each>						
					</tbody>
				</table>

		        <semui:paginate  action="compare" controller="subscription" params="${params}" next="Next" prev="Prev" maxsteps="${max}" total="${unionListSize}" />

				</div>
			</g:if>

		%{-- Hiding the tables from compare_details inside the main table, breaks the modal hide.
 --}%

 <g:each in="${comparisonMap}" var="entry">
		<g:set var="subAIE" value="${entry.value[0]}"/>
		<g:set var="subBIE" value="${entry.value[1]}"/>
		<g:set var="currentTitle" value="${subAIE?.tipp?.title ?:subBIE?.tipp?.title}"/>

		<g:render template="compare_details"
		 model="[subA:subAIE,subB:subBIE,currentTitle:currentTitle, subAName:subInsts.get(0).name, subBName:subInsts.get(1).name]"/>
</g:each>

		<r:script>
			$("div.dropdown").dropdown({
				apiSettings: {
				    url: '<g:link controller="ajax" action="lookupSubscriptions"/>?query={query}',
				    cache: false
				},
				clearable: true
			});
		</r:script>
	</body>
</html>
