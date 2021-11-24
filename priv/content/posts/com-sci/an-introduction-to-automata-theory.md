---
title: "An Introduction to the Theory of Computation"
date: 2021-06-13
desc: "State Machine and Grammar"
tags: ["computer science", "automata theory"]
---

# Finite State Machine

## Prerequisites

- **Symbol**: the smallest building block in the theory of computation and can be any letter, number
- **Alphabet**: collection of symbols, usually presented by $\Sigma$, e.g. $\\{0, 1\\}, \\{a, b, c \dots\\}$
- **String**: a sequence of symbols
- **Language**: a collection of strings
- **Powers of $\Sigma$**: $\Sigma ^ n$ is the set of all strings over $\Sigma$ of length n
- **Kleene Star**: (or **Kleene Closure**) $\Sigma ^ * = \bigcup_{i=1}^{+\infty} \Sigma _ i$

### Example

Given $\Sigma = \\{0, 1\\}$, and $L_1$ is the language of all strings of length 2,
then $L_1 = \\{ 00, 01, 10, 11 \\}$.

## Deterministic Finite Automata

- the simplest model of computation
- has a very limited memory

## Formal Definition

Given $M = \langle  Q, \delta, \lambda \rangle$, where:

- $\Sigma$: a finite set of symbols, which is the input
- $$
