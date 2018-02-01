USE [miscwebdb]
GO
/****** Object:  StoredProcedure [dbo].[sp_OIC_AH_IS]    Script Date: 4/1/2561 9:09:35 ******/

 --drop table #tempPolicy
 --drop table #tempEndorse
 --drop table #tempPolInsured
 --drop table #Result
 --drop table #TumbolMapping
 --drop table #CountryMapping
 --drop table #tmpPrefix



Declare @StartDateFrom char(10) ,  @StartDateTo char(10),@BranchFrom char(3) ,@BranchTo char(3)  , @TrDateFrom  char(10)  , @TrDateTo char(10)
set	@StartDateFrom ='2017/06/01'
set @StartDateTo = CONVERT(char(10),DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @StartDateFrom) + 1, 0)),111) 
set @BranchFrom = '560'
set @BranchTo = '709'
set @TrDateFrom = null 
set @TrDateTo = NULL



DECLARE @StartYear int
SET @StartYear = CONVERT(int,LEFT(@StartDateFrom,4))

DECLARE @Year12 CHAR(2)
DECLARE @Year13 CHAR(2)
DECLARE @Year14 CHAR(2)
DECLARE @Year15 CHAR(2)
DECLARE @Year16 CHAR(2)
DECLARE @Year17 CHAR(2)
  SET @Year12 = '12'
  SET @Year13 = '13'
  SET @Year14 = '14'
  SET @Year15 = '15'
  SET @Year16 = '16'
  SET @Year17 = '17'


DECLARE @CompanyCode VARCHAR(10)
SET @CompanyCode = (select comp_code_oic+'|' from centerdb.dbo.sys_control (NOLOCK) ) 

CREATE TABLE #Result
	(
		CompanyCode VARCHAR(5), 
		MainClass VARCHAR(3),
		SubClass varchar(3),
		PolicyNumber VARCHAR(30),
		EndorsementNumber VARCHAR(30),
		Seq varchar(50),
		InsuredName varchar(200),
		InsuredAddress varchar(500),
		InsuredProvinceDistrictSub  varchar(6),
		InsuredZipCode  varchar(5),
		InsuredCountryCode varchar(3),
		InsuredCitizenId varchar(20),
		OccupationLevel varchar(2),
		OccupationCode varchar(4),
		InsuredBirthday varchar(10),
		InsuredGender varchar(1),
		RelationHolderInsured varchar(2),
		Beneficiary1 VARCHAR (200),
		RelationInsuredBeneficiary1 VARCHAR(2),
		NumOfPerson INTEGER,
		PremiumAmt VARCHAR (18),
		TransactionStatus VARCHAR(1),
		ReferenceNumber VARCHAR(35),
		--==== End data for ผู้เอาประกันภัย และผรู้ับผลประโยชน์
		ClassSub varchar(5),
		InsuredFullName varchar(200),
		HolderFullName varchar(200),
		IsHisInsuredNull bit DEFAULT 0,
		IsInVatControl bit DEFAULT 0,

		PolEnd_Yr CHAR(2) NOT NULL,
		PolEnd_Br CHAR(3) NOT NULL,
		PolEnd_Pre CHAR(3)  NOT NULL,
		PolEnd_No CHAR(6)  NOT NULL,
  		endos_seq smallint NULL,
		ins_seq smallint NULL,
		
		   app_yr CHAR(2) ,
		   app_br  CHAR(3) ,
		   app_pre CHAR(3),
		   app_no CHAR(6),
		IsPolicy bit  NOT NULL,

		position CHAR(5),
		position_name VARCHAR(100),
		addno varchar(20),
		building varchar(40),
		village varchar(50),
		street varchar(40),
		trog varchar(40),
		soi varchar(40),
		tumbol varchar(40),
		amphur char(2),
		province char(2),
		country char(3),

		net_premium float NULL,
		stamp float NULL,
		vat float NULL,
		tax float NULL,
		total_premium float NULL,
		[start_date] varchar(20) NULL,
		end_date varchar(20) NULL,
		sale_code char(5) NULL,
		flag_language char(1) NULL,
		tr_datetime varchar(20) NULL,
		flag_group char(1) NULL,
  		class_oic char(2) NULL,
	  subclass_oic char(2) NULL,
	  ins_position_level char(1) NULL,
	  ins_birthdate datetime,
	   ins_sex char(1),
	   ins_prefix char(3),
	   ins_fname varchar(100),
	);

CREATE CLUSTERED INDEX i_tempResult
ON #Result (PolEnd_Yr,PolEnd_Br,PolEnd_Pre,PolEnd_No,IsPolicy);


CREATE TABLE #tempPolicy
(
	pol_yr CHAR(2) NOT NULL,
	pol_br CHAR(3) NOT NULL,
	pol_pre CHAR(3)  NOT NULL,
	pol_no CHAR(6)  NOT NULL,
  	endos_seq int NULL,
 	net_premium float NULL,
	stamp float NULL,
	vat float NULL,
	tax float NULL,
	total_premium float NULL,
	[start_date] varchar(20) NULL,
	end_date varchar(20) NULL,
	sale_code char(5) NULL,
	flag_language char(1) NULL,
	tr_datetime varchar(20) NULL,
    flag_group char(1) NULL,
  	class_oic char(2) NULL,
   subclass_oic char(2) NULL
);
CREATE CLUSTERED INDEX i_tempResult
ON #tempPolicy (pol_yr,pol_br,pol_pre,pol_no,endos_seq);

--select pol_yr, pol_br, pol_pre, pol_no, count(1) from #tempPolicy group by pol_yr, pol_br, pol_pre, pol_no having count(1) > 1 order by pol_yr, pol_br, pol_pre, pol_no


INSERT INTO #tempPolicy
select  h.pol_yr , h.pol_br, h.pol_pre ,h.pol_no , h.endos_seq  , h.net_premium , h.stamp , h.vat ,h.tax ,
h.total_premium , h.start_date ,h.end_date ,h.sale_code , h.flag_language , h.tr_datetime ,c.flag_group,c.class_oic,c.subclass_oic
from ibs_pol h 
inner join centerdb.dbo.subclass c WITH(NOLOCK) on h.pol_pre = c.class_code+ c.subclass_code --and isnull(c.flag_mixpolicy,'') <> 'Y'
where  c.class_oic in ('06','07','11')
and h.pol_Yr  in  (@Year12 , @Year13 ,@Year14 ,@Year15 ,@Year16 ,@Year17)
and h.pol_br  >= @BranchFrom  
and h.pol_br  <= @BranchTo
and h.endos_seq = 0  
and (( convert(varchar(10) , h.start_datetime ,111 ) between  @StartDateFrom  and @StartDateTo))

--select * from #tempPolicy


INSERT INTO #Result 
    (
	  CompanyCode,
	  MainClass,
      PolicyNumber,
      EndorsementNumber,
      SubClass,
      ClassSub,
	  [start_date],
      PolEnd_Yr,
      PolEnd_Br,
      PolEnd_Pre,
      PolEnd_No,
	  endos_seq,
      IsPolicy,

	  position,
		position_name,
		addno,
		building,
		village,
		street,
		trog,
		soi,
		tumbol,
		InsuredZipCode,
		country,
		amphur,
		province,
		InsuredName,
		Seq,
		InsuredCitizenId,
		ins_position_level,
		ins_birthdate,
		ins_sex,
		ins_prefix,
		InsuredBirthday,
		PremiumAmt,
		TransactionStatus,
		ReferenceNumber,
		ins_fname,
		ins_seq,
		flag_group,
		IsHisInsuredNull			        
		)
select 
		@CompanyCode,
		p.class_oic,
       p.sale_code+'-'+p.pol_yr+p.pol_br+'/POL/'+p.pol_no+'-'+p.pol_pre,
       '',
       p.subclass_oic,
       p.class_oic+p.subclass_oic,
	   p.[start_date],
       p.pol_yr,
       p.pol_br,
       p.pol_pre,
       p.pol_no,
	   p.endos_seq,
       1, 
	   ins.ins_position,
		ins.ins_position_name,
		ins.ins_addno,
		ins.ins_building,
		ins.ins_village,
		ins.ins_street,
		ins.ins_trog,
		ins.ins_soi,
		ins.ins_tumbol,
		ins.ins_zipcode,
		ins.ins_country,
		ins.ins_amphur,
		ins.ins_province,
		
		ins.ins_fname + ins.ins_lname,
		ins.ins_seq,
		ins.ins_idno,
		ins.ins_position_level,
		ins.ins_birthdate,
		ins.ins_sex,
		ins.ins_prefix,
		convert(varchar(10),ins.ins_birthdate,112),
		cast(convert(decimal(15,2),p.total_premium) as varchar(20)),
		'N',
		'',
		ins.ins_fname,
		ins.ins_seq,
		flag_group,
		CASE WHEN ISNULL(ins_addno,'') + ISNULL(ins_amphur,'') + ISNULL(ins_province,'') = '' 
				 THEN 
					1
				 ELSE
					0
		END

FROM #tempPolicy p
inner join his_insured ins WITH(NOLOCK) on 
							(p.pol_yr= ins.pol_yr and
								p.pol_br = ins.pol_br and
								p.pol_pre = ins.pol_pre and
								p.pol_no = ins.pol_no and
								p.endos_seq = ins.endos_seq
								)


--=== Update Subclass for 506, 516
UPDATE  #Result
SET SubClass = (
				case  h.country_code_to 
						when '764' then   '06' 
						else '08' 			
				end
				)
FROM  his_journey_ta h  WITH(NOLOCK) 
where (#Result.PolEnd_Yr = h.pol_yr and 
#Result.PolEnd_Br = h.pol_br and 
#Result.PolEnd_Pre = h.pol_pre and 
#Result.PolEnd_No = h.pol_no and 
#Result.endos_seq = h.endos_seq and
#Result.PolEnd_Pre in ('506', '516')
) 
--==== End Update

-- Update Address his_holder
UPDATE  #Result
SET 
		addno = hld.hld_addno,
		building = hld.hld_building,
		village = hld.hld_village,
		street = hld.hld_street,
		trog = hld.hld_trog,
		soi = hld.hld_soi,
		tumbol = hld.hld_tumbol,
		InsuredZipCode = hld.hld_zipcode,
		country = hld.hld_country,
		amphur = hld.hld_amphur,
		province  = hld.hld_province,
		RelationHolderInsured = (
							case  when #Result.InsuredName = hld.hld_fname+hld.hld_lname then '00'  
								 else  centerdb.dbo.cnudf_GetMasterOic2('AH03','relationship','ผู้เอาประกัน','') 
							end 
					),
		IsHisInsuredNull = (
								CASE WHEN ISNULL( hld.hld_addno,'') + ISNULL( hld.hld_amphur,'') + ISNULL( hld.hld_province,'') = '' 
									 THEN 
										1
									 ELSE
										0
								  END
								)				
FROM
his_holder  hld WITH(NOLOCK)
where
#Result.PolEnd_Yr = hld.pol_yr and 
#Result.PolEnd_Br = hld.pol_br and 
#Result.PolEnd_Pre = hld.pol_pre and 
#Result.PolEnd_No = hld.pol_no and 
#Result.endos_seq = hld.endos_seq  AND
#Result.IsHisInsuredNull = 1

--select * from #Result
-- Update Address his_holder

UPDATE  #Result
SET 
		addno = hld.ins_addno,
		building = hld.ins_building,
		village = hld.ins_village,
		street = hld.ins_street,
		trog = hld.ins_trog,
		soi = hld.ins_soi,
		tumbol = hld.ins_tumbol,
		InsuredZipCode = hld.ins_zipcode,
		country = hld.ins_country,
		amphur = hld.ins_amphur,
		province  = hld.ins_province,
		IsHisInsuredNull =  (
								CASE WHEN ISNULL( hld.ins_addno,'') + ISNULL( hld.ins_amphur,'') + ISNULL( hld.ins_province,'') = '' 
								 THEN 
									1
								 ELSE
									0	
								END	
								)				
FROM
pol_insured  hld  WITH(NOLOCK)
where
#Result.PolEnd_Yr = hld.pol_yr and 
#Result.PolEnd_Br = hld.pol_br and 
#Result.PolEnd_Pre = hld.pol_pre and 
#Result.PolEnd_No = hld.pol_no and 
#Result.IsHisInsuredNull = 1

-- Update Address with branch
UPDATE  #Result
SET 
		
		InsuredZipCode = hld.zipcode,
		province  = hld.province_code,
		IsHisInsuredNull =  (
								CASE WHEN ISNULL( hld.zipcode,'') + ISNULL(hld.province_code,'') = '' 
								 THEN 
									1
								 ELSE
									0	
								END	
								)				
FROM
centerdb.dbo.branch  hld   WITH(NOLOCK)
where
#Result.PolEnd_Br = hld.branch_code and 
#Result.IsHisInsuredNull = 1

--===== End Update Address

--=== Update the data for Undefined data
UPDATE #Result
SET	InsuredCitizenId = 'UNDEFINE'
WHERE  CONVERT(int,LEFT([start_date],4)) <= 2015 and
(InsuredCitizenId = '' or InsuredCitizenId is null )
	 

--==== End


--===== Update  InsuredGender
UPDATE  #Result
SET 
	InsuredGender = (
					  case when isnull(#Result.ins_sex,'') ='' then 
					  			case  when isnull(prf2.flag_sex,'N')='N' then 
								  	'M'  
								  else 
								  	prf2.flag_sex  
								end 
					   else case  when isnull( #Result.ins_sex ,'N')='N' then 
					   				'M' 
								  else 
								  	#Result.ins_sex  
							end 
					  end
					)
FROM centerdb.dbo.prefix prf2   WITH(NOLOCK)
								
where #Result.ins_prefix = prf2.prefix_code AND
(
	#Result.ClassSub in ('0601','0602','0604')
)

--== Update InsuredBirthday
UPDATE  #Result
SET 
	InsuredBirthday  =  NULL							
where
#Result.ClassSub not in ('0601','0602','0604')

----- 76329
--select * from #Result where #Result.ClassSub in ('0601','0602','0604') and  InsuredBirthday is null --14084

--select * from #Result where #Result.ClassSub in ('0601','0602','0604') and  InsuredBirthday is not null --62281
--=== Update Beneficiary


UPDATE #Result
SET Beneficiary1= (
				case when isnull(bnf.bnf_fname,'') ='' or charindex( 'ทายาทโดยธรรม',bnf.bnf_fname  ,1 )> 0  or  charindex( 'ทายาทตามกฏหมาย' ,bnf.bnf_fname ,1 )> 0  then 'ทายาทโดยธรรม'  
					else  isnull(prf3.prefix_name,'') + case when isnull(prf3.flag_space,11) = 'Y' then ' ' else '' end + bnf.bnf_fname +' ' + bnf.bnf_lname 
				end
				), 
RelationInsuredBeneficiary1= (
								case when  isnull(bnf.bnf_fname,'') ='' or charindex('ทายาทโดยธรรม' , bnf.bnf_fname ,1 )> 0  or  charindex('ทายาทตามกฏหมาย' , bnf.bnf_fname ,1 )> 0  then '99' 
									else centerdb.dbo.cnudf_GetMasterOic2('AH03','relationship','', bnf.bnf_relationship) 
								end
							)

FROM  his_beneficiary bnf   WITH(NOLOCK)
left join centerdb.dbo.prefix prf3   WITH(NOLOCK) on 
							prf3.prefix_code = bnf.bnf_prefix

WHERE 
	#Result.PolEnd_Yr = bnf.pol_yr and
	#Result.PolEnd_Br = bnf.pol_br and
	#Result.PolEnd_Pre = bnf.pol_pre and
	#Result.PolEnd_No = bnf.pol_no and
	#Result.endos_seq = bnf.endos_seq  and
	#Result.ins_seq = bnf.ins_seq and
		bnf.bnf_seq in (
						select min (bnf_seq) from his_beneficiary  where 
						#Result.PolEnd_Yr = pol_yr and
						#Result.PolEnd_Br = pol_br and
						#Result.PolEnd_Pre = pol_pre and
						#Result.PolEnd_No = pol_no and
						#Result.endos_seq = endos_seq  and
						#Result.ins_seq = ins_seq  
					)

--== End Benificialry
--===== Update when OccupationLevel h.ClassSub '0601','0602','0603','0604'

UPDATE  #Result
SET OccupationLevel = (
						case when isnull( ins.ins_position_level,'0') = '0' or  
									ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' 
									then '01' 
									else  '0'+ isnull( ins.ins_position_level,'')   
								end
					  )
FROM
his_insured ins  
where
#Result.PolEnd_Yr = ins.pol_yr and 
#Result.PolEnd_Br = ins.pol_br and 
#Result.PolEnd_Pre = ins.pol_pre and 
#Result.PolEnd_No = ins.pol_no and 
#Result.endos_seq = ins.endos_seq AND
(
	#Result.ClassSub in ('0601','0602','0603','0604')
)
--===== End Update OccupationLevel

--=== UPDATE OccupationCode
select position,  isnull(centerdb.dbo.cnudf_GetMasterOic2(NULL,'position','',position ),'9999')  as oicPositionCode, 
      position_name, isnull(centerdb.dbo.cnudf_GetMasterOic2(NULL,'position',position_name ,''),'9999')  as oicPositionNameCode
INTO #OccupationCodeMapping
from (
select distinct position,position_name from #Result
) as a

UPDATE  #Result
SET OccupationCode = a.oicPositionCode
FROM #OccupationCodeMapping a
where #Result.position = a.position

UPDATE  #Result
SET OccupationCode = a.oicPositionNameCode
FROM #OccupationCodeMapping a
where #Result.OccupationCode = '' and #Result.position_name = a.position_name 


UPDATE  #Result
SET OccupationCode = '9999'
WHERE  OccupationCode is null

drop table #OccupationCodeMapping
--select * from #Result
--=== End Update OccupationCode
--=== UPDATE Address

select country,  centerdb.dbo.cnudf_GetMasterOic2(NULL,'country','' ,a.country)   as oicCountryCode
INTO #CountryMapping
from (
select distinct country from #Result
) as a


UPDATE #Result
SET InsuredCountryCode = #CountryMapping.oicCountryCode
FROM #CountryMapping
WHERE #Result.country = #CountryMapping.country

drop table #CountryMapping

UPDATE #Result
SET InsuredAddress = Ltrim(
												(CASE isnull(addno, '')    WHEN ''  THEN '' ElSE addno+' ' END) + 
			       								 (CASE isnull(building, '') WHEN ''  THEN '' ELSE building+' Bld., ' END) + 
												 (CASE isnull(village, '')  WHEN ''  THEN '' ELSE village+' village, ' END) + 
												 (CASE isnull(street, '')   WHEN ''  THEN '' ELSE street+' Rd., ' END) + 
												 (CASE isnull(trog, '')     WHEN ''  THEN '' ELSE trog+', ' END) + 
												(CASE isnull(soi, '')      WHEN ''  THEN '' ELSE soi+', ' END)
											)
where flag_language  = 'E' 


UPDATE #Result
SET InsuredAddress =  Ltrim(
										(CASE isnull(addno, '') WHEN 	'-' THEN '' WHEN 	'' THEN ''  ELSE 'เลขที่ '  + addno END)
									  +(CASE isnull(building, '') WHEN '' THEN '' ELSE ' ' + building END) 
									  +(CASE isnull(village, '') WHEN '' THEN '' ELSE ' ' + village END) 
									  +(CASE isnull(street, '') WHEN '' THEN '' ELSE ' ถ.' + street END) 
									  +(CASE isnull(trog, '') WHEN '' THEN '' ELSE ' ตรอก' + trog END) 
									  + (CASE isnull(soi, '') WHEN '' THEN '' ELSE ' ซ.' + soi END)
									) 
where InsuredAddress is null and country = '764'


UPDATE #Result
SET InsuredAddress = Ltrim(
										 (CASE isnull(addno, '') WHEN '' THEN '' ELSE addno END) 
										 + (CASE isnull(building, '') WHEN '' THEN '' ELSE '  ' + building END) 
										 + (CASE isnull(village, '')  WHEN '' THEN '' ELSE '  ' + village END) 
										 + (CASE isnull(street, '') WHEN '' THEN '' ELSE '  ' + street END) 
										 + (CASE isnull(trog, '') WHEN '' THEN '' ELSE '  ' + trog END) 
										 + (CASE isnull(soi, '')  WHEN '' THEN '' ELSE '  ' + soi END)
									)  	
where InsuredAddress is null 



--== Update District

select tumbol,amphur,province, centerdb.dbo.fn_OIC_Find_SubdistrictCode(tumbol,amphur,province)  as oicTumbolId
INTO #TumbolMapping
from (
select distinct tumbol,amphur,province from #Result
) as a


UPDATE #Result
SET InsuredProvinceDistrictSub	= #TumbolMapping.oicTumbolId
FROM #TumbolMapping
where #TumbolMapping.tumbol = #Result.tumbol and #TumbolMapping.oicTumbolId is not null


drop table #TumbolMapping

UPDATE #Result
SET NumOfPerson= CONVERT(int,
					(
						case  when isnull(#Result.flag_group,'') ='G' and charindex('ตามรายการแนบ',#Result.ins_fname ,1) > 0 
								then (
										select count(ins_seq) 
										from his_insured i 
										where #Result.PolEnd_Yr = i.pol_yr and #Result.PolEnd_Br = i.pol_br and #Result.PolEnd_Pre = i.pol_pre and #Result.PolEnd_No = i.pol_no  and #Result.endos_seq = i.endos_seq
									)
							else  1 
						end
					)
				)

--=== End Update Address

--================== Endosement ==============================
--drop table #tempEndorse

--Declare @StartDateFrom char(10) ,  @StartDateTo char(10),@BranchFrom char(3) ,@BranchTo char(3)  , @TrDateFrom  char(10)  , @TrDateTo char(10)
--set	@StartDateFrom ='2017/06/01'
--set @StartDateTo = '2017/06/30'
--set @BranchFrom = '000'
--set @BranchTo = '709'
--set @TrDateFrom = null 
--set @TrDateTo = NULL



--DECLARE @StartYear int
--SET @StartYear = CONVERT(int,LEFT(@StartDateFrom,4))

--DECLARE @Year12 CHAR(2)
--DECLARE @Year13 CHAR(2)
--DECLARE @Year14 CHAR(2)
--DECLARE @Year15 CHAR(2)
--DECLARE @Year16 CHAR(2)
--DECLARE @Year17 CHAR(2)
--  SET @Year12 = '12'
--  SET @Year13 = '13'
--  SET @Year14 = '14'
--  SET @Year15 = '15'
--  SET @Year16 = '16'
--  SET @Year17 = '17'


SELECT e.pol_yr, e.pol_br, e.pol_no , e.app_yr , e.app_br, e.app_pre ,e.app_no , e.endos_yr, e.endos_no, e.net_premium , e.stamp , e.vat ,e.tax ,e.total_premium , h.start_date ,h.end_date ,h.sale_code , 
e.flag_language , c.class_code, c.subclass_oic, c.class_oic + c.subclass_oic AS class_n_subclass_oic, c.subclass_code, c.class_oic, c.flag_group , e.approve_datetime ,e.endos_group, '   ' as EndorseSeq
INTO #tempEndorse
FROM endos e  
inner join ibs_pol h  on e.pol_yr = h.pol_yr and e.pol_br = h.pol_br and e.app_pre = h.pol_pre and e.pol_no = h.pol_no
inner join endos_detail  ed on
	e.app_yr		= ed.app_yr 
	and e.app_br	= ed.app_br 
	and e.app_pre	= ed.app_pre 
	and e.app_no	= ed.app_no
and ed.seq_no in (select min(seq_no) from endos_detail where e.app_yr = app_yr and e.app_br = app_br and  e.app_pre = app_pre and e.app_no = app_no)
inner join centerdb.dbo.subclass c on e.app_pre = c.class_code + c.subclass_code --and isnull(c.flag_mixpolicy,'') <> 'Y'
WHERE  e.approve_datetime is not null 
and c.class_oic in ('06','07','11')  
and ( (e.eff_date is null)  or ( e.eff_date between  @StartDateFrom  and @StartDateTo))
and e.app_br BETWEEN @BranchFrom AND  @BranchTo
--and  ( (e.approve_datetime is null) or (convert(varchar(10) ,e.approve_datetime ,111 ) between  @TrDateFrom  and @TrDateTo))

CREATE UNIQUE CLUSTERED INDEX i_tempEndorse
ON #tempEndorse (app_yr,app_br,app_pre,app_no);

CREATE NONCLUSTERED INDEX i_tempEndorse_flag_group 
ON #tempEndorse (flag_group);

--=================== prefix =============================

--CREATE TABLE #tmpPrefix (
--	prefix_code CHAR(3) NOT NULL,
--	flag_space CHAR(1) NULL,
--	flag_sex CHAR(1) NULL,
--	prefix_name VARCHAR(50) NOT NULL
--	UNIQUE CLUSTERED ( prefix_code )
--)

--INSERT INTO #tmpPrefix
--select prefix_code, flag_space, flag_sex, prefix_name from centerdb.dbo.prefix

--================================================
--select * from #tempEndorse
print 'Updating endorse seq...'
UPDATE e
SET EndorseSeq = (
                         select cast(count(endos_no) as varchar(5)) 
                         from #tempEndorse 
                         where 
                         pol_yr = e2.pol_yr  and  
                         pol_br = e2.pol_br and 
                         app_pre = e2.app_pre and 
                         pol_no =  e2.pol_no and 
                         endos_yr + endos_no <= e2.endos_yr + e2.endos_no and approve_datetime is not null
                     )

FROM #tempEndorse e
INNER JOIN
    #tempEndorse e2
ON 
    e.app_yr = e2.app_yr and  
    e.app_br = e2.app_br and 
    e.app_pre = e2.app_pre and 
    e.app_no = e2.app_no

--select * from #tempPolicy

print 'Adding endorse insured from his_insured ...'
--delete #Result where #Result.IsPolicy = 0  
--DECLARE @CompanyCode VARCHAR(10)
--SET @CompanyCode = (select comp_code_oic+'|' from centerdb.dbo.sys_control (NOLOCK) ) 
INSERT INTO #Result 
    (
	  CompanyCode,
	  MainClass,
      PolicyNumber,
      EndorsementNumber,
      SubClass,
      ClassSub,
	  [start_date],
      PolEnd_Yr,
      PolEnd_Br,
      PolEnd_Pre,
      PolEnd_No,
	  endos_seq,
       app_yr,
       app_br,
       app_pre,
       app_no,
      IsPolicy,

	  position,
		position_name,
		addno,
		building,
		village,
		street,
		trog,
		soi,
		tumbol,
		InsuredZipCode,
		country,
		amphur,
		province,
		InsuredName,
		Seq,
		InsuredCitizenId,
		ins_position_level,
		ins_birthdate,
		ins_sex,
		ins_prefix,
		InsuredBirthday,
		PremiumAmt,
		TransactionStatus,
		ReferenceNumber,
		ins_fname,
		ins_seq,
		flag_group,
		IsHisInsuredNull			        
		)
select 
		@CompanyCode,
		p.class_oic,
       p.sale_code+'-'+p.pol_yr+p.pol_br+'/POL/'+p.pol_no+'-'+p.app_pre,
       p.endos_yr+p.app_br +'/END/' +p.endos_no +'-'+p.app_pre,
	   p.subclass_oic,
       p.class_n_subclass_oic,
	   p.[start_date],
       p.pol_yr,
       p.pol_br,
       p.app_pre,
       p.pol_no,
	   p.EndorseSeq,
       p.app_yr,
       p.app_br,
       p.app_pre,
       p.app_no,
       0, 
	   ins.ins_position,
		ins.ins_position_name,
		ins.ins_addno,
		ins.ins_building,
		ins.ins_village,
		ins.ins_street,
		ins.ins_trog,
		ins.ins_soi,
		ins.ins_tumbol,
		ins.ins_zipcode,
		ins.ins_country,
		ins.ins_amphur,
		ins.ins_province,
		
		ins.ins_fname + ins.ins_lname,
		ins.ins_seq,
		ins.ins_idno,
		ins.ins_position_level,
		ins.ins_birthdate,
		ins.ins_sex,
		ins.ins_prefix,
		convert(varchar(10),ins.ins_birthdate,112),
		cast(convert(decimal(15,2),p.total_premium) as varchar(20)),
		'N',
		'',
		ins.ins_fname,
		ins.ins_seq,
		flag_group,
		CASE WHEN ISNULL(ins_addno,'') + ISNULL(ins_amphur,'') + ISNULL(ins_province,'') = '' 
				 THEN 
					1
				 ELSE
					0
		END

FROM #tempEndorse p
left join his_insured ins WITH(NOLOCK) on 
							(p.pol_yr= ins.pol_yr and
								p.pol_br = ins.pol_br and
								p.app_pre = ins.pol_pre and
								p.pol_no = ins.pol_no and
								p.EndorseSeq = ins.endos_seq
							)

UPDATE #Result
SET NumOfPerson= CONVERT(int,
					(
						case  when isnull(#Result.flag_group,'') ='G' and charindex('ตามรายการแนบ',#Result.ins_fname ,1) > 0 
								then (
										select count(ins_seq) 
										from his_insured i 
										where #Result.PolEnd_Yr = i.pol_yr and #Result.PolEnd_Br = i.pol_br and #Result.PolEnd_Pre = i.pol_pre and #Result.PolEnd_No = i.pol_no  and #Result.endos_seq = i.endos_seq
									)
							else  1 
						end
					)
				)
print 'Adding endorse insured from endos_insured ...'

INSERT INTO #Result 
    (
	  CompanyCode,
	  MainClass,
      PolicyNumber,
      EndorsementNumber,
      SubClass,
      ClassSub,
	  [start_date],
      PolEnd_Yr,
      PolEnd_Br,
      PolEnd_Pre,
      PolEnd_No,
	  endos_seq,
       app_yr,
       app_br,
       app_pre,
       app_no,
      IsPolicy,

	  position,
		position_name,
		addno,
		building,
		village,
		street,
		trog,
		soi,
		tumbol,
		InsuredZipCode,
		country,
		amphur,
		province,
		InsuredName,
		Seq,
		InsuredCitizenId,
		ins_position_level,
		ins_birthdate,
		ins_sex,
		ins_prefix,
		InsuredBirthday,
		PremiumAmt,
		TransactionStatus,
		ReferenceNumber,
		ins_fname,
		ins_seq,
		IsHisInsuredNull			        
		)
select 
		p.CompanyCode,
		 p.MainClass,
		 p.PolicyNumber,
       p.EndorsementNumber,
	   p.subclass_oic,
       p.ClassSub,
	   p.[start_date],
      p.PolEnd_Yr,
      p.PolEnd_Br,
      p.PolEnd_Pre,
      p.PolEnd_No,
	  p.endos_seq,
       p.app_yr,
       p.app_br,
       p.app_pre,
       p.app_no,
       0, 
	   ins.ins_position,
		ins.ins_position_name,
		ins.ins_addno,
		ins.ins_building,
		ins.ins_village,
		ins.ins_street,
		ins.ins_trog,
		ins.ins_soi,
		ins.ins_tumbol,
		ins.ins_zipcode,
		ins.ins_country,
		ins.ins_amphur,
		ins.ins_province,
		
		ins.ins_fname + ins.ins_lname,
		ins.ins_seq,
		ins.ins_idno,
		ins.ins_position_level,
		ins.ins_birthdate,
		ins.ins_sex,
		ins.ins_prefix,
		convert(varchar(10),ins.ins_birthdate,112),
		cast(convert(decimal(15,2),p.total_premium) as varchar(20)),
		'N',
		'',
		ins.ins_fname,
		ins.ins_seq,
		CASE WHEN ISNULL(ins_addno,'') + ISNULL(ins_amphur,'') + ISNULL(ins_province,'') = '' 
				 THEN 
					1
				 ELSE
					0
		END

FROM #Result p
left join endos_insured ins WITH(NOLOCK) on 
							(p.app_yr= ins.app_yr and
								p.app_br = ins.app_br and
								p.app_pre = ins.app_pre and
								p.app_no = ins.app_no 
							)
where p.IsPolicy = 0 and p.PolEnd_Yr is null and p.PolEnd_Br is null

UPDATE #Result
SET NumOfPerson= CONVERT(int,
					(
						case  when isnull(#Result.flag_group,'') ='G' and charindex('ตามรายการแนบ',#Result.ins_fname ,1) > 0 
								then (
										select count(ins_seq) 
										from endos_insured i 
										where #Result.app_yr = i.app_yr and #Result.app_br = i.app_br and #Result.app_pre = i.app_pre and #Result.app_no = i.app_no 
									)
							else  1 
						end
					)
				)
WHERE IsPolicy = 0
--=================== SELECT ENDORSEMENT =============================


--=== Update Subclass for 506, 516

print 'Updating  endorse SubClass ...'
UPDATE  #Result
SET SubClass = (
				case  h.country_code_to 
						when '764' then   '06' 
						else '08' 			
				end
				)
FROM  his_journey_ta h  WITH(NOLOCK) 
where (#Result.PolEnd_Yr = h.pol_yr and 
#Result.PolEnd_Br = h.pol_br and 
#Result.PolEnd_Pre = h.pol_pre and 
#Result.PolEnd_No = h.pol_no and 
#Result.endos_seq = h.endos_seq and
#Result.IsPolicy = 0 and
#Result.PolEnd_Pre in ('506', '516')
) 
--==== End Update

-- Update Address his_holder
print 'Updating  endorse address his_holder ...'
UPDATE  #Result
SET 
		addno = hld.hld_addno,
		building = hld.hld_building,
		village = hld.hld_village,
		street = hld.hld_street,
		trog = hld.hld_trog,
		soi = hld.hld_soi,
		tumbol = hld.hld_tumbol,
		InsuredZipCode = hld.hld_zipcode,
		country = hld.hld_country,
		amphur = hld.hld_amphur,
		province  = hld.hld_province,
		RelationHolderInsured = (
							case  when #Result.InsuredName = hld.hld_fname+hld.hld_lname then '00'  
								 else  centerdb.dbo.cnudf_GetMasterOic2('AH03','relationship','ผู้เอาประกัน','') 
							end 
					),
		IsHisInsuredNull = (
								CASE WHEN ISNULL( hld.hld_addno,'') + ISNULL( hld.hld_amphur,'') + ISNULL( hld.hld_province,'') = '' 
									 THEN 
										1
									 ELSE
										0
								  END
								)				
FROM
his_holder  hld WITH(NOLOCK)
where
#Result.PolEnd_Yr = hld.pol_yr and 
#Result.PolEnd_Br = hld.pol_br and 
#Result.PolEnd_Pre = hld.pol_pre and 
#Result.PolEnd_No = hld.pol_no and 
#Result.endos_seq = hld.endos_seq  AND
#Result.IsPolicy = 0 and
#Result.IsHisInsuredNull = 1

--select * from #Result where #Result.IsPolicy = 0 
-- Update Address his_holder

print 'Updating  endorse address pol_insured ...'
UPDATE  #Result
SET 
		addno = hld.ins_addno,
		building = hld.ins_building,
		village = hld.ins_village,
		street = hld.ins_street,
		trog = hld.ins_trog,
		soi = hld.ins_soi,
		tumbol = hld.ins_tumbol,
		InsuredZipCode = hld.ins_zipcode,
		country = hld.ins_country,
		amphur = hld.ins_amphur,
		province  = hld.ins_province,
		IsHisInsuredNull =  (
								CASE WHEN ISNULL( hld.ins_addno,'') + ISNULL( hld.ins_amphur,'') + ISNULL( hld.ins_province,'') = '' 
								 THEN 
									1
								 ELSE
									0	
								END	
								)				
FROM
pol_insured  hld  WITH(NOLOCK)
where
#Result.PolEnd_Yr = hld.pol_yr and 
#Result.PolEnd_Br = hld.pol_br and 
#Result.PolEnd_Pre = hld.pol_pre and 
#Result.PolEnd_No = hld.pol_no and 
#Result.IsPolicy = 0 and
#Result.IsHisInsuredNull = 1

-- Update Address with branch
print 'Updating  endorse address centerdb.dbo.branch ...'
UPDATE  #Result
SET 
		
		InsuredZipCode = hld.zipcode,
		province  = hld.province_code,
		IsHisInsuredNull =  (
								CASE WHEN ISNULL( hld.zipcode,'') + ISNULL(hld.province_code,'') = '' 
								 THEN 
									1
								 ELSE
									0	
								END	
								)				
FROM
centerdb.dbo.branch  hld   WITH(NOLOCK)
where
#Result.PolEnd_Br = hld.branch_code and 
#Result.IsPolicy = 0 and
#Result.IsHisInsuredNull = 1

--===== End Update Address

--=== Update the data for Undefined data
print 'Updating  endorse InsuredCitizenId ...'
UPDATE #Result
SET	InsuredCitizenId = 'UNDEFINE'
WHERE  CONVERT(int,LEFT([start_date],4)) <= 2015 and
#Result.IsPolicy = 0 and
(InsuredCitizenId = '' or InsuredCitizenId is null )
	 

--==== End


--===== Update  InsuredGender
print 'Updating  endorse InsuredGender ...'
UPDATE  #Result
SET 
	InsuredGender = (
					  case when isnull(#Result.ins_sex,'') ='' then 
					  			case  when isnull(prf2.flag_sex,'N')='N' then 
								  	'M'  
								  else 
								  	prf2.flag_sex  
								end 
					   else case  when isnull( #Result.ins_sex ,'N')='N' then 
					   				'M' 
								  else 
								  	#Result.ins_sex  
							end 
					  end
					)
FROM centerdb.dbo.prefix prf2   WITH(NOLOCK)
								
where #Result.ins_prefix = prf2.prefix_code AND
#Result.IsPolicy = 0 and
(
	#Result.ClassSub in ('0601','0602','0604')
)

--== Update InsuredBirthday
print 'Updating  endorse InsuredBirthday ...'
UPDATE  #Result
SET 
	InsuredBirthday  =  NULL							
where
#Result.ClassSub not in ('0601','0602','0604') and
#Result.IsPolicy = 0 

----- 76329
--select * from #Result where #Result.ClassSub in ('0601','0602','0604') and  InsuredBirthday is null --14084

--select * from #Result where #Result.ClassSub in ('0601','0602','0604') and  InsuredBirthday is not null --62281
--=== Update Beneficiary


print 'Updating  endorse Beneficiary,RelationInsuredBeneficiary1,NumOfPerson ...'
UPDATE #Result
SET Beneficiary1= (
				case when isnull(bnf.bnf_fname,'') ='' or charindex( 'ทายาทโดยธรรม',bnf.bnf_fname  ,1 )> 0  or  charindex( 'ทายาทตามกฏหมาย' ,bnf.bnf_fname ,1 )> 0  then 'ทายาทโดยธรรม'  
					else  isnull(prf3.prefix_name,'') + case when isnull(prf3.flag_space,11) = 'Y' then ' ' else '' end + bnf.bnf_fname +' ' + bnf.bnf_lname 
				end
				), 
RelationInsuredBeneficiary1= (
								case when  isnull(bnf.bnf_fname,'') ='' or charindex('ทายาทโดยธรรม' , bnf.bnf_fname ,1 )> 0  or  charindex('ทายาทตามกฏหมาย' , bnf.bnf_fname ,1 )> 0  then '99' 
									else centerdb.dbo.cnudf_GetMasterOic2('AH03','relationship','', bnf.bnf_relationship) 
								end
							), 
NumOfPerson= CONVERT(int,
					(
						case  when isnull(#Result.flag_group,'') ='G' and charindex('ตามรายการแนบ',#Result.ins_fname ,1) > 0 
								then (
										select count(ins_seq) 
										from his_insured i 
										where #Result.PolEnd_Yr = i.pol_yr and #Result.PolEnd_Br = i.pol_br and #Result.PolEnd_Pre = i.pol_pre and #Result.PolEnd_No = i.pol_no  and #Result.endos_seq = i.endos_seq
									)
							else  1 
						end
					)
				)

FROM  his_beneficiary bnf   WITH(NOLOCK)
left join centerdb.dbo.prefix prf3   WITH(NOLOCK) on 
							prf3.prefix_code = bnf.bnf_prefix

WHERE 
	#Result.IsPolicy = 0 and
	#Result.PolEnd_Yr = bnf.pol_yr and
	#Result.PolEnd_Br = bnf.pol_br and
	#Result.PolEnd_Pre = bnf.pol_pre and
	#Result.PolEnd_No = bnf.pol_no and
	#Result.endos_seq = bnf.endos_seq  and
	#Result.ins_seq = bnf.ins_seq and
		bnf.bnf_seq in (
						select min (bnf_seq) from his_beneficiary  where 
						#Result.PolEnd_Yr = pol_yr and
						#Result.PolEnd_Br = pol_br and
						#Result.PolEnd_Pre = pol_pre and
						#Result.PolEnd_No = pol_no and
						#Result.endos_seq = endos_seq  and
						#Result.ins_seq = ins_seq  
					)

--== End Benificialry
--===== Update when OccupationLevel h.ClassSub '0601','0602','0603','0604'

print 'Updating  endorse OccupationLevel ...'
UPDATE  #Result
SET OccupationLevel = (
						case when isnull( ins.ins_position_level,'0') = '0' or  
									ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' 
									then '01' 
									else  '0'+ isnull( ins.ins_position_level,'')   
								end
					  )
FROM
his_insured ins  
where
#Result.IsPolicy = 0 and
#Result.PolEnd_Yr = ins.pol_yr and 
#Result.PolEnd_Br = ins.pol_br and 
#Result.PolEnd_Pre = ins.pol_pre and 
#Result.PolEnd_No = ins.pol_no and 
#Result.endos_seq = ins.endos_seq AND
(
	#Result.ClassSub in ('0601','0602','0603','0604')
)
--===== End Update OccupationLevel

--=== UPDATE OccupationCode
select position,  isnull(centerdb.dbo.cnudf_GetMasterOic2(NULL,'position','',position ),'9999')  as oicPositionCode, 
      position_name, isnull(centerdb.dbo.cnudf_GetMasterOic2(NULL,'position',position_name ,''),'9999')  as oicPositionNameCode
INTO #OccupationCodeMapping2
from (
select distinct position,position_name from #Result where #Result.IsPolicy = 0 
) as a

print 'Updating  endorse OccupationCode ...'
UPDATE  #Result
SET OccupationCode = a.oicPositionCode
FROM #OccupationCodeMapping2 a
where  #Result.IsPolicy = 0 and #Result.position = a.position 

UPDATE  #Result
SET OccupationCode = a.oicPositionNameCode
FROM #OccupationCodeMapping2 a
where #Result.IsPolicy = 0  and #Result.OccupationCode = '' and #Result.position_name = a.position_name  


UPDATE  #Result
SET OccupationCode = '9999'
WHERE  OccupationCode is null

drop table #OccupationCodeMapping2

--select * from #Result where OccupationCode != '9999'

--=== End Update OccupationCode
--=== UPDATE Address

select country,  centerdb.dbo.cnudf_GetMasterOic2(NULL,'country','' ,a.country)   as oicCountryCode
INTO #CountryMapping2
from (
select distinct country from #Result where 
#Result.IsPolicy = 0 
) as a


print 'Updating  endorse InsuredCountryCode ...'
UPDATE #Result
SET InsuredCountryCode = #CountryMapping2.oicCountryCode
FROM #CountryMapping2
WHERE
#Result.IsPolicy = 0 and #Result.country = #CountryMapping2.country 

drop table #CountryMapping2

print 'Updating  endorse InsuredAddress in English...'
UPDATE #Result
SET InsuredAddress = Ltrim(
												(CASE isnull(addno, '')    WHEN ''  THEN '' ElSE addno+' ' END) + 
			       								 (CASE isnull(building, '') WHEN ''  THEN '' ELSE building+' Bld., ' END) + 
												 (CASE isnull(village, '')  WHEN ''  THEN '' ELSE village+' village, ' END) + 
												 (CASE isnull(street, '')   WHEN ''  THEN '' ELSE street+' Rd., ' END) + 
												 (CASE isnull(trog, '')     WHEN ''  THEN '' ELSE trog+', ' END) + 
												(CASE isnull(soi, '')      WHEN ''  THEN '' ELSE soi+', ' END)
											)
where flag_language  = 'E'


print 'Updating  endorse InsuredAddress in Thai...'
UPDATE #Result
SET InsuredAddress =  Ltrim(
										(CASE isnull(addno, '') WHEN 	'-' THEN '' WHEN 	'' THEN ''  ELSE 'เลขที่ '  + addno END)
									  +(CASE isnull(building, '') WHEN '' THEN '' ELSE ' ' + building END) 
									  +(CASE isnull(village, '') WHEN '' THEN '' ELSE ' ' + village END) 
									  +(CASE isnull(street, '') WHEN '' THEN '' ELSE ' ถ.' + street END) 
									  +(CASE isnull(trog, '') WHEN '' THEN '' ELSE ' ตรอก' + trog END) 
									  + (CASE isnull(soi, '') WHEN '' THEN '' ELSE ' ซ.' + soi END)
									) 
where 
#Result.IsPolicy = 0 and InsuredAddress is null and country = '764'


print 'Updating  endorse InsuredAddress other...'
UPDATE #Result
SET InsuredAddress = Ltrim(
										 (CASE isnull(addno, '') WHEN '' THEN '' ELSE addno END) 
										 + (CASE isnull(building, '') WHEN '' THEN '' ELSE '  ' + building END) 
										 + (CASE isnull(village, '')  WHEN '' THEN '' ELSE '  ' + village END) 
										 + (CASE isnull(street, '') WHEN '' THEN '' ELSE '  ' + street END) 
										 + (CASE isnull(trog, '') WHEN '' THEN '' ELSE '  ' + trog END) 
										 + (CASE isnull(soi, '')  WHEN '' THEN '' ELSE '  ' + soi END)
									)  	
where
#Result.IsPolicy = 0 and InsuredAddress is null 

--== Update District
select tumbol,amphur,province, centerdb.dbo.fn_OIC_Find_SubdistrictCode(tumbol,amphur,province)  as oicTumbolId
INTO #TumbolMapping2
from (
select distinct tumbol,amphur,province from #Result where 
#Result.IsPolicy = 0 
) as a
--select tumbol, centerdb.dbo.cnudf_GetMasterOic2(NULL,'district',a.tumbol ,'') as oicTumbolId
--INTO #TumbolMapping2
--from (
--select distinct tumbol from #Result where 
--#Result.IsPolicy = 0 
--) as a


print 'Updating  endorse InsuredProvinceDistrictSub...'
UPDATE #Result
SET InsuredProvinceDistrictSub	= #TumbolMapping2.oicTumbolId
FROM #TumbolMapping2
where 
#Result.IsPolicy = 0 and #TumbolMapping2.tumbol = #Result.tumbol and #TumbolMapping2.oicTumbolId is not null


drop table #TumbolMapping2

select CompanyCode+
		MainClass+'|'+
		SubClass+'|'+
		PolicyNumber+'|'+
		EndorsementNumber +'|'+
		Seq  +'|'+
		InsuredName +'|'+
		InsuredAddress  +'|'+
		IsNULL(InsuredProvinceDistrictSub,SUBSTRING(InsuredZipCode,1,2)+'0000')  +'|'+
		IsNULL(InsuredZipCode,'00000') +'|'+
		InsuredCountryCode  +'|'+
		InsuredCitizenId  +'|'+
		IsNULL(OccupationLevel,'')  +'|'+
		OccupationCode  +'|'+
		IsNULL(InsuredBirthday,'-')  +'|'+
		IsNULL(InsuredGender,'UNDEFINE')  +'|'+
		IsNULL(RelationHolderInsured,'13')  +'|'+
		IsNULL(Beneficiary1,'UNDEFINE')  +'|'+
		IsNULL(RelationInsuredBeneficiary1,'13')  +'|'+
		Rtrim(Convert(char(7),NumOfPerson))  +'|'+
		PremiumAmt  +'|'+
		TransactionStatus +'|'+ 
		ReferenceNumber 
 from #Result
 order by IsPolicy DESC, PolicyNumber,EndorsementNumber, Seq ASC


 select
 *
 from 
 (
 select (CompanyCode+
		MainClass+'|'+
		SubClass+'|'+
		PolicyNumber+'|'+
		EndorsementNumber +'|'+
		Seq  +'|'+
		InsuredName +'|'+
		InsuredAddress  +'|'+
		IsNULL(InsuredProvinceDistrictSub,SUBSTRING(InsuredZipCode,1,2)+'0000')  +'|'+
		IsNULL(InsuredZipCode,'00000') +'|'+
		InsuredCountryCode  +'|'+
		IsNULL(InsuredCitizenId,'UNDEFINE')  +'|'+ --waiting for confirmation 2015
		IsNULL(OccupationLevel,'')  +'|'+
		OccupationCode  +'|'+
		IsNULL(InsuredBirthday,'-')  +'|'+
		IsNULL(InsuredGender,'UNDEFINE')  +'|'+
		IsNULL(RelationHolderInsured,'13')  +'|'+
		IsNULL(Beneficiary1,'UNDEFINE')  +'|'+
		IsNULL(RelationInsuredBeneficiary1,'13')  +'|'+
		Rtrim(Convert(char(7),NumOfPerson))  +'|'+
		PremiumAmt  +'|'+
		TransactionStatus +'|'+ 
		ReferenceNumber ) as Name
 from #Result
 ) as a
 where a.Name is null
 
 select * from #Result where InsuredCitizenId is null
 --SELECT * FROM #Result where POLEND_yr='16' and pol_br='181' and pol_pre='569' and pol_no in ('230213','540096')


drop table #tempPolicy
drop table #tempEndorse --drop table #tempPolInsured
--drop table #Result


