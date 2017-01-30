#! /bin/bash

MIT_URL=https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/t8.shakespeare.txt

TXT_WITH_LICENCE=../data/shakespeare/shakespeare_with_licence.txt
TXT_FINAL=../data/shakespeare/shakespeare.txt

START_LINE_NO=245

curl $MIT_URL -o $TXT_WITH_LICENCE
tail -n +$START_LINE_NO $TXT_WITH_LICENCE > $TXT_FINAL
