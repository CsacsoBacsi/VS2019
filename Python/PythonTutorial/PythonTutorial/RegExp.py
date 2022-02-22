# --------------------------------------------------------------------

import re
import os

# *** Matching chars ***
""" MetaCharacters: . ^ $ * + ? { } [ ] \ | ( )
Class [] or set of characters
[abc] or [a-c]
[abc$] $ is not special here!
[^5] complement. Any char but 5. [5^] has no meaning
[a-zA-Z0-9_] = \w

\d Matches any decimal digit; this is equivalent to the class [0-9].
\D Matches any non-digit character; this is equivalent to the class [^0-9].
\s Matches any whitespace character; this is equivalent to the class [ \t\n\r\f\v].
\S Matches any non-whitespace character; this is equivalent to the class [^ \t\n\r\f\v].
\w Matches any alphanumeric character; this is equivalent to the class [a-zA-Z0-9_].
\W Matches any non-alphanumeric character; this is equivalent to the class [^a-zA-Z0-9_].

Can be combined with classes: [\s,abc]
. matches any char except newline. re.DOTALL matches newline as well

"""
p = re.compile ('a[\S]*')
print ('a[\S]', p.search ('abcbd n')) # Matches till d. After d there is a space char
p = re.compile ('a[\D]*') # Non-decimal digits
print ('a[\D]', p.search ('abc5bd1n')) # Matches till c
p = re.compile ('a[^0-9]*') # Non-decimal digits
print ('a[^0-9]', p.search ('abc5bd1n')) # Matches till c. ^ in a set it means complement

# *** Repeating things ***
"""
* matches the previous char 0 or more times
ca*t will match 'ct' (0 'a' characters), 'cat' (1 'a'), 'caaat' (3 'a' characters)

* is greedy. Goes as far as it can.
a[bcd]*b tries to match 'abcbd'
'a' is matched against 'a' so it tries to match the next part of regexp: [bcd*]
It goes till the end because the letter 'd' matches [bcd*] but then it fails because regexp part 3 'b' does not match the string as the string is finished
So it back tracks. 'd' does not match 'b' so it back tracks again. Finally the regexp 'b' (last bit of the regexp) matches 'b'
"""

p = re.compile ('a[bcd]*b')
print (p.match ('abcbd')) # If matches from the beginning
print (p.match ('abcbd'))
# matches 'abcb'. Span: [0-4]

'''
+ matches previous char 1 or more times
ca+t will match 'cat' (1 'a'), 'caaat' (3 'a's), but won’t match 'ct'

? matches the previous char 0 or once. Means 'optional'
home-?brew matches either 'homebrew' or 'home-brew'.

{m,n} matches previous char at least m times but at most n times
a/{1,3}b will match 'a/b', 'a//b', and 'a///b'. It won’t match 'ab', which has no slashes, or 'a////b', which has four
'''

'''
Backslash in regexp is '\\' but Python also requires escaping so '\\\\' is required to match a sinle '\'
or use 'r' meaning raw string
'''
# --------------------------------------------------------------------

'''
match() Determine if the RE matches at the beginning of the string.
search() Scan through a string, looking for any location where this RE matches.
findall() Find all substrings where the RE matches, and returns them as a list.
finditer() Find all substrings where the RE matches, and returns them as an iterator.
'''
p = re.compile ('[bcd]*b')
print (p.match ('abcbdabmbertdb')) # None as it has to start with 'a'
print (p.findall ('abcbdabmbertdb')) # bcb b b db as it is match 0 or more times
print (p.search ('abcbdabmbertdb')) # bcb first occurrence
m = p.search ('abcbdabmbertdb') 
print ('')
print ("Group:", m.group (), "Start:", m.start (), "End:", m.end (), "Span:", m.span ())
print ('-')
p = re.compile ('[bcd]+b')
print (p.match ('abcbdabmbertdb')) # None as it has to start with 'a'
print (p.findall ('abcbdabmbertdb')) # bcb db as it has to match at least once
print (p.search ('abcbdabmbertdb')) # bcb first occurrence
m = p.search ('abcbdabmbertdb') 
print ('')
print ("Group:", m.group (), "Start:", m.start (), "End:", m.end (), "Span:", m.span ())

if m:
    print ("Match found!")
else:
    print ("No match")

print (re.match ('[bcd]+b', 'abcbdabmbertdb')) # Implicit compilation and calls the function. No need for pattern object
p = re.compile ('a[bcd]+b', re.IGNORECASE) # Compilation flags. MULTILINE affects ^ and $ as they are applied after each newline
print (p.match ('ABCBDBMBERTDB'))

# --------------------------------------------------------------------

# More metacharacters
# | is the OR operator 
print (re.findall ('a|b', 'karbon'))
# ^ at the beginning
print (re.findall ('^(abs|bra)', 'absolute'))
print (re.findall ('^(abs|bra)', 'brass'))
# $ at the end
print (re.findall ('(abs|bra)$', 'pre-abs'))
print (re.findall ('(abs|bra)$', 'abra'))
print (re.findall ('(abs|bra)$', 'abrak'))

# --------------------------------------------------------------------

# Search and replace
p = re.compile('(blue|white|red)')
cc = p.sub ('colour', 'blue socks and red shoes')

p = re.compile (r'^(create.+table).+udm\.')
m = p.search ('create  table  udm.claims as (')
if m:
    p = re.compile (r'udm\.')
    newline = p.sub ('ProjectName.', 'create table udm.claims as (')
    print (newline)
else:
    print ("No match!")

#os.system ("pause")
# exit ()

# Greedy vs non-greedy
# Greedy goes as far as it can
s = '<html><head><title>Title</title>'
print (re.match('<.*>', s).span()) # (0, 32) goes all the way. <html>'s first < and </title>'s >
print (re.match('<.*?>', s).group()) # returns <html> Stops as early as it can

# Practice
print (re.search ('abcm*y', 'abcy')) # abcy
print (re.search ('abc[opk*]y', 'abcy')) # None. Tries abc, any of op zero or more times k* then y. op can not be found!
print (re.search ('abc[opky]*y', 'abcpypyoy')) # abcy. Tries abc, any of opk zero or more times then y
print (re.search ('abc(opk)*y', 'abcpy')) # abcy. Tries abc, the word (group) opk zero or more times then y
print (re.search ('a[bcd]*b', 'abcbd')) # abcb. Starts with a, any of bcd zero or more times. Finds d at the end as it is greedy. Backtracks and finds b
print (re.search ('a[bcd]', 'abcbd')) # ab. Starts with a, any of bcd. Finds b and stops. Non-greedy
print (re.search ('a[bcd]d', 'abcbd')) # None. Starts with a, any of bcd finds b then d but there is a c after b
print (re.search ('a[bcd]d', 'abdbd')) # abd. Starts with a, any of bcd. Finds b then d. Non-greedy

# --------------------------------------------------------------------

# Replace strings in a file

fin = open ("inputfile.txt", "rt")
fout = open ("outfile.txt", "wt")
p1 = re.compile (r'^(create.+table).+udm\.')
p2 = re.compile (r'varchar')
p3 = re.compile (r'integer')
for line in fin:
    m1 = p1.search (line)
    m2 = p2.search (line)
    m3 = p3.search (line)
    if m1:
        p1 = re.compile (r'udm\.')
        line = p1.sub ('ProjectName', line)
    else:
        line = line
    if m2:
        p2 = re.compile (r'varchar.*?,|varchar.*?\n')
        line = p2.sub ('string,', line)
    else:
        line = line
    if m3:
        p3 = re.compile (r'integer,|integer')
        line = p3.sub ('int64', line)
    else:
        line = line
    fout.write (line)

fin.close()
fout.close()

# --------------------------------------------------------------------

api_url = 'https://aventri.com/v2/ereg/listEvents/?accesstoken=a547f5deA32CA8013Ab849faB90&lastmodified-gt=2022-02-15&limit=1' # First param
api_url2 = 'https://aventri.com/v2/ereg/listEvents/?lastmodified-gt=2022-02-15&limit=1&accesstoken=a547f5deA32CA8013Ab849faB90&offset=100' # Middle param
api_url3 = 'https://aventri.com/v2/ereg/listEvents/?accesstoken=a547f5deA32CA8013Ab849faB90' # Only param
api_url4 = 'https://aventri.com/v2/ereg/listEvents/?lastmodified-gt=2022-02-15&limit=1&accesstoken=a547f5deA32CA8013Ab849faB90' # Last param

s = re.sub (r"accesstoken=([a-zA-Z0-9])+", r"*at*", api_url, count=1).replace ("*at*", "accesstoken=***Access token***")
s2 = re.sub (r"accesstoken=([a-zA-Z0-9])+", r"*at*", api_url2, count=1).replace ("*at*", "accesstoken=***Access token***")
s3 = re.sub (r"accesstoken=([a-zA-Z0-9])+", r"*at**", api_url3, count=1).replace ("*at*", "accesstoken=***Access token***")
s4 = re.sub (r"accesstoken=([a-zA-Z0-9])+", r"*at*", api_url4, count=1).replace ("*at*", "accesstoken=***Access token***")
print (s)

pattern = r"Cook"
sequence = "Cookie"
if re.match (pattern, sequence):
    print ("Match!")
else: print ("Not a match!")

s = re.search (r'Co.k.e', 'Cookie').group () # Without group it is just a match object!
s = re.search (r'^Eat', "Eat cake!").group () # Match at the beginning of the string
s= re.search (r'cake$', "Cake! Let's eat cake").group () # Match at the end
# group () without parameters is the whole matched string

s = re.search (r'[0-6]', 'Number: 5').group () # 5
s = re.search (r'[abc]', 'x-ray').group () # a

s = re.search(r'Not a\sregular character', 'Not a regular character').group () # \ = escaping. \s = space char

'''
Character(s)	What it does
.	A period. Matches any single character except the newline character.
^	A caret. Matches a pattern at the start of the string.
\A	Uppercase A. Matches only at the start of the string.
$	Dollar sign. Matches the end of the string.
\Z	Uppercase Z. Matches only at the end of the string.
[ ]	Matches the set of characters you specify within it.
\	∙ If the character following the backslash is a recognized escape character, then the special meaning of the term is taken.
∙ Else the backslash () is treated like any other character and passed through.
∙ It can be used in front of all the metacharacters to remove their special meaning.
\w	Lowercase w. Matches any single letter, digit, or underscore.
\W	Uppercase W. Matches any character not part of \w (lowercase w).
\s	Lowercase s. Matches a single whitespace character like: space, newline, tab, return.
\S	Uppercase S. Matches any character not part of \s (lowercase s).
\d	Lowercase d. Matches decimal digit 0-9.
\D	Uppercase D. Matches any character that is not a decimal digit.
\t	Lowercase t. Matches tab.
\n	Lowercase n. Matches newline.
\r	Lowercase r. Matches return.
\b	Lowercase b. Matches only the beginning or end of the word.
+	Checks if the preceding character appears one or more times.
*	Checks if the preceding character appears zero or more times.
?	∙ Checks if the preceding character appears exactly zero or one time.
∙ Specifies a non-greedy version of +, *
{ }	Checks for an explicit number of times.
( )	Creates a group when performing matches.
< >	Creates a named group when performing matches.
'''

# --------------------------------------------------------------------

os.system ("pause")
