grammar NebulaCEP;


cep
   : (cepQuery)+ EOF
   ;

cepQuery
   : p (quantifier)? (optional)? (contiguity p (quantifier)? (optional)?)* (skipStrategy?)
   ;

p 
   : (FROM inputStream)?
	 PATTERN pStruc
	 (WHERE expressions )?
	 (WITHIN  slidingWindow )?
	 (HAVING  expression )?
	 (RETURN  expression )?

   ;

quantifier
	: TIMES? DECIMAL_LITERAL
  | TIMESPLUS? DECIMAL_LITERAL
	| TIMES '[' DECIMAL_LITERAL ',' DECIMAL_LITERAL ']'
	| UNTIL expression   
	;

optional
	: OPTIONAL 
	| GREEDY
	;

contiguity
	: (NOT)? NEXT
	| FOLLOWED_BY (ANY)?
	| NOT FOLLOWED_BY
	| CONSECUTIVE
	| COMBINATION
	;

skipStrategy
	: TO toStat
	| PAST LAST 
	;	

toStat
	: NEXT
	| FIRST
	| LAST
	;

inputStream
	: NAME
	;

pStruc
   :
   '(' listEvents ')'
   ;			



//    Expressions, predicates

expressions
    :  expression (',' expression)* 
    ;

// Simplified approach for expression
expression
    : LR_BRACKET expression RR_BRACKET                           #expressionInBrackets
    | notOperator=(NOT | '!') expression                            #notExpression
    | expression logicalOperator expression                         #logicalExpression
    | predicate IS NOT? testValue=(TRUE | FALSE | UNKNOWN)          #isExpression
    | predicate                                                     #predicateExpression
    ;  
 //predicates
 predicate
    : predicate NOT? IN '(' (pStruc | expressions) ')'     #inPredicate
    | predicate IS nullNotnull                                      #isNullPredicate
    | left=predicate comparisonOperator right=predicate #subqueryComparasionPredicate 
    | expressionAtom #regexpPredicate
    ;    
//sliding Windows
slidingWindow
   : '1' singularEntity
   | DECIMAL_LITERAL pluralEntity
   | TIME DOT pluralEntity LR_BRACKET DECIMAL_LITERAL RR_BRACKET
   ; 

singularEntity
   : HOUR
   | MINUTE 
   ;

pluralEntity
   : HOURS
   | MINUTES 
   ;   


listEvents
   : eventElem (',' eventElem)*
   ;

eventElem
   :  EVENT NAME 
   | '(' listEvents ')'
   ;   

// Add in ASTVisitor nullNotnull in constant
expressionAtom
    : constant                                                     #constantExpressionAtom
    | unaryOperator expressionAtom                                  #unaryExpressionAtom
    | BINARY expressionAtom                                         #binaryExpressionAtom
    | '(' expression (',' expression)* ')'                          #nestedExpressionAtom
    | left=expressionAtom bitOperator right=expressionAtom          #bitExpressionAtom
    | left=expressionAtom mathOperator right=expressionAtom         #mathExpressionAtom
    ;

constant
    : stringLiteral | decimalLiteral
    | '-' decimalLiteral
    | hexadecimalLiteral | booleanLiteral
    | REAL_LITERAL | BIT_STRING
    | NOT? nullLiteral=(NULL_LITERAL | NULL_SPEC_LITERAL)
    ;

stringLiteral
    : (
        STRING_CHARSET_NAME? STRING_LITERAL
        | START_NATIONAL_STRING_LITERAL
      ) STRING_LITERAL+
    | (
        STRING_CHARSET_NAME? STRING_LITERAL
        | START_NATIONAL_STRING_LITERAL
      ) 
    | NAME DOT NAME
    | NAME
    ;

decimalLiteral
    : DECIMAL_LITERAL | ZERO_DECIMAL | ONE_DECIMAL | TWO_DECIMAL
    ;

booleanLiteral
    : TRUE | FALSE;

hexadecimalLiteral
    : STRING_CHARSET_NAME? HEXADECIMAL_LITERAL;



logicalOperator
    : AND | '&' '&' | XOR | OR | '|' '|'
    ;   

comparisonOperator
    : '=' | '>' | '<' | '<' '=' | '>' '='
    | '<' '>' | '!' '=' | '<' '=' '>'
    ;

nullNotnull
    : NOT? (NULL_LITERAL | NULL_SPEC_LITERAL)
    ;

unaryOperator
    : '!' | '~' | '+' | '-' | NOT
    ;


bitOperator
    : '<' '<' | '>' '>' | '&' | '^' | '|'
    ;

mathOperator
    : '*' | '/' | '%' | DIV | MOD | '+' | '-' | '--'
    ;


 //KEYWORDs  
 FROM:                              'FROM';
 PATTERN:                           'PATTERN';
 WHERE:                             'WHERE';
 WITHIN:                            'WITHIN';
 HAVING:                            'HAVING';
 RETURN:                            'RETURN';
 TIMES:								'TIMES';
 UNTIL:								'UNTIL';
 OPTIONAL:							'OPTIONAL';
 GREEDY:							'GREEDY';
 NOT:								'NOT';
 NEXT:								'NEXT';
 FOLLOWED_BY:						'FOLLOWED_BY';
 ANY:								'ANY';
 CONSECUTIVE:						'CONSECUTIVE';
 COMBINATION:						'COMBINATION';
 TO:								'TO';
 PAST:								'PAST';
 LAST:								'LAST';
 FIRST:								'FIRST';
 UNKNOWN:             'UNKNOWN';
 FALSE:               'FALSE';
 TRUE:                'TRUE';
 NULL_LITERAL:                        'NULL';
NULL_SPEC_LITERAL:                   '\\' 'N';
REGEXP:                              'REGEXP';
TIMESPLUS :           'TIMES+';
DECIMAL_LITERAL:                     DEC_DIGIT+;
IS:                                  'IS';
IN:                                  'IN';
TIME:                   'TIME';
HOUR: 'HOUR';
MINUTE: 'MINUTE' ;
HOURS: 'HOURS';
MINUTES: 'MINUTES' ;
EVENT:'EVENT';
AND:'AND';
XOR: 'XOR' ;
OR : 'OR' ;
DIV:                                 'DIV';
MOD:                                 'MOD';



// Constructors symbols

DOT:                                 '.';
LR_BRACKET:                          '(';
RR_BRACKET:                          ')';
COMMA:                               ',';
SEMI:                                ';';
AT_SIGN:                             '@';
ZERO_DECIMAL:                        '0';
ONE_DECIMAL:                         '1';
TWO_DECIMAL:                         '2';
SINGLE_QUOTE_SYMB:                   '\'';
DOUBLE_QUOTE_SYMB:                   '"';
REVERSE_QUOTE_SYMB:                  '`';
COLON_SYMB:                          ':';
STRING_CHARSET_NAME:                 '_' NAME;
BIT_STRING:                          BIT_STRING_L;


// Fragments for Literal primitives

fragment EXPONENT_NUM_PART:          'E' [-+]? DEC_DIGIT+;
fragment ID_LITERAL:                 [A-Z_$0-9\u0080-\uFFFF]*?[A-Z_$\u0080-\uFFFF]+?[A-Z_$0-9\u0080-\uFFFF]*;
fragment DQUOTA_STRING:              '"' ( '\\'. | '""' | ~('"'| '\\') )* '"';
fragment SQUOTA_STRING:              '\'' ('\\'. | '\'\'' | ~('\'' | '\\'))* '\'';
fragment BQUOTA_STRING:              '`' ( '\\'. | '``' | ~('`'|'\\'))* '`';
fragment HEX_DIGIT:                  [0-9A-F];
fragment DEC_DIGIT:                  [0-9];
fragment BIT_STRING_L:               'B' '\'' [01]+ '\'';

START_NATIONAL_STRING_LITERAL:       'N' SQUOTA_STRING;
STRING_LITERAL:                      DQUOTA_STRING | SQUOTA_STRING | BQUOTA_STRING;
HEXADECIMAL_LITERAL:                 'X' '\'' (HEX_DIGIT HEX_DIGIT)+ '\''
                                     | '0X' HEX_DIGIT+;

REAL_LITERAL:                        (DEC_DIGIT+)? '.' DEC_DIGIT+
                                     | DEC_DIGIT+ '.' EXPONENT_NUM_PART
                                     | (DEC_DIGIT+)? '.' (DEC_DIGIT+ EXPONENT_NUM_PART)
                                     | DEC_DIGIT+ EXPONENT_NUM_PART;
BINARY:                              'BINARY';

// Charsets

ARMSCII8:                            'ARMSCII8';
ASCII:                               'ASCII';
BIG5:                                'BIG5';
CP1250:                              'CP1250';
CP1251:                              'CP1251';
CP1256:                              'CP1256';
CP1257:                              'CP1257';
CP850:                               'CP850';
CP852:                               'CP852';
CP866:                               'CP866';
CP932:                               'CP932';
DEC8:                                'DEC8';
EUCJPMS:                             'EUCJPMS';
EUCKR:                               'EUCKR';
GB2312:                              'GB2312';
GBK:                                 'GBK';
GEOSTD8:                             'GEOSTD8';
GREEK:                               'GREEK';
HEBREW:                              'HEBREW';
HP8:                                 'HP8';
KEYBCS2:                             'KEYBCS2';
KOI8R:                               'KOI8R';
KOI8U:                               'KOI8U';
LATIN1:                              'LATIN1';
LATIN2:                              'LATIN2';
LATIN5:                              'LATIN5';
LATIN7:                              'LATIN7';
MACCE:                               'MACCE';
MACROMAN:                            'MACROMAN';
SJIS:                                'SJIS';
SWE7:                                'SWE7';
TIS620:                              'TIS620';
UCS2:                                'UCS2';
UJIS:                                'UJIS';
UTF16:                               'UTF16';
UTF16LE:                             'UTF16LE';
UTF32:                               'UTF32';
UTF8:                                'UTF8';
UTF8MB3:                             'UTF8MB3';
UTF8MB4:                             'UTF8MB4';

NAME
   :
   ('a'..'z' | 'A'..'Z')+
   ;  


WS
   : [ \r\n\t]+ -> skip
   ;


CHARSTRING1
   : [a-zA-Z.]+
   ;
