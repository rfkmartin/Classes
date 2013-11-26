function drawMBR(mbr)

line([mbr.xmin mbr.xmin],[mbr.ymin mbr.ymax]);
line([mbr.xmax mbr.xmax],[mbr.ymin mbr.ymax]);
line([mbr.xmin mbr.xmax],[mbr.ymin mbr.ymin]);
line([mbr.xmin mbr.xmax],[mbr.ymax mbr.ymax]);
