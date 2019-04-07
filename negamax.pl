	/*
	Ce programme met en oeuvre l'algorithme Minmax (avec convention
	negamax) et l'illustre sur le jeu du TicTacToe (morpion 3x3)
	*/
	
:- [tictactoe].


	/****************************************************
  	ALGORITHME MINMAX avec convention NEGAMAX : negamax/5
  	*****************************************************/

	/*
	negamax(+J, +Etat, +P, +Pmax, [?Coup, ?Val])

	SPECIFICATIONS :

	retourne pour un joueur J donne, devant jouer dans
	une situation donnee Etat, de profondeur donnee P,
	le meilleur couple [Coup, Valeur] apres une analyse
	pouvant aller jusqu'a la profondeur Pmax.

	Il y a 3 cas a decrire (donc 3 clauses pour negamax/5)
	
	1/ la profondeur maximale est atteinte : on ne peut pas
	developper cet Etat ; 
	il n'y a donc pas de coup possible a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	2/ la profondeur maximale n'est pas  atteinte mais J ne
	peut pas jouer ; au TicTacToe un joueur ne peut pas jouer
	quand le tableau est complet (totalement instancie) ;
	il n'y a pas de coup a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	3/ la profondeur maxi n'est pas atteinte et J peut encore
	jouer. Il faut evaluer le sous-arbre complet issu de Etat ; 

	- on determine d'abord la liste de tous les couples
	[Coup_possible, Situation_suivante] via le predicat
	 successeurs/3 (deja fourni, voir plus bas).

	- cette liste est passee a un predicat intermediaire :
	loop_negamax/5, charge d'appliquer negamax sur chaque
	Situation_suivante ; loop_negamax/5 retourne une liste de
	couples [Coup_possible, Valeur]

	- parmi cette liste, on garde le meilleur couple, c-a-d celui
	qui a la plus petite valeur (cf. predicat meilleur/2);
	soit [C1,V1] ce couple optimal. Le predicat meilleur/2
	effectue cette selection.

	- finalement le couple retourne par negamax est [Coup, V2]
	avec : V2 is -V1 (cf. convention negamax vue en cours).

A FAIRE : ECRIRE ici les clauses de negamax/5
.....................................
	*/
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


	/*******************************************
	 DEVELOPPEMENT D'UNE SITUATION NON TERMINALE
	 successeurs/3 
	 *******************************************/

	 /*
   	 successeurs(+J,+S, ?Succ)

   	 retourne la liste des couples [Coup, Etat_Suivant]
 	 pour un joueur donne dans une situation donnee 
	 */

successeurs(J,S,Succ) :-
	copy_term(S, Etat_Suiv),
	findall([Coup,Etat_Suiv],
		    successeur(J,Etat_Suiv,Coup),
		    Succ).

	/*************************************
         Boucle permettant d'appliquer negamax 
         a chaque situation suivante :
	*************************************/

	/*
	loop_negamax(+J,+P,+Pmax,+Successeurs,?Liste_Couples)
	retourne la liste des couples [Coup, Valeur_Situation_Suivante]
	a partir de la liste des couples [Coup, Situation_Suivante]
	*/

loop_negamax(_,_, _  ,[],                []).
loop_negamax(J,P,Pmax,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]) :-
	loop_negamax(J,P,Pmax,Succ,Reste_Couples), /*boucle jusqu'� la fin de Succ*/
	adversaire(J,A), /*d�finie A comme l'adversaire de J*/
	Pnew is P+1, /*incr�mmente la profondeur P */
	negamax(A,Suiv,Pnew,Pmax, [_,Vsuiv]). /*applique l'algo negamax sur les elements contenus ds Succ, et avec [_,Vsuiv] on r�cup�re leur valeur*/

	/*

A FAIRE : commenter chaque litteral de la 2eme clause de loop_negamax/5,
	en particulier la forme du terme [_,Vsuiv] dans le dernier
	litteral ?
	*/

	/*********************************
	 Selection du couple qui a la plus
	 petite valeur V 
	 *********************************/

	/*
	meilleur(+Liste_de_Couples, ?Meilleur_Couple)

	SPECIFICATIONS :
	On suppose que chaque element de la liste est du type [C,V]
	- le meilleur dans une liste a un seul element est cet element
	- le meilleur dans une liste [X|L] avec L \= [], est obtenu en comparant
	  X et Y,le meilleur couple de L 
	  Entre X et Y on garde celui qui a la petite valeur de V.

A FAIRE : ECRIRE ici les clauses de meilleur
	*/
	/*le meilleur dans une liste a un seul element est cet element*/
	meilleur([Elem],Elem).
	
	meilleur([[Cx,Vx]|L],[Bestc,Bestv]):-
	L \= [],
	meilleur(L,[Cy,Vy]),
	((Vy < Vx)->
	/*entre X et Y on garde celui qui a la petite valeur de V*/
			[Bestc,Bestv]=[Cy,Vy]; [Bestc,Bestv]=[Cx,Vx]).
	
	/*Cest le pr�dicat "successeurs" qui permet de conna�tre sous forme de liste l�ensemble des couples [Coord, Situation_Resultante]
tels que chaque �l�ment (couple) associe le coup d�un joueur et la situation qui en r�sulte � partir d�une situation donn�e.*/
/* Tester ce pr�dicat en d�terminant la liste des couples [Coup, Situation Resultante] pour le joueur X dans la situation initiale.*/

test_succ(J,S,Succ) :- 
	joueur_initial(J),
	sit3(S),
	successeurs(J,S,Succ).

	/******************
  	PROGRAMME PRINCIPAL
  	*******************/
		
main(B,V,Pmax) :-
	adversaire(J,A),
	joueur_initial(J),
	situation_initiale(S),
	negamax(J, S, 1, Pmax, [B, V]).
	

	/*
A FAIRE :
	Compl�ter puis tester le programme principal pour plusieurs valeurs de la profondeur maximale.
	Pmax = 1, 2, 3, 4 ...
	Commentez les r�sultats obtenus.
	*/
	
/*
4.1 Quel est le meilleur coup � jouer et le gain esp�r� pour une profondeur d�analyse de 1, 2, 3, 4 , 5 , 6 , 7, 8, 9
Expliquer les r�sultats obtenus pour 9 (toute la grille remplie).
Au dessus de 7, error out of stack (le programme n'a pas assez de m�moire)


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
V = 0 */

/*4.2 Comment ne pas d�velopper inutilement des situations sym�triques de situations d�j� d�velopp�es ?*/
	
/*4.3 Que faut-il reprendre pour passer au jeu du puissance 4 ?*/
/*il faut modifier successeur pour restreindre les coups suivants possibles � jouer*/
