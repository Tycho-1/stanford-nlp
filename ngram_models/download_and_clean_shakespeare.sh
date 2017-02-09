#! /bin/bash

MIT_URL=https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/t8.shakespeare.txt

RAW=./raw_shakespeare.txt
RAW_NO_LICENCE=./plays_no_licence.txt
CLEAN=./clean_plays.txt
SENTENCES=./sentences.txt
FINAL=./words.txt

# Line of the first play, ALLS WELL THAT ENDS WELL
START_LINE_NO=2886

curl $MIT_URL -o $RAW

# Remove header containing metadata, licencing info, etc. and Sonnets
tail -n +$START_LINE_NO $RAW > $RAW_NO_LICENCE

# Remove licence reminder in between works
sed -e '/^<<THIS ELECTRONIC/,/FOR MEMBERSHIP.>>$/d' -i "" $RAW_NO_LICENCE

# Find character prompts from plays, e.g.
#   COUNTESS. In delivering my son from me, ...
RE_CHARACTER_PROMPT='^[[:space:]]*[A-Z][A-Z]+[A-Z ]*\.'
RE_KING_LEAR_PROMPT='^  (Corn|Glou|Reg|Kent|Lear|Fool|Edg|Edm|Gent|Gon|Osw|Alb|Knight|Bur|France|Old Man)\.'
RE_HAMLET_PROMPT='^  (Ber|Fran|Hor|Mar|King|Pol|Ham|Queen|All|Laer|Oph|Ghost|Both|Rey|Ros|Guil|Volt|Player|Capt|Mess|Servant|Sailor|Clown|Other|Priest|Osr|Fort|Ambassador)\.'

# Find stage movement direction, e.g.
#   [Kneeling] or [Flourish. Exeunt]
RE_DIRECTION='\[.+\]'

# Find instructions to exit
# This fails to remove the second line of
#              Exeunt all but LAFEU and PAROLLES who stay behind,
#                                      commenting of this wedding
RE_EXIT='(  |<)(Exit|Exeunt)(.*[A-Z]+.*)?\.?$'

# Find instructions to enter, e.g.
#   Enter SILVIUS and PHEBE
# or
#   Re-enter LUCIANA with a purse
# Won't find things similar to
#   Enter a MESSENGER, hastily
# or
#   Enter a Doctor.
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

CONTRACTION=+

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
    -e "s/($RE_CHARACTER_PROMPT)|($RE_KING_LEAR_PROMPT)|($RE_HAMLET_PROMPT)|($RE_DIRECTION)|($RE_EXIT)|($RE_ACT_SCENE_SHORT)//g" \
    -e "s/([A-Za-z])'([A-Za-z])/\1$CONTRACTION\2/g" \
    $RAW_NO_LICENCE > $CLEAN

# Sentence delimiter
END_SENT=*

sed -E \
    -e "s/[.!?]$/ $END_SENT/g" \
    -e "s/[.!?][[:space:]]/ $END_SENT /g" \
    -e "s/\.'/ $END_SENT'/g" \
    $CLEAN > $SENTENCES

tr -c -s "A-Za-z$CONTRACTION$END_SENT" '\n' < $SENTENCES | tr 'A-Z' 'a-z' > $FINAL

rm $RAW $RAW_NO_LICENCE $CLEAN $SENTENCES
