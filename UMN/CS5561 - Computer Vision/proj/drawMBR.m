function drawMBR(mbr)

h=line([mbr.a(2) mbr.b(2)],[mbr.a(1) mbr.b(1)]);
set(h,'Color',[1 0 0],'LineWidth',2);
h=line([mbr.a(2) mbr.c(2)],[mbr.a(1) mbr.c(1)]);
set(h,'Color',[1 0 0],'LineWidth',2);
h=line([mbr.c(2) mbr.d(2)],[mbr.c(1) mbr.d(1)]);
set(h,'Color',[1 0 0],'LineWidth',2);
h=line([mbr.b(2) mbr.d(2)],[mbr.b(1) mbr.d(1)]);
set(h,'Color',[1 0 0],'LineWidth',2);
