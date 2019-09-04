## Description

*clang-refactor* is a small wrapper around [clang-refactor](https://clang.llvm.org/docs/RefactoringEngine.html) cli tool from clang extra tools for Emacs.

## Installation

### Install manually 

Clone the git repository.

Add this in your init.el:
``` emacs-lisp
(add-to-list 'load-path "<path-to-clang-refactor.el>")
(require 'clang-refactor)
```

## Customization

*clang-refactor* defines these variables that the user can tweak:

- `clang-refactor-binary`: path to `clang-refactor` executable.

## Usage

Now *clang-refactor* provides only one function `clang-refactor-extract-region`, which uses clang-refactor to extract the code in selected region.

## Contribute

All contributions are most welcome!

It might include any help: bug reports, questions on how to use it, feature suggestions, and documentation updates.

This is my first attempt on emacs-lisp code and I am glad to get some critique.

## Tributes

Many thanks to the authors of [clang-rename](https://github.com/llvm/llvm-project/blob/master/clang/tools/clang-rename/clang-rename.el) for inspiration and to the authors of clang-refactor cli tool.

## License

[GPL-3.0](./LICENSE)
