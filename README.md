# sicp-solutions

我的 SICP 习题解答（解题集）。

在线阅读：[https://ls-hower.github.io/sicp-solutions/](https://ls-hower.github.io/sicp-solutions/)

## 依赖

Racket 工具链（其中包含 Scribble）。

Racket 包 [`scribble-math`](https://docs.racket-lang.org/scribble-math/index.html) 。

## 生成

`src` 目录下是源文件，使用 `scribble` 编译成 HTML 文件及相关资源，它们位于 `docs` 目录下。

如果可以使用 `make` 命令，则可以在项目根目录使用 `make` 命令：

```bash
make
```

也可以在项目根目录手动运行 `scribble` 命令：

```bash
scribble --dest docs src/index.scrbl src/additional-lisp.scrbl src/resources.scrbl src/chapter-1.scrbl
```

上述命令将编译 `src` 目录下的所有 `.scrbl` 文件，并将结果输出到 `docs` 目录。当然，也可以修改命令，只编译一部分文件。有关 Scribble 更详细的用法，见 Racket 官方文档 [Running `scribble`](https://docs.racket-lang.org/scribble/running.html) 。
