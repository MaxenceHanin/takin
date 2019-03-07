# TP1 : A*
tom.portoleau@laas.fr
rbailonr@laas.fr
## Application au takin

### Familiarisation avec le problème de Taquin 3*3

** Comment sont modélisées la situation initiale et la situation finale du système ?**

Il y a un prédicat par état initial et un prédicat état final, chaque état est représenté sous forme de matrice.

** Quelle structure de données (quel type de terme Prolog) permettrait de représenter une situation du Taquin 4x4, par
exemple la situation finale suivante **

C'est donc aussi un prédicat avec une matrice qui répresente cet état :
```pl
initial_state([ [1, 2, 3, 4],
                [5, 6, 7, 8],
                [9, 10, 11, 12],
                [13, 14, 15, vide]]).
```

** Quelle requête permet de déterminer chaque situation suivante (successeur) S de l'état initial du Taquin 3×3 ? Il doit y avoir 3 réponses possibles. **

Trois mouvements possible donc 3 réponses possibles :

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

** Quelle requête permet d'avoir les 3 réponses d'un coup regroupées dans une liste ?  **

```pl
initial_state(IS), findall(NS,rule(Y,1,IS,NS),L).
>> IS = [[b, h, c], [a, f, d], [g, vide, e]]
>> NS = NS
>> Y = Y
>> L = [[[b, h, c], [a, vide, d], [g, f, e]], [[b, h, c], [a, f, d], [vide, g, e]], [[b, h, c], [a, f, d], [g, e, vide]]]
```

** Quelle requête permet d'avoir la liste de tous les couples [A, S] tels que S est la situation qui résulte de l'action A
appliquée dans l'état initial ? **

```pl
initial_state(IS), findall([Y,NS],rule(Y,1,IS,NS),L).
>> IS = [[b, h, c], [a, f, d], [g, vide, e]]
>> NS = NS
>> Y = Y
>> L = [[up, [[b, h, c], [a, vide, d], [g, f, e]]], [left, [[b, h, c], [a, f, d], [vide, g, e]]], [right, [[b, h, c], [a, f, d], [g, e, vide]]]]
```
### Développement des 2 heuristiques

#### Nombre de pièce maplacées
Pour trouver le nombre de pièce malplacées on définit d'abord un prédicat nous permettant de comparer deux éléments d'une liste puis un prédicat appelant cette comparaison sur une ligne de nos matrices puis un prédicat appelant ces différentes lignes.

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
```
#### Distance de Manhattan

```pl
coord([lig,col], Mat, Elt) #peut servir a avoir l'element a partir d'une coordonnee ou les coordonnees d'un element

```
