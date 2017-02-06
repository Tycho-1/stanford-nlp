#! /bin/bash

MIT_URL=https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/t8.shakespeare.txt

RAW=./raw_shakespeare.txt
RAW_NO_LICENCE=./raw_no_licence_shakespeare.txt
CLEAN=./clean_shakespeare.txt

START_LINE_NO=245

curl $MIT_URL -o $RAW

# Remove header containing metadata, licencing info, etc.
tail -n +$START_LINE_NO $RAW > $RAW_NO_LICENCE

# Remove licence reminder in between works
sed -e '/^<<THIS ELECTRONIC/,/FOR MEMBERSHIP.>>$/d' -i "" $RAW_NO_LICENCE

# Find character prompts from plays, e.g.
#   COUNTESS. In delivering my son from me, ...
RE_CHARACTER_PROMPT='^[[:space:]]*[A-Z][A-Z]+[A-Z ]*\.'

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
# It doesn't find this one bad example:
#                       INDUCTION. SCENE I.
RE_ACT_SCENE='^[[:space:]]*(ACT|SCENE|Act|Scene)[^_a-z]'

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
#
# NOTE: If swapping order of commands, check that you don't break anything
sed -E \
    -e "/($RE_ACT_SCENE)|($RE_ENTER)/{N; d;}" \
    -e "s/($RE_CHARACTER_PROMPT)|($RE_DIRECTION)|($RE_EXIT)|($RE_ACT_SCENE_SHORT)//g" \
    $RAW_NO_LICENCE > $CLEAN
