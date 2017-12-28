% XML-parsing

rule(b, 
	blanks:seq(1,99,any([" ","\t","\n"]))).

rule(tag,[
	start:start_tag >> S,
	get(S,name,SN),
	contents:any([
		children:seq(1,1000,tag),
		text:seq(1,1000,char_alnum)]),
	end:end_tag >> E,
	get(E,name,SN)
	]).

rule(start_tag,[
	"<",
	name:seq(1,1000,char_alnum),
	children:maybe(seq(1,100,attribute)), % maybe(..)
	">"
	]).

rule(attribute,[
	" ",
	name:seq(1,100,char_alnum),
	"=\"",
	value:seq(1,100,char_alnum),
	"\""
	]).
	
rule(end_tag,[
	"</",
	name:seq(1,1000,char_alnum),
	">"
	]).

/*
output(tag,[
	
]).
*/

/*
A = '<a t1="hupp" t2="mupp"><b>jj</b><c>ccc</c></a>',
T = [tag::[start:start_tag::["<", name:[a], children:[...|...], ">"], contents:children:[tag::[... : ...|...], tag::[...|...]], end:end_tag::["</", ... : ...|...]], nohit:""],
E = "<a><b>jj</b><c>ccc</c></a>" .

A = '<a t1="hupp" t2="mupp"><b>jj</b><c>ccc</c></a>',call_trawl(tag,A,T),!, construct(T,E).
A = '<a t1="hupp" t2="mupp"><b>jj</b><c>ccc</c></a>',
T = [tag::[start:start_tag::["<", name:[a], children:[...|...], ">"], contents:children:[tag::[... : ...|...], tag::[...|...]], end:end_tag::["</", ... : ...|...]], nohit:""],
E = "<a><b>jj</b><c>ccc</c></a>" .
*/



output(tag,[
	start,
	get(start,Start),
	try([
		get(Start,children,Children),
		Children]),
	get(contents,C),
	%C,
	try([get(C,text,Text),start_tag::[name:"original"],Text,end_tag::[name:"original"]]),
	try([get(C,children,Subtags),Subtags]),
	end
]).
output(start_tag,[
	"<",
	name,
	">"
]).
output(attribute,[
	get(name,N),
	start_tag::[name:N],
	value,
	end_tag::[name:N]	
]).
output(end_tag,[
	"</",
	name,
	">"
]).

% build a tag from attribute-data 
/*output(att_to_tag,[
	
]).
*/

/*	
?- A = '<a><b>jj</b><c>ccc</c></a>',call_trawl(tag,A,T), construct(T,E).
A = '<a><b>jj</b><c>ccc</c></a>',
T = [tag::[start:start_tag::["<", name:[a], children:[], ">"], contents:children:[tag::[... : ...|...], tag::[...|...]], end:end_tag::["</", ... : ...|...]], nohit:""],
E = "<a><b>jj</b><c>ccc</c></a>" 

?- A = '<a t1="hupp" t2="mupp"><b>jj</b><c>ccc</c></a>',call_trawl(tag,A,T), construct(T,E).
A = '<a t1="hupp" t2="mupp"><b>jj</b><c>ccc</c></a>',
T = [nohit:"<a t1=\"hupp\" t2=\"mupp\">", tag::[start:start_tag::["<", name:[...], ... : ...|...], contents:text:[j, j], end:end_tag::["</"|...]], tag::[start:start_tag::["<", ... : ...|...], contents:text:[c|...], end:end_tag::[...|...]], nohit:"</a>"],
E = "<a t1=\"hupp\" t2=\"mupp\"><b>jj</b><c>ccc</c></a>" ;

rule(b, 
	blanks:seq(1,99,any([" ","\t","\n"]))).

rule(tag,[
	start:start_tag >> S,
	get(S,name,SN),
	contents:any([
		children:seq(1,1000,tag),
		text:seq(1,1000,char_alnum)]),
	end:end_tag >> E,
	get(E,name,SN)
	]).

rule(start_tag,[
	"<",
	name:seq(1,1000,char_alnum),
	children:maybe(seq(1,100,[b,attribute])),
	">"
	]).

rule(attribute,[
	b,
	name:seq(1,100,char_alnum),
	"=\"",
	value:seq(1,100,char_alnum),
	"\""
	]).
	
rule(end_tag,[
	"</",
	name:seq(1,1000,char_alnum),
	">"
	]).
*/