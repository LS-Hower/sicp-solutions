# sicp-solutions

我的 SICP 习题解答（解题集）。

**在线阅读：[`https://ls-hower.cc/sicp-solutions/`](https://ls-hower.cc/sicp-solutions/)**

## 依赖

1. [Racket](https://racket-lang.org/) 工具链。其中包含了 Scribble。
2. Racket 包 [`scribble-math`](https://docs.racket-lang.org/scribble-math/index.html) 。

## 生成

目录用途：

- `src/`：源代码。
- `docs-test`：编译出的 HTML 和其他资源，作为沙盒用于本地测试。加入了 `.gitignore` ，不会被 Git 跟踪。
- `docs/`：编译出的 HTML 和其他资源，是要发布的页面。

在项目根目录运行：

- `make`：编译到 `docs-test` 目录。
- `make publish`：编译到 `docs` 目录（会先清空它）。

也可以在项目根目录手动运行 `scribble` 命令：

```bash
scribble --dest docs ...
# --dest 后面是输出目录。
# 将省略号（...）改成要编译的源文件的路径，如 src/index.scrbl。
# 可以一次编译多个。
```

有关 Scribble 更详细的用法，见 Racket 官方文档 [Running `scribble`](https://docs.racket-lang.org/scribble/running.html) 。
