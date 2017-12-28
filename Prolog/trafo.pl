% try to solve - otherwise collect until match found, and repeat

:- multifile rule/2.
:- dynamic rule/2.
:- multifile output/2.
:- dynamic output/2.

/* YÄSSSS!!
[debug]  ?- string_codes("TAdogBAcat",String),trawl(verb,A,String,R,[]),print(A).
[nohit:"AT",verb:"dog",nohit:"AB",verb:"cat"]
String = [84, 65, 100, 111, 103, 66, 65, 99, 97|...],
A = [nohit:"AT", verb:"dog", nohit:"AB", verb:"cat"],
R = [] .
*/

dump_rules :-
	retractall(db(_,_)),
	retractall(rule(_,_)).
	
:- op(600,xfy,::).


:- op(700,xfx,??).

'??'(List,Elem) :-
	member(Elem,List).

call_trawl(Rule,Text,Tree):-
	atom_codes(Text, String),
	trawl(Rule,Tree,String,_Rest,[]).

/*?- A = 'hhj_%jMomentjkkjk\nl.MomentkkswMoment.',call_trawl(momentfind,A,T), construct(T,E).*/
	
construct(List,Out) :-
	constructFromTrawlResult(List,Product),
	doFlatPrint(Product,Out).

% transformRule([[attribute::[" ", name:[t, '1'], "=\"", value:[...|...], "\""]], contents, end], [start:start_tag::["<", name:[a], children:[... :: ...], ">"], contents:children:[tag::[start: ... :: ..., ... : ...|...]], end:end_tag::["</", name:[...], ">"]], _2422)
 

 constructFromTrawlResult([],[]).
constructFromTrawlResult([Rule::Data|Rest],[Constructed|Prev]):-	% actual result - transform
	constructFromRule(Rule::Data, Constructed),
	constructFromTrawlResult(Rest,Prev).
constructFromTrawlResult([_Tag:Data|Rest],[Rendered|Prev]):-			% tags are just nohit-tags here - just bring them along without change
	constructPart(Data,Rendered),									% - but remove everything that's not data, first!
	constructFromTrawlResult(Rest, Prev).
constructFromRule(Rule::Data, Constructed):-						% is there an output-rule for this rule?
	output(Rule, Body),!,
	transformRule(Body, Data, Constructed).
constructFromRule(_Rule::Data, Constructed):- 						% otherwise, just process its parts - go further into it, looking for things to transform or repeat
	constructFromBody(Data, Constructed).
	
constructFromBody([],[]).
constructFromBody([Elem|Rest],[ThisResult|PrevResult]):-			
	constructPart(Elem,ThisResult),
	constructFromBody(Rest, PrevResult).
	
	
transformRule([],_,[]).
transformRule([get(TagName,TagValue)|Parts],Data,PrevOut):-
	member(TagName:TagValue,Data),
	transformRule(Parts, Data, PrevOut).
transformRule([try(TryParts)|Parts],Data,Out):-					
	(
		transformRule(TryParts,Data,TryOut) ->						% do the try-part, but don't be sore if it fails
		Out = [TryOut|PrevOut]
		;
		Out = PrevOut
	),
	transformRule(Parts, Data, PrevOut).
transformRule([get(_Rule::Object,TagName,TagValue)|Parts],Data,PrevOut):-
	member(TagName:TagValue,Object),!,
	transformRule(Parts, Data, PrevOut).
transformRule([get(ObjectList,TagName,TagValue)|Parts],Data,PrevOut):-
	member(TagName:TagValue,ObjectList),!,
	transformRule(Parts, Data, PrevOut).
transformRule([Part|Parts],Data,[Out|PrevOut]):-					% is Part the name of a tag i Data?
	member(Part:Value, Data),!,
	constructPart(Value, Out),
	transformRule(Parts, Data, PrevOut).
transformRule([Part|Parts],Data,[Out|PrevOut]):-
	constructRulePart(Part,Data,Out),
	transformRule(Parts, Data, PrevOut).
	
constructRulePart(Part,_,Part):-
	string(Part).
constructRulePart([Part|Parts],_Data,Out):-
	constructParts([Part|Parts],Out).
constructRulePart(Part,_Data,Out):-
	constructPart(Part,Out).
	
constructParts([],[]).
constructParts([E|R],[A|P]):-
	constructPart(E,A),
	constructParts(R,P).
	
	 
constructPart(_Tag:Contents, Out):-
	constructPart(Contents, Out).
constructPart(Rule::Data, Out):-
	constructFromRule(Rule::Data, Out).
constructPart(Part,Part):-
	atom(Part).
constructPart(Part, Out):-
	is_list(Part),
	constructParts(Part, Out).
constructPart(Part, Part):-
	string(Part).
	

outputTree([],[]).
outputTree([E|Rest],[A|Prev]):-
	outputBranch(E,A),
	outputTree(Rest, Prev).
	
outputBranch(E,A):-
	is_list(E),!,
	outputTree(E,A).
outputBranch(RuleName::E,A):-
	!,
	(
		output(RuleName, ToPrint)
		->
		printRule(RuleName::E, ToPrint, A)
		;
		outputBranch(E,A)
	).
outputBranch(_:E,A):-
	!,outputBranch(E,A).
outputBranch(E,E).
	

printRule(_, [], []).
printRule(_Tag:Rule::Result, Edo, Ret):-
	printRule(Rule::Result, Edo, Ret).
printRule(RuleName::Result, [Edo|RestDo], [Ret|PrevReturn]):-
	printPart(RuleName::Result,Edo,Ret),
	printRule(RuleName::Result, RestDo, PrevReturn).
		


printPart(_, Rule::E, Answer):-
	% an object with which we can call a rule to help us write?
	outputBranch(Rule::E,Answer).
printPart(_Tag:Rest, Part, Answer):-
	printPart(Rest, Part, Answer).
printPart(_, Part, Part):-
	% is it a string?
	string(Part).
printPart(_::Res, Part, Answer):-
	% is it a tag which we can find in Res?
	print("DOING IT!3"),
	member(Part:Data, Res),
	outputBranch(Data,Answer),!.
printPart(_::Res, get(LocalTagName, Data),Data):-
	print("DOING IT2!"),
	% is it a local tag which we can find in Res, and put in a variable?
	member(LocalTagName:Data, Res),!.
printPart(_, get(_Rule::List, TagName, Data),Data):-
	print("DOING IT!"),
	% is it tag we can find in Res, and put in a variable?
	member(TagName:Data, List),!.

doFlatPrint(Tree, String):-
	flatPrint(Tree,CodeList),
	string_codes(String, CodeList).
	
flatPrint([],[]).
flatPrint([E|R],OutList):-
	is_list(E),!,
	flatPrint(E,SubList),
	flatPrint(R,RestList),
	append(SubList,RestList,OutList).
flatPrint([E|R],OutList):-
	string_codes(E,ElemList),
	flatPrint(R,RestList),
	append(ElemList,RestList,OutList).



trawl(_,[nohit:PrevNoHitString],[],[],PrevNoHit):-
	reverse(PrevNoHit,NoHitReversed),
	string_codes(PrevNoHitString,NoHitReversed).

trawl(ToSolve,OutBuild,Input,RestOut,PrevNoHit):-
	solve(ToSolve,Answer,Input,Input2),!,
	(
		PrevNoHit = [],
		OutBuild = [Answer|PrevAnswer],!
		;
		reverse(PrevNoHit,NoHitReversed),
		string_codes(PrevNoHitString,NoHitReversed),
		OutBuild = [nohit:PrevNoHitString,Answer|PrevAnswer]
	),
	trawl(ToSolve,PrevAnswer,Input2,RestOut,[]).

trawl(ToSolve,Answer,[C|InputRest],Rest,TrawlPrev):-
	trawl(ToSolve,Answer,InputRest,Rest,[C|TrawlPrev]).
	

until_hit(_,[nohit:PrevNoHitString],[],[],PrevNoHit):-
	reverse(PrevNoHit,NoHitReversed),
	string_codes(PrevNoHitString,NoHitReversed).

until_hit(ToSolve,OutBuild,Input,RestOut,PrevNoHit):-
	solve(ToSolve,Answer,Input,RestOut),!,
	(
		PrevNoHit = [],
		OutBuild = Answer,!
		;
		reverse(PrevNoHit,NoHitReversed),
		string_codes(PrevNoHitString,NoHitReversed),
		OutBuild = [PrevNoHitString,Answer]
	).

until_hit(ToSolve,Answer,[C|InputRest],Rest,TrawlPrev):-
	until_hit(ToSolve,Answer,InputRest,Rest,[C|TrawlPrev]).
	

	
% --- all solved
solve([],[],RestInput, RestInput).


% get from lists
solve([get(List,Name,Value)|Rest],Answer,Input,Out):-
	(
		List = _RuleName::ValueList,!;
		ValueList = List
	),
	member(Name:Value,ValueList),	
	solve(Rest,Answer,Input,Out).
	
% --- solve body
solve([Part|Rest],[Answer|PrevAnswer],Input,RestOut):-
	!,solve(Part,Answer,Input,Input2),
	solve(Rest,PrevAnswer,Input2,RestOut).

	
% --- solve labeled part	
solve(Label:Rule, Label:AnswerOut, Input, Rest):-
	!,solve_rule(Rule,Answer,Input,Rest),
	(
		Answer = L2:A2,!,AnswerOut = L2:[A2]	% label1:label2: --> label1:[label2:..]
		;
		AnswerOut = Answer
	).
	
/*
% --- solve labeled part	
solve(Label:Rule, Label:Answer, Input, Rest):-
	!,solve_rule(Rule,Answer,Input,Rest).
*/
	
% --- solve unlabeled part
solve(Rule, Answer, Input, Rest):-
	!,solve_rule(Rule,Answer,Input,Rest).

	
match([],In,In).
match([FT|RT],[FT|IR],Final):-
	match(RT,IR,Final).	
	
	

% hantera återskickande av variabler, dit de ska
solve_rule(Rule>>DataPart,Match,Input,Out):-
	solve_rule(Rule,Match,Input,Out),
	(Match = _Tag:AfterTag,!; AfterTag = Match),
	(AfterTag = _Rulename::DataPart,!;DataPart = Match).
% hitta i db-match
solve_rule(db_match-Name, Match, Input, Out):-
	db(Name,Match),
	string_codes(Match, MatchCodes),
	match(MatchCodes,Input,Out).
% hitta regel som finns inbyggd
solve_rule(seq(Min,Max,X),Answer,Input,Rest):-
	sequence(X,Min,Max,0,Answer,Input,Rest).
% pröva olika alternativ
solve_rule(any(Alternatives), [Answer], Input, Rest):-
	member(ToTry,Alternatives),
	solve(ToTry,Answer,Input,Rest),!.
% negera
solve_rule(not(X),Answer, Input, Rest):-
	solve_rule(X, Answer, Input, Rest)-> fail; true.
% hitta regel som finns i rule/1
solve_rule(Name, Name :: Answer2, Input, Rest):-
	rule(Name, Body),
	solve(Body, Answer, Input, Rest),
	(
		% always put Answer in a list
		is_list(Answer),
		Answer2 = Answer
		;
		Answer2 =[Answer]
	).
% hitta literal
solve_rule(Literal,Literal,Input,Rest):-
	string(Literal),
	string_codes(Literal, MatchCodes),
	match(MatchCodes,Input,Rest).	
solve_rule(until(X),Answer,Input,Rest):-
	until_hit(X, Answer, Input, Rest,[]).
solve_rule(maybe(X),Answer,Input,Rest):-
	solve(X, Answer, Input, Rest)
	;
	Answer = [],
	Rest = Input.
solve_rule(char_lower,C,[E|R],R):-
	char_type(E,lower),
	char_code(C,E).
solve_rule(char_alnum,C,[E|R],R):-
	char_type(E,alnum),
	char_code(C,E).
% catch characters into Text while char matches rule/s X/
/*solve_rule(chars(X),Text,Input,Rest):-
	while_char(X,RevText,[],Input,Rest),
	reverse(RevText,Text).
	
	
while_char(Checks,[OkChar|PrevOk],[OkChar|RestChars],Rest):-
	(
		check_char(Checks,OkChar),
		while_char(Checks,PrevOk,RestChars,Rest),
		!
	)
	;
	*/
	
	
sequence(What,Min,Max,CurrCount,[Answer|PrevAnswer],Input,Rest):-
	(
		(Max = any) 
		;
		(CurrCount =< Max)
	),
	% -- not over count, so continue looking
	(
		% succeed or finalize search
		solve(What,Answer,Input,Rest2)
	),	
	NewCount is CurrCount + 1,
	sequence(What,Min,Max,NewCount,PrevAnswer,Rest2,Rest).
		
sequence(_What,Min,_Max,CurrCount,[],Rest,Rest):-
	CurrCount >= Min.
	
	
	
	
	

	
	/*
resolve_body(_, [], [], RemainingInput, RemainingInput).
resolve_body(Name, [Part|Rest],[OutProd|OutPrevProd], Input, InputRest):-
	resolve_rule(Part, OutProd, Input, RemainingInput),
	resolve_body(Name, Rest, OutPrevProd, RemainingInput, InputRest).
resolve_body(Name, db_match, Match, Input, Out):-
	db(Name,Match),
	string_codes(Match, MatchCodes),
	match(MatchCodes,Input,Out).
	*/
	
	
/*
smatch(MatchString,In,Out):-
	string_codes(MatchString, MatchCodes),
	match(MatchCodes,In,Out).
	
match([],In,In).
match([FT|RT],[FT|IR],Final):-
	match(RT,IR,Final).

dump_rules :-
	retractall(db(_,_)),
	retractall(rule(_,_)).

:- dynamic db/2.

db(verb,"cat").
db(verb,"dog").

db(substantive,"shit").
db(substantive,"smell").


rule(test,[any([verb, " ", substantive])]).
rule(sentences, [sentence,seq(0,99," ")]).
rule(sentence, [actor:verb, b, done:substantive]).
rule(verb, db_match-verb).
rule(substantive, db_match-substantive).
rule(b, blanks:seq(1,99,any([" ","\t","\n"]))).
% rule(moment,[neg:not("."),hit:"Moment"]).
*/


/*

% hitta regel som finns i rule/1
resolve_rule(Name, Answer, Input, Rest):-
	rule(Name, Body),
	resolve_body(Name, Body, Product, Input, Rest),
	Answer = Name:Product.
% hitta regel som finns inbyggd
resolve_rule(seq(Min,Max,X),Answer,Input,Rest):-
	match_sequence(X,Min,Max,0,Answer,Input,Rest).
% hitta literal
resolve_rule(Literal,Literal,Input,Rest):-
	string(Literal),
	string_codes(Literal, MatchCodes),
	match(MatchCodes,Input,Rest).
% pröva olika alternativ
resolve_rule(any(Alternatives), Answer, Input, Rest):-
	member(ToTry,Alternatives),
	resolve_rule(ToTry,Answer,Input,Rest),!.
% negera
resolve_rule(not(X),Answer, Input, Rest):-
	resolve_rule(X, Answer, Input, Rest)-> fail; true.

	
	
resolve_body(_, [], [], RemainingInput, RemainingInput).
resolve_body(Name, [Part|Rest],[OutProd|OutPrevProd], Input, InputRest):-
	resolve_rule(Part, OutProd, Input, RemainingInput),
	resolve_body(Name, Rest, OutPrevProd, RemainingInput, InputRest).
resolve_body(Name, db_match, Match, Input, Out):-
	db(Name,Match),
	string_codes(Match, MatchCodes),
	match(MatchCodes,Input,Out).

	
match_sequence(What,Min,Max,CurrCount,[Answer|PrevAnswer],Input,Rest):-
	(
		(Max = any) 
		;
		(CurrCount =< Max)
	),
	% -- not over count, so continue looking
	(
		% succeed or finalize search
		resolve_rule(What,Answer,Input,Rest2)
	),	
	NewCount is CurrCount + 1,
	match_sequence(What,Min,Max,NewCount,PrevAnswer,Rest2,Rest).
		
match_sequence(_What,Min,_Max,CurrCount,[],Rest,Rest):-
	CurrCount >= Min.
*/
	