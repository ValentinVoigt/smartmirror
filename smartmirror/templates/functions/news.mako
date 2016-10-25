<%def name="render_news(news)">
	<div class="source">${news.feed.title}</div>
	% for idx, entry in zip(range(10), news.entries):
	<div class="entry" style="${'display:none' if idx!=0 else ''}" data-id="${idx}">${entry.title}</div>
	% endfor
</%def>
