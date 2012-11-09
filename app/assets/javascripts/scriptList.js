
// INIT PAGE

$(document).ready(function() 
{
	// TR CSS
	$('.tabela tr').each(function(numCount) {
		if (numCount%2 == 0)
		{
			$(this).addClass('trListColor');
		}
		$(this).mouseover(function() {
			$(this).addClass('trListOver');
		});
		$(this).mouseout(function() {
			$(this).removeClass('trListOver');
		});
		if ($(this).attr('link'))
		{
			$(this).css('cursor','pointer');
			$(this).click(function() {
				redirect($(this).attr('link'));
			});
		}
	});
	
});
