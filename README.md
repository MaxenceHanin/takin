# TP1 : A*
tom.portoleau@laas.fr
rbailonr@laas.fr

## Application au takin
### Familiarisation avec le problème de Taquin 3*3

** Question 1.2.a : Quelle clause Prolog permettrait de représenter la situation finale du Taquin 4x4? **
```pl
final_state([ [1, 2, 3, 4],
                [5, 6, 7, 8],
                [9, 10, 11, 12],
                [13, 14, 15, vide]]).
```

** Question 1.2.b : A quelles questions permettent  de répondre les requêtes suivantes : **
```pl
initial_state(Ini), nth1(L,Ini,Ligne), nth1(C,Ligne, d).
% Renvoi L et C respectviement le numéro de la ligne et de la colonne de l'élément d présent dans la matrice représentant l'état initial.

final_state(Fin), nth1(3,Fin,Ligne), nth1(2,Ligne,P).
% Renvoi P l'élément placé à la 3-ième ligne et la 2-ième colonne de la matrice répresentant l'état final.
```

** Question 1.2.c : Quelle requête Prolog permettrait de savoir si une pièce donnée P (ex: a)  est bien placée dans U0(par rapport à F)? **
```pl
initial_state(Ini),final_state(Fin), nth1(L,Ini,Ligne), nth1(C,Ligne,a), nth1(L,Fin,LigneFin), nth1(C,LigneFin,a).
% requête vraie si **a** est placé au même endroit dans U0 que dans F, c'est-à-dire **a** est bien placé.
```

** Question 1.2.d : Quelle requête permet de déterminer chaque situation suivante (successeur) S de l'état initial du Taquin 3×3 ? Il doit y avoir 3 réponses possibles. **
Trois mouvements possible donc trois réponses possibles :
```pl
initial_state(IS), rule(up, 1 , IS , NS).
>> IS = [[b, h, c], [a, f, d], [g, vide, e]]
>> NS = [[b, h, c], [a, vide, d], [g, f, e]]

initial_state(IS), rule(left, 1 , IS , NS).
>> IS = [[b, h, c], [a, f, d], [g, vide, e]]
>> NS = [[b, h, c], [a, f, d], [vide, g, e]]

initial_state(IS), rule(right, 1 , IS , NS).
>> IS = [[b, h, c], [a, f, d], [g, vide, e]]
>> NS = [[b, h, c], [a, f, d], [g, e, vide]]
```
** Question 1.2.e : Quelle requête permet d'avoir les 3 réponses d'un coup regroupées dans une liste ?  **
```pl
initial_state(IS), findall(NS,rule(Y,1,IS,NS),L).
>> IS = [[b, h, c], [a, f, d], [g, vide, e]]
>> NS = NS
>> Y = Y
>> L = [[[b, h, c], [a, vide, d], [g, f, e]], [[b, h, c], [a, f, d], [vide, g, e]], [[b, h, c], [a, f, d], [g, e, vide]]]
```
** Quelle requête permet d'avoir la liste de tous les couples [A, S] tels que S est la situation qui résulte de l'action A en U0 ? **
```pl
initial_state(IS), findall([Y,NS],rule(Y,1,IS,NS),L).
>> IS = [[b, h, c], [a, f, d], [g, vide, e]]
>> NS = NS
>> Y = Y
>> L = [[up, [[b, h, c], [a, vide, d], [g, f, e]]], [left, [[b, h, c], [a, f, d], [vide, g, e]]], [right, [[b, h, c], [a, f, d], [g, e, vide]]]]
```
### Développement des 2 heuristiques
#### 1ère heuristique : Nombre de pièces maplacées

Notre méthode pour trouver le nombre de pièces malplacées est de définir d'abord un prédicat nous permettant de comparer deux éléments d'une liste puis un prédicat appelant cette comparaison sur une ligne de nos matrices puis un prédicat appelant ces différentes lignes.

```pl
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

% On définit l'heuristique n°1 à partir de nos prédicats
heuristique1(U, H) :-
  final_state(M),
  diff_mat(U,M,H).
```
#### 2 ème heuristique : Distance de Manhattan
Pour pouvoir calculer la distance minimale à parcourir pour chaque pièce pour rejoindre sa potion finale on créé d'abord une fonction permettant d'obtenir les coordonnées d'une pièce (respectivement le symbole d'une pièce avec les coordonnées).

Une fois cette fonction outil en main pour calculer cette distance il suffit de calculer la valeur absolue de la difference des coordonnees de la position initiale et de la position finale de chaque pièce.

```pl
coordonnees([L,C], Mat, Elt):-
  nth1(L,Mat,LM),
  nth1(C,LM,Elt).

dm(M1,M2,H) :-
  coordonnees([L1,C1], M1, Elt),
  coordonnees([L2,C2], M2, Elt),
  Elt \= 'vide',
  H is (abs(L2-L1)+abs(C2-C1)).

% On définit l'heuristique n°2 à partir de nos prédicats
heuristique2(U, H) :-
  final_state(M),
  findall(H2,dm(U,M,H2),LH2),
  sumlist(LH2, H).
```
#### Tests des heuristiques
**Résulats des tests :**
```pl
%------- Tests des heuristiques sur la situation initiale
initial_state(S),heuristique1(S,H).
>> S = [[b, h, c],[a, f, d],[g,vide,e]],
>> H = 5.

initial_state(S),heuristique2(S,H).
>> S = [[b, h, c],[a, f, d],[g,vide,e]],
>> H = 5.

% Pour cette situation initale les deux heurisiques renvoient le même résultat mais ça pourrait ne pas être le cas comme ci-dessous.

initial_state(S),heuristique1(S,H).
>> S = [[a, b, c], [g, h, d], [vide, f, e]],
>> H = 3.

initial_state(S),heuristique2(S,H).
>> S = [[a, b, c], [g, h, d], [vide, f, e]],
>> H = 2.


%------- Tests des heuristiques sur la situation final_state
initial_state(S),heuristique1(S,H).
>> S = [[a, b,  c], [h,vide,d], [g, f, e]],
>> H = 0.

initial_state(S),heuristique2(S,H).
>> S = [[a, b,  c], [h,vide,d], [g, f, e]],
>> H = 0.

% Comme l'on pouvait sans douter, étant donné que la situation finale n'a pas d'écart avec elle-même les heuristiques renvoient 0.
```
## Implémentation de A*
### Implémentation de main/0
```pl
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
```
### Implémentation de aetoile/3
```pl
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
```

### Implémentation des autres prédicats
```pl
%print_solution permet d'afficher la solution suite à l'exécution de A*
print_solution(Q) :- final_state(M), print_solution(Q, M).
	print_solution(Q, nil).
print_solution(Q, Pere) :-
	Parent_node = [Pere, _, New_Pere, A],
	belongs(Parent_node, Q),
	write(Pere), write(" --> "),
	writeln(A),
	print_solution(Q, New_Pere).

% expand retourne une liste de tous les successeurs possibles de U
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


%loop_successors traite chaque noeud successeur
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
```
### Analyse expérimentale



# TP2 :  Algo MinMax
## Familiarisation avec le problème du TicTacToe3*3
 **Question 1.2 : sens des requêtes suivantes**
```pl
?-situation_initiale(S), joueur_initial(J).
% Initialise la grille vide et désigne le joueur J comme premier joueur

?-situation_initiale(S), nth1(3,S,Lig), nth1(2,Lig,o)
% Vérifie si sur la grille si il y a un rond sur la 3ème ligne, 2ème colonne
```
**Question 1.3 : compléter le prédicat alignement(Ali, Matrice)**
```pl
alignement(L, Matrix) :- ligne(    L,Matrix).
alignement(C, Matrix) :- colonne(  C,Matrix).
alignement(D, Matrix) :- diagonale(D,Matrix).
```
**Question 1.4 : définir le prédicat possible(Ali, Joueur)**
```pl
possible([X|L], J) :- unifiable(X,J), possible(L,J).
possible([   ], _).

unifiable(X,J) :-
	var(X); X==J.
```
**Question 1.5 : définir les prédicats alignement_gagnant(A, J) et alignement_perdant(A,J)**
```pl
alignement_gagnant([],_).
alignement_gagnant([X|L], J) :-
	ground([X|L]),
	X==J,
	alignement_gagnant(L, J).

alignement_perdant(Ali, J) :-
	adversaire(J,A),
	alignement_gagnant(Ali,A).
```
### Tests unitaires pour les prédicats
```pl
```
## Développement de l'heuristique h(Joueur, Situation)
**Question 2.1 développer le prédicat heuristique(Joueur,Sit,H)**
```pl
heuristique(J,Situation,H) :-		% cas 1
   H = 10000,				% grand nombre approximant +infini
   alignement(Alig,Situation),
   alignement_gagnant(Alig,J), !.

heuristique(J,Situation,H) :-		% cas 2
   H = -10000,				% grand nombre approximant -infini
   alignement(Alig,Situation),
   alignement_perdant(Alig,J),!.


% on ne vient ici que si les cut precedents n'ont pas fonctionne,
% c-a-d si Situation n'est ni perdante ni gagnante.


heuristique(J,Situation,H) :-   % cas 3
  findall(Ali,(alignement(Ali,Situation),possible(Ali,J)),L1),
  adversaire(J,A),
  length(L1,N1),
  findall(Ali,(alignement(Ali,Situation),possible(Ali,A)),L2),
  length(L2,N2),
  H is (N1-N2).
```
### Tests unitaires de l'heuristique
```pl
% Déclaration de différentes situations
sit1([[A,x,B],[C,x,o],[o,D,E]]).
sit2([[a,b,c],[d,e,f],[g,h,i]]).
win([[x,x,x],[o,x,o],[o,o,E]]).
loose([[o,o,o],[x,o,x],[x,x,E]]).
nul([[x,o,x],[o,x,o],[o,x,o]]).
sit3([[o,F,o],[x,o,x],[x,V,x]]).

% Quelques prédicats de tests
test_heur_init(J,S,H) :- situation_initiale(S),heuristique(J,S,H).
test_heur(J,S,H) :- sit3(S),heuristique(J,S,H).
test_heur_win(J,S,H) :- win(S),heuristique(J,S,H).
test_heur_loose(J,S,H) :- loose(S),heuristique(J,S,H).
test_heur_nul(J,S,H) :- nul(S),heuristique(J,S,H).

% Les requêtes et leur réponse

test_heur_init(o,S,H).
>> S = [[_G2455, _G2458, _G2461], [_G2467, _G2470, _G2473], [_G2479, _G2482, _G2485]],
>> H = 0.

test_heur_init(x,S,H).
>> S = [[_G2455, _G2458, _G2461], [_G2467, _G2470, _G2473], [_G2479, _G2482, _G2485]],
>> H = 0.

% Notre heuristique ne renvoit pas le +4 -4 mentionné dans l'énoncé nous n'avons pas déterminé pourquoi.

test_heur(x,S,H).
>> S = [[o, _G2458, o], [x, o, x], [x, _G2482, x]],
>> H = -1.

test_heur(o,S,H).
>> S = [[o, _G2458, o], [x, o, x], [x, _G2482, x]],
>> H = 1.

test_heur_win(o,S,H).
>> S = [[x, x, x], [o, x, o], [o, o, _G2485]],
>> H = -10000.

test_heur_win(x,S,H).
>> S = [[x, x, x], [o, x, o], [o, o, _G2485]],
>> H = 10000.

test_heur_loose(x,S,H).
>> S = [[o, o, o], [x, o, x], [x, x, _G2485]],
>> H = -10000.

test_heur_loose(o,S,H).
>> S = [[o, o, o], [x, o, x], [x, x, _G2485]],
>> H = 10000.

test_heur_nul(o,S,H). %idem avec x
>> S = [[x, o, x], [o, x, o], [o, x, o]],
>> H = 0
```
Le prédicat heuristique fonctionne pour tout les cas sauf pour la situation initiale avec le plateau vide.

## Implémentation de negamax
### Les clauses de negamax

```pl
/* 1 la profondeur maximale est atteinte */
negamax(J, S, Pmax, Pmax, [rien, H]):-
	heuristique(J,S,H).

/* 2 la profondeur maximale n'est pas  atteinte mais J ne
peut pas jouer*/
negamax(J, S, P, Pmax, [rien, H]):-	
	heuristique(J,S,H),
	ground(S).	/*ground -> pas de var libre -> J ne peux pas jouer*/
	
/*3 la profondeur maxi n'est pas atteinte et J peut encore
jouer*/
negamax(J, S, P, Pmax, [C1,V2]):-
	successeurs(J,S,Succ), not(ground(S)),
	loop_negamax(J,P,Pmax,Succ,L),
	meilleur(L,[C1,V1]),
	V2 is -V1.
```

### Le prédicat loop_negamax commenté
```pl
loop_negamax(_,_, _  ,[],                []).
loop_negamax(J,P,Pmax,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]) :-
	loop_negamax(J,P,Pmax,Succ,Reste_Couples), /*boucle jusqu'à la fin de Succ*/
	adversaire(J,A), /*définie A comme l'adversaire de J*/
	Pnew is P+1, /*incrémmente la profondeur P */
	negamax(A,Suiv,Pnew,Pmax, [_,Vsuiv]). /*applique l'algo negamax sur les elements contenus ds Succ, et avec [_,Vsuiv] on récupère leur valeur*/
```
### Le prédicat meilleur
```pl
/*le meilleur dans une liste a un seul element est cet element*/
	meilleur([Elem],Elem).
	
	meilleur([[Cx,Vx]|L],[Bestc,Bestv]):-
	L \= [],
	meilleur(L,[Cy,Vy]),
	((Vy < Vx)->
	/*entre X et Y on garde celui qui a la petite valeur de V*/
			[Bestc,Bestv]=[Cy,Vy]; [Bestc,Bestv]=[Cx,Vx]).
```

### Le prédicat main
```pl
main(B,V,Pmax) :-
	adversaire(J,A),
	joueur_initial(J),
	situation_initiale(S),
	negamax(J, S, 1, Pmax, [B, V]).
```
** Quel prédicat permet de connaître sous forme de liste l’ensemble des couples [Coord, Situation_Resultante]
tels que chaque élément (couple) associe le coup d’un joueur et la situation qui en résulte à partir d’une situation donnée ?
```pl
Cest le prédicat "successeurs" 
```
** Tester ce prédicat en déterminant la liste des couples [Coup, Situation Resultante] pour le joueur X dans la situation initiale.
```pl
test_succ(J,S,Succ) :- 
	joueur_initial(J),
	sit3(S),
	successeurs(J,S,Succ).
```

** Quel est le meilleur coup à jouer et le gain espéré pour une profondeur d’analyse de 1, 2, 3, 4 , 5 , 6 , 7, 8, 9 ?
Expliquer les résultats obtenus pour 9 (toute la grille remplie).
```pl
Au dessus de 7, "ERROR: Out of local stack" : le programme n'a pas assez de mémoire, les calculs sont trop longs

8 ?- main(B,V,7).
B = [2, 2],
V = 1 .

9 ?- main(B,V,6).
B = [2, 2],
V = 3 .

10 ?- main(B,V,5).
B = [2, 2],
V = 1 .

11 ?- main(B,V,4).
B = [2, 2],
V = 3 .

12 ?- main(B,V,3).
B = [2, 2],
V = 1 .

13 ?- main(B,V,2).
B = [2, 2],
V = 4 .

14 ?- main(B,V,1).
B = rien,
V = 0
```
** Comment ne pas développer inutilement des situations symétriques de situations déjà développées ?
	
** Que faut-il reprendre pour passer au jeu du puissance 4 ?
```pl
Il faut modifier successeur pour restreindre les coups suivants possibles à jouer.
En effet au puissance 4, on ne peut mettre des jetons que de haut en bas, et le jeton est positionné au plus bas possible
```

**Comment améliorer l’algorithme en élaguant certains coups inutiles (recherche Alpha-Beta) ?
```pl

```
```pl

```
```pl

```
