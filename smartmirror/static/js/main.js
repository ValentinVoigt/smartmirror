// XXX News

var current_news = 0;
var current_newsfeed = 0;
var num_newsfeeds = 0;
var news_running = false;

function switch_to_next_news() {
	var last_news = current_news;
	var last_newsfeed = current_newsfeed;
	var num_news = $('#news .entry[data-feed-id='+current_newsfeed+']').length;

	if (++current_news > num_news-1) {
		current_news = 0;
		if (++current_newsfeed > num_newsfeeds-1) {
			current_newsfeed = 0;
		}
	}

	if (last_newsfeed != current_newsfeed) {
		$('#news .source[data-id='+last_newsfeed+']').toggle('slide', {'direction': 'up'},  function() {
			$('#news .source[data-id='+current_newsfeed+']').toggle('slide', {'direction': 'down'});
		});
	}

	if (last_news != current_news || last_newsfeed != current_newsfeed) {
		$('#news .entry[data-id='+last_news+'][data-feed-id='+last_newsfeed+']').toggle('slide', {'direction': 'up'}, function() {
			$('#news .entry[data-id='+current_news+'][data-feed-id='+current_newsfeed+']').toggle('slide', {'direction': 'down'}, function() {
				setTimeout(switch_to_next_news, 3000);
			});
		});
	} else {
		news_running = false;
	}
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
		num_newsfeeds = $('#news .source').length;
		current_news = 0;
		current_newsfeed = 0;
		if (num_newsfeeds > 0 && !news_running) {
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
