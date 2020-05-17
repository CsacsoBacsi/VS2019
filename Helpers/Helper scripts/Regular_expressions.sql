-- Regular expressions

-- **********************
-- Simple match anywhere
-- **********************
SELECT REGEXP_INSTR ('Csaba', 'b') 
FROM   DUAL ; -- matches at 4

SELECT REGEXP_INSTR ('Csaba 123', 'a 1')
FROM   DUAL ; -- matches at 5

-- **********************
-- * - zero or more times
-- **********************
SELECT REGEXP_INSTR ('Csaba', 'x*') 
FROM   DUAL ; -- x could not be found, but it is allowed not be found so 1

SELECT REGEXP_INSTR ('Csaba', 'a*') 
FROM   DUAL ; -- a can be found, but it is allowed not be found so 1

SELECT REGEXP_INSTR ('1234567', '4*6') 
FROM   DUAL ; -- at 5, it is zero hit so moves on to 6

SELECT REGEXP_INSTR ('1234567', '9*6') 
FROM   DUAL ; -- up to 6 it is zero hit so moves on to 6

SELECT REGEXP_INSTR ('1234567', '6*?6') 
FROM   DUAL ; -- 6 followed by 6. The first 6 is treated as 0 match followed by 6 so it is 6
-- Well, it should then be 5 should not it?

SELECT REGEXP_REPLACE ('1234537', '4*4', ':') 
FROM   DUAL ; -- Replaces 4 with : Not sure why.

-- **********************
-- + - 1 or more times
-- **********************
SELECT REGEXP_INSTR ('1234567', '6+6') 
FROM   DUAL ; -- 6 followed by 6 so it is 0. Can not find match

SELECT REGEXP_INSTR ('12334567', '3+4') 
FROM   DUAL ; -- one or more 3s followed by 4 so it is 3. Match found

SELECT REGEXP_INSTR ('12334567', '3+3') 
FROM   DUAL ; -- one or more 3s followed by 3 so it is 3. Match found

SELECT REGEXP_INSTR ('1233453367', '3+3') 
FROM   DUAL ; -- one or more 3s followed by 3 so it is 3. Match found at its earliest

SELECT REGEXP_INSTR ('1234537', '4+4') 
FROM   DUAL ; -- 4 followed by 4 results in no match so 0

-- **********************
-- ? - 0 or 1 time
-- **********************
SELECT REGEXP_INSTR ('1233453367', '9?') 
FROM   DUAL ; -- matched 0 times at the first char

SELECT REGEXP_INSTR ('1233453367', '3?') 
FROM   DUAL ; -- matched 0 times at the first char

SELECT REGEXP_INSTR ('1234567', '3?3') 
FROM   DUAL ; -- matched 0 times at the first occurrence of 3 just to satisfy criteria of 3 after
-- not sure about it though...

-- **********************
-- . - any character
-- **********************
SELECT REGEXP_INSTR ('1234567', '3.3') 
FROM   DUAL ; -- 3 followed by any char followed by 3 can not be matched so 0

SELECT REGEXP_INSTR ('1234567', '3.5') 
FROM   DUAL ; -- matched at position 3

SELECT REGEXP_INSTR ('1234567', '3.4') 
FROM   DUAL ; -- no match. There must be a char between 3 and 4

SELECT REGEXP_INSTR ('1234567', '3.?4') 
FROM   DUAL ; -- there can be a char between 3 and 4, so match at 3

SELECT REGEXP_INSTR ('12345347', '.*4') 
FROM   DUAL ; -- any char any times somewhere followed by a 4 is match at 1

SELECT REGEXP_SUBSTR ('12345347', '.*4') 
FROM   DUAL ; -- here we can see greediness. The match encompasses the two 4s

SELECT REGEXP_SUBSTR ('12345347', '.*?4') 
FROM   DUAL ; -- here we can see non-greediness. The match encompasses the first 4 only

SELECT REGEXP_INSTR ('12345347', '.?.4') 
FROM   DUAL ; -- any char followed by zero or any char followed by 4 is match at 2

SELECT REGEXP_SUBSTR ('12345347', '.*?', 1) 
FROM   DUAL ; -- results in an empty string (possibly because of non-greediness. * is lazy and finds zero match)
-- but this
SELECT REGEXP_INSTR ('12345347', '.*?') 
FROM   DUAL ; -- results in a match at 1. What is going on????? Lazy * matches 0 times

SELECT REGEXP_SUBSTR ('12345347', '.*') 
FROM   DUAL ; 

SELECT REGEXP_REPLACE ('12345347', '.*', ':') 
FROM   DUAL ; -- Huhh, this is now beyond my comprehension.... Why two colons?

-- **********************
-- | - alternativ matches (means OR)
-- **********************
SELECT REGEXP_INSTR ('12345347', '4|5+2') 
FROM   DUAL ; -- 4 or 5 followed by 2 matches 4

SELECT REGEXP_INSTR ('12345347', '(4|5)+2') 
FROM   DUAL ; -- (4 or 5) followed by 2 matches 0

SELECT REGEXP_INSTR ('12345347', '(2|5)+3') 
FROM   DUAL ; -- (2 or 5) followed by 3 matches at 2

SELECT REGEXP_SUBSTR ('12345347', '(2|5)+3') 
FROM   DUAL ; -- (2 or 5) followed by 3 matches at 2

SELECT REGEXP_REPLACE ('csaaba', 'a+a+', ':') 
FROM   DUAL ;

-- **********************
-- ^ - matches at the beginning
-- **********************

SELECT REGEXP_INSTR ('cs ba cs baba', '(ba)*') 
FROM   DUAL ;

SELECT REGEXP_SUBSTR ('cs ba cs baba', '.*(ba)*') 
FROM   DUAL ; -- Greedy goes till the end

SELECT REGEXP_SUBSTR ('xx cs ba cs baba', '(cs)+.*(cs)+') 
FROM   DUAL ; -- Matches at 4 and the whole string

SELECT REGEXP_SUBSTR ('xx cs ba cs baba', '^(cs)+.*(cs)+') 
FROM   DUAL ; -- Matches at 0 because it starts with xx

-- **********************
-- $ - matches at the end
-- **********************
SELECT REGEXP_SUBSTR ('xx cs ba cs baba', '(ba)+$') 
FROM   DUAL ; -- Matches at 13. ba 1 or more times at the end of the string

-- **********************
-- [] - matching list
-- **********************
SELECT REGEXP_SUBSTR ('xx cs ba cs baba', '[A-Z]') 
FROM   DUAL ; -- Can't find uppercase letters

SELECT REGEXP_SUBSTR ('xx cs bA cs baba', '[A-Z]') 
FROM   DUAL ; -- Now it can

SELECT REGEXP_SUBSTR ('xx cs bA cs baba', '([a-z]|\s)+') 
FROM   DUAL ; -- Lowercase chars followed by space. Finds everything from beginning till 'A'

SELECT REGEXP_SUBSTR ('sdsd12345676879', '[a-z | 0-9]*')
FROM   DUAL ; -- * is greedy, so everything

SELECT REGEXP_SUBSTR ('sdsd12345676879', '[a-z | 0-9]*?')
FROM   DUAL ; -- Lazy, so zero matches, but at position 1

SELECT REGEXP_INSTR ('sdsd12345676879', '[a-z | 0-9]*?')
FROM   DUAL ;

SELECT REGEXP_INSTR ('sdsd12345676879', '[^a-z]')
FROM   DUAL ; -- First non-matching alpha char, so matching numbers. Matches at 5

-- **********************
-- {m,n} - matches at least m but no more than n times
-- **********************

SELECT REGEXP_INSTR ('aabbbzzzzbbbbbyyyy', 'b{4,6}')
FROM   DUAL ; -- Matches at 10 and not at 3

-- **********************
-- POSIX character classes
-- **********************
-- Double bracket required
SELECT REGEXP_INSTR ('aabbbzzzzbbbbbyyyy', '[[:alnum:]]')
FROM   DUAL ; -- Matches at 1 as it is alphanumeric

SELECT REGEXP_INSTR ('  ', '[[:alnum:]]')
FROM   DUAL ; -- No matches, as it is spaces

SELECT REGEXP_INSTR ('123abc', '[[:alpha:]]')
FROM   DUAL ; -- Matches at 4. The first alpha char


SELECT REGEXP_INSTR ('Fdf fg', '[[:upper:]]|[[:blank:]]')
FROM   DUAL ; -- Matches at 1, as it is uppercase

SELECT REGEXP_INSTR ('Fdf fg', '[[:blank:]]')
FROM   DUAL ; -- Matches at 4, as it is a space (could be tab as well)

SELECT REGEXP_INSTR ('Fdf7fg', '[[:digit:]]')
FROM   DUAL ; -- Matches at 4, as it is a digit

-- Punctuation chars: ! " # $ % & ' ( ) * + , \ -. / : ; < = > ? @ [ ] ^ _ ` { | }
SELECT REGEXP_INSTR ('Fdf7f?g', '[[:punct:]]')
FROM   DUAL ; -- Matches at 6, as it is a punctuation char

SELECT REGEXP_INSTR ('12345', '3-1')
FROM DUAL ;
