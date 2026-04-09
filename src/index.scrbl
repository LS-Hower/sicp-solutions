#lang scribble/manual

@title{SICP 解题集}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

更新日期：2026-04-09

@; ----------------------------------------------------------------------

@section{说明}

SICP，全名为《计算机程序的构造和解释》，英文名为 @italic{Structure and Interpretation of Computer Programs} ，作者为 Harold Abelson、Gerald Jay Sussman 和 Julie Sussman。

这里使用本书第二版。

书中使用 @hyperlink["https://www.scheme.org/"]{Scheme 编程语言} 。本项目使用 @hyperlink["https://racket-lang.org/"]{Racket 编程语言} 及其文档工具 @hyperlink["https://docs.racket-lang.org/scribble/"]{Scribble} 写成。

Racket 基本可以当成 Scheme 的超集，书中的许多代码无需修改即可直接用 Racket 解释器正常运行。但它们之间仍然存在差别。 @hyperlink["./additional-lisp.html"]{补充的 Lisp 知识} 这个页面中有更详细的讲解。

原书中的练习题只有形如“x.y”的编号，没有名称。名称是我自行添加的。

@; ----------------------------------------------------------------------

@section{目录}

@itemlist[
  @item{@hyperlink["./resources.html"]{学习资源}}
  @item{@hyperlink["./additional-lisp.html"]{补充的 Lisp 知识}}
  @item{
    第 1 章 构造过程抽象
    @itemlist[
      @item{@hyperlink["./chapter-1-1.html"]{1.1 程序设计的基本元素} （练习 1.1 ~ 1.8）}
      @item{@hyperlink["./chapter-1-2.html"]{1.2 过程及其产生的计算} （练习 1.9 ~ 1.28）}
      @item{@hyperlink["./chapter-1-3.html"]{1.3 用高阶函数做抽象}（练习 1.29 ~ 1.46）}
    ]
  }
  @item{
    第 2 章 构造数据抽象
    @itemlist[
      @item{@hyperlink["./chapter-2-1.html"]{2.1 数据抽象导引} （练习 2.1 ~ 2.16）}
      @item{@hyperlink["./chapter-2-2.html"]{2.2 层次性数据和闭包性质} （练习 2.17 ~ 2.52）}
    ]
  }
  @item{（其余部分正在编写中）}
  @item{@hyperlink["https://github.com/LS-Hower/sicp-solutions"]{（外部）本项目 GitHub 仓库}}
  @item{@hyperlink["https://ls-hower.github.io/index.html"]{（外部）LS_Hower 的个人主页（本页面的父页面）}}
]
