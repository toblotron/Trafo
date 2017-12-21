# Trafo
Tool for parsing and transforming text files, through grammar, logic, and functional stuff

Inspired (heavily) by Prolog's DCG (Definite Clause Grammar), and also using Prolog in this initial, exploratory implementation
PS - not ready to try - just using GIT to store history & stuff for now 

This project will also include a Java GUI connected to prolog, to let you work with your parsing projects in a way inspired by 
tools like MySQL Workbench - so you can try things, and store your experiments

Will also (hopefully) include graphical debugging of the rules you write, for debugging and pedagogical purposes.



Lets say you want to parse some text-file, get all the relevant data structured as it suits you, and then transform that data in 
some practical manner. (or - heck - just perform a Really complex search/replace operation)

Here's a pidgin version of parsing simple XML, like 
"<a t1="hupp" t2="mupp"><b>jj</b><c>ccc</c></a>"


tag =>
	start: start_tag,						% try parsing a start_tag, and put that under the key "start" 
	contents: any([							% in contents should go either... 
		children: seq(tag),						% a sequence of sub-tags
		text: seq(char_alnum)]),				% or just a piece of text
	end: end_tag							% and after that we want the end-tag to come

start_tag =>
	"<",									% literals always match directly against the text
	name: seq(char_alnum),
	children: maybe(seq(attribute)), 		% "maybe" means that we don't insist on finding this, but it's nice if we do!
	">"

attribute =>
	" ",
	name: seq(char_alnum),
	"=\"",
	value: seq(char_alnum),
	"\""
	
end_tag =>
	"</",
	name: seq(char_alnum),
	">"
	
	
THINGS TO FOCUS ON NEXT

* Figure out what kinds of data-structure transformations I want to do, and how to do them	
* Improve the parsing-rule-API, to make more practical ways of capturing things
* Nail down how the abstract syntax trees from parsing should look, so I can update the Java GUI to display that after parsing





















