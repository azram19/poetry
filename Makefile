app:
	./node_modules/.bin/coffee --compile --output public/js/ assets/js/
	./node_modules/.bin/lessc -x assets/css/style.less > public/css/style.css
