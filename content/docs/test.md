---
title: "Test"
date: 2021-11-15T22:39:09+08:00
type: docs
draft: true
---

# Button

XXXXXX

{{<button relref="/" class="...">}} Get Home {{</button>}}

{{<button href="https://github.com/3-F">}} 3-F {{</button>}}



# Columns

{{<columns>}}

## Left Content

Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa protulit, sed sed aere valvis inhaesuro Pallas animam: qui *quid*, ignes. Miseratus fonte Ditis conubia

<--->

## Mid Content

Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter!

<--->

## Right Content

Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa protulit, sed sed aere valvis inhaesuro Pallas animam: qui *quid*, ignes. Miseratus fonte Ditis conubia.

{{</columns>}}



# Details



{{<details "Another" open>}}

##  Marketdown content

LLLLL

FFFF

ok

Hello world

{{</details>}}



## Expand

{{< expand >}}

## MarketDoown content

HEllo Wordl

xxx

{{< /expand >}}



{{< expand "Custom Label FF" "...." >}}

## Market down contetn

Hellow rld

{{< /expand >}}



## Hints

{{< hint info >}}

## Markdown content
Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa

{{< /hint >}}



{{< hint warning >}}

## Markdown content

Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa

{{< /hint >}}



{{< hint danger >}}

## Markdown content

Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa

{{< /hint >}}



## KaTex

{{< katex display >}}

f(x) = \int_{-\infty}^\infty\hat f(\xi)\,e^{2 \pi i \xi x}\,d\xi

{{< /katex >}}



{{< katex display>}}

f(x) = \int_{-\infty}^\infty\hat f(\xi)\,e^{2 \pi i \xi x}\,d\xi

{{< /katex >}}



Here is some inline example {{< katex >}} f(x) = \int_{-\infty}^\infty\hat f(\xi)\,e^{2 \pi i \xi x}\,d\xi {{< /katex >}}



# Mermaid Chart

{{< mermaid class="text-center" >}}
stateDiagram-v2
    State1: The state with a note
    note right of State1
        Important information! You can write
        notes.
    end note
    State1 --> State2
    note left of State2 : This is the note to the left.
{{< /mermaid >}}


# Section

{{< section >}}

## First Page

First page # Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Second Page

Second Page # Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

{{< section >}}



# Tabs

{{< tabs "uniqueid" >}}

{{< tab "MacOS" >}} 

# MacOS

This is tab **MacOS** content.

Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa protulit, sed sed aere valvis inhaesuro Pallas animam: qui *quid*, ignes. Miseratus fonte Ditis conubia

{{< /tab >}}

{{< tab "Linux" >}} 

# Linux

This is tab Linux content.

Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa protulit, sed sed aere valvis inhaesuro Pallas animam: qui *quid*, ignes. Miseratus fonte Ditis conubia

{{< /tab >}}

{{< tab "Win" >}} 

# Windows

This is tab Windows content.

Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa protulit, sed sed aere valvis inhaesuro Pallas animam: qui *quid*, ignes. Miseratus fonte Ditis conubia

{{< /tab >}}



{{< /tabs >}}