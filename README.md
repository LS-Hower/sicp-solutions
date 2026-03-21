# sicp-solutions

我的 SICP 习题解答（解题集）。

**在线阅读：[`https://ls-hower.github.io/sicp-solutions/`](https://ls-hower.github.io/sicp-solutions/)**

## 依赖

1. [Racket](https://racket-lang.org/) 工具链。其中包含了 Scribble。
2. Racket 包 [`scribble-math`](https://docs.racket-lang.org/scribble-math/index.html) 。

## 生成

源文件位于 `src` 目录，编译出的 HTML 及其他资源位于 `docs` 目录。

可以在项目根目录运行 `make` ：

```bash
make
```

也可以在项目根目录手动运行 `scribble` 命令：

```bash
scribble --dest docs ...
# 将省略号（...）改成要编译的源文件的路径，如 src/index.scrbl。
# 可以一次编译多个。
```

有关 Scribble 更详细的用法，见 Racket 官方文档 [Running `scribble`](https://docs.racket-lang.org/scribble/running.html) 。
