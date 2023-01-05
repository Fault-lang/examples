---- MODULE position ----
EXTENDS Integers, TLC, Naturals

(* --algorithm position
variables 
    From \in 0..9, 
    To \in 0..9,

define 
    Landing == [][From >= 0]_From
end define;


process move \in 1..4
variables
    m \in 1..9,  
    begin
        Up:
            while From < To do 
                From := From + m
            end while;
        Down:
            while From > To do 
                From := From - m
            end while;
end process;

end algorithm; *)
\* BEGIN TRANSLATION (chksum(pcal) = "7eef1f49" /\ chksum(tla) = "a7f3544b")
VARIABLES From, To, pc

(* define statement *)
Landing == [][From >= 0]_From

VARIABLE m

vars == << From, To, pc, m >>

ProcSet == (1..4)

Init == (* Global variables *)
        /\ From \in 0..9
        /\ To \in 0..9
        (* Process move *)
        /\ m \in [1..4 -> 1..9]
        /\ pc = [self \in ProcSet |-> "Up"]

Up(self) == /\ pc[self] = "Up"
            /\ IF From < To
                  THEN /\ From' = From + m[self]
                       /\ pc' = [pc EXCEPT ![self] = "Up"]
                  ELSE /\ pc' = [pc EXCEPT ![self] = "Down"]
                       /\ From' = From
            /\ UNCHANGED << To, m >>

Down(self) == /\ pc[self] = "Down"
              /\ IF From > To
                    THEN /\ From' = From - m[self]
                         /\ pc' = [pc EXCEPT ![self] = "Down"]
                    ELSE /\ pc' = [pc EXCEPT ![self] = "Done"]
                         /\ From' = From
              /\ UNCHANGED << To, m >>

move(self) == Up(self) \/ Down(self)

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == (\E self \in 1..4: move(self))
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 

==========================================================================
