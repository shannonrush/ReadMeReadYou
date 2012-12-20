$(document).ready(function() {
	// on subject click toggle message view and mark message.read true
	$('.subject').click(function() {
		var container = $(this).parents('.message_container');
		container.children('.read_message').toggle();	
		var id = container.find('.id').html();	
		var subject = container.find('.subject');
		subject.removeClass("bolder_link");
		$.ajax({
			type: "POST",
			url: "/messages/"+id+".json",
			data: { _method:'PUT',message:{read:true}},
			dataType: 'json',
			success: function() {
			}
		});

		return false;
	})

	// on reply click close message view, open new message and populate new message fields
	$('.reply').click(function() {
		$(this).parents('.message_container').children('.read_message').hide();
		$('#new_message').show();
		var container = $(this).parents('.message_container');
		var id = container.find('.from a').attr("href").split('/')[2];
		var name = container.find('.from a').text();
		var subject = container.find('.subject a').text();
		var message = container.find('.hidden_message').text();
		$('#to_id').val(id);
		$('#user_name').val(name);
		$('#message_subject').val(subject);
		$('#message_message').val("\n\n"+name+" wrote:\n\n"+message);
		return false;
	})

	// on sent_message_link click toggle sent_messages 
	$('#sent_messages_link').click(function() {
		$('#sent_messages').toggle();
		return false;
	})

	// on new_message_link click toggle new_message
	$('#new_message_link').click(function() {
		$('#new_message').toggle();
		return false;
	})

});
