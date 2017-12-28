% try to solve - otherwise collect until match found, and repeat

/* YÄSSSS!!
[debug]  ?- string_codes("TAdogBAcat",String),trawl(verb,A,String,R,[]),print(A).
[nohit:"AT",verb:"dog",nohit:"AB",verb:"cat"]
String = [84, 65, 100, 111, 103, 66, 65, 99, 97|...],
A = [nohit:"AT", verb:"dog", nohit:"AB", verb:"cat"],
R = [] .
*/

call_trawl(Rule,Text,Tree):-
	atom_codes(Text, String),
	trawl(Rule,Tree,String,_Rest,[]).
	

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
	
	
% --- all solved
solve([],[],RestInput, RestInput).

% --- solve body
solve([Part|Rest],[Answer|PrevAnswer],Input,RestOut):-
	!,solve(Part,Answer,Input,Input2),
	solve(Rest,PrevAnswer,Input2,RestOut).

% --- solve labeled part	
solve(Label:Rule, Label:Answer, Input, Rest):-
	!,solve_rule(Rule,Answer,Input,Rest).
	
% --- solve unlabeled part
solve(Rule, Answer, Input, Rest):-
	!,solve_rule(Rule,Answer,Input,Rest).

	
	
	

% hitta i db-match
solve_rule(db_match-Name, Match, Input, Out):-
	db(Name,Match),
	string_codes(Match, MatchCodes),
	match(MatchCodes,Input,Out).
% hitta regel som finns inbyggd
solve_rule(seq(Min,Max,X),Answer,Input,Rest):-
	sequence(X,Min,Max,0,Answer,Input,Rest).
% pröva olika alternativ
solve_rule(any(Alternatives), Answer, Input, Rest):-
	member(ToTry,Alternatives),
	solve(ToTry,Answer,Input,Rest),!.
% negera
solve_rule(not(X),Answer, Input, Rest):-
	solve_rule(X, Answer, Input, Rest)-> fail; true.
% hitta regel som finns i rule/1
solve_rule(Name, Answer, Input, Rest):-
	rule(Name, Body),
	solve(Body, Answer, Input, Rest).
% hitta literal
solve_rule(Literal,Literal,Input,Rest):-
	string(Literal),
	string_codes(Literal, MatchCodes),
	match(MatchCodes,Input,Rest).	
	
	
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
	
	

smatch(MatchString,In,Out):-
	string_codes(MatchString, MatchCodes),
	match(MatchCodes,In,Out).
	
match([],In,In).
match([FT|RT],[FT|IR],Final):-
	match(RT,IR,Final).


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
rule(moment,[neg:not("."),hit:"Moment"]).

	
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

	