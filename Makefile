app:
	./node_modules/.bin/coffee --compile --output app/public/js/ app/assets/js/
	./node_modules/.bin/lessc -x app/assets/css/style.less > app/public/css/style.css
	handlebars -m app/assets/js/templates/poetry.handlebars -f app/public/js/templates/poetry.tmpl.min.js
	handlebars -m app/assets/js/templates/index.handlebars -f app/public/js/templates/index.tmpl.min.js
	handlebars -m app/assets/js/templates/authorize.handlebars -f app/public/js/templates/authorize.tmpl.min.js


.PHONY: app
