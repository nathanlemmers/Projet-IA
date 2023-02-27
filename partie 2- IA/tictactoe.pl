	/*********************************
	DESCRIPTION DU JEU DU TIC-TAC-TOE
	*********************************/

	/*
	Une situation est decrite par une matrice 3x3.
	Chaque case est soit un emplacement libre (Variable LIBRE), soit contient le symbole d'un des 2 joueurs (o ou x)

	Contrairement a la convention du tp precedent, pour modeliser une case libre
	dans une matrice on n'utilise pas une constante speciale (ex : nil, 'vide', 'libre','inoccupee' ...);
	On utilise plut�t un identificateur de variable, qui n'est pas unifiee (ex : X, A, ... ou _) .
	La situation initiale est une "matrice" 3x3 (liste de 3 listes de 3 termes chacune)
	o� chaque terme est une variable libre.	
	Chaque coup d'un des 2 joureurs consiste a donner une valeur (symbole x ou o) a une case libre de la grille
	et non a deplacer des symboles deja presents sur la grille.		
	
	Pour placer un symbole dans une grille S1, il suffit d'unifier une des variables encore libres de la matrice S1,
	soit en ecrivant directement Case=o ou Case=x, ou bien en accedant a cette case avec les predicats member, nth1, ...
	La grille S1 a change d'etat, mais on n'a pas besoin de 2 arguments representant la grille avant et apres le coup,
	un seul suffit.
	Ainsi si on joue un coup en S, S perd une variable libre, mais peut continuer a s'appeler S (on n'a pas besoin de la designer
	par un nouvel identificateur).
	*/

situation_initiale([ [_,_,_],
                     [_,_,_],
                     [_,_,_] ]).

	% Convention (arbitraire) : c'est x qui commence

joueur_initial(x).


	% Definition de la relation adversaire/2

adversaire(x,o).
adversaire(o,x).


situation_terminale(_Joueur, Situation) :-  
	ground(Situation).

situation_terminale(J, Sit) :-
	alignement(Alig,Sit),
   	alignement_perdant(Alig,J), !.	

situation_terminale(J, Sit) :-
	alignement(Alig,Sit),
   	alignement_gagnant(Alig,J), !.

	/***************************
	DEFINITIONS D'UN ALIGNEMENT
	***************************/

alignement(L, Matrix) :- ligne(    L,Matrix).
alignement(C, Matrix) :- colonne(  C,Matrix).
alignement(D, Matrix) :- diagonale(D,Matrix).


ligne(L, M) :- 
	member(L, M).


colonne(C,M) :- colonne(C, M, _K).


colonne([], [], _).
colonne([E|C], [L|M], K) :-
	nth1(K,L, E),
	colonne(C, M, K).
	

diagonale(D, M) :- 
	premiere_diag(1,D,M).


diagonale(D, M) :- 
	length(M, K),
	seconde_diag(K, D, M).

	
premiere_diag(_,[],[]).
premiere_diag(K,[E|D],[Ligne|M]) :-
	nth1(K,Ligne,E),
	K1 is K+1,
	premiere_diag(K1,D,M).

seconde_diag(_,[],[]).
seconde_diag(K,[E|D],[Ligne|M]) :-
	nth1(K,Ligne,E),
	K1 is K-1,
	seconde_diag(K1,D,M).


	/*****************************
	 DEFINITION D'UN ALIGNEMENT 
	 POSSIBLE POUR UN JOUEUR DONNE
	 *****************************/

possible([X|L], J) :- unifiable(X,J), possible(L,J).
possible(  [],  _).

unifiable(X,_) :-
	var(X), 
	!.

unifiable(X,X).
	
	/**********************************
	 DEFINITION D'UN ALIGNEMENT GAGNANT
	 OU PERDANT POUR UN JOUEUR DONNE J
	 **********************************/
	/*
	Un alignement gagnant pour J est un alignement
possible pour J qui n'a aucun element encore libre.
	*/
	
	/*
	Remarque : le predicat ground(X) permet de verifier qu'un terme
	prolog quelconque ne contient aucune partie variable (libre).
	exemples :
		?- ground(Var).
		no
		?- ground([1,2]).
		yes
		?- ground(toto(nil)).
		yes
		?- ground( [1, toto(nil), foo(a,B,c)] ).
		no
	*/
		
	/* Un alignement perdant pour J est un alignement gagnant pour son adversaire. */


alignement_gagnant(Ali, J) :-  ground(Ali), possible(Ali, J).

alignement_perdant(Ali, J) :- adversaire(J,A), alignement_gagnant(Ali, A).


test_alignement:-
	alignement_gagnant([x,x,x], x),
	alignement_gagnant([o,o,o], o),
	alignement_perdant([x,x,x], o),
	alignement_perdant([o,o,o], x),
	not(alignement_gagnant([_,x,x], x)),
	not(alignement_gagnant([o,x,_], x)),
	not(alignement_perdant([_,o,x], x)).

	/* ****************************
	DEFINITION D'UN ETAT SUCCESSEUR
	****************************** */

	/* 
	Il faut definir quelle operation subit la matrice
	M representant l'Etat courant
	lorsqu'un joueur J joue en coordonnees [L,C]
	*/	




successeur(J, Etat,[L,C]) :- 
	nth1(L, Etat, Ligne), nth1(C, Ligne, P),
	var(P),
	P=J.

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


heuristique(J,Situation,H) :-		% cas 2
   H = -10000,				% grand nombre approximant -infini
   alignement(Alig,Situation),
   alignement_perdant(Alig,J), !.	

heuristique(J,Situation,H) :-		% cas 1
   H = 10000,				% grand nombre approximant +infini
   alignement(Alig,Situation),
   alignement_gagnant(Alig,J), !.
	

% on ne vient ici que si les cut precedents n'ont pas fonctionne,
% c-a-d si Situation n'est ni perdante ni gagnante.

%cas 3
heuristique(J,Situation,H) :-
	findall(1, (alignement(Ali, Situation),possible(Ali,J)), Poss),
	length(Poss, K),
	adversaire(J, A),
	findall(1, (alignement(Ali, Situation),possible(Ali,A)), Poss2),
	length(Poss2, K2),
	H is (K-K2).


test_heuristique_initial :-
	[tictactoe], situation_initiale(S), heuristique(x, S, 0).

test_heuristique :-
	heuristique(x,[[o,o],[o,o]], -10000),
	heuristique(x,[[x,x],[x,x]], 10000),
	heuristique(x,[[x,o],[_,_]], 0),
	heuristique(x,[[x,_,_],[_,o,x],[_,x,o]],1),
	heuristique(x,[[x,_,_],[_,_,o],[_,x,_]],3).


