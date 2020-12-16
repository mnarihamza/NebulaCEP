grammar NebulaCEP;


cep
   : CEPQuery+ EOF
   ;

CEPQuery
   : p (quantifier)? (option)? 
   (contiguity p (quantifier)? (option)?)* (skipStrategy?)
   ;

p 
   : (FROM inputStream)?
	 PATTERN pStruc
	 (WHERE expressions )?
	 (WITHIN  slidingWindow )?
	 (HAVING  patternFilteringCondition )?
	 (RETURN  outputSpecification )?

   ;

quantifier
	: TIMES(+)? INT
	| TIMES [INT , INT]
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
	: PAST LAST 
	;	

toStat
	: NEXT
	| FIRST
	| LAST
	;

inputStream
	: CHARSTRING1
	;

pStruc
   :
   ( listEvents )
   ;			



//    Expressions, predicates

expressions
    : expression (',' expression)*
    ;

// Simplified approach for expression
expression
    : notOperator=(NOT | '!') expression                            #notExpression
    | expression logicalOperator expression                         #logicalExpression
    | predicate ******* current level of progress ******** IS NOT? testValue=(TRUE | FALSE | UNKNOWN)          #isExpression
    | predicate                                                     #predicateExpression
    ;  
 //predicates
 predicate
    : predicate NOT? IN '(' (selectStatement | expressions) ')'     #inPredicate
    | predicate IS nullNotnull                                      #isNullPredicate
    | left=predicate comparisonOperator right=predicate             #binaryComparasionPredicate
    | predicate comparisonOperator
      quantifier=(ALL | ANY | SOME) '(' selectStatement ')'         #subqueryComparasionPredicate
    | predicate NOT? BETWEEN predicate AND predicate                #betweenPredicate
    | predicate SOUNDS LIKE predicate                               #soundsLikePredicate
    | predicate NOT? LIKE predicate (ESCAPE STRING_LITERAL)?        #likePredicate
    | predicate NOT? regex=(REGEXP | RLIKE) predicate               #regexpPredicate
    | (LOCAL_ID VAR_ASSIGN)? expressionAtom                         #expressionAtomPredicate
    | predicate MEMBER OF '(' predicate ')'                         #jsonMemberOfPredicate
    ;    


listEvents
   : eventElem (',' eventElem)*
   ;

eventElem
   :
   EVENT (NAME | listEvents)
   ;   

NAME
   :
   ('a'..'z' | 'A'..'Z')+
   ;  

CHARSTRING1
   : [a-zA-Z.]+
   ;

logicalOperator
    : AND | '&' '&' | XOR | OR | '|' '|'
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


