
<div class="modal hide" id="compare_details${currentTitle.id}">
	<div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">×</button>
        <h3 class="ui header">${message(code:'subscription.details.details.further.label', default:'Further details')}</h3>
    </div>

    <div class="modal-body">
    	<table class="ui celled la-table table">
	    	<thead>
	    		<tr>
	    			<th>${message(code:'default.attribute.label', default:'Attribute')}</th>
	    			<th> ${subAName} </th>
	    			<th> ${subBName} </th>
	    		</tr>
	    	</thead>
	    	<tbody>
	    		<tr>
	    			<td><strong>${message(code:'tipp.coverageDepth', default:'Coverage Depth')}</strong></td>
	    			<td>${subA?.coverageDepth} </td>
	    			<td>${subB?.coverageDepth} </td>
	    		</tr>
	    		<tr>
	    			<td><strong>${message(code:'tipp.embargo', default:'Embargo')}</strong></td>
	    			<td>${subA?.embargo}</td>
	    			<td>${subB?.embargo}</td>
	    		</tr>
	    	</tbody>  		
    	</table>
	</div>
</div>
