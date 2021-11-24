---
title: "All About the Tar Ball in Linux"
date: 2021-03-31
desc: "How to use tar command to create archive files in linux"
tags: ["linux", "command-line"]
---

## Create `tar` Archive File

```bash
$ tar -cvf xxx.tar /path/to/your/files
```

**Options**:

- **c**: crate a new tar file
- **v**: verbosely display info
- **f**: specify the file name


## Create Compressed Archive File


```bash
$ tar -cvzf xxx.tar.gz /path/to/your/files
```

Use option `z` to create a compressed gzip archive file, and option `j` for bzip2 archive.

## Extract Files from a Tar Ball

```bash
$ tar -xvf xxx.tar
$ tar -xvf xxx.tar -C /path/to/yout/dir/
```

Use option `x` to extract files from a tar ball, files will be extracted to the current directory.

Use option `-C` to specify the target directory.

Also works for compressed archives.

## List Content of a Tar Ball


```bash
$ tar -tvf xxx.tar
```

Use option `t` to list the content of a tar ball.

Also works for compressed archives.

## Extract Specific Files from a Tar Ball

```bash
$ tar -xvf xxx.tar target1.txt target2.txt
```

Additional option `z` for extracting from a gzip archive is needed.

```bash
$ tar -zxvf xxx.tar.gz --wildcards '*.txt'
```

Use `--wildcards` option for wildcards support.

## Append Files to a Tar Ball

```bash
$ tar -rvf xxx.tar file.txt
```

Use option `r` to append files or directories to a tar archive file.

Notice that appending files to a compressed archive is not supported.

