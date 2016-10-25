// XXX News

var current_news = 0;
var num_news = 0;
var news_running = false;

function switch_to_next_news() {
	var last_news = current_news;
	if (++current_news > num_news-1) {
		current_news = 0;
	}
	$('#news .entry[data-id='+last_news+']').toggle('slide', {'direction': 'up'}, function() {
		$('#news .entry[data-id='+current_news+']').toggle('slide', {'direction': 'down'}, function() {
			setTimeout(switch_to_next_news, 3000);
		});
	});
}

// XXX Timing

var timing_running = false;

function show_time() {
	var now = new Date(); 
	var hour = now.getHours();
	var minute = now.getMinutes();

	if (hour < 10) 
		hour = '0' + hour;
	if (minute < 10) 
		minute = '0' + minute;

	$('#timing .time').html(hour + ":" + minute);
	setTimeout(show_time, 1000);
}

// XXX General

function load_news() {
	$("#news").load($("#news").data('ajax-url'), function() {
		num_news = $('#news .entry').length;
		current_news = 0;
		if (num_news > 0 && !news_running) {
			setTimeout(switch_to_next_news, 3000);
			news_running = true;
		}
	});
}

function load_timing() {
	$("#timing").load($("#timing").data('ajax-url'), function() {
		if (!timing_running) {
			show_time();
			timing_running = true;
		}
	});
}

function load_weather() {
	$("#weather").load($("#weather").data('ajax-url'));
}

function load_all() {
	load_news();
	load_timing();
	load_weather();
}

function start_cronjob() {
	var minute = (new Date()).getMinutes();
	if (minute % 15 == 0) {
		load_all();
		setTimeout(start_cronjob, 90*1000);
	} else {
		setTimeout(start_cronjob, 30*1000);
	}
}

load_all();
start_cronjob();

$("html").keydown(function(event) {
	if (event.key == ' ') {
		$('#curtain').fadeToggle();
	}
});
