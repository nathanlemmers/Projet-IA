%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************

maina :-
	% initialisations Pf, Pu et Q 
	initial_state(S0), heuristique(S0, H0),
	G0 is 0, F0 is (H0+G0),
	empty(Pf1), empty(Pu1), empty(Q),
	insert([[F0, H0, G0], S0],Pf1, Pf), 
	insert([S0, [F0, H0, G0], nil, nil], Pu1, Pu),
	writeln("Début"),
	aetoile(Pf, Pu, Q).

	% lancement de Aetoile

	   %********
			% A FAIRE
			%********



%*******************************************************************************


aetoile(Pf, _, _) :-
	empty(Pf),
	!, 
	write( " PAS de SOLUTION : L’ETAT FINAL N’EST PAS ATTEIGNABLE !").


aetoile(Pf,Pu,Q) :-
	suppress_min([[F,_,_], U], Pf, _),
	final_state(U), 
	write("Solution trouvée : "),
	writeln(F) ,
	!,
	affiche_solution(Pu, Q).


aetoile(Pf, Pu, Q) :-
	suppress_min([[F,H,G], U], Pf, Pf1),
	%writeln(F),
	%writeln([[F, H, G], U]),
	%put_90(Pu),
	suppress([U, [F,H,G], Pere, A], Pu, Pu1),
	%writeln("Suppress fonctionne"),
	expand(U, G ,Lu),
	%writeln("Expand fonctionnne"),
	loop_successor(Lu, Pf1, Pu1, Q, Pf2, Pu2),
	insert([U, [F,H,G], Pere, A], Q, Q1),
	aetoile(Pf2, Pu2, Q1).

	
	
affiche_solution(Pu, Q) :-
	final_state(U),
	belongs([U, [_, _, _], Pere, A], Pu),
	writeln("Solution : "),
	affiche(Q, Pere),
	writeln(A).


affiche(Q, U) :-
	belongs([U,_,_,nil], Q),
	!.

affiche(Q, U) :-
	belongs([U,_,P,A], Q),
	affiche(Q,P),
	writeln(A).
	

expand(U, Gu, L) :-
	findall([U1, [F, H, G], U, A], (rule(A,1, U, U1), G is Gu+1, heuristique(U1, H), F is (H+G)), L).


loop_successor([], Pf, Pu, _, Pf, Pu) :-
%writeln("Fin"),
!.


loop_successor([[S0, _, _, _]|R], Pf, Pu, Q, Pf2, Pu2) :-
	belongs([S0,_, _, _], Q), 
	!,
	%writeln(R),
	loop_successor(R, Pf, Pu, Q, Pf2, Pu2).

loop_successor([[S0, [F0, _, _], _, _]|R], Pf, Pu, Q, Pf2, Pu2) :-
	belongs([S0, [F, _, _], _, _], Pu), 
	F0>=F,
	!,
	%writeln(R),
	loop_successor(R, Pf, Pu, Q, Pf2, Pu2).

loop_successor([[S0, [F0, H0, G0], Pere, A]|R], Pf, Pu, Q, Pf3, Pu3) :-
	belongs([S0, [F, H, G], P, B], Pu), 
	!,
	suppress([S0, [F, H, G] , P , B], Pu, Pu1), 
	suppress([[F, H, G], S0], Pf, Pf1), 
	insert([S0, [F0, H0, G0], Pere, A], Pu1, Pu2), 
	insert([[F0,H0,G0], S0], Pf1, Pf2),
	loop_successor(R, Pf2, Pu2, Q, Pf3, Pu3).

loop_successor([[S0, [F0, H0, G0], Pere, A]|R], Pf, Pu, Q, Pf3, Pu3) :-
	insert([S0, [F0, H0, G0], Pere, A], Pu, Pu2), 
	insert([[F0,H0,G0], S0], Pf, Pf2),
	loop_successor(R, Pf2, Pu2, Q, Pf3, Pu3).