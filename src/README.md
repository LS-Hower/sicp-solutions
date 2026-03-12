# 部分文件来源

- `interaction.ss` 模仿了 `mreval.rkt`: [`https://github.com/racket/slideshow/blob/master/slideshow-doc/scribblings/quick/mreval.rkt`](https://github.com/racket/slideshow/blob/master/slideshow-doc/scribblings/quick/mreval.rkt)

# 生成

```Bash
scribble --dest ../docs index.scrbl chapter-1.scrbl additional-lisp.scrbl resources.scrbl
```
