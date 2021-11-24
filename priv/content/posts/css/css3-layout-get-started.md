---
title: "CSS3 Layout Get Started"
date: 2021-03-08
desc: "学习 CSS 定位布局以及 Flex 布局"
tags: ["css", "web"]
---

# Box Model

![box model](https://mdn.mozillademos.org/files/16558/box-model.png)

- **Content**: 内容显示，大小通过 `width` 和 `height` 属性控制
- **Padding**: 包围住内容的外部区域的内边距
- **Border**: 包围内容和内边距的外边框
- **Margin**: 盒子与其它元素之间的空白区域

故 $box\ size = content\ size\ +\ padding\ size\ +\ border\ size$

# Position

在没有给元素设置 CSS 属性的情况下，各种元素是按照正常的流（**normal flow**）来布局显示的，可以通过设置元素的 `position` 属性改变元素的布局，其默认值为 `static`，设置了除了 `static` 值以外的元素称为**定位元素**（**positioned element**）。

## Relative

相对位置使得可以更改元素相对于正常流布局下的位置移动，通过 `top`，`bottom`，`left`，`right` 等属性来控制各方向的偏移量，偏移量的设置并不会影响其它的元素。相对元素并没有脱离文档流。

## Absolute

设置了绝对位置属性的元素会被移除正常的文档流，并且不会为该元素预留位置，通过 `top`，`bottom`，`left`，`right` 等属性来设置其相对于最近的上层的定位元素的位置，即一般会将其所在的容器元素位置属性设置为 `relative`。

## Fixed

固定位置是一种特殊的绝对定位类型，元素会被移除正常的文档流，通过 `top`，`bottom`，`left`，`right` 等属性控制其相对于整个窗口的偏移量，并且其位置不会随着滚动条的滚动而改变。

## Float

通过 `float` 属性指定元素沿其所在的容器的左侧或右侧放置，元素会被移除正常的文档流，允许文本或内联元素环绕它，通常配合 `width` 元素属性来设置其占据的空间。

# Flexbox

通过为元素设置 `display: flex;` 属性将其变为 flex 容器，其内的元素按照主轴（main axis）和交叉轴（cross axis）来布局，主轴方向沿着是 flex 元素放置的方向，交叉轴方向垂直于主轴方向。

![flex](https://developer.mozilla.org/files/3739/flex_terms.png)

通过 `flex-direction` 属性设置元素按行或按列排布，可用属性值除了 `row` 和 `column` 外还有对应的反转行和反转列，即 `row-reverse` 和 `column-reverse`。

通过 `justify-content` 属性设置 flex 容器内的元素在主轴的对齐方向，可用的属性包括：

- `flex-start` 默认值，从 main start 开始对齐
- `flex-end` 从 main end 开始对齐
- `center` 对齐到 flex 容器的中间
- `space-between` 按照主轴方向排布 flex 元素，各元素间有一定空间，开始和结尾的元素吸附于 flex 容器两侧
- `space-around` 和上面的属性类似，但开始和结尾的元素不会锁定在 flex 容器两侧
- `space-evenly` 元素间隔均匀分布

通过 `align-items` 属性设置元素在交叉轴的排布，可用的属性包括：

- `flex-start` 从 cross start 开始对齐
- `flex-end` 从 cross end 开始对齐
- `center` 对齐到容器的中间
- `stretch` 默认值，延伸元素填充整个 flex 容器
- `base-line` 按照文本文字的基线对齐

也可以使用 `align-self` 属性单独为某个元素设置

通过 `flex-wrap` 属性设置元素是否折行，可用属性值为 `wrap`，`wrap-reverse`，默认值为 `nowrap`。

通过对 flex 元素设置 `flex-shrink`，`flex-grow`，`flex-basis` 属性来设置元素的大小。

`flex-shrink` 设置了元素的缩减因子，当所有的 flex 元素的总大小超出其所在的 flex 容器，则根据该属性值来缩减元素尺寸适应大小。`flex-grow` 设置了元素在主尺寸（main size）下的生长因子，`flex-basis` 设置了元素在主尺寸下的初始大小。可以用 `flex` 简写设置。

# Responsive

## Media Query

使用 CSS3 引入的媒体查询语法可以帮助构建响应式的页面，即根据页面的大小调用不同的 CSS 片段。

```css
/* when the device's width is less than or equal to 100px */
@media (max-width: 100px) {
  /* CSS Rules */
}
/* when the device's height is more than or equal to 350px */
@media (min-height: 350px) {
  /* CSS Rules */
}
```

# Tips

## 注意属性的作用对象

注意 CSS 属性对当前的元素是否有作用，是否会被其子元素继承。

## 响应式图片

限制图片的最大宽度，使得在页面缩小的时候图片的尺寸会跟着发生变化

```css
img {
  max-width: 100%;
  height: auto;
}
```

# References

- **MDN Web Docs**

- [box model](https://developer.mozilla.org/zh-CN/docs/Learn/CSS/Building_blocks/The_box_model)
- [flexbox](https://developer.mozilla.org/zh-CN/docs/Learn/CSS/CSS_layout/Flexbox)
- [position](https://developer.mozilla.org/en-US/docs/Web/CSS/position)
