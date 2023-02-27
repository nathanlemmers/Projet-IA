%*******************************************************************************
%                                    AETOILE
%*******************************************************************************



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
	suppress([U, [F,H,G], Pere, A], Pu, Pu1),
	expand(U, G ,Lu),
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
!.


loop_successor([[S0, _, _, _]|R], Pf, Pu, Q, Pf2, Pu2) :-
	belongs([S0,_, _, _], Q), 
	!,
	loop_successor(R, Pf, Pu, Q, Pf2, Pu2).

loop_successor([[S0, [F0, _, _], _, _]|R], Pf, Pu, Q, Pf2, Pu2) :-
	belongs([S0, [F, _, _], _, _], Pu), 
	F0>=F,
	!,
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