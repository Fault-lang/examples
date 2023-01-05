---- MODULE orchestrator ----
EXTENDS Integers, Sequences, TLC, FiniteSets

(* --algorithm orchestrator
variables 
    Loading = 0,
    Instances = 1,

define 
    Ready == [][Instances > 1]_Instances
end define;


process op \in 1..4
variables 
    
    begin
        Add:
            if Loading > 0 then
                Loading := Loading - 1;
                Instances := Instances + 1;
            end if;
        Remove:
            if Instances > 1 then
                Instances := Instances - 1;
            end if;
        
        Boot:
            Loading := Loading + 1;
        
end process;

end algorithm; *)
\* BEGIN TRANSLATION (chksum(pcal) = "5e362118" /\ chksum(tla) = "5ae7bb07")
VARIABLES Loading, Instances, pc

(* define statement *)
Ready == [][Instances > 1]_Instances


vars == << Loading, Instances, pc >>

ProcSet == (1..4)

Init == (* Global variables *)
        /\ Loading = 0
        /\ Instances = 1
        /\ pc = [self \in ProcSet |-> "Add"]

Add(self) == /\ pc[self] = "Add"
             /\ IF Loading > 0
                   THEN /\ Loading' = Loading - 1
                        /\ Instances' = Instances + 1
                   ELSE /\ TRUE
                        /\ UNCHANGED << Loading, Instances >>
             /\ pc' = [pc EXCEPT ![self] = "Remove"]

Remove(self) == /\ pc[self] = "Remove"
                /\ IF Instances > 1
                      THEN /\ Instances' = Instances - 1
                      ELSE /\ TRUE
                           /\ UNCHANGED Instances
                /\ pc' = [pc EXCEPT ![self] = "Boot"]
                /\ UNCHANGED Loading

Boot(self) == /\ pc[self] = "Boot"
              /\ Loading' = Loading + 1
              /\ pc' = [pc EXCEPT ![self] = "Done"]
              /\ UNCHANGED Instances

op(self) == Add(self) \/ Remove(self) \/ Boot(self)

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == (\E self \in 1..4: op(self))
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 

==========================================================================
