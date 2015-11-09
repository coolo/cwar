function setupWarriors() {
    $('#warriors').multiSelect(
	{ keepOrder: true ,
	  afterSelect: function(value){
	      $('#warriors option[value="'+value+'"]').remove();
	      $('#warriors').append($('<option></option>').attr('value',value).attr('selected', 'selected'));
	  }
	}
    );
}

function renderAttack(at) {
    var td = $("#T_" + at['index'] + "_" + at['base']);
    if (at['state'] == 'sug') {
	td.addClass('sug-attack');
    } else if (at['state'] == 'no') {
	td.addClass('no-attack');
    } else if (at['state'] == 'sure') {
	td.addClass('sure-attack');
    } else {
	alert(at);
    }
}

function renderPlan(data) {
    console.log("renderPlan");
    $('.no-attack').removeClass('no-attack');
    $('.sure-attack').removeClass('sure-attack');
    $('.sug-attack').removeClass('sug-attack');
    $.each(data['attacks'],
	   function(index, value) { renderAttack(value); });
}

function setupPlan() {
    $(document).ready( function() {
	$('.attack').click(function() {
	    var state = 'def';
	    if ($(this).hasClass('no-attack')) {
		//$(this).removeClass('sure-attack').removeClass('no-attack');
	    } else if ($(this).hasClass('sure-attack')) {
		//$(this).addClass('no-attack').removeClass('sure-attack');
		state = 'no';
	    } else {
		//$(this).addClass('sure-attack').removeClass('no-attack');
		state = 'sure';
	    }
	    $.post($('#plan').data('post-url'),
		   { base: $(this).data('base'),
		     index: $(this).data('index'),
		     state: state
		   }, renderPlan);
	    return false;
	});
    });
    $.get($('#plan').data('get-url'), renderPlan);
}
