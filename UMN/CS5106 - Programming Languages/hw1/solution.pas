PROGRAM Prefix; 

(******************************************************************
 * solution.pas
 *
 * checks whether a list is a sublist of another
 *
 * Robert F.K. Martin
 * ID 1505151
 * CSci 5106 - Programming Languages
 * Lab 1
 * 
 *****************************************************************)

TYPE 
  arraytype = array[1..50] of integer;
VAR
  one,two : arraytype;
  i, cnt, usedone, usedtwo : integer;
  good : boolean;

function getNum : integer; 
var 
  it : integer;
begin
  read(it); 
  getNum := it;
end;

begin 
  write("How many elements in list 1? ");
  usedone := getNum;
  for i := 1 to usedone do
  begin
    write("List 1 - #", i:2, ": "); 
    one[i] := getNum;
  end;
 
  write("How many elements in list 2? ");
  usedtwo := getNum;
  for i := 1 to usedtwo do
  begin
    write("List 2 - #", i:2, ": "); 
    two[i] := getNum;
  end;
 
  good := true;
  if usedone > usedtwo then 
     good := false
  else
  (* Compare the first elements of list 1 and 2 incrementally. If a match
   * is found, note the position and continue to match the remainder of 
   * list 1 with list 2. If there are no failures to the end of list 1,
   * we have a match. Otherwise, go back to the previous position in list
   * 2 and continue as before. *)   
  begin
     good := false;
     for i := 1 to usedtwo do
     begin
	if two[i] = one[1] then
	   begin
	      cnt := 2;
	      while (((i + cnt - 1) <= usedtwo) and (one[cnt] = two[i+cnt-1])) do
	      begin
		 if (cnt = usedone) then good := true;
		 cnt := cnt + 1
	      end
	   end
     end
  end;

   if usedone = 0 then
      good := true;

  if good then
    writeln("List 1 is a sublist of list 2.")
  else
    writeln("List 1 is NOT a sublist of list 2.")
end.
