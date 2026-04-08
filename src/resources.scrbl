#lang scribble/manual

@title{学习资源}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section{SICP 电子书}

麻省理工学院官网提供了 SICP 电子版资源：

@itemlist[@item{@hyperlink["https://web.mit.edu/6.001/6.037/sicp.pdf"]{SICP PDF 电子版}}
          @item{@hyperlink["https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/index.html"]{SICP HTML 电子版}}
          @item{@hyperlink["https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip"]{SICP HTML 电子版 压缩包下载链接}}]

@; ----------------------------------------------------------------------

@section{Scheme 实现与开发环境}

要运行 Scheme 代码，可以选择：

@itemlist[@item{@hyperlink["https://download.racket-lang.org/"]{Racket} ：工具链成熟，其中就包含集成开发环境 DrRacket。安装方便。但在语言细节上和书中的 Scheme 不同之处略多一些（但也都不难克服）。本站 @hyperlink["./additional-lisp.html"]{补充的 Lisp 知识} 页面对差异做了讲解。此外也可以通过 @tt{#lang} 指定语言。本项目也使用了 Racket 工具链和语言。}
          @item{@hyperlink["https://github.com/cisco/ChezScheme/releases"]{Chez Scheme} ：较为纯粹的 Scheme 语言解释器，同样也是开箱即用的。}
          @item{@hyperlink["https://www.gnu.org/software/mit-scheme/"]{MIT/GNU Scheme} ：最为正统，是书中所使用的 Scheme 实现。但安装难度稍大一些。}
          @item{@hyperlink["https://try.scheme.org/"]{@tt{try.scheme.org}} ：Scheme 官网的在线解释器，无需下载。}]

@; @url["https://try.scheme.org/"] 有点难看了，而且 @url["try.scheme.org"] 行为也不正确。

要编写 Scheme 代码，可以选择：

@itemlist[@item{DrRacket：是 Racket 工具链的一部分。}
          @item{@hyperlink["https://www.gnu.org/software/emacs/"]{GNU Emacs} ：优秀的 Lisp 开发环境。}]

此外还有更多 Scheme 实现与开发环境，可以上网查找。
