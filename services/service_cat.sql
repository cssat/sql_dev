if object_id('dbo.service_cat') is not null
	drop table dbo.service_cat

select distinct 
	std.cd_srvc 
	,std.tx_srvc
	,std.cd_subctgry
	,std.tx_subctgry
	--create a budget code column that is based on the CA budget units (first two integers in tx_program_index).  
	,case 
		--get rid of duplicate program indices (based on cd_srvc)
		when std.cd_srvc in (41, 42, 43, 
							44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 
							65, 66, 67, 68, 81, 82, 246, 247, 248, 268, 271, 272, 273, 274, 275, 276, 285, 286, 
							339, 345, 407, 470, 266002, 119001, 119002) 
		then 12
		when std.cd_srvc in (87, 132, 408, 409, 173025, 173026, 173027)
		then 19
		when std.cd_srvc in (96, 108)
		then 14
		when std.cd_srvc in  (406)
		then 16
		--get rid of null or old program indices
		when std.cd_srvc in (1092,1093,1094,1095,1102,1103,1104,1118,1119,1120,1128,1134,1183,1184,1185,1186,1187
							 ,1188,1197,1198,1199,1205,1206,1207,1208,1209,1210,1211,1212,1213,1214,1215,1216,1595
							 ,1596,1600,1611,1612,1613,1621,1670,1671,1672,1677,1678,1679,1680,1681,1682,1683,1688
							 ,1689,1721,1722,1723,1765,249000) 
		then 12
		when std.cd_srvc in (83,401,402,403,404,405,437,458,500,501,502,503,504,505,506,507,508
							,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526
							,527,528,529,530,531,532,533,534,535,536,537,538,539,540,541,542,543,544,545
							,643,644,645,646,647,648,669,670,671,680,681,682,683,684,685,706,707,708,709
							,710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728
							,729,730,731,732,733,734,735,736,737,738,739,740,741,742,743,744,745,746,760
							,761,762,763,764,765,766,767,768,769,770,771,772,773,774,775,776,777,778,779
							,780,781,782,783,784,785,786,787,788,789,790,791,792,793,794,795,796
							,797,798,799,809,810,811,812,813,814,815,816,817,818,819,820,821,822
							,823,824,825,860,861,862,863,864,865,866,867,903,904,905,906,907,908,909,910
							,911,912,913,914,915,916,917,918,919,920,954,955,956,957,958,959,960,961,971
							,972,973,986,1031,1032,1033,1049,1063,1064,1065,1066,1108,1109,1110,1357,1358
							,1359,1360,1361,1362,1363,1379,1380,1381,1382,1383,1384,1385,1386,1391,1392
							,1393,1394,1395,1396,1397,1398,1399,1400,1401,1402,1403,1404,1405,1406,1407
							,1408,1409,1410,1411,1412,1413,1414,1415,1416,1417,1418,1419,1420,1421,1422
							,1423,1424,1438,1439,1440,1441,1442,1443,1444,1445,1446,1447,1448,1449,1450
							,1451,1452,1453,1458,1459,1460,1461,1462,1463,1464,1465,1458,1459,1460,1461
							,1462,1463,1464,1465,1491,1492,1520,1521,1522,1523,1524,1525,1526,1527,1528
							,1529,1530,1531,1532,1533,1534,1535,1536,1537,1538,1560,1561,1562,1563,1574
							,1575,1576,1589,1593,1594,1601,1602,1603,1771,1775,119005,186000,186001,186002
							,186003,188000,231014,278001,320000,320001,396000
							,359000,359001,359002,360000,377000,396001,1762)
		then 19
		when std.cd_srvc in (99,134,347,436,546,547,548,549,554,555,556,557,558,559,560
							 ,561,562,563,564,565,566,649,650,656,677,678,679,757,758,759,800,801,802,803
							 ,1288,1289,1290,1291,1292,1293,1294,1295,1296,1297,1298,1299,1300,1301,1302,1303,1304
							,1305,1306,1307,1308,1309,1332,1336,1337,1338,1339,1340,1341,1342,1343,1344,1345,1346
							,1347,1348,1349,1350,1351,1387,1388,1389,1435,1436,1437,1454,1455,1456,1457,209005,244004
							,414000)
		then 14
		when std.cd_srvc in  (269,459,460,482,483,829,831,832,833,834,835,837,838,839,840,841,842,843,844
							  ,845,846,847,1221,1270,1271,1272,1273,1274,1275,1276,1277,1278,1279,1280,1281
							  ,1282,1283,1284,1285,1474,1475,1476,1477,1478,1479,1734,1735,1736,1737,1738,1739
							  ,1728,1729,1730,1731,1732,1733,1756,1757,1759,1760,1770,1773,185019)
		then 15
		when std.cd_srvc in  (1225,1226,1257,1258,1259)
		then 16
		when std.cd_srvc in (1075,1081)
		then 18
		--recode unpaids to 99
		when std.cd_srvc in (2,342,405,438,500
							 ,1040,1042,1043,1044,1045,1046,1469,1470,1471,1758,1761,1766,1767,1768,1769
							 ,1772,1774,1776,1777,1778,99999,209008,209009,234002,234003,245000,1763,1764)
		then 99
		else right(left(cad.tx_program_index, 3), 2)
	end as cd_budget_poc_frc
	--create a sub-ctgry column that spans conversion codes. 
	,case 
		when std.cd_srvc in (500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519
									,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538
									,539,540,541,542,543,544,545,643,644,645,646,647,648,649,650,651,652,653,654
									,655,656,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,673,674
									,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693
									,694,695,696,697,698,699,700,701,702,703,704,705,706,707,708,709,710,711,712
									,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,730,731
									,732,733,734,735,736,737,738,739,740,741,742,743,744,745,746,747,748,749,750
									,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,768,769
									,770,771,772,773,774,775,776,777,778,779,780,781,782,783,784,785,786,787,788
									,789,790,791,792,793,794,795,796,797,798,799,800,801,802,803,804,805,806,807
									,808,809,810,811,812,813,814,815,816,817,818,819,820,821,822,823,824,825,1357
									,1358,1359,1360,1361,1362,1363,1364,1365,1366,1367,1368,1369,1370,1371,1372
									,1373,1374,1375,1376,1377,1378,1379,1380,1381,1382,1383,1384,1385,1386,1387
									,1388,1389,1390,1391,1392,1393,1394,1395,1396,1397,1398,1399,1400,1401,1402
									,1403,1404,1405,1406,1407,1408,1409,1410,1411,1412,1413,1414,1415,1416,1417
									,1418,1419,1420,1421,1422,1423,1424,1425,1426,1427,1428,1429,1430,1431,1432
									,1433,1434,1435,1436,1437,1438,1439,1440,1441,1442,1443,1444,1445,1446,1447
									,1448,1449,1450,1451,1452,1453,1454,1455,1456,1457,1458,1459,1460,1461,1462
									,1463,1464,1465,3,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560
									,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579
									,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597
									,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615
									,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633
									,634,635,636,637,638,639,640,641,642,1049,1074,1075,1076,1080,1081,1082,1077
									,1078,1079,1336,1337,1338,1339,1340,1341,1342,1343,1344,1345,1346,1347,1348
									,1349,1350,1351,1594) 
		then 2
		when std.cd_srvc in (826,827,828,829,830,831,832,833,834,835,836,837,838,839,840,841,842,843,844,845
									,846,847,848,1092,1093,1094,1095,1096,1097,1098,1099,1100,1101,1102,1103,1104
									,1105,1106,1107,1270,1271,1272,1273,1274,1275,1276,1277,1278,1279,1280,1281,1282
									,1283,1284,1285,1286,1287,1466,1467,1468,1472,1473,1474,1475,1476,1477,1478,1479
									,1480,1481,1482,1483,1484,1485,1486,1487,1488,1489,1490,1728,1729,1730,1731,1732
									,1733,1734,1735,1736,1737,1738,1739,1756,1757,1759,1760,1765,1770)
		then 9
		when std.cd_srvc in (868,869,870,871,1112,1113,1114,1115,1116,1117,1118,1119,1120,1121,1122,1123,1124
								,1125,1126,1128,1134,1135,1136,1137,1138,1139,1140,1141,1142,1143,1144,1145,1146,1147
								,1148,1149,1150,1151,1152,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1164
								,1165,1166,1167,1168,1169,1170,1171,1172,1173,1174,1175,1176,1177,1178,1179,1180,1181
								,1182,1183,1184,1185,1186,1187,1188,1189,1190,1191,1192,1193,1194,1195,1196,1197,1198
								,1199,1200,1201,1202,1203,1204,1205,1206,1207,1208,1209,1210,1211,1212,1213,1214,1215
								,1216,1217,1218,1219,1220,1221,1222,1223,1224,1595,1596,1597,1598,1599,1600,1611
								,1612,1613,1614,1615,1616,1617,1618,1619,1620,1621,1626,1627,1628,1629,1630,1631,1632
								,1633,1634,1635,1636,1637,1638,1639,1640,1641,1642,1643,1644,1645,1646,1647,1648,1649
								,1650,1651,1652,1653,1654,1655,1656,1657,1658,1659,1660,1661,1662,1663,1664,1665,1666
								,1667,1668,1669,1670,1671,1672,1673,1674,1675,1676,1677,1678,1679,1680,1681,1682,1683
								,1684,1685,1686,1687)
		then 7
		when std.cd_srvc in  (849,850,851,852,853,854,855,856,857,858,859,860,861,862,863,865,866,867,872,873,874
									,875,876,877,878,879,880,881,882,883,884,885,886,887,888,889,890,891,892,893,894
									,895,896,897,898,899,900,901,902,903,904,905,906,907,908,909,910,911,912,913,914
									,915,916,917,918,919,920,921,922,923,924,925,926,927,928,929,930,931,932,933,934
									,935,936,937,938,998,999,1000,1001,1002,1003,1004,1005,1006,1007,1008
									,1009,1227,1228,1229,1230,1493,1494,1495,1496,1497,1498,1499,1500,1501,1502,1503
									,1504,1505,1506,1507,1508,1509,1510,1511,1512,1513,1514,1515,1516,1517,1518,1519
									,1520,1521,1522,1523,1524,1525,1526,1551,1552,1553,1554,1555,1556
									,1590,1591,1592,1593,1762,1763,1764,1758,1772,1775,1776,1777,1574,1575,1576,1577
									,1578,1579,1580,1581,1582,1583,1584,1585,1586,1587,1588,971,972,973,974,975,976
									,977,978,979,980,981,982,983,984,985)
		then 6
		when std.cd_srvc in (942,943,944,945,946,947,948,949,950,951,952,953,1010,1011,1012,1013,1014,1015,1016,1017
									,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1035,1036,1037,1038
									,1039,1041,1047,1048,1054,1055,1056,1057,1058,1491,1492,1527,1528,1529,1530,1531,1532
									,1533,1534,1535,1536,1537,1538,1539,1540,1541,1542,1543,1544,1545,1546,1547,1548,1549
									,1550,1771) 
		then 10
		when std.cd_srvc in (954,955,956,957,958,959,960,961,1293,1294,1295,1296,1297,1298,1299,1300,1301,1302,1303
									,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,1316,1317,1318,1319,1320
									,1321,1322,1323,1324,1325,1326,1327,1328,1329,1330,1331,1332,1333,1334,1335,1560,1561
									,1562,1563,1740,1741,1742,1743,1744,1745,1746,1747,1748,1749,1750,1751,1752,1753,1754,1755)
		then 16
		when std.cd_srvc in (962,963,969,970,1031,1032,1033,1034,1564,1565,1572,1573)
		then 4
		when std.cd_srvc in (1059,1060,1061,1062,1063,1064,1065,1066,1067,1068,1069,1070,1071,1072,1073)
		then 13
		when std.cd_srvc in  (964,965,966,967,968,986,987,988,989,990,1566,1567,1568,1569,1570,1571,1605,1606,1607,1608
									,1609,1610,1589)
		then 11
		when std.cd_srvc in  (939,940,941,1557,1558,1559,1111,1604)
		then 11
		when std.cd_srvc in  (991,992,993,994,995,996,997,1127,1133,1288,1289,1290,1291,1292,1352,1353,1354,1355,1356)
		then 1
		when std.cd_srvc in (1040,1042,1043,1044,1045,1046,1083,1084,1085,1086,1087,1088,1089,1090,1091,1469,1470,1471,1766
									,1767,1768,1769,1774,1778,99999)
		then 15
		when std.cd_srvc in (1050,1051,1052,1053,1108,1109,1110,1129,1130,1131,1132,1601,1602,1603,1761,1770,1773)
		then 8
		when std.cd_srvc in (1225,1226,1231,1232,1233,1234,1235,1236,1237,1238,1239,1240,1241,1242,1243,1244,1245,1246,1247
									,1248,1249,1250,1251,1252,1253,1254,1255,1256,1257,1258,1259,1260,1261,1262,1263,1264,1265
									,1266,1267,1268,1269,1622,1623,1624,1625,1688,1689,1690,1691,1692,1693,1694,1695,1696,1697
									,1698,1699,1700,1701,1702,1703,1704,1705,1706,1707,1708,1709,1710,1711,1712,1713,1714,1715
									,1716,1717,1718,1719,1720,1721,1722,1723,1724,1725,1726,1727)
		then 14
		when std.cd_srvc in (864)
			then 11
		else std.cd_subctgry
	end as cd_subctgry_poc_frc
	--create a flag for services that have been identified as occuring within placement episodes.  
	,case 
		when std.cd_srvc in (1,3,4,7,10,13,14,16,17,18,19,22,23,24,25,28,29,31,32,33,34,36,37,38,39,40,41,42,43,44,45,46,47,48
									,49,50,51,53,54,55,57,63,64,65,66,67,68,74,75,76,77,78,79,80,81,82,84,85,86,87,88,90,91,92
									,93,95,96,97,98,99,101,102,103,104,105,106,107,108,110,112,113,114,115,117,118,119,120,121
									,122,123,125,126,128,129,131,132,136,137,160,161,162,173,175,176,177,194,195,196,197,198
									,199,200,204,206,209,212,213,214,215,216,217,218,220,224,225,226,235,243,244,245,246,247
									,248,249,250,251,252,261,262,264,265,266,267,269,270,272,273,274,275,276,277,278,279,281
									,282,285,286,287,290,291,292,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309
									,310,311,312,313,314,315,316,317,318,319,320,324,325,326,327,328,329,330,332,333,334,335
									,336,337,339,341,343,344,345,346,348,349,350,352,357,358,359,361,362,363,367,368,370,378
									,379,380,383,384,392,393,394,395,397,398,399,408,409,412,413,415,416,417,418,430,431,432
									,433,434,435,444,445,446,447,448,449,450,451,452,453,454,455,456,457,461,462,465,466,467
									,468,469,470,471,472,473,474,475,476,477,478,550,551,552,553,566,567,568,569,570,571,572
									,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594
									,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,617
									,618,619,620,621,622,624,625,626,627,628,629,630,631,632,634,636,637,638,640,641,642,643
									,644,645,646,647,648,649,650,651,652,653,654,655,659,660,661,662,663,664,665,666,667,668
									,669,670,671,672,673,674,675,676,677,678,679,680,681,682,683,684,685,687,688,691,692,693
									,694,695,696,697,698,699,700,701,702,703,704,705,706,709,710,712,714,715,716,718,720,721
									,722,723,724,727,728,730,732,734,736,738,739,740,741,742,743,744,745,746,747,748,749,750
									,751,752,753,754,755,756,757,758,759,760,762,763,764,765,767,768,770,771,772,773,775,776
									,777,793,794,795,796,797,799,804,805,806,807,808,809,810,811,812,821,822,823,826,827,828
									,836,837,838,839,840,841,842,843,848,849,850,851,852,853,854,855,856,857,858,859,868,869
									,870,871,872,873,874,875,876,877,878,879,880,881,882,883,884,885,886,887,888,889,890,891
									,892,893,894,895,896,897,898,899,900,901,902,903,904,905,906,907,908,909,910,911,912,913
									,914,915,916,917,918,919,920,922,923,924,925,926,927,928,929,930,931,932,933,934,935,936
									,937,938,939,940,941,942,943,944,945,946,947,948,949,950,951,952,953,962,963,964,965,966
									,967,968,969,970,972,975,976,977,979,981,988,991,992,993,994,995,996,997,998,1001,1002
									,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019
									,1020,1022,1023,1024,1025,1026,1027,1029,1035,1036,1037,1038,1039,1041,1047,1048,1054
									,1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1070,1071,1072,1073
									,1083,1085,1094,1096,1097,1100,1101,1103,1105,1106,1107,1108,1109,1111,1112,1113,1114
									,1115,1116,1117,1118,1119,1120,1121,1122,1123,1124,1125,1126,1127,1128,1129,1130,1131
									,1133,1135,1136,1137,1138,1139,1141,1142,1143,1144,1145,1146,1147,1148,1149,1150,1151
									,1152,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1164,1165,1167,1168,1169
									,1170,1171,1172,1173,1174,1175,1176,1177,1178,1179,1180,1181,1182,1183,1184,1185,1186
									,1187,1190,1191,1192,1194,1195,1197,1198,1199,1200,1201,1202,1203,1204,1210,1211,1212
									,1213,1214,1215,1216,1217,1218,1219,1220,1227,1228,1229,1230,1231,1232,1233,1234,1235
									,1236,1237,1238,1239,1240,1241,1243,1244,1245,1246,1247,1248,1249,1251,1252,1254,1255
									,1256,1257,1258,1259,1260,1261,1262,1263,1265,1270,1271,1272,1273,1274,1275,1276,1277
									,1278,1279,1280,1281,1283,1284,1285,1286,1287,1310,1311,1312,1313,1314,1315,1316,1317
									,1318,1319,1320,1321,1322,1323,1324,1325,1326,1329,1330,1331,1333,1334,1335,1352,1353
									,1357,1358,1359,1360,1361,1362,1363,1364,1365,1366,1367,1368,1370,1371,1372,1374,1375
									,1376,1377,1387,1388,1389,1390,1391,1410,1421,1423,1424,1425,1426,1427,1428,1430,1431
									,1432,1434,1435,1436,1437,1451,1452,1459,1460,1461,1466,1468,1474,1475,1476,1477,1478
									,1479,1480,1481,1482,1483,1484,1485,1486,1487,1488,1489,1490,1493,1494,1495,1496,1497
									,1498,1499,1500,1501,1502,1503,1505,1506,1507,1508,1509,1510,1515,1516,1517,1518,1519
									,1527,1528,1529,1530,1533,1534,1535,1536,1538,1541,1542,1545,1546,1547,1548,1551,1552
									,1553,1554,1555,1556,1557,1558,1559,1564,1565,1566,1567,1568,1569,1570,1571,1572,1573
									,1579,1595,1597,1598,1599,1604,1607,1609,1610,1611,1614,1615,1616,1617,1618,1620,1621
									,1622,1624,1626,1628,1630,1632,1634,1635,1636,1637,1638,1639,1640,1641,1642,1643,1644
									,1645,1646,1647,1648,1649,1650,1651,1652,1653,1654,1655,1658,1660,1662,1663,1664,1665
									,1666,1668,1669,1670,1673,1674,1677,1678,1679,1681,1684,1686,1687,1690,1691,1692,1693
									,1694,1695,1696,1699,1704,1705,1706,1707,1721,1723,1728,1732,1734,1737,1739,1742,1748
									,1749,1750,1751,1752,99999,109000,109001,109002,116000,119001,119002,119003,119004
									,163000,172000,172001,172002,172003,172004,172005,173001,173003,173006,173008,173009
									,173015,173017,173019,173020,173021,173022,173024,173025,173026,173028,173029,173030
									,173031,173033,173035,173036,173037,173038,173039,173040,176000,176001,176002,176003
									,176004,176005,176006,176007,176008,176009,176010,176011,176013,176015,176016,176017
									,176019,176021,177001,177002,177003,177006,177008,177009,178000,179000,179002,179003
									,179004,179005,179006,179007,179008,179009,185001,185002,185003,185004,185005,185006
									,185007,185008,185009,185010,185011,185013,185015,185016,185018,185019,187000,187001
									,187002,187003,187009,187010,187011,187012,187013,187014,207001,207006,207009,231000
									,231001,231002,231003,231004,231005,231006,231009,231010,231011,231012,231013,231015
									,231016,231017,231018,231019,232000,234000,234001,238006,238007,238008,238009,238010
									,238011,238012,238013,238014,238015,238016,238017,238018,244001,244005,244007,244008
									,244009,244010,244011,249001,249002,249003,266000,266001,266002,266005,278002,278003
									,278008,278009,278011,290002,295000,298000,298001,298002,306001,314000,338000,338001
									,356001,356002,356006,356007,356008,356009,377001,396002,405000,419000,429000,433000
									,433001,434000,434004,434007,434008,434009,434010)
		then 1 
		else 0 
	end as fl_plc_svc
	--create a flag for services that have been identified as primary placement services (only looking at fl_plc_svc = 1)
	,case
		when std.cd_srvc in (4,37,38,39,40,46,47,49,50,53,54,55,57,65,82,123,160,161,162,200,220,224,225,226,248,261,265,266
									,272,276,286,296,298,299,300,301,302,303,304,324,329,330,339,341,358,359,378,397,412,471
									,475,477,826,827,828,836,837,838,839,840,841,842,849,850,851,852,853,854,855,856,857,858
									,859,868,869,870,871,872,873,874,875,876,877,878,879,880,881,882,883,884,885,886,887,903
									,904,905,906,907,908,909,910,911,912,913,914,915,916,917,918,919,920,950,951,952,953,996
									,1035,1036,1037,1038,1048,1054,1055,1056,1057,1058,1096,1097,1100,1101,1108,1109,1118,1121
									,1122,1123,1124,1125,1126,1135,1136,1137,1138,1139,1141,1142,1143,1144,1145,1146,1147,1148
									,1149,1150,1151,1152,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1164,1165,1167
									,1168,1169,1170,1171,1172,1173,1174,1175,1176,1177,1178,1179,1180,1181,1182,1191,1217,1218
									,1219,1220,1466,1468,1474,1475,1476,1477,1478,1479,1480,1481,1482,1483,1484,1485,1486,1487
									,1488,1489,1490,1493,1494,1495,1496,1497,1498,1499,1500,1501,1502,1503,1505,1506,1507,1508
									,1509,1510,1527,1528,1529,1530,1533,1534,1535,1536,1538,1541,1542,1545,1546,1547,1548,1614
									,1615,1616,1617,1618,1626,1628,1630,1632,1634,1635,1636,1637,1638,1639,1640,1641,1642,1643
									,1644,1645,1646,1647,1648,1649,1650,1651,1652,1653,1654,1655,1658,1660,1662,1663,1664,1665
									,1666,1668,1669,1684,1686,1687,116000,119001,163000,172003,173001,173008,173019,173022
									,173024,173029,173031,176002,176003,176005,176007,176009,176011,176013,176015,176017
									,176021,177001,177002,177003,177006,231002,231005,231006,238011,249002,249003,356009
									,419000)
		then 1
		else 0
	end as fl_prim_plc_svc
	--create a flag for services that have been identified as primary placement services (regardless of the value of fl_plc_svc)
	,case
		when std.cd_srvc in (4,37,38,39,40,46,47,49,50,53,54,55,57,65,82,123,160,161,162,200,220,224,225,226,248,261,265,266
									,272,276,286,296,298,299,300,301,302,303,304,324,329,330,339,341,358,359,378,397,412,471
									,475,477,826,827,828,836,837,838,839,840,841,842,849,850,851,852,853,854,855,856,857,858
									,859,868,869,870,871,872,873,874,875,876,877,878,879,880,881,882,883,884,885,886,887,903
									,904,905,906,907,908,909,910,911,912,913,914,915,916,917,918,919,920,950,951,952,953,996
									,1035,1036,1037,1038,1048,1054,1055,1056,1057,1058,1096,1097,1100,1101,1108,1109,1118,1121
									,1122,1123,1124,1125,1126,1135,1136,1137,1138,1139,1141,1142,1143,1144,1145,1146,1147,1148
									,1149,1150,1151,1152,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1164,1165,1167
									,1168,1169,1170,1171,1172,1173,1174,1175,1176,1177,1178,1179,1180,1181,1182,1191,1217,1218
									,1219,1220,1466,1468,1474,1475,1476,1477,1478,1479,1480,1481,1482,1483,1484,1485,1486,1487
									,1488,1489,1490,1493,1494,1495,1496,1497,1498,1499,1500,1501,1502,1503,1505,1506,1507,1508
									,1509,1510,1527,1528,1529,1530,1533,1534,1535,1536,1538,1541,1542,1545,1546,1547,1548,1614
									,1615,1616,1617,1618,1626,1628,1630,1632,1634,1635,1636,1637,1638,1639,1640,1641,1642,1643
									,1644,1645,1646,1647,1648,1649,1650,1651,1652,1653,1654,1655,1658,1660,1662,1663,1664,1665
									,1666,1668,1669,1684,1686,1687,116000,119001,163000,172003,173001,173008,173019,173022
									,173024,173029,173031,176002,176003,176005,176007,176009,176011,176013,176015,176017
									,176021,177001,177002,177003,177006,231002,231005,231006,238011,249002,249003,356009
									,419000,135,142,197,198,199,247,262,263,274,321,322,323,342,357,398,399,401,407
									,829,830,831,832,833,834,835,843,844,845,846,847,848,860,861,862,863,1102,1103,1104,1050,1051
									,1052,1053,1092,1093,1094,1095,1098,1099,1119,1120,1190,1192,1193,1194,1195,1196,1205,1206,1207
									,1208,1209,1221,1222,1223,1224,1467,1469,1470,1471,1472,1473,1491,1492,1504,1531,1532,1537,1539
									,1540,1543,1544,1549,1550,1590,1591,1592,1593,1595,1596,1602,1603,1611,1612,1613,1619,1627,1629
									,1631,1633,1656,1657,1659,1661,1667,1756,1757,1758,1759,1760,1761,1762,1763,1764,1765,1766,1767
									,1768,1769,1770,1771,1772,1773,1774,1775,1776,1777,1778,173011,173012,173013,173015,173017,173018
									,176004,176006,176008,176010,176012,176014,176016,176018,176019,176020,176022,176023,177000,177004
									,177007,185017,185018,207000,207001,207002,207003,207004,207005,207006,207007,207008,231011,231012
									,231013,238000,238001,238002,238003,238004,238005,244006,244007,298000)
		then 1
		else 0
	end as fl_prim_plc_svc_all
into 
	dbo.service_cat
from
	ca.service_type_dim std
	full outer join ca.chart_of_accounts_dim cad
		on std.cd_srvc = cad.cd_srvc
where 
	std.cd_srvc <> -99

alter table 
	dbo.service_cat
add 
	tx_budget_poc_frc varchar(100)

--add label for budget codes
update 
	dbo.service_cat
set tx_budget_poc_frc = 
	case 
		when cd_budget_poc_frc = 12
		then 'C12: Behavioral Rehabilitative Services (BRS)'
		when cd_budget_poc_frc = 14
		then 'C14: Family Support Services'
		when cd_budget_poc_frc = 15
		then 'C15: Transitional Services for Youth'
		when cd_budget_poc_frc = 16
		then 'C16: Adoption Program'
		when cd_budget_poc_frc = 18
		then 'C18: Victims Assistance'
		when cd_budget_poc_frc = 19
		then 'C19: Foster Care'
		else 'Unpaid Service'
	end

--add label for service categories
alter table 
	dbo.service_cat
add 
	tx_subctgry_poc_frc varchar(100)

update 
	dbo.service_cat 
set 
	tx_subctgry_poc_frc = std.tx_subctgry
from
	dbo.service_cat sc
	join (select distinct cd_subctgry, tx_subctgry from ca.service_type_dim) std
		on sc.cd_subctgry_poc_frc = std.cd_subctgry
