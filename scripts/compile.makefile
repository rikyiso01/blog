out/%/index.html: posts/%/post.md
	mkdir -p "$$(dirname $@)"
	pandoc $< -o $@

out/%.svg: posts/%.mmd
	mkdir -p "$$(dirname $@)"
	mmdc -i $< -o $@

