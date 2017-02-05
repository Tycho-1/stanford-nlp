#! /bin/bash

MIT_URL=https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/t8.shakespeare.txt

DATA_DIR=../data/shakespeare

TXT_WITH_LICENCE=$DATA_DIR/shakespeare_with_licence.txt
TXT_FINAL=$DATA_DIR/shakespeare.txt

START_LINE_NO=245

#curl $MIT_URL -o $TXT_WITH_LICENCE

# Remove header containing metadata, licencing info, etc.
tail -n +$START_LINE_NO $TXT_WITH_LICENCE > $TXT_FINAL

# Remove licence reminder in between works
sed -e '/^<<THIS ELECTRONIC/,/FOR MEMBERSHIP.>>$/d' -i "" $TXT_FINAL

# Find character prompts from plays, e.g.
#   COUNTESS. In delivering my son from me, ...
RE_CHARACTER_PROMPT='^[[:space:]]*[A-Z][A-Z]+\.'

# Find stage movement direction, e.g.
#   [Kneeling] or [Flourish. Exeunt]
RE_DIRECTION='\[.+\]'

# Find instructions to exit
# This fails to remove the second line of
#              Exeunt all but LAFEU and PAROLLES who stay behind,
#                                      commenting of this wedding
RE_EXIT='(  |<)(Exit|Exeunt)(.*[A-Z]+.*)?$'

# Find instructions to enter, e.g.
#   Enter SILVIUS and PHEBE
# or
#   Re-enter LUCIANA with a purse
# Won't find things similar to
#   Enter a MESSENGER, hastily
RE_ENTER='[Ee]nter [A-Z][A-Z]'

# Find shortened Act/Scene label e.g.
#   ACT_3|SC_1
RE_ACT_SCENE_SHORT='(ACT_|SC_).+$'

# Find the act/scene delimiter, e.g.
#   SCENE II.
#   Corioli. The Senate House.
RE_ACT_SCENE='^[[:space:]]*(ACT|SCENE)[^_]'

# The second command "/.../{N; d;}" doesn't delete all of
#   SCENE 4
#
#   A street
# Similarly, it doesn't delete all of
#       Enter VENTIDIUS, as it were in triumph, with SILIUS
#      and other Romans, OFFICERS and soldiers; the dead body
#                of PACORUS borne before him
# Also, it deletes
#                           Enter AENEAS  
#   Good morrow, lord, good morrow.
# where it shouldn't (the last line is spoken, not a direction)
sed -E \
    -e "s/($RE_CHARACTER_PROMPT)|($RE_DIRECTION)|($RE_EXIT)|($RE_ACT_SCENE_SHORT)//g" \
    -e "/($RE_ACT_SCENE)|($RE_ENTER)/{N; d;}" \
    $TXT_FINAL > $DATA_DIR/clean_shake.txt
