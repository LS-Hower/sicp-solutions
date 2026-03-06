#lang scribble/doc

@title{SICP 解题集}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble/manual
          "mreval.rkt")

@; ----------------------------------------------------------------------

更新日期：2026-03-07

@section{目录}

@itemlist[@item{@hyperlink["./chapter-1.html"]{第一章 习题解答}}]

其余部分正在编写中。

@section{链接}

@hyperlink["https://github.com/LS-Hower/sicp-solutions"]{本站 GitHub 仓库}

@hyperlink["https://ls-hower.github.io/index.html"]{LS_Hower 的个人主页}

@section{SICP 正文之外的说明}

Racket 支持大整数类型。

@ss-interaction[
(* 18446744073709551616 2)
]

Racket 对整数除法生成有理数类型。当然，如果分母为 1，则结果为整数。

@ss-interaction[
(/ 6 10)
(/ 6 2)
]

TODO:
@itemlist[@item{对于约定只有两个元素的表，可以将圆括号改成方括号}
          @item{打印不适当表结尾（包括序对）时出现的点号}
          @item{延迟求值可以使用宏实现}
          @item{将项目 README.md 中的内容移到此处}]
