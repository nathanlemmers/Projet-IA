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

	negamax(J, Etat, P, P, [rien, Val]) :-
		heuristique(J, Etat, Val),
		!.


	negamax(J, Etat, _, _, [rien, Val]) :-
		situation_terminale(J, Etat),
		heuristique(J, Etat, Val),
		!.

	negamax(J, Etat, P, Pmax, [Coup, Val]) :-
		successeurs(J, Etat, ListeSucc),
		loop_negamax(J, P, Pmax, ListeSucc, ListeValeur),
		meilleur(ListeValeur,[Coup, V1]),
		Val is -V1.






	/*******************************************
	 DEVELOPPEMENT D'UNE SITUATION NON TERMINALE
	 successeurs/3 
	 *******************************************/

	 /*
   	 successeurs(+J,+Etat, ?Succ)

   	 retourne la liste des couples [Coup, Etat_Suivant]
 	 pour un joueur donne dans une situation donnee 
	 */

successeurs(J,Etat,Succ) :-
	copy_term(Etat, Etat_Suiv),
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
	loop_negamax(J,P,Pmax,Succ,Reste_Couples),	%récursivité pour travailler sur les coups suivant et créer l'arbre
	adversaire(J,A),							%Changement de joueur pour anticiper le coup suivant et alterner qui joue
	Pnew is P+1,								% Incrémentation de la profondeur pour attendre la PMax (P= P+1)
	negamax(A,Suiv,Pnew,Pmax, [_,Vsuiv]).  		%Appel de Negamax avec l'adversaire pour jouer le prochain coup, pour récuperer la valeur de l'heuristique correspondante avec
												%Vsup. Le coup est laissé vide pour être libre.				
	%Ce prédicat sert à lier les différents coup à leur valeur heuristique.
	/*

A FAIRE : commenter chaque litteral de la 2eme clause de loop_negamax/5,
	en particulier la forme du terme [_,Vsuiv] dans le dernier
	litteral ?
	*/

	/*********************************
	 Selection du couple qui a la pluss
	 petite valeur V 
	 ********************************/

	meilleur([[Coup, Valeur]], [Coup, Valeur]):-
	!.
	

	meilleur([[Coup, Valeur]|Suiv], [Coup, Valeur]) :-
		meilleur(Suiv, [_, MValeur]),
		Valeur=<MValeur.

	meilleur([[_, Valeur]|Suiv], [NCoup, NValeur]) :-
		meilleur(Suiv, [NCoup, NValeur]),
		Valeur>NValeur,
		!.

/*




	SPECIFICATIONS :
	On suppose que chaque element de la liste est du type [C,V]
	- le meilleur dans une liste a un seul element est cet element
	- le meilleur dans une liste [X|L] avec L \= [], est obtenu en comparant
	  X et Y,le meilleur couple de L 
	  Entre X et Y on garde celui qui a la petite valeur de V.

A FAIRE : ECRIRE ici les clauses de meilleur/2
	*/



	/******************
  	PROGRAMME PRINCIPAL
  	*******************/

main(C,V, Pmax) :-
	situation_initiale(S), joueur_initial(J),
	negamax(J, S, 0, Pmax, [C, V]),
	!.        




test_unitaire:-
	joueur_initial(J),
	negamax(J, [[x,o,_],
				[x,o,_],
				[_,_,_]],0, 8, [[3,1],10000]) ,
	negamax(J, [[_,o,_],
				[x,o,_],
				[_,_,_]],0, 2, [[3,2],_]) ,
	negamax(J, [[x,_,o],
				[_,x,o],
				[_,_,_]],0, 8, [[3,3],10000]),
	negamax(J, [[_,o,_],
					[x,o,_],
					[_,_,_]],0, 8, [_,-10000]).

%Pmax = 1, C = [2, 2], V = 4.
%Pmax = 2, C = [2, 2], V = 1.
%Pmax = 3, C = [2, 2], V = 3.
%Pmax = 4, C = [2, 2], V = 1.
%Pmax = 5, C = [2, 2], V = 3.
%Pmax = 6, C = [2, 2], V = 1.
%Pmax = 7, C = [2, 2], V = 2.
%Pmax = 8, C = [1, 1], V = 0.
%Pmax = 9, C = [1, 1], V = 0.

%Au début l'heuristique alterne car cela depend du dernier coup qu'il a prédit. Pour les nombres impair il joue en dernier et se voit vainqueur, et pour les
%nombres pair il se voit perdant car c'est l'adervsaire qui a jouéé.
%A partir de 8, il découvre qu'il ne peut en réalité pas gagner si l'adversaire joue bien. C'est pour cela que l'heuristique vaut 0.

	/*
A FAIRE :
	Compl�ter puis tester le programme principal pour plusieurs valeurs de la profondeur maximale.
	Pmax = 1, 2, 3, 4 ...
	Commentez les r�sultats obtenus.
	*/

