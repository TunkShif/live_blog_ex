---
title: "C Learning Notes - Basics"
date: 2020-09-16
desc: "C 语言学习记录 - 变量 数据类型 控制流"
tags: ["c", "programming"]
---

## 基础概念

![C Langauge](https://i.loli.net/2020/09/26/6G4Mnt3rwcdPxUv.png)

```c
#include <stdio.h>

int main(void) {
    int num;
    num = 1;
    printf("Hello World!\n");
    printf("My favorite number is %d", num);
    return 0;
}
```

### 预处理器 Preprocessor

源码中以 `#` 开头的叫做**预处理指令** (**_preprocessor instructions_**), 会在编译过程进行之前执行, 实际上进行的是简单的**剪切与替换** (**_cut-and-paste_**), 该过程完成后会生成替换后的源码.

`#include` 指令的作用是将另一文件包含在该文件当中, 预处理器执行完毕后, 需要被包含的文件内容会被原样地替换进来, 一般会将该条指令放在程序的头部, 因此被包含的这些文件一般被称作**头文件** (**_headers_**).

`stdio.h` 即**标准输入输出** (**_standard input/output_**), 里面包含了进行输入输出所需的信息, 例如 `printf()` 函数的信息就包含在内.

头文件中一般包括了宏定义和函数声明, 然而函数的具体实现并非包含在头文件内, 而一般是在预编译好的库中.

### 主函数 Main Function

主函数为程序的入口, 是一般情况下程序第一个执行的函数, 函数名必须命名为 `main`, 一些老旧的代码可能采用以下方式声明主函数

```c
main() // MEVER DO THIS!!!

void main() // Not Recommended
```

但按照现在的标准建议按照以下格式声明主函数

```c
int main(void) // omitting void is acceptable
```

其中主函数在执行结束后会返回一个整型的状态码给系统, 以提示程序的运行退出情况.

### 表达式 Expressions

由操作符 (_Operators_) 和参与操作符运算的量 (_Operands_) 组成的叫做表达式, 例如下面各行都是一个表达式

```c
4
-6
2+3
a * (b + c)
x = ++i / 3
x >= 3`
```

### 语句 Statements

语句以一个分号结束, 例如下面的例子中每行都是一条语句, 其中第三行的叫做空语句

```c
x = a + b;
i++;
; // null statement
```

#### 复合语句/代码块 Blocks

将多条语句用大括号包围起来构成复合语句, 或者又叫代码块, 例如下面的例子便使用到了复合语句

```c
int i;
while (i <= 10) {
    printf("%d\n", i * i);
}
```

### 声明语句 Declarations

```c
int number;
```

上面是一个声明整型变量的例子, 编译器将会根据变量类型为该变量分配一块合适的内存区域, 末尾的分号标志着这是一个语句, 这个分号也是语句的一部分.

所有的变量在使用之前必须先声明, 传统的习惯是在每个函数体的最开头进行变量声明，但 C99 和 C11 标准已经支持在代码块的任何地方声明变量.

### 初始化值 Initializing

```c
int number = 7;
int a = 1, b = 2;
int x, y = 1; // valid, but not recommended
```

在声明变量的同时赋值给该变量, 注意不支持多重赋值, 因此上述例子的最后一条语句仅仅初始化了变量 `y` 的值.

### 标识符 Identifiers

标识符是变量, 函数或其它实体的自定义名称, 合法的标识符应该由大小写字母, 数字, 下划线组合而成, 并且不能以数字开头, 同时标识符不能和关键字同名.

C99 和 C11 标准在国际化上进行了扩展, 使得更多非英文字母文字成为合法的字符.

### 赋值语句 Assignment

```c
number = 1;
```

赋值语句将数据值存储到了在声明变量时所划定的内存区域, 同时此后可以再重新给变量分配值, 其中的 `=` 为赋值运算符, 其作用是将右侧的值赋给左侧的变量, 不等同于数学上的等号.

## 数据类型

### 数据量单位

- 位/比特 (_Bit_): 最小的内存单位, 只能是 1 或 0 中的一个数
- 字节 (_Byte_): 常用的内存单位, 由 8 位组成, 即一个字节能表示 0~255 的 256 个十进制数
- 字 (_Word_): 根据计算机构架而决定的内存单位, 如对于 32 位的计算机, 1 word 即 32 bits

### 整数和浮点数

整数是不带有小数点的数值, 例如 `7` 是整数而 `7.00` 是浮点数, 整数在计算机内部由固定数位的二进制数表示, 浮点数在计算机内部存储时, 按照科学计数法划分为小数部分和指数部分, 将这两部分分别存储, 浮点数表示的范围比整数大, 计算机内部无法准确表示十进制的实数范围内的所有数, 有时候有些浮点数只能被表示为近似值

### 整型 Integer

整型属于有符号 (_signed_) 的类型, 其大小为计算机的自然的整数大小, 其中 `99`, `27` 这类数值叫做**整型常量** (_integer constants_) 或 **整型字面量** (_integer literals_).

C 默认所有的整型常量都为 `int` 类型, 但对于特别大的数可能会有不同的处理, 同样也可以自行指定整数常量的类型, 在数值后面加上后缀 `l` 或 `L` 来指明其为 `long` 类型, 加上 `u` 或 `U` 来指明 `unsigned` 类型.

#### 八进制和十六进制数

C 默认所有的整型常量都是十进制整数, 但特定的前缀可以改变识别整数的方式.

用 `0x` 或 `0X` 前缀来指定一个十六进制数, 用 `0` 前缀来指定一个八进制数, 但不管其字面形式为多少进制, 在计算机内部都是用二进制表示的.

#### 修饰符

在声明变量时用 `long`, `short`, `long long` 修饰可以改变变量的存储大小

存在修饰符的变量声明时的 `int` 关键字可以忽略, 即 `long int` 等价于 `long`

用 `unsigned` 指明变量为无符号数, 即零或正数, 它能够表示更广范围的正数

对任何有符号的类型用 `signed` 修饰可以显式的表明该数据类型有符号, 实际并不会影响变量的存储大小

能表示的数的范围大小关系为 `short < int < long`, 但具体的范围由不同的计算机构架决定

### 浮点型 Float

#### 浮点型字面量 Floating-Point Literals

浮点数字面量, 亦即浮点数常量, 有多种写法可以表示, 其中一种是如同数学上的小数表示, 如 `3.14`, 另一种是指数表示, 如 `4.57e-3` 或 `4.57E-3`, 即数学上的 `2.57 * 10^-3`, 要注意的是数字和 `e` 之间不能有空格. 此外还可以忽略整数部分或小数部分中的一个, 例如 `.2` 和 `100.` 都是合法的浮点数.

编译器默认会将浮点型常量处理为双精度类型, 在浮点数后加上相应的后缀可以特别地指明其类型, 例如 `float` 类型的 `3.14f`, `long double` 类型的 `3.14L`.

#### 浮点数溢出 Overflow

观察下属例子, 对于一个过大的浮点数的计算结果, 现今的编译器会将其分配至一个特殊的值, 表示为 `inf` 或 `infinity`.

```c
float num = 3.4E48 * 100.0f;
printf("%e\n", num); // inf
```

### 字符型 Character

整型变量用于存储一个字符, 可以是字母或符号, 但其本质仍然是一个整型, 存储的是一个整数, 为字符对应的 [ASCII](https://en.wikipedia.org/wiki/ASCII) 码的值, 标准的 ASCII 编码范围为 0~127, 因此字符类型一般是八位的, 以便能够容纳其他编码的文字.、

#### 使用字符型变量

```c
char letter = 'T';
```

上述例子中的 `'T'` 为字符常量或字符字面量形式, 需要注意的是, 字符类型需要被单引号包裹起来, 而不能用双引号包裹, 双引号包围的是字符串类型. 编译器实际上会将字符常量形式转化为其对应的编码值, 因此也可以直接给字符型变量赋上整数值, 但并不推荐这样做.

#### 不可打印字符 Nonprinting Characters

诸如新行 (_Newline_), 回车 (_Carriage Return_), 水平制表符 (_Horizontal Tab_) 等特殊的字符, 除了可以使用其对应的 ASCII 码表示, 还可以通过转义序列来表示, 具体如下表格


![Escape Sequences](https://i.loli.net/2020/09/29/vnlzkETXVAuRixF.png)

### 布尔类型 Boolean

> 待补充

### 跨平台通用类型 Portable Types

C 默认提供了很多可供选择的数据类型, 但在不同的操作系统或不同的计算机构架上, 同一类型的占用内存大小可能并不一样, C99 引入了 `stdint.h` 和 `inttypes.h` 两个头文件, 定义了一系列的宏以实现在不同构架平台上通用的固定大小的数据类型.

#### 获取数据类型大小

使用 `sizeof` 运算符可以获取某种数据类型的占用内存大小, 如下面的例子将会打印出运行的平台构架上 `int` 类型的大小.

```c
printf("The size of int type is %zd bytes.\n", sizeof(int));
```

### 字符串 String

字符串并不是 C 语言中的一种基本数据类型, 实际上是一个字符类型的数组, 字符串中的每个字符在内存单元中划分的内存地址都相邻, 并且字符串都以空字符 `\0` 结尾, 空字符并不是 0, 它的 ASCII 码的值是 0.

字符串需要用双引号包裹起来, 注意区分 `"x"` 和 `'x'`, 前者是一个字符串, 包含两个字符, `'x'` 和 `'\0'`.

#### 字符串长度 Length

引入 `string.h` 头文件后, 可以使用 `strlen()` 函数来获取字符串的长度, 观察下面的例子

```c
#include <stdio.h>
#include <sting.h>

int main(void) {
    char name[5] = "Mark";
    printf("The size of name is %zd bytes.\n", sizeof(name));
    printf("The length of name is %zd.\n", strlen(name));
    return 0;
}
```

从运行结果可以看到, `name` 变量的大小为 5 bytes, 但长度只有 4 个字符, 空字符并不会计入长度, 但空格或其它标点符号会计入字符串长度.

### 常量 Constants

定义符号化常量 (_Symbolic Constant_) 可以使得代码更具有可读性.

#### 使用宏定义常量

定义常量的传统的方法即使用宏, 在编译器的预处理阶段进行替换.

```c
#define PI 3.14

float AreaOfCircle(float);

float AreaOfCircle(float r) {
    return PI * r * r;
}
```

#### 使用 `const` 关键字

C90 标准引入了一个新的关键字 `const` 来定义符号化的常量, 这种方法更加灵活有效, 使得可以定义常量的类型.

```c
const int MONTHS = 12;
```

### 类型转换

对于 C 语言, 基础的类型转换的规则如下:

1. 当 `char` 和 `short` 类型出现在表达式中的时候, 包括 `signed` 或 `unsigned` 修饰的类型, 都会自动转型成为 `int` 或 `unsigned int` 类型.
2. 涉及到两种类型的数据运算时, 这两个数据都会被转换成二者中更高级别的类型.
3. 各种类型的级别顺序为 `long double`, `double`, `float`, `unsigned long long`, `long long`, `unsigned long`, `long`, `unsigned int`, `int`. `short` 和 `char` 类型没有列出是因为它们参与运算时都会被提升为 `int` 类型.
4. 在赋值语句中, 右侧计算出的值会转换成左侧变量的类型, 这可能会造成类型提升或类型下降.
5. 当 `char` 和 `short` 类型作为函数参数传递时, 通用会被提升为 `int` 类型, 相应的 `float` 也会被提升至 `double` 类型. 该机制会被函数原型中的参数类型声明所覆盖.

#### 强制转型 Casting

在数据前使用 `(type)` 操作符可以实现对数据的强制转型, 例如下面的例子

```c
float x = 1.6, y = 1.7;
int a, b;
a = x + y; // a = 3
b = (int) x + (int) y; // b = 2
```

## 格式化输出与输入

### 格式化输出

使用 `printf()` 函数实现格式化输出变量的值, 将要输出的变量的值需要以占位符的形式写在字符串中, 可用的占位符如下表

![conversion specifiers](https://i.loli.net/2020/10/05/SgezUKsb3r7u1O6.png)

在占位符前面加上特定的修饰符可以实现按一定的格式输出数据

![modifiers](https://i.loli.net/2020/10/05/cqlfbMXdoskIJBr.png)

![flags](https://i.loli.net/2020/10/05/i47PhHFpC8EeA5N.png)

`printf()` 函数具有返回值, 正常情况下, 函数会返回所输出的字符的个数.

#### 输出较长的字符串

除了将长字符串拆分开用多个 `printf()` 输出外, 还可以用 `\` 来连接两行的内容

```c
printf("This string is way too long \
to display in only one line...\n");
```

但上述方式会造成缩进的不美观, 所以还可以用 `"` 来连接字符串

```c
printf("This string is way too long "
       "to display in only one line...\n");
```

### 获取输入

C 标准库提供了多种获取输入的方式, 其中 `scanf()` 函数是最为常用的一个, 它能够将输入的字符转换为指定类型, 下面是一个获取整数和字符串输入的例子

```c
int number;
char name[20];
scanf("%d", &number);
scanf("%s", name);
```

注意 `scanf()` 函数在接收参数时, 对于一般的数据类型的变量, 需要附加 `&` 取址符, 而对于数组包括字符串则不需要取址符.

使用单个函数语句来接收多个数值的时候, 在输入时需要用空格将输入的多个值分隔开, 但如果要求输入的是字符类型的话, 则空格不会被忽略而是作为字符输入进去.

可用的占位符和修饰符如下表

![conversion specifiers](https://i.loli.net/2020/10/05/alHq2FumviNoL5E.png)


![modifiers](https://i.loli.net/2020/10/05/x4EDGwF9cb3aZ7d.png)

`scanf()` 函数的返回值是读取到的**有效的数据**的个数.

### 获取字符

对于获取和输出单一字符输入, 可以使用 `getchar()` 和 `putchar()` 函数, 等同于输入输出单一字符的 `scanf()` 和 `printf()`

```c
char ch;
ch = getchar();

scanf("%c", ch);
```

## 控制流程

### `while` 循环

基本形式为 `while (expression) statement`, 其中的语句既可以是单条以分号结尾的语句, 也可以是用大括号包围起来的复合语句, 下面的两个示例是等价的

```c
int num, status;
status = scanf("%d", &num);
while (status == 1) {
    // do something...
    status = scanf("%d", &num);
}

while (scanf("%d", &num) == 1) {
    // do something
}
```

每次循环开始都会执行圆括号中的表达式进行判定, 若其中的值为非零, 则执行后面的语句, 完成一次循环, 称作一次迭代 (_iteration_), 然后又进行下一次判定, 直到判定得到的值为零则终止循环.

### `for` 循环

基本形式为 `for (expressions) statement`, 观察下面例子, 圆括号中一共有三条表达式, 分别用于初始化计数变量的值, 设定循环进行的条件, 以及完成循环后对计数变量的操作, 该表达式会在每次循环结束后便执行, 然后再次进行条件判定.

```c
for (int i = 0; i <= 10; i++) {
    printf("%d", i);
}
```

初始化值和对改变变量的部分中可以有多条表达式, 用逗号隔开.

若括号中几个表达式都留空, 就像 `for (; ; )`, 会默认为真值而产生死循环, 等同于 `while (1)`. 类似地, `for ( ;condition; )` 其实等价于 `while (condition)`.

此外, 圆括号中的第一个表达式并非一定要初始化一个变量, 也可以是其它的表达式比如 `printf()` 函数, 该表达式只会在第一次循环开始前执行一次, 例如下面的例子

```c
int num = 0;

for (printf("Enter numbers!\n"); num != 0; ) {
    scanf("%d", &num);
}
```

### `do while` 循环

上面两种循环都是*进入式循环*, 即先判定条件, 若条件为真才开始循环. 而 `do while` 循环是一类*跳出式循环*, 即先开始循环, 每次循环后进行条件判断, 知道条件不为真才跳出循环. 基本形式为 `do statement while (expression);`.
