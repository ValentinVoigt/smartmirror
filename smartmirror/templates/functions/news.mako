<%def name="render_news(news)">
	<% enumerator = list(enumerate(news)) %>

	% for newsfeed_id, newsfeed in enumerator:
		<div 
		 	class="source"
		 	style="${'display:none' if newsfeed_id != 0 else ''}"
			data-id="${newsfeed_id}">
			${newsfeed.feed.title}
		</div>
	% endfor

	% for newsfeed_id, newsfeed in enumerator:
		% for idx, entry in zip(range(10), newsfeed.entries):
			<div
			 	class="entry"
			 	style="${'display:none' if idx != 0 or newsfeed_id != 0 else ''}"
			 	data-feed-id="${newsfeed_id}"
				data-id="${idx}">
				${entry.title}
			</div>
		% endfor
	% endfor
</%def>
