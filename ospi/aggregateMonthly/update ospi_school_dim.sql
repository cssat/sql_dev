update ospi.school_dim
set SchoolType='HIGH',gradestart=9,gradeend=12
where schooltype is null and charindex(' High School',schoolname)>0


update ospi.school_dim
set SchoolType='HIGH',gradestart=9,gradeend=12
where schooltype is null and charindex(' High Schl',schoolname)>0


update ospi.school_dim
set SchoolType='MIDL',gradestart=6,gradeend=8
where schooltype is null and charindex(' Middle ',schoolname)>0

update ospi.school_dim
set SchoolType='ELEM',gradestart='K',gradeend=5
where schooltype is null and charindex(' Elementary ',schoolname)>0