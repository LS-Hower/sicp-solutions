#lang scribble/doc

@title{SICP 解题集}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble/manual
          "mreval.rkt")

@; ----------------------------------------------------------------------

更新日期：2026-03-07

@; ----------------------------------------------------------------------

@section{目录}

@itemlist[@item{@hyperlink["./chapter-1.html"]{第一章 习题解答}}]

其余部分正在编写中。

@; ----------------------------------------------------------------------

@section{说明}

SICP，全名为《计算机程序的构造和解释》（@italic{Structure and Interpretation of Computer Programs}），作者为 Harold Abelson、Gerald Jay Sussman 和 Julie Sussman。

这里使用本书第二版。

书中使用 @hyperlink["https://www.scheme.org/"]{Scheme 编程语言} 。本仓库使用 @hyperlink["https://racket-lang.org/"]{Racket 编程语言} 。后者是前者的超集。

本仓库使用了：

@itemlist[@item{Racket 文档工具 @hyperlink["https://docs.racket-lang.org/scribble/"]{Scribble} ，用于生成网页，便于浏览。}
          @item{Racket 包 @hyperlink["https://docs.racket-lang.org/sicp-manual/index.html"]{SICP Collections} ，便于在代码中引用在书中定义的实用过程等对象。}]

@; ----------------------------------------------------------------------

@section{SICP 正文之外的说明}

Racket 支持大整数类型。

@ss-interaction[(let ([x 18446744073709551616]) (* x x x x))]

在 Racket 中，整数除法 @racket[(/ a b)] 的结果类型为有理数（或整数，如果分母为 1），而不是进行进行浮点除法或整除。

@ss-interaction[(/ 6 10) (/ 6 2)]

TODO:
@itemlist[@item{对于约定只有两个元素的表，可以将圆括号改成方括号}
          @item{打印不适当表结尾（包括序对）时出现的点号}
          @item{延迟求值可以使用宏实现}
          @item{Chez Scheme 的情况}]

@; ----------------------------------------------------------------------

@section{SICP 官方电子版资源}

麻省理工学院官网提供了 SICP 电子版资源。

@itemlist[@item{@hyperlink["https://web.mit.edu/6.001/6.037/sicp.pdf"]{SICP PDF 电子版}}
          @item{@hyperlink["https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/index.html"]{SICP HTML 电子版}}
          @item{@hyperlink["https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip"]{SICP HTML 电子版 压缩包下载链接}}]

@; ----------------------------------------------------------------------

@section{链接}

@hyperlink["https://github.com/LS-Hower/sicp-solutions"]{本站 GitHub 仓库}

@hyperlink["https://ls-hower.github.io/index.html"]{LS_Hower 的个人主页}
