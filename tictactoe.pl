/*:- lib(listut). */
:-use_module(library(clpfd), [transpose/2 as transp]).
	/*********************************
	DESCRIPTION DU JEU DU TIC-TAC-TOE
	*********************************/

	/*
	Une situation est decrite par une matrice 3x3.
	Chaque case est soit un emplacement libre, soit contient le symbole d un des 2 joueurs (o ou x)

	Contrairement a la convention du tp pr�c�dent, pour mod�liser une case libre
	dans une matrice on n'utilise pas une constante sp�ciale (ex : nil, 'vide', 'libre','inoccupee' ...);
	On utilise plut�t une variable libre (_), c'est�-dire un terme non instanci� ('_').
	La situation initiale est donc une matrice 3x3 composee uniquement de variables libres (_).
	Ceci est possible car le jeu consiste � instancier la grille avec des symboles et non � d�placer les symbles d�j� affect�s.



	Jouer un coup, c-a-d placer un symbole dans une grille S1 ne consiste pas � g�n�rer une nouvelle grille S2 obtenue
	en copiant d'abord S1 puis en remplacant le symbole de case libre par le symbole du joueur, mais plus simplement
	� INSTANCIER (au sens Prolog) la variable libre qui repr�sentait la case libre par la valeur associ�e au joueur, ex :
	Case = Joueur, ou a realiser indirectement cette instanciation par unification via un pr�dicat comme member/2, select/3, nth1/3 ...

	Ainsi si on joue un coup en S, S perd une variable libre, mais peut continuer � s'appeler S (on n a pas besoin de la d�signer
	par un nouvel identificateur).
	La situation initiale est une "matrice" 3x3 (liste de 3 listes de 3 termes chacune)
	o� chacun des 9 termes est une variable libre.
	*/

situation_initiale([ [_,_,_],
                     [_,_,_],
                     [_,_,_] ]).

	% Convention (arbitraire) : c'est x qui commence

joueur_initial(x).


	% Definition de la relation adversaire/2

adversaire(x,o).
adversaire(o,x).


	/****************************************************
	 DEFINIR ICI � l aide du pr�dicat ground/1 comment
	 reconnaitre une situation terminale dans laquelle il
	 n y a aucun emplacement libre : aucun joueur ne peut
	 continuer � jouer (quel qu'il soit).
	 ****************************************************/

situation_terminale(_Joueur, Situation) :-
	ground(Situation).

/***************************
 DEFINITIONS D'UN ALIGNEMENT
 ***************************/

alignement(L, Matrix) :- ligne(    L,Matrix).
alignement(C, Matrix) :- colonne(  C,Matrix).
alignement(D, Matrix) :- diagonale(D,Matrix).

% TEST HEURISTIQUE
sit1([[A,x,B],[C,x,o],[o,D,E]]).
sit2([[a,b,c],[d,e,f],[g,h,i]]).
win([[x,x,x],[o,x,o],[o,o,E]]).
loose([[o,o,o],[x,o,x],[x,x,E]]).
nul([[x,o,x],[o,x,o],[o,x,o]]).
sit3([[o,F,o],[x,o,x],[x,V,x]]).

/***************************
 TEST SOUS FONCTIONS
 ***************************/

test_ali(L,M) :- sit2(M), alignement(L,M).
test_lig(L,M) :- sit2(M),ligne(L,M).
test_col(L,M) :- sit2(M),colonne(L,M).
test_diag(L,M) :- sit2(M), diagonale(L,M).

	/********************************************
	 DEFINIR ICI chaque type d'alignement maximal
 	 existant dans une matrice carree NxN.
	 ********************************************/

ligne(L, M) :-
	member(L,M).


colonne(C,M) :-
	transp(M,Mt),
	ligne(C,Mt).


	/* Definition de la relation liant une diagonale D � la matrice M dans laquelle elle se trouve.
		il y en a 2 sortes de diagonales dans une matrice carree(https://fr.wikipedia.org/wiki/Diagonale) :
		- la premiere diagonale (principale) (descendante) : (A I)
		- la seconde diagonale  (ascendante)  : (R Z)
		A . . . . . . . Z
		. \ . . . . . / .
		. . \ . . . / . .
		. . . \ . / . . .
		. . . . X . . .
		. . . / . \ . . .
		. . / . . . \ . .
		. / . . . . . \ .
		R . . . . . . . I
	*/

diagonale(D, M) :- premiere_diag(1,D,M); seconde_diag(1,D,M).

premiere_diag(_,[],[]).
premiere_diag(K,[E|D],[Ligne|M]) :-
	nth1(K,Ligne,E),
	K1 is K+1,
	premiere_diag(K1,D,M).

% definition de la seconde diagonale A COMPLETER

seconde_diag(_,[],[]).
seconde_diag(K,[E|D],[Ligne|M]) :-
	reverse(Ligne,LigneRev),
	nth1(K,LigneRev,E),
	K1 is K+1,
	seconde_diag(K1,D,M).


	/***********************************
	 DEFINITION D'UN ALIGNEMENT POSSIBLE
	 POUR UN JOUEUR DONNE
	 **********************************/

possible([X|L], J) :- unifiable(X,J), possible(L,J).
possible([   ], _).

	/* Attention
	il faut juste verifier le caractere unifiable
	de chaque emplacement de la liste, mais il ne
	faut pas realiser l'unification.
	*/

unifiable(X,J) :-
	var(X); X==J.


	/**********************************
	 DEFINITION D'UN ALIGNEMENT GAGNANT
	 OU PERDANT POUR UN JOUEUR DONNE J
	 **********************************/

	/*
	Un alignement gagnant pour J est un alignement
possible pour J qui n'a aucun element encore libre.
Un alignement perdant pour J est gagnant
pour son adversaire.
	*/
alignement_gagnant([],_).
alignement_gagnant([X|L], J) :-
	ground([X|L]),
	X==J,
	alignement_gagnant(L, J).

alignement_perdant(Ali, J) :-
	adversaire(J,A),
	alignement_gagnant(Ali,A).


	/******************************
	DEFINITION D'UN ETAT SUCCESSEUR
	*******************************/

     /*Il faut definir quelle op�ration subit une matrice M representant la situation courante
	lorsqu'un joueur J joue en coordonnees [L,C]
     */

successeur(J,Etat,[L,C]) :-
	nth1(L,Etat,Lig), nth1(C,Lig,J).


	/**************************************
   	 EVALUATION HEURISTIQUE D'UNE SITUATION
  	 **************************************/

/*
1/ l'heuristique est +infini si la situation J est gagnante pour J
2/ l'heuristique est -infini si la situation J est perdante pour J
3/ sinon, on fait la difference entre :
	   le nombre d'alignements possibles pour J
	moins
 	   le nombre d'alignements possibles pour l'adversaire de J
*/


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

% A FAIRE 					cas 3
heuristique(J,Situation,H) :-
findall(Ali, (alignement(Ali,Situation),possible(Ali,J)),L1),
adversaire(J,A),
length(L1,N1),
findall(Ali, (alignement(Ali,Situation),possible(Ali,A)),L2),
length(L2,N2),
H is (N1-N2).

% TEST
test_heur_init(J,S,H) :- situation_initiale(S),heuristique(J,S,H).
test_heur(J,S,H) :- sit3(S),heuristique(J,S,H).
test_heur_win(J,S,H) :- win(S),heuristique(J,S,H).
test_heur_loose(J,S,H) :- loose(S),heuristique(J,S,H).
test_heur_nul(J,S,H) :- nul(S),heuristique(J,S,H).
