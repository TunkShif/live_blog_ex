---
title: "C Learning Notes - Functions and Pointers"
desc: "C 语言学习记录 - 函数 指针 结构体"
date: 2020-10-08
tags: ["c", "programming"]
---

> 标题中以斜体呈现的内容和文章中的部分名词可能并非通行的中文译名 (~~自己瞎翻的~~)

## 函数 Functions

观察下列创建一个新的函数并调用的例子

```c
#include <stdio.h>

void starbar(void);

int main(void) {
    starbar();
    printf("Hello World!\n");
    return 0;
}

void starbar(void) {
    for (int i = 0; i < 10; i++) {
        printf("*");
    }
    printf("\n");
}
```

### 函数声明与定义

上面的例子中, `starbar()` 函数出现了三次, 在最开始的是函数原型 (_function prototype_), 向编译器指明了函数的类型, 在主函数中的是函数调用 (_function call_), 表明在此处使用该函数, 最下面的是函数的具体定义 (_function defination_), 是函数行为的具体实现.

函数同样具有类型, 在使用函数前都应当进行声明, 函数声明应该放在定义之前, 例如 `void starbar(void);` 中的 `void` 指明了函数类型, 表明该函数没有返回值, `starbar` 是函数的名称, 后面紧跟的圆括号表明这是一个函数, 圆括号中的 `void` 表明该函数不需要接收参数, 末尾的分号表明这是一条函数声明语句, 而不是在进行函数的定义, 编译器应当在别处寻找函数定义.

函数声明并不一定需要指明参数类型, 例如 `int f();` 是函数声明但不是函数原型. 函数原型指定了函数的返回值类型和参数的类型, 又叫做函数签名 (_signature_).

C 语言的标准库中的函数按照功能分类成了不同的类别, 例如与输入输出有关的 `printf()`, `getchar()`, `putchar()` 等函数的声明都包括在了 `stdio.h` 的头文件中.

### 函数参数

下面是一个带有参数的函数的示例

```c
void show_n_char(char, int);

void show_n_char(char ch, int num) {
    for (int i = 0; i < num; i++) {
        putchar(ch);
    }
    putchar('\n');
}
```

在函数原型中, 指明参数的数量和各自的类型, 此时参数的名称可以省略, 但在函数定义中参数的名称不可以省略.

在函数调用的时候, 编译器会根据函数原型中给定的参数个数和类型对函数调用时传入的参数进行检验, 如果传入的参数数量正确, 再检验类型是否匹配, 如果不符, 会先将传入的参数强制转型后再传入函数.

在函数定义时的参数仅仅只是形式参数 (_parameters_), 并不会实际创建变量, 在调用函数时必须传入实际的参数 (_arguments_), 对于一般的数据类型, 传参的方式是传入值, 即将传入的数据的值拷贝传入, 因此函数内部对传入的变量不会产生作用, 例如下面的例子

```c
void change_value(int);

int main(void) {
    int x = 1;
    change_value(x);
    printf("%d", x); // 1
    return 0;
}

void change_value(int n) {
    n = 0;
}
```

#### 不指定参数

下面的两条函数声明语句中, 若采用第一条语句的声明方式, 在调用函数时编译器将不会对传入的参数进行检查, 而第二条声明语句则表明了该函数不能接收参数.

```c
void test();
void test(void);
```

### 返回值

使用 `return` 语句来返回值, 其后可以接一个常量, 也可以是一个可求值的表达式或者是一个变量.

如果返回的值的数据类型与函数的类型不符, 会先将预计返回的值强制转型为函数预期的类型再返回, 例如下面的例子, 若传入的 `n` 的值为 30, 得到的返回值实际上是 3.

```c
int test(int);

int test(int n) {
    double z = 100.0 / (double) n;
    return z;
}
```

此外, 当某个函数执行到 `return` 语句后便会立即终止, 其后的所有语句不会再执行, 例如下面的例子, 最后一行的 `printf()` 函数始终不会被执行, 因为无论运行到哪个 `return` 语句后, 都会立即停止.

```c
int imax(int, int);

int imax(int a, int b) {
    if (a >= b) {
        return a;
    } else if (
        return b;
    )
    printf("MAX!\n");
}
```

同样也可以不给 `return` 语句提供返回值, 即直接使用 `return;`, 这将使得函数不会返回值, 并立即停止函数的继续执行, 该语句只能用于 `void` 类型的函数.

### 递归函数 Recursion

C 语言中允许创建使用递归函数, 即在函数定义中又调用函数本身, 观察下面的求和函数和求斐波那契数列项的例子

```c
int sum(int);
int fib(int);

int sum(int n) {
    if (n <= 1) {
        return 1;
    } else {
        return sum(n - 1) + n;
    }
}

int fib(int n) {
    if (n <= 2) {
        return 1;
    } else {
        return fib(n - 1) + fib(n - 2);
    }
}
```

## 数组和指针 Arrays and Pointers

C 语言中的指针是一类特殊的变量, 用于存储变量的内存地址, 使用一元运算符 `&` 可以获取变量的地址, 内存地址一般都以十六进制数表示, 例如下面的例子, 输出变量 `num` 的地址

```c
int num = 1;
printf("The address of num: %p\n", &num);
```

回到提到 [函数参数](#函数参数) 时的例子, C 语言的函数传入参数时一般都是传入的值, 因此传入的变量在函数体的局部作用域中的地址与原来的变量地址是不同的, 如果想实现改变传入的变量的值, 就需要用到指针, 例如下面的例子

```c
void change_value(int *, int);

void change_value(int *n, int num) {
    *n = num;
}
```

### 指针变量

指针变量同样具有类型, 在声明变量时的变量名前加上一个星号 `*` 即声明了一个该类型的指针变量

```c
int * ptr_i;
char * ptr_c;
float * ptr_f;
```

值得注意的是, 星号的位置比较灵活, `int * ptr;`, `int* ptr;`, `int *ptr`, 这几种声明方式都是合法的.

此外, 在一行内声明多个指针变量时, 需要注意在每个变量名前都要加星号, 例如下面的示例

```c
int * ptr_1, * ptr_2;
```

之后便可以将内存地址赋值给指针变量, 同样也可以再次对指针变量使用解引用 `*` 运算符来获取地址所存储的值, 例如下面的示例

```c
int num = 5;
int * ptr = &num;
int n = *ptr; // n = 5
```

#### 指针运算

注意指针也是一个变量, 它存储的值是另一个变量的地址, 因此指针变量本身也有所存储的内存地址, 因此同样可以对指针变量使用 `&` 操作符.

内存地址一般都是以一个十六进制数来表示, 且通常内存的最小存储单元是 `byte`, 因此可以对指针**加减一个整数**, 但两个指针变量不能进行加法运算.

```c
int a = 0, b = 1;
int c;
printf("The size of int is %d bytes.\n", sizeof(int));
printf("&a = %p\n&b = %p\n&c = %p\n", &a, &b, &c);
```

上面程序的一个输出示例如下, 可以看到 `int` 类型占用 4 bytes 的大小, 连续声明了三个变量, 它们被分配到了内存上连续的位置, 相邻两个地址之间相差的值都为 4.

```
The size of int is 4 bytes.
&a = 0x7ffff867956c
&b = 0x7ffff8679570
&c = 0x7ffff8679574
```

因此, 对于同种类型的指针, 还可以进行大小的比较运算.

#### 未初始化指针

指针是指向另一个变量的地址的变量, 如果在声明指针变量时未初始化指针的值, 那么会得到一个野指针, 即指向一个位置的地址, 此时再对其解引用并赋值的话可能会造成异常行为, 因此我们并不知道这个未初始化的指针所指向的地址的具体值.

```c
int *ptr;
*ptr = 5; // NEVER DO THIS!
```

#### 指针常量

定义一个指针常量, 其指向的数据不能被更改, 但指针所指向的原始的变量仍然可以被修改, 同样对指针常量做自增等运算也是合法的.

```c
int num[3] = {0, 1, 2};
const int *ptr = num;
ptr[1] = 2; // Not Allowed
num[1] = 2; // Allowed
ptr++; // Allowed
```

指针常量的值可以指向任意变量或常量的地址, 但是指针变量的值只能指向非常量的地址, 这样才能防止常量的值被改变.

##### `const` 详解

下面声明了一个指向浮点型常量的指针变量, 即指针指向的量不能被改变, 但指针变量自身的值可以被改变.

```c
const float *pf;
```

下面声明了一个指向浮点型的指针变量, 但指针变量本身的值不能改变.

```c
float * const ptr;
```

下面声明的指针变量指向的值不能改变, 其本身的值也不能改变.

```c
const float * const ptr;
```

下面这种声明方式等价于第一种声明.

```c
float const * pfc; // const float * pfc;
```

#### 指针类型

对于普通的数据类型, 在不同类型的数据赋值的时候, 一般会出现隐式的强制转型, 使得赋值得以实现, 例如

```c
int c = 3 / 2; // c = 1
```

但对于指针变量来说, 赋给指针变量的值一定要与其类型相对应

```c
int a = 0;
float b = 3.14;
int * pi = &b; // invalid
float * pf = &a; // invalid

int *pt = &a; // valid
int **ppt = &pt; // valid

int ar1[2][3];
int ar2[2][2];
int (*pta)[3] = ar1; // valid
pta = ar2; // invalid
```

### 数组

#### 声明和初始化数组

数组是一种用来容纳若干个同种类型的元素的数据类型, 其声明方式如下, 即在变量名后加上方括号, 里面写上数组的大小

```c
int numbers[10];
float fractions[3];
char codes[5];
```

使用索引(或者叫做下标)来访问数组中的元素, 索引是从 `0` 开始的, 因此 `int numbers[10];` 声明了一个大小为 `10` 的数组, 但访问数组中的第 10 个元素时, 需要使用 `numbers[9]`.

在声明数组的时候可以同时初始化数组的值, 例如

```c
int numbers[5] = {1, 3, 5, 7, 9};
```

未初始化的数组元素会被分配到任意不确定的值.

若初始化时提供的值的数量小于数组的大小, 则剩余的值会被分配到该类型的默认值, 如整型数组即为 `0`

```c
int num[3] = {1, 2}; // the value of num[3] is 0
```

在声明变量的同时初始化数组, 可以省略数组的大小

```c
int num[] = {0, 1, 2, 3, 4};
```

C99 引入的新特性使得可以部分初始化指定索引的值, 类似于枚举常量时的特性, 数组会按照给出的数据顺序赋值, 例如 `num[0] = 31`, `num[1] = 28`, 然后直接跳到 `num[4] = 31`, `num[5] = 30`, 最后再次覆盖 `num[1] = 29`, 其余都赋值为 `0`.

```c
int num[12] = {[5] = 212};
int num[12] = {31, 28, [4] = 31, 30, 31, [1] = 29};
```

声明数组时, 数组的大小必须是一个正的整型常量, 或者计算结果为正的整型常量的表达式, C99 标准引入了可变长数组后, 可以使用整型变量作为数组的大小, 其值也必须是正的整型常量

#### 数组越界

访问数组的元素时, 如果给定的索引值超出了数组的范围, 编译器并不会检测到该错误, 从而造成未定义行为, 造成程序运行异常.

由于 C 语言 `trusting the programmer` 的哲学理念, C 标准并未引入数组边界检查的特性, 因为不检查数组边界会使得程序运行得更快.

#### 多维数组

C 语言支持多维数组, 其中二维数组是最简单的一种, 声明方式如下

```c
int map[2][2];
```

它实际上相当于数组中再嵌套数组, 用字面量进行初始化时的直观表现如下

```c
int map[2][2] = {
    {1, 2},
    {2, 1}
};
```

#### 数组常量

使用 `const` 关键字定义数组常量, 使得数组中的元素都将被视作常量而不能修改, 此时在声明数组时必须同时初始化数组, 因为在定义后数组无法被修改.

```c
const int numbers[3] = {0, 3, 9};
```

#### 保护数组内容

对 `int` 这类数据进行函数参数传递的时候, 我们可以自行选择是传值(直接将变量传入)还是传引用(传入指向变量的指针), 但对于数组, 默认只能传入指针, 因此在函数调用过程中可能会有改变原始数组中的元素的风险.

在声明和定义函数的时候, 在参数中的数组前加上 `const` 关键字, 可以使得在函数调用过程中, 将传入的数组视作常量而变得不可修改, 如果函数体中试图修改传入的数组的值, 编译器会报错.

对于作为参数传入函数的数组, 并不一定要声明为常量.

```c
void change_value(const int[]);
```

#### 变长数组

注意这里提到的变长数组(_Variable-Length Arrays_) 并不是指在运行时还能够改变长度的数组.

在定义数组的时候, 一般需要我们手动指定数组的长度, 例如 `int arr[3];`, 或者也可以声明数组的同时进行初始化, 这样可以由编译器推断数组长度, `char str[] = "TEST";`.

在 C99 标准以前, 此处数组的长度只能是一个正整型常量, 数组的长度是在编译时确定的. 而 C99 引入了变长数组的特性, 使得在声明数组时数组长度可以用变量来代替, 数组的长度在运行时才确定, 例如下面的例子

```c
int n;
scanf("%d", &n);
int arr[n];
```

再次注意, 变长数组只是在运行时阶段才确定数组的长度, 但是一旦确定仍然不能再更改数组长度, 此外, 变长数组在定义时不能进行初始化.

同样在函数参数中也可以使用变长数组, 但要注意数组长度中的变量一定要先于数组声明, 例如

```c
int sum(int row, int col, int arr[row][col]) {
    // Do something
}
```

如果在函数原型中省略参数的话, 数组长度用 `*` 占位

```c
int sum(int, int, int[*][*]);
```

> 实际上该特性也是一个语法糖, 具体等学到内存管理再补充.

#### 复合字面量

C99 标准新加入了复合字面量的特性, 例如可以直接向函数传入一个数组字面量, 而不用先新建一个变量再将其传入, 下面是数组字面量的例子

```c
(int [2]) {1, 2}
(int [] {1, 2, 3, 4, 5})
```

数组字面量同样可以赋值给指针变量, 等同于将数组名赋值给指针变量.

```c
int *ptr = (int []) {1, 2, 3, 4, 5};
```

类似地, 同样可以创建多维数组的字面量.

### 数组和指针的关系

在**大多数**时候, 例如数组作为参数传递给函数, 或者在表达式中, 数组名都会**隐式**地转换成**指向数组第一个元素的指针**, 除了对其使用 `sizeof` 和 `&` 操作符的时候. 因此大多数情况下 `arr == &arr[0]`, 两者等价, 因此可以赋值给指针变量.

在声明数组时, 会划分一块相邻的内存区域给数组内的各个元素, 而指针变量指向一块内存地址, 因此可以对指针变量进行加减运算, 例如对指针变量 `ptr + 1`, 得到的仍然是一个指针变量, 只是地址向后增加一个数据单位的大小, 这个数据单位根据指针所指向的变量类型决定, 因此使用索引访问数组元素与用指针运算访问数组元素两者是等价的, 即 `arr[1] == *(arr + 1)`, `&arr[1] == (arr + 1)`.

注意运算符的优先级, 例如 `*arr + 1` 是等价于 `arr[0] + 1` 的.

因此 `array[index]` 实际上是 `*(array + index)` 的语法糖.

#### 一维数组作为函数参数

基于以上提到的特性, 我们可以直接将函数参数设定为一个指针变量, 然后在调用函数的时候直接传入数组的名称, 此时会隐式地转换成数组中第一个元素的指针, 在函数体中使用 `arr[i]` 时, 实际上又是被隐式地转换成了 `*(arr + i)`.

同时, 编译器并不会进行数组的边界检查, 也无法获取数组的长度, 一般在函数参数中还需要自己手动指定数组的长度.

```c
void print_value(int *, int);

void print_value(int *arr, int length) {
    for (int i = 0; i < length; i++) {
        printf("%d", arr[i]);
    }
}
```

在声明或定义函数时, 对于数组类型的参数还可以写成下面这种方式, 注意只有在声明函数原型的时候参数名才可以省略, 以下的写法同样会被隐式地转换成 `int *`.

```c
void print_value(int arr[]);
void print_value(int[]);
```

注意只有在参数中 `int []` 和 `int *` 是等价的, 但在声明变量的时候, 前者是一个整型数组, 而后者是一个整形指针.

此外, 由于数组中的元素在内存中是顺序分布的, 要将数组作为参数传递给一个函数, 只需要传递数组中的首尾元素即可, 例如下面的例子, 传入指向数组首尾元素的指针,

```c
int sum(int *, int *);

int sum(int *start, int *end) {
    int result = 0;
    while (start < end) {
        result += *start;
        start++;
    }
    return result;
}
```

另外注意运算符的优先级问题, 例如 `*start++` 这个表达式中, `*` 和 `++` 有相同的优先级, 但从右往左计算, 会先计算 `start++`, 再对其解引用, 为了更加清晰的指示顺序, 加上括号后即为 `*(start++)`

#### 多维数组与指针

声明一个二维数组, 即一个长度为 3 的数组里再嵌套长度为 2 的数组, 例如下面这个例子

```c
int map[3][2] = {
    {1, 2},
    {3, 4},
    {5, 6}
};
```

如同上文提到的一样, 数组名称在使用时等价于该数组中第一个元素的指针, 即 `map == &map[0]`, 而数组的第一个元素又是一个数组, 又等价于其第一个元素的指针, 即 `map[0] == &map[0][0]`.

因此, `map` 是指向**外层数组首元素** `{1, 2}` 的地址, 而 `map[0]` 是指向**首个内层数组的首元素** `1` 的地址.

虽然二维数组在形式上具有行和列, 但实际上在内存中数组中的所有元素仍然被划分在**连续的区域**上, 即 `map` 和 `map[0]` 都是从同一内存地址开始划分的, 所以 `map` 和 `map[0]` 两者具有相同的地址.

由于 `map` 和 `map[0]` 指向的数据类型不同, 其大小也不同, 因此 `map + 1` 和 `map[0] + 1` 产生的结果也不同

例如下面的一个示例, 因为 `map` 指向的是一个二元整型数组, 其大小为 8 bytes, 所以 `map + 1` 相当于增加了 8 bytes, 而 `map[0]` 指向的是一个整数, 大小为 4 bytes, 所以 `map[0] + 1` 相当于增加了 4 bytes.

```
0x7fffdd273b60 // both map and map[0]
0x7fffdd273b68 // map + 1
0x7fffdd273b64 // map[0] + 1
```

在解引用时, 要注意 `[]` 的**优先级高于** `+`, 所以要注意在适当的地方加上括号, 例如下面的等价例子, `*(map[0]) == map[0][0]`, `*map == &map[0][0]`, `**map = map[0][0]`

即 `map` 是指向另一个指针的指针, 必须被解引用两次才能获取到值.

对上面的隐式转换过程作一个推导如下

```c
map -> &map[0]
map[0] -> &map[0][0]
```

```c
*(map[0]) -> *(&map[0][0]) -> map[0][0]
*map -> *(&map[0]) -> map[0] -> &map[0][0]
```

#### 声明多维数组的指针

> 始终注意 `[]` 的优先级高于 `*`.

观察下面两个声明语句, 前者声明了一个指向二元数组的指针, 后者声明了一个含有两个指针变量的数组

```c
int (*ptr)[2];
int *ptr[2];
```

`int (*ptr)[2]` 意味着先声明一个指针变量, 指向一个类型为 `int[2]` 的数组.

`int *ptr[2]` 意味着先声明一个大小为 2 的数组, 数组的元素类型为 `int *`, 即一个含有两个指针的数组.

例如下面的例子

```
int map[3][2] = {
    {1, 2},
    {3, 4},
    {5, 6}
};

int (*ptr)[2] = map; // &map[0]
```

#### 多维数组作为函数参数

参考二维数组的指针声明方式, 按照以下方式声明参数为二维数组的函数, `int (*arr)[4]` 表示声明一个指针, 指向长度为 4 的数组, 即二维数组的内层.

```c
void some_func(int (*)[4]);

void some_func(int (*arr)[4]) {
    // Do something...
}
```

在前文提到, C 编译器不会检查数组的边界, 也无法获取数组的实际长度, 因此一维数组作为参数时, 其长度可以不确定, 即传递给函数的实际上只是一维数组中第一个元素的指针, 通过对指针进行加法运算而获其后面地址的值. 而二维数组作为参数传递给函数时, 同样也是传递的二维数组外层中的第一个元素的指针, 其指向的是一个一维的数组, 则这个一维数组必须是确定的, 必须得确定其元素个数, 这样才能确定这个一维数组的大小, 从而使得在进行 `*(arr + 1)` 运算时, 能够正确判定应该将内存地址向后偏移多少个单位, 因此在声明时必须附带上一维数组的长度.

类似地, 参数中的二维数组除了可以写成指针, 也可以写作下面数组的样式, 同样注意二维数组内层的数组大小一定要确定, 该写法同样会隐式地转换成指针的写法

```c
void some_func(int [][4]);

void some_func(int arr[][4]) {
    // Do something
}
```

实际上在参数中也可以写明一维数组的长度, 例如 `int arr[3][4]`, 但实际上编译器会将其忽略.

### 函数和指针

一个函数除了可以接收指针作为参数, 也可以返回一个指针, 同时指针变量也可以指向一个函数.

## 存储类 Storage Class

C 语言中所有的数据都存储在内存上, 存储的每一个数据都占用一块物理内存空间, 在 C 语言中使用对象 (_object_) 来代指这样的一块内存空间, 一个对象能够容纳一个或多个数据, 也可能并没有存储数据, 但一个对象一定占有适当的大小来容纳所指定类型的数据. 这里的对象的含义与面向对象编程中的对象并不相同.

在软件层面上, C 使用标识符 (_identifier_) 提供了访问对象的途径, 例如声明并初始化一个变量 `int n = 3;`, 其中的 `n` 就是标识符, 通过这个标识符能够访问到其所在的物理内存区域上的数据.

> TODO: lvalues & rvalues

### 作用域 Scope

作用域指的是程序能够访问到某个标识符的区域, C 语言中有以下几种作用域, 块作用域 (_block scope_), 函数作用域 (_function scope_), 函数原型作用域 (_function prototype scope_), 文件作用域 (_file scope_).

#### `block scope`

定义在复合语句中的变量即属于块作用域, 只能在其所在的代码块中被访问, 在代码块执行结束后便不能再被访问.

例如上面的例子, 全局定义了一个变量 `i`, 在 `for` 循环语句中的代码块里定义了局部变量 `q`, 只能在循环语句的作用域中被访问到.

```c
int i;
for (i = 0; i <= 3; i++) {
    int q;
    q = i * i;
}
```

传统上, 块作用域中的变量都应在代码块的开头进行声明, 但 C99 标准后, 放宽了这一限制, 可以在代码块的任意地方进行变量声明.

#### `function prototype scope`

对于函数原型作用域来说, 在声明函数时, 例如 `int func(int n);`, 我们指定了一个形参, 但函数原型的作用域只局限于函数声明的开始和结束, 因此实际上这个形参在函数声明的时候是不能被访问到的, 在之后的函数定义中, 完全可以使用不同的参量名, 所以在函数声明中完全可以将参数名省略.

但对于使用变长数组作为参数的函数来说, 数组长度的变量一定要先于数组声明, 例如 `void func(int n, int ar[n]);`

#### `file scope`

任何放置在函数体外的变量都属于文件作用域, 即全局变量, 在该文件中都能被访问到.

### _链接_ Linkage

C 语言中的变量有以下几种类型的 linkage, `external linkage`, `internal linkage` 和 `no linkage`, 在块作用域, 函数作用域, 函数原型作用域中的变量属于 `no linkage`, 意味着这个变量只对其所在的代码块内可见, 在文件作用域中的变量即可以是 `internal linkage` 或 `external linkage`, 属于 `external linkage` 的变量可以在多个文件之间使用, 而属于 `internal linkage` 的变量可以在单个翻译单元 (_translation unit_) 的任意位置使用.

<Admonition type="info" title="部分术语解释">

*Translation Unit* 指的是 `.c` 源文件以及其所引用的头文件. 属于 `file scope
with internal linkage` 的变量可以在单个翻译单元中被访问, 属于 `file scope with
external linkage` 的变量可以在多个翻译单元之间被访问到.

</Admonition>

在声明全局变量的时候, 使用 `static` 修饰符修饰的变量属于 `internal linkage`, 未修饰的变量则属于 `external linkage`

### _存储持续时长_ Storage Duration

作用域和链接描述了变量的可见性, 存储持续时长指的是对象能够在内存中持续存在的时间. C 语言中的对象具有以下四种类型的持续时长, 静态存储 (_static strorage duration_), 线程存储 (_thread strorage duration_), 自动存储 (_automatic strorage duration_), 分配存储 (_allocated strorage duration_).

#### `static storage duration`

该种类型的变量将会在整个程序运行的过程中持续存在, 需要**注意**的是, 属于 `file scope` 的变量都是静态存储类型, 即在函数体外声明的变量都是属于 `file scope with static storage duration`, 而对其使用 `static` 修饰符只是为了区别 `internal linkage` 和 `external linkage`.

在块作用域中声明变量时使用 `static` 修饰符来声明 `block scope with static storage duration` 的变量, 例如下面的例子, 变量 `ct` 将在编译时初始化, 并一直持续到程序运行结束, 即在第一次调用函数后再次调用该函数, 代码块中的 `ct` 并不会再初始化为 0.

```c
void func(void);

void func(void) {
    static int ct = 0;
    ct++;
    printf("This function has been called %d times", ct);
}
```

#### `thread storage duration`

与并发编程相关的概念, 该种类型的变量将从其被声明开始一直持续存在到所在的线程终止. 其余细节不作过多介绍.

#### `automatic storage duration`

在块作用域中声明的变量都是自动类的, 一般称作局部变量, 该类型的变量在程序运行到其所在的代码块后才在内存中分配空间, 当所在的代码块运行结束后又释放内存.

例外的是对于变长数组作函数参数时, 变量是从声明开始存在持续到代码块结束, 而不是从代码块开始.

总结来说, 不考虑 `thread storage duration` 的话, 本书将存储类划分为五大类, 如下表所示

![storgae classes](https://i.loli.net/2020/10/16/f2cXGhy8RJPl1jF.png)

### 变量类型

#### Automatic Variables

该种类型的变量属于 `automatic storgae class, automatic storage duration, block scope, no linkage`, 所有在代码块或函数体里面声明的变量默认都是这种类型, 也可以显示的用 `auto` 关键字修饰指明, 但一般不推荐这样做, 因为在 C++ 中 `auto` 关键字用于自动推导类型, 在 C 和 C++ 混编的时候可能会出现问题.

在代码块中使用变量时, 会优先使用代码块中已经存在的同名的局部变量, 例如下面的例子, 主函数中声明的 `x` 和内层代码块中声明的 `x` 分配在不同的内存地址, 拥有不同的值.

```c
int main(void) {
    int x = 0;
    {
        int x = 1;
        printf("The x in inner block is %d", x); // 1
    }
    printf("The x in main function is %d", x); // 0
}
```

自动类型的变量在声明时不会默认初始化值, 需要自己手动初始化值, 例如 `int i, j = 1;`, 变量 `i` 没有手动初始化, 其值可能会是分配到的内存上之前占用的值, 因此对局部变量建议都手动初始化.

#### Register Variable

变量通常都存储在计算机的内存当中, 但还可以存储在 CPU 的寄存器当中, 这类变量即寄存器变量, 其访问和操作速度比一般的变量更加快速. 寄存器变量没有地址, 其存储类与自动类型的变量相同, 即 `block scope, no linkage, automatic storage duration`.

使用 `register` 关键字来声明寄存器变量, 但由于 CPU 的寄存器数目有限, 并不是所有声明为寄存器变量的变量都能实现, 此时会默认当作自动类型的变量处理, 但仍然不能对其内存地址进行操作.

同样在声明函数时参数中也可以指定为寄存器类型.

#### Static Variables with Block Scope

在局部变量声明前加上 `static` 关键字, 该类变量属于 `block scope, no linkage, static storage duration`.

静态局部变量在编译时即完成初始化, 如果未指定初始化值, 会自动赋上默认的值, 例如对于整型会默认赋值为 0.

#### Static Variables with External Linkage

定义在函数体外的变量属于该种类型, 即 `file scope, external linkage, static storage duration`.

如果在某个函数中调用了全局变量, 可以手动用 `extern` 关键字再声明一次, 如果需要使用另一文件定义的某个变量, 则必须强制使用 `extern` 关键字声明变量. 在函数内部声明外部数组变量的时候, 数组大小可以省略.

```c
int i;
int arr[10];
extern char ch; // Mandatory declaration if ch defined in another file

int main(void) {
    extern int i; // Optional declaration
    extern int arr[]; // Array size can be omitted
    return 0
}
```

如果将上述主函数中的 `extern int i;` 的声明语句改为 `int i;`, 那么这将会新创建一个自动类型的局部变量 `i`, 在主函数中会优先使用该变量而不是先前定义的全局变量.

#### Static Variables with Internal Linkage

对全局变量使用 `static` 关键字声明的变量属于 `file scope, internal linkage, static storage duration`. 即该变量只能在当前文件中访问到, 而不能在其它文件中使用.

### 函数的存储类

不仅是变量具有存储类, 函数同样也有. 函数默认被声明为 `external` 类型, 即可以被外部文件访问到. 有 `static` 修饰的函数声明为 `internal` 类型, 只能在当前文件访问到.

## 内存分配 Allocated Memory

在进行变量声明的时候, 编译器会自动根据变量的数据类型来划分合适大小的内存空间, 例如 `float x;` `int arr[10]` 之类的声明.

但在 C 语言中, 可以很方便的对内存进行操作, 因此我们可以为数据划分超出其所需要的内存空间, C 标准库提供的 `malloc()` 函数便提供了此功能.

### 动态分配内存

`malloc()` 函数会根据传入的参数大小, 寻找一块合适的空内存, 并返回这块内存的第一个字节所在的内存地址, 即一个 `void` 类型的指针. 对该指针进行强制转型操作即可获得所需类型的指针.

因为 `char` 类型占用的大小恰好为一个字节, 所以对某些编译器或某些 C 标准而言, `malloc()` 返回的即是 `char` 类型的指针.

但如果调用 `malloc()` 函数时未能够找到所需的内存空间, 会返回 `null` 指针, 即空指针.

使用常规方式声明定义变量的时候, 变量的大小在编译期已经决定, 通过使用 `malloc()` 函数即可实现在运行时动态管理分配内存.

下面的例子便分配了一个大小为 10 个 `double` 类型大小的内存地址, 并将其第一块字节的地址赋给指针变量 `ptd`. 就相当于动态的声明了一个大小为 10 的 `double` 类型的数组.

```c
double * ptd;
ptd = (double *) malloc(10 * sizeof(double))
```

使用 `free()` 函数对已经动态分配的内存进行释放, 以便其能被再次使用. 其接收的参数是使用 `malloc()` 分配内存的指针.

上文提到调用 `malloc()` 函数时返回的可能是空指针, 因此有必要对此进行异常处理, 下面是一个常见的处理异常的例子

```c
int *ptr;
ptr = (int *) malloc(10 * sizeof(int));
if (ptr == NULL) {
    puts("Null pointer error!");
    exit(EXIT_FAILURE);
}
```

### 释放内存的重要性

在程序运行结束退出后, 一般操作系统会自动完成内存的释放工作, 但仍然建议在程序中自己手动使用 `free()` 释放内存.

如果在函数中使用了 `malloc()` 而没有使用 `free()` 进行内存释放, 那么每次调用该函数都会占用一部分内存, 最终可能会造成溢出.

### 分配初始化内存

使用 `malloc()` 函数分配的内存空间不会被初始化, 而使用 `calloc()` 函数可以在分配内存空间的同时将每一个字节都初始化为 0.

```c
long *nums;
nums = (long *) calloc(10, sizeof(long));
```

### 动态分配内存与变长数组

使用 `malloc()` 来动态创建数组和使用变长数组在功能上类似, 但区别在于, 变长数组是自动类型的, 因此编译器会自动分配并释放内存, 但自己手动使用 `malloc()` 分配内存创建的数组并不会自动释放.

## 文件读写操作

下面是一个读取文本文件并输出其内容的程序

```c
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    char ch;
    FILE *fp;
    if ((fp = fopen("./test.txt", "r")) == NULL) {
        puts("Can't open the file!");
        exit(EXIT_FAILURE);
    }
    while ((ch = getc(fp)) != EOF) {
        putchar(ch);
    }
    fclose(fp);
    return 0;
}
```

首先声明一个 `FILE` 类型的指针变量 `fp`, 然后使用 `fopen()` 函数打开文件, 两个字符串参数分别是文件路径和打开模式, 常用的模式如下所示

- `r`: 读取文本文件
- `w`: 写入文本文件, 会将已存在的文件清空, 如果目标文件不存在会自动新建
- `a`: 写入文本文件, 将内容附加到文件的末尾, 如果目标文件不存在会自动新建
- `r+`: 读写文件
- `w+`: 读写文件, 写入时会覆盖文件原有内容, 如果目标文件不存在会自动新建
- `a+`: 读写文件, 写入时会将内容附加到原文件的末尾, 如果目标文件不存在会自动新建
- `rb` `wb` `ab` `...`: 附加上 `b` 后以二进制模式打开

### `getc()` & `putc()`

这两个函数类似于 `getchar()` 和 `putchar()`, 分别是从标准输入流 (_stdin_) 获取字符和输出字符到标准输出流 (_stdout_).

使用 `getc()` 可以指定输入流, 例如像上述例子一样传入一个指向文件流的指针.

## 结构化数据类型

### 结构体 Structure

结构体可以用来存储多个不同种类型的变量, 例如用一个结构体来表示一本书, 需要包括书的名字, 作者, 价格等信息, 下面是一个例子

```c
#define MAX_TITLE_LEN 41
#define MAX_AUTHOR_LEN 31

struct Book {
    char title[MAX_TITLE_LEN];
    char author[MAX_AUTHOR_LEN];
    float value;
}

int main(void) {
    struct Book myBook;
}
```

#### 结构体声明

上述的结构体 `Book` 中有 3 个成员 (_members_) 或叫做字段 (_fields_), 在主函数外进行了结构体的声明, 定义了一个结构体类型 的模板, 这只是声明了一个该种类型的结构体类型, 但实际上并不会创建任何结构体变量. 其中 `struct` 是用来声明结构体的关键字, 后面跟的 `Book` 是一个可选的名称, 即为这个结构体创建一个可供简写的名称, 方便后面声明结构体变量.

结构体声明既可以放在函数外部, 也可以放在函数内部, 函数内部声明的结构体同样只能够在函数内部使用.

#### 定义结构体变量

同样使用 `struct` 关键字来定义结构体变量, 其后加上在声明结构体时指定的名称或者也可以将结构体成员定义写出来.

```c
struct Book myBook;

struct {
    char title[41];
    char author[31];
    float value;
} myBook;
```

编译器会在内存上划分一块连续的区域按照结构体声明中的成员次序分配给结构体中的各变量.

#### 初始化结构体变量

在定义结构体变量的同时初始化其成员的值, 按照结构体中定义的成员次序, 依次将初始化值用逗号分隔开

```c
struct Book myBook = {
    "The Book",
    "Nobody",
    3.99
};
```

C99 引入的新特性允许按照任意次序初始化结构体成员变量, 例如下面的例子

```c
struct Book myBook = {
    .value = 33.67,
    .author = "Nobody",
    .title = "A Book"
};

struct Book myBook = {
    .author = "Nobody",
    .title = "A Book",
    33.67
};
```

#### 访问结构体成员

使用 `.` 来访问结构体变量的成员的值, 注意下面的 `&myBook.value` 中, `.` 操作符的优先级高于 `&`, 因此会先曲结构体中的变量, 再取其地址.

```c
printf("%s", myBook.title);
scanf("%f", &myBook.value);
```

#### 结构体数组

同样, 同种类型的结构体可以被包含在一个数组里, 结构体数组的声明方式与普通的数组声明方式一致.

```c
int main(void) {
    struct Book books[10];
}
```

#### 嵌套结构体

结构体的成员仍然可以是结构体

```c
struct Name {
    char firstName[21];
    char lastName[21];
};

struct Person {
    struct Name name;
    int age;
};

int main(void) {
    struct Person guy = {
        {"Mark", "Lee"},
        28
    };
    printf("Name: %s %s\n", guy.name.firstName, guy.name.Lastname);
}
```

#### 结构体的指针

同样可以定义结构体的指针, 其值为结构体的

```c
int main(void) {
    struct Person guys[2] = {
        {
            {"Ada", "Evens"},
            19
        },
        {
            {"Ben", "Mark"},
            23
        }
    };
    struct Person *him = guys; // &guys[0]
    printf("%s %s is %d y.o.\n", (*him).name.firstName, (*him).name.lastName, (*him).age);
    return 0;
}
```

#### 通过指针访问成员

我们可以按照上面的例子先对结构体指针解引用, 再使用 `.` 操作符来访问结构体的成员, 使用 `->` 操作符可以直接通过结构体指针来访问其成员变量, 例如上述例子等价于下面的例子

```c
printf("%s %s is %d y.o.\n", him->name.firstName, him->name.lastName, him->age);
```

#### 结构体的更多特性

可以将一个结构体变量赋值给另一个相同类型的结构体变量, 对于数组这样做是不允许的, 但结构体可以.

同样, 结构体在作为参数传递给函数时, 传递的是结构体的拷贝.

注意下面这个例子, 其中 `name` 变量在创建时, 结构体变量所在的内存区域划分了足够多的区域来存储字符数组的值, 因此在初始化结构体时的两个字符串是存储在结构体内部的, 而 `pname` 变量创建时只分配了两个字符指针变量的大小的内存空间, 而字符串常量实际上是存储在别的地方而不是在结构体内.

```c
struct Name {
    char firstName[31];
    char lastName[31];
}

struct pName {
    char *firstName;
    char *lastName;
}

struct Name name = {"Mark", "Lee"};
struct pName pname = {"Mark", "Lee"};
```

如果我们用 `scanf()` 直接对 `pname` 中的成员进行修改, 那么可能会出现问题. 使用 `malloc()` 对其成员分配内存空间可以避免这个问题, 下面是一个示例

```c
struct Name {
    char *firstName;
    char *lastName;
}

void GetInfo(struct Name *);

void GetInfo(struct Name *pnm) {
    char tmp[11];
    puts("Enter your first name:");
    scanf("%s", tmp);
    pnm->firstName = (char *) malloc((strlen(tmp) + 1));
    strcpy(pnm->firstName, tmp);
    puts("Enter yout last name:");
    scanf("%s", tmp);
    pnm->lastName = (char *) malloc((strlen(tmp) + 1));
    strcpy(pnm->lastName, tmp);
}

int main(void) {
    struct Name name;
    GetInfo(&name);
}
```

#### 结构体字面量

C99 引入的新特性, 类似于数组字面量, 同样也可以用相同的方法创建数组字面量, 例如

```c
struct Book myBook;

myBook = (struct Book) {
    "A Book",
    "Unknown",
    3.99
};
```

#### Flexible Array Members

C99 引入的新特性, 可以在数组的成员中定义一个特殊的数组类型, 要求该数组不能指定大小, 且必须放在最后一个成员位置, 并且除该数组外结构体还需要有其它的成员.

```c
struct Flex {
    int count;
    double average;
    double scores[];
}
```

声明一个 `Flex` 类型的结构体变量后, 不能访问到其 `scores` 成员, 因为该成员没有分配到任何大小的内存空间. 这时需要声明一个结构体指针, 为结构体分配内存, 示例如下

```c
struct Flex *pf;
pf = malloc(sizeof(struct Flex) + 5 * sizeof(double));

pf->count = 5;
pf->scores[0] = 18.75;
```

即上面的例子为 `pf` 分配了内存空间, 其大小是在结构体的基础上加上了 5 个 `double` 类型的大小, 即相当于为 `scores` 成员分配了能够容纳 5 个 `double` 元素的大小. 然后便可以访问其成员.

#### 匿名结构体

C11 引入的新特性允许定义不带名称的结构体, 方便在结构体中嵌套使用, 例如下面的例子

```c
struct Person {
    int id;
    struct {
        char firstName[21];
        char lastName[21];
    }
}
```

但此时如果访问嵌套的结构体中的成员的话, 只需使用 `person.firstName` 即可.

### 共用体 Union

共用体是一种可以将不同类型的数据存储在同一内存空间上的数据类型, 但不同类型的数据不能同时存储在同一内存空间.

#### 声明共用体

类似于结构体, 用 `union` 关键字来声明共用体, 同样类似地声明共用体变量, 数组, 指针.

```c
union Holder  {
    int digit;
    double bigfl;
    char letter;
}

union Holder holder;
union Holder holders[3];
union Holder *phdr;
```

#### 初始化共用体

在声明共用体变量的时候, 编译器会给变量分配能够容纳共用体中最大数据类型所需的变量, 比如上面的例子中, 一个共用体变量的大小即是一个 `double` 类型所需的大小.

在声明变量的时候也可以进行初始化

```c
union Holder hdra;
hdra.letter = 'A';
union Holder hdrb = hdra;
union Hodler hdrc = {99};
union Holder hdrd = {.bigfl = 119.22};
```

#### 访问共用体成员

同样使用 `.` 操作符访问共用体成员, 但共用体不能同时存储其多个成员的值, 即共用体只能容纳其中的一个成员的值. 同样可以使用 `->` 操作符直接通过共用体的指针访问其成员.

```c
holder.digit = 9;
holder.bigfl = 33.4;

phdr->letter = 'A';
```

### 枚举类型 Enumerated Type

枚举类型使得可以使用一个符号化的名称来表示一个整型常量, 例如下面的例子, 首先定义了枚举类型 `COLOR`, 接着声明了一个枚举类型变量 `color`

```c
enum COLOR {red, yellow, blue, green};
enum COLOR color;

if (color == red) {
    // Do something...
}
```

### 命名空间 Namespace

结构体, 共用体, 枚举类型的标签 (_tag_) 所在的命名空间不同于一般变量的, 因此允许重名, 例如下面的例子是合法的

```c
struct rect {double x; double y;}
int rect;
```

### 使用 `typedef`

使用 `typedef` 关键字可以为某一数据类型创建别名, 例如下面是一个简单的例子

```c
typedef unsigned char BYTE;
BYTE x, y[10], z;

typedef char * STRING;
STRING name, sign; // char * name, * sign;
```

因此我们可以使用 `typedef` 为结构体和共用体创建别名

```c
typedef struct complex {
    float real;
    float imag;
} COMPLEX;
```
