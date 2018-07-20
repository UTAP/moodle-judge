Judge Script for [Moodle](https://moodle.org/)-uploaded Codes

## Usage

### Set-up
You should set up some parameters before using this judge.
* `EXE`: name of executable file made after compiling the codes
* `COMPILER`: compile command  
You may use `$EXE` in the command.
* `VERBOSE`: boolean variable to show verbose diff using `VERBOSE_DIFF_TOOL` on test failure
* `DEST_DIR`: path to extract downloaded zip from moodle (See below)
* `TEMP_DIR`: path to save outputs of compiled codes
* `INPUT_DIR`: path to read inputs of test-cases
* `SOL_DIR`: path to correct solutions of test-cases
* `JUDGE_DIR`: path to special judges (See below)
* `INPUT_EXT`: extension of inputs of test-cases
* `SOL_EXT`: extension of correct solutions of compiled codes
* `OUT_EXT`: extension of outputs of compiled codes
* `JUDGE_EXT`: extension of special judges
* `CODE_ADDR`: address of code to judge  
Default is `$2` for second argument.
* `TIME_LIM`: time limit for each test-case
* `VERBOSE_DIFF_TOOL`: difftool to use on test failure when `VERBOSE` is `true`
* `DIFF_TOOL`: normal difftool to judge the answers
* `HAS_SPECIAL_JUDGE`: array of _question_name_‌s with special judge

For example, for default parameters, there should be a folder structure like:

    .
    ├── data
    │   ├── 0
    │   │   ├── 1.in
    │   │   ├── 1.sol
    │   │   ├── 2.in
    │   │   ├── 2.sol
    │   ├── 1
    │   │   ├── 01.in
    │   │   ├── 01.sol
    │   ├── 1.judge
    ├── judge.sh
    └── temp

### Special Judge
It's possible to use custom special judge instead of simple diff to judge the codes; e.g. in situations which there is many correct solutions.

Special judge should be an executable file which can be run like:
```bash
./judge <output_file> <solution_file>
```
It should return (**not** print) `0` on _Accept_ and `1` or any more-than-zero exit code on _Wrong Answer_. It should has got `$JUDGE_EXT` extension and should be on path `$JUDGE_DIR`.  
Remember that in this case, _solution_file_ can be any file, not necessarily a correct answer.

Remember to add _question_name_ to `HAS_SPECIAL_JUDGE` to use special judge instead of `$DIFF_TOOL`.

### Commands

* show help
```bash
./judge.sh -h
./judge.sh --help
```

* unzip the file which is downloaded by _Download all submissions_ button from Moodle _Assignment_
```bash
./judge.sh -u <codes_archive_addr>
./judge.sh --unzip <codes_archive_addr>
```

* judge the code
```bash
./judge.sh <question_name> <code_file>
```

## Contribution

Please see [contribution guide](CONTRIBUTING.md) to contribute to this project.
