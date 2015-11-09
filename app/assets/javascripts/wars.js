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
    } else if (at['state'] == 'done') {
	td.addClass('done-attack');
	td.text(at['stars'] + "*");
	if (at['stars'] == 3) {
	    $(".base_" + at['base']).hide();
	}
    } else {
	alert(at);
    }
}

function renderPlan(data) {
    $('.no-attack').removeClass('no-attack');
    $('.sure-attack').removeClass('sure-attack');
    $('.sug-attack').removeClass('sug-attack');
    $.each(data['attacks'],
	   function(index, value) { renderAttack(value); });
    $('.missing-base').removeClass('missing-base');
    $.each(data['missing'],
	   function(index, value) { $(value).addClass('missing-base'); });
    $.each(data['finished'],
	   function(index, value) { $('.index_' + value).hide() });
    
}

function setupPlan() {
    $(document).ready( function() {
	$('.attack').click(function() {
	    var state = 'def';
	    if ($(this).hasClass('no-attack')) {
	    } else if ($(this).hasClass('sure-attack')) {
		state = 'no';
	    } else {
		state = 'sure';
	    }
	    $.post($('#plan').data('post-url'),
		   { base: $(this).data('base'),
		     index: $(this).data('index'),
		     state: state
		   }, renderPlan);
	    return false;
	});
	$.get($('#plan').data('get-url'), renderPlan);
    });
}

function setupStartedWar() {
    $(document).ready( function() {
	$('#submit_result').click(function(e){
	    e.preventDefault();
	    $.post($('#finishedModal form').attr('action'),
		   { index: $('#warrior-id').val(),
		     base: $('#enemy-index').val(),
		     percent: $('#percent').val(),
		     townhall: $('#townhall').prop('checked')
		   });
	    $('#finishedModal').modal('hide');
	    $.get($('#plan').data('get-url'), renderPlan);
	});
				 
	$('.attack').click(function() {
	    $('#warrior-name').text($(this).parent('tr').find('td:first').data('name'));
	    $('#enemy-name').text($(this).data('base'));
	    $('#warrior-id').val($(this).parent('tr').find('td:first').data('wid'));
	    $('#enemy-index').val($(this).data('base'));
	    $('#finishedModal').modal('show');
	});
	$.get($('#plan').data('get-url'), renderPlan);
    });
}
