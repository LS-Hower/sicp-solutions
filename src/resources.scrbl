#lang scribble/manual

@title{学习资源}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@hyperlink["./index.html"]{返回主页面}

@; ----------------------------------------------------------------------

@section{哪里可以读 SICP：一些电子书资源}

麻省理工学院官网提供了 SICP 电子版资源：

@itemlist[@item{@hyperlink["https://web.mit.edu/6.001/6.037/sicp.pdf"]{SICP PDF 电子版}}
          @item{@hyperlink["https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/index.html"]{SICP HTML 电子版}}
          @item{@hyperlink["https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip"]{SICP HTML 电子版 压缩包}}]

@; ----------------------------------------------------------------------

@section{如何运行代码：一些 Scheme 实现}

@itemlist[
  @item{@hyperlink["https://download.racket-lang.org/"]{Racket} ：工具链成熟，其中就包含集成开发环境 DrRacket。本项目也使用了 Racket 工具链和语言。}
  @item{@hyperlink["https://www.gnu.org/software/mit-scheme/"]{MIT/GNU Scheme} ：最为正统，是书中所使用的 Scheme 实现。（安装难度稍大。）}
  @item{@hyperlink["https://github.com/cisco/ChezScheme/releases"]{Chez Scheme} ：一般认为是最快、最稳定的 Scheme 实现之一。}
  @item{@hyperlink["https://www.gnu.org/software/guile/"]{GNU Guile} ：便于嵌入其他程序作为扩展，是 GNU 各种软件项目的首选。}
  @item{@hyperlink["https://try.scheme.org/"]{@tt{try.scheme.org}} ：Scheme 官网的在线交互式解释器，可以快速地测试少量代码片段。}
]

@; @url["https://try.scheme.org/"] 有点难看了，而且 @url["try.scheme.org"] 行为也不正确。

各种 Scheme 实现都基本遵循（至少一些版本的）Scheme 标准，所以都能运行书中绝大多数代码。虽然偶尔会有不同行为，但这类问题一般都不难解决。例如，在 Racket 语言中， @racket[cons] 所生成的序对是不可变的，不能对它们使用 @racket[set-car!] 和 @racket[set-cdr!] 。要解决这一问题，可以使用 Racket 里专门的可变序对类型。还有更简单的方式：在源代码首行用 @tt{#lang r5rs} 指定使用 R5RS 标准 Scheme 语言，这样书上的 @racket[set-car!] 和 @racket[set-cdr!] 就都可以正常使用了。（@hyperlink["./additional-lisp.html"]{补充的 Lisp 知识} 页面对序对不可变性有更详细的讲解。）

@; ----------------------------------------------------------------------

@section{如何编写代码：一些 Scheme 开发环境}

@itemlist[@item{DrRacket：上一节提到的 Racket 工具链的一部分。}
          @item{@hyperlink["https://www.gnu.org/software/emacs/"]{GNU Emacs} ：优秀的 Lisp 开发环境，对 Scheme 有着优良的原生支持。}]
