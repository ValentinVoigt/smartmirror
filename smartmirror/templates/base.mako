<!doctype html>
<html lang="de">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Smartmirror</title>
		<link rel="stylesheet" href="${request.static_path('smartmirror:static/css/main.css')}">
	</head>
	<body>
		${self.body()}

		<script type="text/javascript" src="${request.static_path('smartmirror:static/js/jquery-3.1.1.min.js')}"></script>
		<script type="text/javascript" src="${request.static_path('smartmirror:static/js/jquery-ui.min.js')}"></script>
		<script type="text/javascript" src="${request.static_path('smartmirror:static/js/main.js')}"></script>
	</body>
</html>
