---- MODULE cache ----
EXTENDS Integers, Sequences, TLC, FiniteSets

(* --algorithm cache
variables 
    Records = {"r1", "r2", "r3", "r4", "r5", "r6"},
    table = {},
    blocks = 0,

define 
    Capacity == Cardinality(table) <= 4
    OOD == [][Capacity]_table
    OOM == [][blocks < 4]_blocks
end define;


process op \in 1..4
variables 
    r \in Records,
    rec = "",
    begin
        Expire:
            while Cardinality(table) >= 3 do 
                rec := CHOOSE x \in table : TRUE;
                table := table \ {rec};
                blocks := blocks + 1;
                goto Release;
            end while;
        Add:
            if Cardinality(table) < 4 /\ r \notin table then 
                table := table \union {r};
                blocks := blocks + 1;
                goto Release;
            end if;
        Lookup:
            if r \in table then 
                blocks := blocks + 1;
                goto Release;
            else
                goto Add;
            end if;
        Release:
            if blocks > 0 then 
                blocks := blocks - 1;
            end if;
end process;

end algorithm; *)
\* BEGIN TRANSLATION (chksum(pcal) = "b11d7f85" /\ chksum(tla) = "54eeb738")
VARIABLES Records, table, blocks, pc

(* define statement *)
Capacity == Cardinality(table) <= 4
OOD == [][Capacity]_table
OOM == [][blocks < 4]_blocks

VARIABLES r, rec

vars == << Records, table, blocks, pc, r, rec >>

ProcSet == (1..4)

Init == (* Global variables *)
        /\ Records = {"r1", "r2", "r3", "r4", "r5", "r6"}
        /\ table = {}
        /\ blocks = 0
        (* Process op *)
        /\ r \in [1..4 -> Records]
        /\ rec = [self \in 1..4 |-> ""]
        /\ pc = [self \in ProcSet |-> "Expire"]

Expire(self) == /\ pc[self] = "Expire"
                /\ IF Cardinality(table) >= 3
                      THEN /\ rec' = [rec EXCEPT ![self] = CHOOSE x \in table : TRUE]
                           /\ table' = table \ {rec'[self]}
                           /\ blocks' = blocks + 1
                           /\ pc' = [pc EXCEPT ![self] = "Release"]
                      ELSE /\ pc' = [pc EXCEPT ![self] = "Add"]
                           /\ UNCHANGED << table, blocks, rec >>
                /\ UNCHANGED << Records, r >>

Add(self) == /\ pc[self] = "Add"
             /\ IF Cardinality(table) < 4 /\ r[self] \notin table
                   THEN /\ table' = (table \union {r[self]})
                        /\ blocks' = blocks + 1
                        /\ pc' = [pc EXCEPT ![self] = "Release"]
                   ELSE /\ pc' = [pc EXCEPT ![self] = "Lookup"]
                        /\ UNCHANGED << table, blocks >>
             /\ UNCHANGED << Records, r, rec >>

Lookup(self) == /\ pc[self] = "Lookup"
                /\ IF r[self] \in table
                      THEN /\ blocks' = blocks + 1
                           /\ pc' = [pc EXCEPT ![self] = "Release"]
                      ELSE /\ pc' = [pc EXCEPT ![self] = "Add"]
                           /\ UNCHANGED blocks
                /\ UNCHANGED << Records, table, r, rec >>

Release(self) == /\ pc[self] = "Release"
                 /\ IF blocks > 0
                       THEN /\ blocks' = blocks - 1
                       ELSE /\ TRUE
                            /\ UNCHANGED blocks
                 /\ pc' = [pc EXCEPT ![self] = "Done"]
                 /\ UNCHANGED << Records, table, r, rec >>

op(self) == Expire(self) \/ Add(self) \/ Lookup(self) \/ Release(self)

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == (\E self \in 1..4: op(self))
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 

==========================================================================
