---
title: "Understanding Morphology Reading Notes 1"
date: 2020-12-29
desc: "从零开始的形态学学习记录 - 序言"
tags: ["linguistics", "morphology"]
---

# Introduction

# 前言

这是我决定正式开始认真读的一本语言学领域的导论，也可以说是我迈向系统化地学习语言学的第一步。之前都是在知乎上零碎地观看各位巨佬的回答，拾人牙慧，又或者是零散地在 Wikipedia 上查阅一些资料进行了解，但都涉猎不深，不过至少据此建立起来了一个对于语言学比较宏观的学习框架。

在此为何我会选择形态学（_Morphology_）作为系统学习语言学的第一步呢？首先其实我最早是在学习英语的过程中，逐渐了解到了词根词缀的构词理论，又逐渐通过此了解到词源学（_Etymology_），最后逐渐了解到了语言学（_Linguistics_）这门庞大的学科，以及其下的子领域学科。所以说形态学可以说是我初涉语言学领域的学科，其次形态学对我来说感觉入门难度算是比较友好的了，不知道为什么我看语音学的导论会有些头疼...

另外学习所用的教材是 Haspelmath, M. & Sims, A. (2010). _Understanding Morphology_. _2nd ed_. London: Hodder.

# 简介

## What is morphology?

形态学是一门研究单词内部结构的学科，目前已知的最早的语言学家主要都是 morphologist，甚至最早的像希腊与罗马的语法学家其实主要都是在研究单词上的形态变化，例如变格和变位，以至于到十九世纪后半叶，形态学（morphology）这个词才被提出，远晚近于音系学（phonology）的概念的提出。这是因为由于印欧语言丰富的形态变化，其对语法（grammar）的研究实际上大部分都是对单词的结构的研究，而在语言学的研究逐渐迈进现代化后，形态学的概念才被提出。

另外在此补充说明一下关于对单词（word）的定义，单词这个概念似乎从直觉上便能分辨理解，但实际上目前还没有给出具体对单词的定义，所以暂时后文提到的单词便是一个比较宽松的、直觉上的概念。

形态学研究的具体是什么？例如英语单词 nuts、books、lapse 都以音素 /s/ 结尾，但我们可以发现 nuts 和 books 中的 /s/ 都指示了名词的复数概念，且去掉末尾的 s 后其仍然是一个单词，但 lapse 就并不符合这种情况，像 nuts 和 books 这样的词我们可以称作 **_complex words_**. 因此我们发现了英语中有这样一组词满足一个相同的规则，即在词的末尾加上一个 /s/ 后便成为了其复数概念，即存在一种形式（form）和表意（meaning）上的关联性。由此引出对形态学的一个定义：

> **_Definition 1_**
> Morphology is the study of systematic covariation in the form and meaning of words.
> _形态学是对单词在形式和表意上的系统性的关联变化的研究。_

~~默默吐槽一句：可能是自己语文水平太差，翻译出来还不如直接看原文（~~

像上文提到的 nuts 和 books 这两个单词都还可以再次拆分成为比单词还要细化一级的单位，即 nut-s 和 book-s，所以形态学还是一门研究单词的组成成分（**_constituents_**）的学科。即 nuts 包含有 _nut_ 和 _s_ 这两个比单词更细小一级的元素，按照惯例我们习惯在一个单词中用短横线（hyphen）将其分隔开。而这个在单词中最小的能够辨义的元素叫做语素（**_morphemes_**）。一些复杂的单词都能被分割成为多个语素，例如 hope-less，ear-bud-s. 由此引出对形态学的另一定义：

> **Deginition 2**
> Morphology is the study of the combination of morphemes to yield words.
> _形态学是对能产出单词的语素组合的研究。_

上述的第二定义看上去似乎不那么抽象了，但其并不能适用于所有情况，在某些具体研究下还是得使用更加抽象的第一定义。

此外，形态学不仅是语言学下的一个子领域，它也是某一门具体语言的一部分，例如我们可以说 the morphology of Spanish，即对西班牙语的单词结构的研究。事实上手语（sign languages）也存在形态学的特征，但本书主要讲解的还是口头语言的形态学。

## Morphology in different languages

形态学在不同语言中的体现程度是不同的，例如汉语、越南语等语言就缺少词的形态变化，而多数印欧语系和亚非语系下的语言在单词形态上富于变化，例如英语的 I eat 和 you eat 中的 eat 的主语人称的区分需要用额外的人称代词来指示，而对应的西班牙语的 como 和 comes 则通过动词形态上的变化即可以区分人称。

有时语言学家用分析化的（**_analytic_**）和综合化的（**_synthetic_**）这两个术语来描述形态学在某一门语言中的体现程度。像汉语、越南语等缺乏单词的形态变化的语言，属于高度分析化的语言，也被称作**孤立语**（**_isolating_**），注意孤立语和孤立语言是不同的概念。而像苏美尔语、斯瓦希里语、古希腊语等富于单词形态变化的语言被称作**综合语**（**_synthetic_**）。

而观察下面的一个西格陵兰岛语（West Greenlandic）的例子

$$Paasi-nngil-luinnar-para ilaa-juma-sutit.$$
$$understand-not-completely-1SG.SBJ.3SG.OBJ.IND come-want-2SG.PTCP$$
$$I\ didn't\ understand\ at\ all\ that\ you\ wanted\ to\ come\ along.$$

当一门语言高度体现形态学特征或者说是高度综合化的时候，可以被称作**多式综合语**（**_polysynthetic_**），其特点是很多在其他语言中需要用一个句子表达的含义，在多是综合语中往往只需要一个单词即可表达。

但分析语和综合语的区分并不是二元的对立关系，即使在综合语中有可能会有分析化的体现，反之亦然。可以用某段语言的随机文本样本中每个单词所含语素的占比来评判一门语言的综合化的程度。

## The goals of morphological research

### Elegant description

所有的 morphological patterns 都应以一种优雅的、直觉上令人满意的方式描述出来。例如我们能总结出在英语中通过在名词后加 -s 来形成复数这一普适性（generality）的规则，而非是将 book，books；ability，abilities 等所有单词的形式一一列举出来。

### Cognitively realistic description

对语言形态学的描述不仅需要优雅，同时还需要以一种符合语言使用者的认知的方式。比如说英语使用者对于英语的知识不仅是单纯的将名词的单复数列举出来，而是在其认知中有着“在单数名词后加 -s 能形成复数名词”这样一条普适化的规则。例如给你提出一个新的名词概念，有一种叫 wug 的小动物，你会能够反映出很多个 wug 应该用 wugs。即我们总结出来的形态学上的规则是符合语言使用者的认知的。

### System-external explanation

形态学上的规则总结出来后，可能会面临更进一步的深入的问题：为什么这些规则是这样的？例如为什么在英语中用 -s 来表示复数名词的概念？即我们需要一个体系之外的更进一步的解释。但要注意的是，很多情况下，这些规则之所以是这样只是因为历史上的偶然罢了，而无法进一步被解释，即对应索绪尔观点下的“语言符号具有任意性”。要想探清这些问题的答案，可能需要更深层次的对全体人类语言进行通行性（universals）研究。而首先我们必须查明哪些 morphological patterns 是普遍性的，例如 -s 表名词复数的规则便不是普遍性的，甚至通过形态学手段来表达复数概念也不是普遍性的，例如汉语就缺乏形态学上的复数概念（morphological plurals）。但据研究可以总结出“如果一门语言的全体名词具有形态学上的复数，那么其指代人的概念的单词也会有复数形式”这样的普遍性的规则，例如有些语言中仅与人相关的词才有复数形式，据此我们可能提出推论，即在语言交流过程中，在口头的语言表达中分辨人的数量比起分辨事物的数量会更加有用，也即是说语言中人物的复数概念比起事物的复数概念更加实用，而这一原则又普适于全体的语言，那么这就是一条体系之外的解释（system-external explanation），即在口头语言中数的概念的区分的实用性（the usefulness of number distinctions in speech）。

### A restrictive architecture for description

许多语言学家认为语法研究的一个重要目的便在于规范出所有语言都适用的通用语法。很多语言学家假定语法的结构体系是天然固有的，是所有人类语言都遵从的，即所谓的**通用语法**（**_Universal Grammar_**），则形态学研究的一个目的便是探索这些与单词结构相关联的通用语法的准则。

而现在的语言学研究者通常只关注于 system-external explanation 和 formulating an architecture for grammatical description 两者中的一个，前者即为功能主义派别（functionalist），后者即为生成派别（generative）或者形式主义派别（formalist）。

[0]: https://www.notion.so/Understanding-Morphology-e241468176c84fffb5b28e1785f6024f
