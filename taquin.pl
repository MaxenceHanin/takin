/*:- lib(listut).       % a placer en commentaire si on utilise Swi-Prolog
                      % (le predicat delete/3 est predefini)

                      % Indispensable dans le cas de ECLiPSe Prolog
                      % (le predicat delete/3 fait partie de la librairie listut)
        */
%***************************
%DESCRIPTION DU JEU DU TAKIN
%***************************

   %********************
   % ETAT INITIAL DU JEU
   %********************

initial_state([ [a, b, c],
                [g, h, d],
                [vide,f,e] ]). % h=2, f*=2
/*
initial_state([ [b, h, c],     % EXEMPLE
                [a, f, d],     % DU COURS
                [g,vide,e] ]). % h=5 = f* = 5actions
*/
/*
initial_state([ [b, c, d],
                [a,vide,g],
                [f, h, e]  ]). % h=10 f*=10

initial_state([ [f, g, a],
                [h,vide,b],
                [d, c, e]  ]). % h=16, f*=20

initial_state([ [e, f, g],
                [d,vide,h],
                [c, b, a]  ]). % h=24, f*=30
*/

   %******************
   % ETAT FINAL DU JEU
   %******************

final_state([[a, b,  c],
             [h,vide,d],
             [g, f,  e]]).

   %********************
   % AFFICHAGE D'UN ETAT
   %********************

write_state([]).
write_state([Line|Rest]) :-
   writeln(Line),
   write_state(Rest).


%**********************************************
% REGLES DE DEPLACEMENT (up, down, left, right)
%**********************************************
   % format :   rule(+Rule_Name, ?Rule_Cost, +Current_State, ?Next_State)

rule(up,   1, S1, S2) :-
   vertical_permutation(_X,vide,S1,S2).

rule(down, 1, S1, S2) :-
   vertical_permutation(vide,_X,S1,S2).

rule(left, 1, S1, S2) :-
   horizontal_permutation(_X,vide,S1,S2).

rule(right,1, S1, S2) :-
   horizontal_permutation(vide,_X,S1,S2).

   %***********************
   % Deplacement horizontal
   %***********************

horizontal_permutation(X,Y,S1,S2) :-
   append(Above,[Line1|Rest], S1),
   exchange(X,Y,Line1,Line2),
   append(Above,[Line2|Rest], S2).

   %***********************************************
   % Echange de 2 objets consecutifs dans une liste
   %***********************************************

exchange(X,Y,[X,Y|List], [Y,X|List]).
exchange(X,Y,[Z|List1],  [Z|List2] ):-
   exchange(X,Y,List1,List2).

   %*********************
   % Deplacement vertical
   %*********************

vertical_permutation(X,Y,S1,S2) :-
   append(Above, [Line1,Line2|Below], S1), % decompose S1
   delete(N,X,Line1,Rest1),    % enleve X en position N a Line1,   donne Rest1
   delete(N,Y,Line2,Rest2),    % enleve Y en position N a Line2,   donne Rest2
   delete(N,Y,Line3,Rest1),    % insere Y en position N dans Rest1 donne Line3
   delete(N,X,Line4,Rest2),    % insere X en position N dans Rest2 donne Line4
   append(Above, [Line3,Line4|Below], S2). % recompose S2

   %***********************************************************************
   % Retrait d'une occurrence X en position N dans une liste L (resultat R)
   %***********************************************************************
   % use case 1 :   delete(?N,?X,+L,?R)
   % use case 2 :   delete(?N,?X,?L,+R)

delete(1,X,[X|L], L).
delete(N,X,[Y|L], [Y|R]) :-
   delete(N1,X,L,R),
   N is N1 + 1.

   %**********************************
   % HEURISTIQUES (PARTIE A COMPLETER)
   %**********************************

heuristique(U,H) :-
   heuristique1(U, H).  % choisir l'heuristique
%   heuristique2(U, H).  % utilisee ( 1 ou 2)

   %****************
   %HEURISTIQUE no 1
   %****************

   % Calcul du nombre de pieces mal placees dans l'etat courant U
   % par rapport a l'etat final F

	diff_elements(X, Y, H) :-
		(X \= Y ->
		H=1
		;
		H=0).

	diff_ligne([],[],0).
	diff_ligne([A|B], [C|D], Hl) :-
		diff_ligne(B, D, N),
		diff_elements(A, C, H),
		Hl is ( N + H).

	diff_mat([],[],0).
	diff_mat([A|B], [C|D], Hl) :-
		diff_mat(B, D, N),
		diff_ligne(A, C, H),
		Hl is ( N + H).

    heuristique1(U, H) :-
		final_state(M),
		diff_mat(U,M,H).

   %****************
   %HEURISTIQUE no 2
   %****************

   % Somme sur l'ensemble des pieces des distances de Manhattan
   % entre la position courante de la piece et sa positon dans l'etat final


	coordonnees([L,C], Mat, Elt):-
		nth1(L,Mat,LM),
		nth1(C,LM,Elt).

	dm(M1,M2,H) :-
		coordonnees([L1,C1], M1, Elt),
		coordonnees([L2,C2], M2, Elt),
		Elt \= 'vide',
		H is (abs(L2-L1)+abs(C2-C1)).

    heuristique2(U, H) :-
		final_state(M),
		findall(H2,dm(U,M,H2),LH2),
		sumlist(LH2, H).

%-----------------------------------------
% Aetoile
%-----------------------------------------

print_solution(Q) :- final_state(M), print_solution(Q, M).
	print_solution(Q, nil).
print_solution(Q, Pere) :-
	Parent_node = [Pere, _, New_Pere, A],
	belongs(Parent_node, Q),
	write(Pere), write(" --> "),
	writeln(A),
	print_solution(Q, New_Pere).

% Retourne une liste de tous les successeurs possibles de U

expand([U,[F,H,G],Pere,A], Succ):-
	findall([X,Y], (member(X, [up, down, right,left]), rule(X, 1, U, Y)), Res),
	loop_exp(Res, [U,[F,H,G],Pere,A], Succ).

loop_exp(Res,[U,[F,H,G],Pere,A], L) :-
	loop_exp(Res, [U,[F,H,G],Pere,A], L, []).
	loop_exp([], [U,[F,H,G],Pere,A], Acu, Acu).

loop_exp([[Action, State]|Succ], [U,[F,H,G],Pere,A], Res, Acu) :-
	heuristique(State,HS),
	GS is G+1,
	FS is HS+GS,
	loop_exp(Succ,[U,[F,H,G],Pere,A],Res,[[State,[FS,HS,GS],U,Action]|Acu]).



loop_successors([], Pf, Pu, Q, Pf, Pu).
loop_successors([S1|Succ], Pf, Pu, Q, New_Pf, New_Pu) :-
	belongs(S1, Q),
	loop_successors(Succ, Pf, Pu, Q, New_Pf, New_Pu).

loop_successors([[U, [F,H,G], P, A]|Succ], Pf, Pu, Q, New_Pf, New_Pu) :-
	belongs([U, [F2,H2,G2], _, _], Pu), [F2,H2,G2] @=<[F,H,G],
	loop_successors(Succ, Pf, Pu, Q, New_Pf, New_Pu).

loop_successors([[U, [F,H,G], P, A]|Succ], Pf, Pu, Q, New_Pf, New_Pu) :-
	belongs([U, [F2,H2,G2], _, _], Pu), [F2,H2,G2] @> [F,H,G],
	suppress([U, [F2,H2,G2], _, _], Pu, Pu1),
	insert([U, [F,H,G], P, A], Pu1, Pu2),
	suppress([[F2,H2,G2],U], Pf, Pf1),
	insert([[F,H,G],U], Pf1, Pf2),
	loop_successors(Succ, Pf2, Pu2, Q, New_Pf, New_Pu).

loop_successors([[U, [F,H,G], P, A]|Succ], Pf, Pu, Q, New_Pf, New_Pu) :-
	insert([U, [F,H,G], P, A], Pu, Pu1),
	insert([[F,H,G],U], Pf, Pf1),
	loop_successors(Succ, Pf1, Pu1, Q, New_Pf, New_Pu).

aetoile(nil,nil,_) :-
write('PAS DE SOLUTION , Pf Pu vides').

aetoile(Pf,_,Q) :-
	suppress_min(Min,Pf, _),
	final_state(F),
	member(F, Min),
	print_solution(Q).


aetoile(Pf,Pu,Q) :-
	suppress_min([[F,H,G],U], Pf, New_Pf),
	suppress([U,[F,H,G],Pere,A], Pu, New_Pu),
	expand([U,[F,H,G],Pere,A], Successors),			%pas sur que ce soit G
	loop_successors(Successors, New_Pf, New_Pu, Q, New2_Pf, New2_Pu),
	insert([U,[F,H,G],Pere,A], Q, New_Q),
	aetoile(New2_Pf, New2_Pu, New_Q).


%-----------------------------------------
% main
%-----------------------------------------

main :-
	initial_state(S0),
	G0 is 0,
 	heuristique(S0,H0),
	F0 is (G0 + H0),
	empty(Pf),
	empty(Pu),
	empty(Q),
	insert([[F0,H0,G0],S0], Pf, New_Pf),
	insert([S0, [F0,H0,G0],nil,nil], Pu, New_Pu),
	aetoile(New_Pf,New_Pu,Q).
