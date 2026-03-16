#lang scribble/manual

@title{SICP 解题集}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble/manual
          scribble-math
          "interaction.ss")

@; ----------------------------------------------------------------------

@(use-mathjax)

@; ----------------------------------------------------------------------

更新日期：2026-03-16

SICP，全名为《计算机程序的构造和解释》（@italic{Structure and Interpretation of Computer Programs}），作者为 Harold Abelson、Gerald Jay Sussman 和 Julie Sussman。

这里使用本书第二版。

书中使用 @hyperlink["https://www.scheme.org/"]{Scheme 编程语言} 。本项目使用 @hyperlink["https://racket-lang.org/"]{Racket 编程语言} 。后者是前者的超集。

本项目使用了：

@itemlist[@item{Racket 文档工具 @hyperlink["https://docs.racket-lang.org/scribble/"]{Scribble} ，用于生成网页，便于浏览。}
          @item{Racket 包 @hyperlink["https://docs.racket-lang.org/scribble-math/index.html"]{@tt{scribble-math}} ，用于在代码中写出数学公式。}]

@; ----------------------------------------------------------------------

@section{目录}

@itemlist[@item{@hyperlink["./chapter-1.html"]{第 1 章 构造过程抽象}}
          @item{@hyperlink["./resources.html"]{学习资源}}
          @item{@hyperlink["./additional-lisp.html"]{补充的 Lisp 知识}}]

@; ----------------------------------------------------------------------

@section{其他链接}

@hyperlink["https://github.com/LS-Hower/sicp-solutions"]{本项目 GitHub 仓库}

@hyperlink["https://ls-hower.github.io/index.html"]{LS_Hower 的个人主页（本页面的父页面）}
