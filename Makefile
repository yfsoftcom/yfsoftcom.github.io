all: get-theme local

get-theme:
	git clone https://github.com/spf13/hyde.git themes/hyde

local:
	docker run --rm -it \
		-p 1313:1313 \
  	-v $(shell pwd):/src \
  	klakegg/hugo:0.74.3 server -D