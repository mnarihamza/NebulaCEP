grammar NesCEPSimp;


cep
   : cepQuery+ EOF
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
	: TIMES? INT
    | TIMESPLUS? INT
	| TIMES '[' INT COMMA INT ']'
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
   LR_BRACKET listEvents RR_BRACKET
   ;			

//    Expressions, predicates

expressions
    : LR_BRACKET expression (COMMA expression)* RR_BRACKET
    ;

// Simplified approach for expression
expression
    : NAME
    ;

//sliding Windows
slidingWindow
   : ONE_DECIMAL singularEntity
   | INT pluralEntity
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
   : eventElem (COMMA eventElem)*
   ;

eventElem
   :  EVENT NAME 
   | '(' listEvents ')'
   ;          


WS
   : [ \r\n\t]+ -> skip
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
GREEDY:							    'GREEDY';
NOT:								'NOT';
NEXT:								'NEXT';
FOLLOWED_BY:						'FOLLOWED_BY';
ANY:								'ANY';
CONSECUTIVE:						'CONSECUTIVE';
COMBINATION:						'COMBINATION';
TO:								    'TO';
PAST:								'PAST';
LAST:								'LAST';
FIRST:								'FIRST';
TIMESPLUS :           				'TIMES+';
HOUR:								'HOUR';
HOURS:								'HOURS';
MINUTE:					            'MINUTE';
MINUTES:							'MINUTES';
EVENT:								'EVENT';

 // Constructors symbols
LR_BRACKET:                          '(';
RR_BRACKET:                          ')';
COMMA:                               ',';
ONE_DECIMAL:                         '1';

NAME
   :
   ('a'..'z' | 'A'..'Z')+
   ;    

INT
   : ('0'..'9')+
   ;