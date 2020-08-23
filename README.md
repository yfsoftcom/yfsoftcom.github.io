# The blog of the blog.yunplus.io

- install hugo

- clone the theme

  `git clone https://github.com/spf13/hyde.git themes/hyde`

- hugo

  `$ hugo server -D`

  `$ hugo -D`

- run with docker

```sh
# Run build
docker run --rm -it \
  -v $(pwd):/src \
  klakegg/hugo:0.74.3
  
# Run server
docker run --rm -it \
  -v $(pwd):/src \
  -p 1313:1313 \
  klakegg/hugo:0.74.3 \
  server
```

# TODO

- [ ] 部署在 Nginx 里面
- [ ] publish

    `git clone -b public git@github.com:yfsoftcom/blogs-of-blog.yunplus.io.git blog.yunplus.io`