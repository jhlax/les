black:
	black .

push:
	git add .
	git commit
	git push

lock:
	pipenv lock --pre

