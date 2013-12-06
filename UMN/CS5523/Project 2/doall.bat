
apriori.exe -ts -s.01 T10I4D100K_new.dat problem1a1.txt
perl addemup.pl problem1a1.txt
apriori.exe -ts -s.02 T10I4D100K_new.dat problem1a2.txt
perl addemup.pl problem1a2.txt
apriori.exe -ts -s.03 T10I4D100K_new.dat problem1a3.txt
perl addemup.pl problem1a3.txt

apriori.exe -ts -s5 -m2 -n15 mushroom_new.dat problem1b1.txt
perl addemup.pl problem1b1.txt
apriori.exe -ts -s10 -m2 -n15 mushroom_new.dat problem1b2.txt
perl addemup.pl problem1b2.txt
apriori.exe -ts -s20 -m2 -n15 mushroom_new.dat problem1b3.txt
perl addemup.pl problem1b3.txt

apriori.exe -ts -s5 mushroom_new.dat problem1c1.txt
wc -l problem1c1.txt
apriori.exe -tc -s5 mushroom_new.dat problem1c2.txt
wc -l problem1c2.txt
apriori.exe -tm -s5 mushroom_new.dat problem1c3.txt
wc -l problem1c3.txt
apriori.exe -ts -s.01 T10I4D100K_new.dat problem1c3.txt
wc -l problem1c3.txt
apriori.exe -tc -s.01 T10I4D100K_new.dat problem1c4.txt
wc -l problem1c4.txt
apriori.exe -tm -s.01 T10I4D100K_new.dat problem1c5.txt
wc -l problem1c5.txt

apriori.exe -tr -s5 -c25 Teams_new.dat problem2a1.txt problem2a1.out
cat problem2a1.out
cat problem2a1.txt

apriori.exe -ts -m0 -n1 -s0 la1_new.txt problem3a1.txt
cat problem3a1.txt
apriori.exe -ts -m2 -s10 la1_new.txt problem3b1.txt
cat problem3b1.txt
apriori.exe -ts -m2 -s.466 la1_new.txt problem3c1.txt
cat problem3c1.txt

hcwin.exe -th -s0 -c30 la1_new.txt la1.out
cat la1.out