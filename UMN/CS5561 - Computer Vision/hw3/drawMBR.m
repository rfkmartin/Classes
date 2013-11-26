function drawMBR(mbr)

line([mbr.ymin mbr.ymin],[mbr.xmin mbr.xmax]);
line([mbr.ymax mbr.ymax],[mbr.xmin mbr.xmax]);
line([mbr.ymin mbr.ymax],[mbr.xmin mbr.xmin]);
line([mbr.ymin mbr.ymax],[mbr.xmax mbr.xmax]);
