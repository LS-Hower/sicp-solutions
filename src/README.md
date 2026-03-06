# 部分文件来源

- `mreval.rkt`: [`https://github.com/racket/slideshow/blob/master/slideshow-doc/scribblings/quick/mreval.rkt`](https://github.com/racket/slideshow/blob/master/slideshow-doc/scribblings/quick/mreval.rkt)
- `manual-style.css`: [`https://github.com/racket/scribble/blob/master/scribble-lib/scribble/manual-style.css`](https://github.com/racket/scribble/blob/master/scribble-lib/scribble/manual-style.css)
- `manual-racket.css`: [`https://github.com/racket/scribble/blob/master/scribble-lib/scribble/manual-racket.css`](https://github.com/racket/scribble/blob/master/scribble-lib/scribble/manual-racket.css)

# 生成

```Bash
scribble --dest ../docs ++style manual-racket.css ++style manual-style.css index.scrbl
scribble --dest ../docs ++style manual-racket.css ++style manual-style.css chapter-1.scrbl
```
