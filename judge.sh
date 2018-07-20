#!/usr/bin/env bash

EXE=a.out
COMPILER="g++ -o $EXE"
VERBOSE=true
DEST_DIR="codes"
TEMP_DIR="temp"
INPUT_DIR="data"
SOL_DIR="data"
JUDGE_DIR="data"
INPUT_EXT="in"
SOL_EXT="sol"
OUT_EXT="out"
JUDGE_EXT="judge"
CODE_ADDR=$2
TIME_LIM=10s
VERBOSE_DIFF_TOOL="sdiff -sWiw 60"
DIFF_TOOL="sdiff -sWi"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
B="\033[1;4m"
NC="\033[0m"

INPUT_DIR=$(readlink -f "$INPUT_DIR")
SOL_DIR=$(readlink -f "$SOL_DIR")
JUDGE_DIR=$(readlink -f "$JUDGE_DIR")
CODE_ADDR=$(readlink -f "$CODE_ADDR")

HAS_SPECIAL_JUDGE=()

if [[ $1 == "--unzip" ]] || [[ $1 == "-u" ]]; then
    if [[ -e "$DEST_DIR" ]]; then
        echo -e "${B}$DEST_DIR${NC} already existed."
        rm -rI "$DEST_DIR"
    fi
    unzip "$2" -d "$DEST_DIR" > /dev/null
    pushd "$DEST_DIR" > /dev/null
    rm -rf *_onlinetext_
    for f in *; do
        mv "$f" "`echo ${f/_*_assignsubmission_file_/}`"
    done
    for f in **/*.zip; do
        pushd "`dirname "$f"`" > /dev/null
        unzip "`basename "$f"`" > /dev/null && rm "`basename "$f"`"
        popd > /dev/null
    done
    rm -rf **/__MACOSX 2> /dev/null
    rm -rf **/.DS_Store 2> /dev/null
    find . -name *.out -delete
    find . -name *.o -delete
    popd > /dev/null
    echo -e "$PWD/${B}$DEST_DIR${NC} ("$(ls "$DEST_DIR" | wc -l)")"

elif [[ $1 == "--help" ]] || [[ $1 == "-h" ]] || [[ $# != 2 ]]; then
    echo "usage:"
    echo -e "\t$0 --help|-h"
    echo -e "\t$0 --unzip|-u <codes_archive_addr>"
    echo -e "\t$0 <question_name> <code_file>"

else
    if [[ ! -e $TEMP_DIR ]]; then
        mkdir $TEMP_DIR
    fi

    pushd "$TEMP_DIR" > /dev/null
    rm * 2> /dev/null
    passed=0
    failed=0
    compiled=true
    echo -e "\n${YELLOW}Compiling...${NC}"
    if ! $COMPILER "$CODE_ADDR"; then
        echo -e "${RED}Compile Error${NC}"
        compiled=false
        failed=$(ls "$INPUT_DIR/$1/"*".$INPUT_EXT" | wc -l)
    else
        echo -e "${GREEN}Compiled!${NC}"
        echo -e "\n${YELLOW}Running...${NC}"
        for input in "$INPUT_DIR/$1/"*".$INPUT_EXT"; do
            test_case="$(basename "$input")"
            test_case="${test_case/.$INPUT_EXT/}"
            sol="$SOL_DIR/$1/$test_case.$SOL_EXT"
            judge="$JUDGE_DIR/$1.$JUDGE_EXT"
            output="$test_case.$OUT_EXT"
            printf "Testcase $test_case: "
            if timeout $TIME_LIM ./$EXE < "`echo $input`" > "$output"; then
                if [[ " ${HAS_SPECIAL_JUDGE[*]} " == *" $1 "* ]]; then
                    if "$judge" "$output" "$sol"; then
                        echo -e "${GREEN}Accepted${NC}"
                        ((passed+=1))
                    else
                        echo -e "${RED}Wrong Answer${NC}"
                        ((failed+=1))
                    fi
                else
                    if $DIFF_TOOL "$output" "$sol" > /dev/null; then
                        echo -e "${GREEN}Accepted${NC}"
                        ((passed+=1))
                    else
                        echo -e "${RED}Wrong Answer${NC}"
                        if $VERBOSE; then
                            printf "%28s | %28s\n" "< $output" "> $sol"
                            $VERBOSE_DIFF_TOOL "$output" "$sol"
                        fi
                        ((failed+=1))
                    fi
                fi
            else
                echo -e "${RED}Timed out${NC}"
                ((failed+=1))
            fi
        done
    fi
    echo -e "\n${YELLOW}Report${NC}"
    echo -e "Question: $1"
    printf "Code: $2 (compiled: %b)\n" $compiled
    echo -e "Passed:\t${GREEN}$passed${NC} out of $((passed + failed))"
    echo -e "Failed:\t${RED}$failed${NC} out of $((passed + failed))"
    popd  > /dev/null

fi
