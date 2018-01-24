USE [miscwebdb]
GO


Declare @StartDateFrom char(10) ,  @StartDateTo char(10),@BranchFrom char(3) ,@BranchTo char(3)  , @TrDateFrom  char(10)  , @TrDateTo char(10)
set	@StartDateFrom ='2017/01/01'
set @StartDateTo = '2017/01/07'
set @BranchFrom = '000'
set @BranchTo = '709'
set @TrDateFrom = null 
set @TrDateTo = NULL


DECLARE @YEARNO_12 CHAR(2)
set @YEARNO_12 = '12';
DECLARE @YEARNO_13 CHAR(2)
set @YEARNO_13 = '13';
DECLARE @YEARNO_14 CHAR(2)
set @YEARNO_14 = '14';
DECLARE @YEARNO_15 CHAR(2)
set @YEARNO_15 = '15';
DECLARE @YEARNO_16 CHAR(2)
set @YEARNO_16 = '15';
DECLARE @YEARNO_17 CHAR(2)
set @YEARNO_17 = '17';

DECLARE @MonthNDayStart CHAR(6)
DECLARE @MonthNDayEnd CHAR(6)
DECLARE @YEARNO CHAR(2)
set @YEARNO =  @YEARNO_17

declare @pol_yr_start DATETIME;
SET @pol_yr_start = convert(datetime , @StartDateFrom ,121 )
DECLARE @pol_yr_end DATETIME;
set @pol_yr_end = convert(datetime , @StartDateTo ,121 )


--================== Endosement ==============================

SELECT e.pol_yr, e.pol_br, e.pol_no , e.app_yr , e.app_br, e.app_pre ,e.app_no , e.endos_yr, e.endos_no, e.net_premium , e.stamp , e.vat ,e.tax ,e.total_premium , h.start_date ,h.end_date ,h.sale_code , 
e.flag_language , c.class_code, c.subclass_oic, c.class_oic + c.subclass_oic AS class_n_subclass_oic, c.subclass_code, c.class_oic, c.flag_group , e.approve_datetime ,e.endos_group
INTO #tempEndorse
FROM ibs_end e  
inner join ibs_pol h  on e.pol_yr = h.pol_yr and e.pol_br = h.pol_br and e.app_pre = h.pol_pre and e.pol_no = h.pol_no
inner join endos_detail  ed on
	e.app_yr		= ed.app_yr 
	and e.app_br	= ed.app_br 
	and e.app_pre	= ed.app_pre 
	and e.app_no	= ed.app_no
and ed.seq_no in (select min(seq_no) from endos_detail where e.app_yr = app_yr and e.app_br = app_br and  e.app_pre = app_pre and e.app_no = app_no)
inner join centerdb.dbo.subclass c on e.app_pre = c.class_code + c.subclass_code --and isnull(c.flag_mixpolicy,'') <> 'Y'
WHERE e.app_Yr BETWEEN @YEARNO_13 AND @YEARNO_17 
and e.approve_datetime is not null 
and c.class_oic in ('06','07','11')  
and ( (e.eff_date is null)  or ( e.eff_date between  @pol_yr_start  and @pol_yr_end ))
and e.app_br BETWEEN @BranchFrom AND  @BranchTo
--and  ( (e.approve_datetime is null) or (convert(varchar(10) ,e.approve_datetime ,111 ) between  @TrDateFrom  and @TrDateTo))

CREATE UNIQUE CLUSTERED INDEX i_tempEndorse
ON #tempEndorse (app_yr,app_br,app_pre,app_no);

CREATE NONCLUSTERED INDEX i_tempEndorse_flag_group 
ON #tempEndorse (flag_group);

--drop table #tempEndorse

--=================== prefix =============================

CREATE TABLE #tmpPrefix (
	prefix_code CHAR(3) NOT NULL,
	flag_space CHAR(1) NULL,
	flag_sex CHAR(1) NULL,
	prefix_name VARCHAR(50) NOT NULL
	UNIQUE CLUSTERED ( prefix_code )
)

INSERT INTO #tmpPrefix
select prefix_code, flag_space, flag_sex, prefix_name from centerdb.dbo.prefix

--drop table #tmpPrefix

--=================== #tmpCountry =============================

--DECLARE @YEARNO_12 CHAR(2)
--set @YEARNO_12 = '12';
--DECLARE @YEARNO_13 CHAR(2)
--set @YEARNO_13 = '13';
--DECLARE @YEARNO_14 CHAR(2)
--set @YEARNO_14 = '14';
--DECLARE @YEARNO_15 CHAR(2)
--set @YEARNO_15 = '15';
--DECLARE @YEARNO_16 CHAR(2)
--set @YEARNO_16 = '15';
--DECLARE @YEARNO_17 CHAR(2)
--set @YEARNO_17 = '17';

CREATE TABLE #tmpCountryHld (
	country_number CHAR(3) NULL,
	country_code CHAR(3) NULL,
	UNIQUE CLUSTERED ( country_number )
)

INSERT INTO #tmpCountryHld
SELECT hld_country AS country_number , centerdb.dbo.cnudf_GetMasterOic('', 'country', '' , hld_country ) AS country_code 
FROM pol_holder (nolock)
WHERE pol_yr BETWEEN @YEARNO_13 AND @YEARNO_17
GROUP BY hld_country

--drop table #tmpCountryHld


--==================

--CREATE TABLE #tmpCountryIns (
--	country_number CHAR(3) NULL,
--	country_code CHAR(3) NULL,
--	UNIQUE CLUSTERED ( country_number )
--)

--INSERT INTO #tmpCountryIns
--SELECT ins_country AS country_number , centerdb.dbo.cnudf_GetMasterOic('', 'country', '' , ins_country ) AS country_code 
--FROM pol_insured (nolock)
--WHERE pol_yr BETWEEN @YEARNO_13 AND @YEARNO_17
--GROUP BY ins_country

--drop table #tmpCountryIns

--=================== SELECT =============================


DECLARE @comp_code_oic AS VARCHAR(10) 
SET @comp_code_oic = ( select comp_code_oic+'|' from centerdb.dbo.sys_control (NOLOCK) )

DECLARE @YEARNO_12 CHAR(2)
set @YEARNO_12 = '12';
DECLARE @YEARNO_13 CHAR(2)
set @YEARNO_13 = '13';
DECLARE @YEARNO_14 CHAR(2)
set @YEARNO_14 = '14';
DECLARE @YEARNO_15 CHAR(2)
set @YEARNO_15 = '15';
DECLARE @YEARNO_16 CHAR(2)
set @YEARNO_16 = '15';
DECLARE @YEARNO_17 CHAR(2)
set @YEARNO_17 = '17';

SELECT 
CompanyCode			= @comp_code_oic,
MainClass			= e.class_oic +'|', 
SubClass			=  (case when e.app_pre	IN ( '506' , '516' )
								THEN (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = e.pol_yr and pol_br = e.pol_br and pol_pre = e.app_pre and pol_no = e.pol_no  /*order by journey_seq asc*/ )
								--when '506' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = e.pol_yr and pol_br = e.pol_br and pol_pre = e.app_pre and pol_no = e.pol_no  /*order by journey_seq asc*/ ) 
								--when '516' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = e.pol_yr and pol_br = e.pol_br and pol_pre = e.app_pre and pol_no = e.pol_no  /*order by journey_seq asc*/ ) 
						else  e.subclass_oic end )+'|'  ,
PolicyNumber		= e.sale_code+'-'+ e.pol_yr+e.pol_br+'/POL/'+e.pol_no+'-'+e.app_pre+'|' ,
EndorsementNumber	= e.endos_yr+e.app_br +'/END/' +e.endos_no +'-'+e.app_pre +'|' ,
Seq					= CAST(ins.ins_seq as varchar(20))+'|' ,
InsuredName			= ISNULL(prf2.prefix_name,'') + case when ISNULL(prf2.flag_space,'')  ='Y' then ' ' else '' end  +ins.ins_fname +' ' +ins.ins_lname  +'|' ,

-- no insurance address    return 233 rows in    12	sec 7 days
-- have insurance address  return 233 rows in    21	sec 7 days
-- have insurance address  return 233 rows in    31	sec try 1 7 days
-- have insurance address  return 233 rows in    05 sec try 3 modify all 7 days
-- have insurance address  return 217 rows in 01:33 sec try 4 modify all full 7 days
InsuredAddress = 
(
		CASE e.flag_language     ---- Eng ------------------------------------------
		WHEN 'E' THEN
				CASE ISNULL(ins.ins_addno, '') + ISNULL(ins.ins_amphur, '') + ISNULL(ins.ins_province, '') --ins.ins_addno IS NULL AND ins.ins_amphur IS NULL AND ins.ins_province IS NULL
				WHEN '' THEN
					Ltrim(
					  (CASE WHEN hld.hld_addno		IS NULL	THEN '' ElSE hld.hld_addno+' ' END)
			       	+ (CASE WHEN hld.hld_building	IS NULL THEN '' ELSE hld.hld_building+' Bld., ' END)
					+ (CASE WHEN hld.hld_village	IS NULL THEN '' ELSE hld.hld_village+' village, ' END)
					+ (CASE WHEN hld.hld_street		IS NULL THEN '' ELSE hld.hld_street+' Rd., ' END)
					+ (CASE WHEN hld.hld_trog		IS NULL THEN '' ELSE hld.hld_trog+', ' END)
					+ (CASE WHEN hld.hld_soi		IS NULL THEN '' ELSE hld.hld_soi+', ' END))
				ELSE
					Ltrim(
					  (CASE WHEN ins.ins_addno		IS NULL	THEN '' ElSE ins.ins_addno+' ' END)
			       	+ (CASE WHEN ins.ins_building	IS NULL THEN '' ELSE ins.ins_building+' Bld., ' END)
					+ (CASE WHEN ins.ins_village	IS NULL THEN '' ELSE ins.ins_village+' village, ' END)
					+ (CASE WHEN ins.ins_street		IS NULL THEN '' ELSE ins.ins_street+' Rd., ' END)
					+ (CASE WHEN ins.ins_trog		IS NULL THEN '' ELSE ins.ins_trog+', ' END)
					+ (CASE WHEN ins.ins_soi		IS NULL THEN '' ELSE ins.ins_soi+', ' END))
				END
		ELSE
			CASE ins.ins_country WHEN '764' THEN 
				CASE ISNULL(ins.ins_addno, '') + ISNULL(ins.ins_amphur, '') + ISNULL(ins.ins_province, '') --ins.ins_addno IS NULL AND ins.ins_amphur IS NULL AND ins.ins_province IS NULL
				WHEN '' THEN
					Ltrim(
					  (CASE WHEN hld.hld_addno		IS NULL  OR hld.hld_addno = '-'		
															THEN '' ELSE 'เลขที่ '  + hld.hld_addno END)
					+ (CASE WHEN hld.hld_building	IS NULL THEN '' ELSE ' ' + hld.hld_building END) 
					+ (CASE WHEN hld.hld_village	IS NULL THEN '' ELSE ' ' + hld.hld_village END) 
					+ (CASE WHEN hld.hld_street		IS NULL THEN '' ELSE ' ถ.' + hld.hld_street END) 
					+ (CASE WHEN hld.hld_trog		IS NULL THEN '' ELSE ' ตรอก' + hld.hld_trog END) 
					+ (CASE WHEN hld.hld_soi		IS NULL THEN '' ELSE ' ซ.' + hld.hld_soi END)) 
				ELSE
					Ltrim(
					  (CASE WHEN ins.ins_addno		IS NULL  OR ins.ins_addno = '-'		
															THEN '' ELSE 'เลขที่ '  + ins.ins_addno END)
					+ (CASE WHEN ins.ins_building	IS NULL THEN '' ELSE ' ' + ins.ins_building END) 
					+ (CASE WHEN ins.ins_village	IS NULL THEN '' ELSE ' ' + ins.ins_village END) 
					+ (CASE WHEN ins.ins_street		IS NULL THEN '' ELSE ' ถ.' + ins.ins_street END) 
					+ (CASE WHEN ins.ins_trog		IS NULL THEN '' ELSE ' ตรอก' + ins.ins_trog END) 
					+ (CASE WHEN ins.ins_soi		IS NULL THEN '' ELSE ' ซ.' + ins.ins_soi END)) 
				END
			ELSE
				CASE ISNULL(ins.ins_addno, '') + ISNULL(ins.ins_amphur, '') + ISNULL(ins.ins_province, '') --ins.ins_addno IS NULL AND ins.ins_amphur IS NULL AND ins.ins_province IS NULL
				WHEN '' THEN
					Ltrim(
					  (CASE WHEN hld.hld_addno		IS NULL THEN '' ELSE hld.hld_addno END) 
					+ (CASE WHEN hld.hld_building	IS NULL THEN '' ELSE '  ' + hld.hld_building END) 
					+ (CASE WHEN hld.hld_village	IS NULL THEN '' ELSE '  ' + hld.hld_village END) 
					+ (CASE WHEN hld.hld_street		IS NULL THEN '' ELSE '  ' + hld.hld_street END) 
					+ (CASE WHEN hld.hld_trog		IS NULL THEN '' ELSE '  ' + hld.hld_trog END) 
					+ (CASE WHEN hld.hld_soi		IS NULL THEN '' ELSE '  ' + hld.hld_soi END))  
				ELSE
					Ltrim(
					  (CASE WHEN ins.ins_addno		IS NULL THEN '' ELSE ins.ins_addno END) 
					+ (CASE WHEN ins.ins_building	IS NULL THEN '' ELSE '  ' + ins.ins_building END) 
					+ (CASE WHEN ins.ins_village	IS NULL THEN '' ELSE '  ' + ins.ins_village END) 
					+ (CASE WHEN ins.ins_street		IS NULL THEN '' ELSE '  ' + ins.ins_street END) 
					+ (CASE WHEN ins.ins_trog		IS NULL THEN '' ELSE '  ' + ins.ins_trog END) 
					+ (CASE WHEN ins.ins_soi		IS NULL THEN '' ELSE '  ' + ins.ins_soi END)) 
				END
			END
		END  
)+'|' 
, InsuredProvinceDistrictSub	=  (case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
									when '' then centerdb.dbo.cnudf_GetMasterOic('','district'  ,hld.hld_tumbol ,'')  
											else centerdb.dbo.cnudf_GetMasterOic('','district'  ,ins.ins_tumbol ,'') end )+'|'
, InsuredZipCode				= (case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
									when '' then hld.hld_zipcode 
											else ins.ins_zipcode end)+'|'
, InsuredCountryCode			= ( case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
									when '' then centerdb.dbo.cnudf_GetMasterOic('','country','' ,hld.hld_country)  
											else centerdb.dbo.cnudf_GetMasterOic('','country','' ,ins.ins_country)  end)+'|'
, InsuredCitizenId				= ins.ins_idno + '|'
, OccupationLevel				= (
					case  e.class_n_subclass_oic	
									when '0601' then 
											case when ins.ins_position_level IS NULL OR ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' 
											else  '0'+ isnull( ins.ins_position_level,'')   end /**01  Defatult**/
									when '0602'  then  
											case when ins.ins_position_level IS NULL OR ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' 
											else  '0'+ isnull( ins.ins_position_level,'')   end /**01  Defatult**/
									when '0603'  then  
											case when ins.ins_position_level IS NULL OR ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' 
											else  '0'+ isnull( ins.ins_position_level,'')   end /**01  Defatult**/
									when '0604'  then  
											case when ins.ins_position_level IS NULL OR ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' 
											else  '0'+ isnull( ins.ins_position_level,'')   end /**01  Defatult**/
									else '' end			)+'|'					
, OccupationCode  = (case when isnull(centerdb.dbo.cnudf_GetMasterOic('','position','' ,ins.ins_position ),'9999') =  '' then 
							   isnull(centerdb.dbo.cnudf_GetMasterOic('','position', ins.ins_position_name ,''),'9999')
						  else isnull(centerdb.dbo.cnudf_GetMasterOic('','position','' ,ins.ins_position ),'9999')  end) + '|'
, InsuredBirthday = (case  when e.class_n_subclass_oic IN ('0601' , '0602', '0604') 
									then  convert(varchar(10),ins.ins_birthdate,112) 
									--when '0601'  then  convert(varchar(10),ins.ins_birthdate,112) 
									--when '0602'  then  convert(varchar(10),ins.ins_birthdate,112) 
									--when '0604'  then  convert(varchar(10),ins.ins_birthdate,112) 
									else '' end)+'|'
, InsuredGender    = (case WHEN e.class_n_subclass_oic IN ('0601' , '0602', '0604') 
									then case when isnull(ins.ins_sex,'') ='' then case  when isnull(prf2.flag_sex,'N')='N' then 'M'  else prf2.flag_sex  end else case  when isnull( ins.ins_sex ,'N')='N' then 'M' else ins.ins_sex  end end 
									--when '0601' then 
									--			case when isnull(ins.ins_sex,'') ='' then case  when isnull(prf2.flag_sex,'N')='N' then 'M'  else prf2.flag_sex  end else case  when isnull( ins.ins_sex ,'N')='N' then 'M' else ins.ins_sex  end end 
									--when '0602'  then  
									--			case when isnull(ins.ins_sex,'') ='' then case  when isnull(prf2.flag_sex,'N')='N' then 'M'  else prf2.flag_sex  end else case  when isnull( ins.ins_sex ,'N')='N' then 'M' else ins.ins_sex  end end 
									--when '0604'  then  
									--			case when isnull(ins.ins_sex,'') ='' then case  when isnull(prf2.flag_sex,'N')='N' then 'M'  else prf2.flag_sex  end else case  when isnull( ins.ins_sex ,'N')='N' then 'M' else ins.ins_sex  end end 
									else '' end)+'|'
, RelationHolderInsured			= (case  when ins.ins_fname + ins.ins_lname = hld.hld_fname+hld.hld_lname then ''  
										else  centerdb.dbo.cnudf_GetMasterOic('AH03','relationship','ผู้เอาประกัน','') end )+'|'
, Beneficiary1					= (case when isnull(bnf.bnf_fname,'') ='' or  charindex( 'ทายาทโดยธรรม' ,bnf.bnf_fname ,1 )> 0  or  charindex('ทายาทตามกฏหมาย' , bnf.bnf_fname ,1 )> 0  then 'ทายาทโดยธรรม'  
										else  isnull(prf3.prefix_name,'') + case when isnull(prf3.flag_space,11) = 'Y' then ' ' else '' end + bnf.bnf_fname +' ' + bnf.bnf_lname end)+'|'
, RelationInsuredBeneficiary1	= (case when isnull(bnf.bnf_fname,'') ='' or  charindex( 'ทายาทโดยธรรม' ,bnf.bnf_fname ,1 )> 0  or  charindex( 'ทายาทตามกฏหมาย' ,bnf.bnf_fname ,1 )> 0  then '99' 
										else centerdb.dbo.cnudf_GetMasterOic('AH03','relationship','', bnf.bnf_relationship)  end )+'|'
, NumOfPerson					= cast((case  when isnull(e.flag_group,'') ='G' and charindex(ins.ins_fname ,'ตามรายการแนบ',1) > 0 then (select count(ins_seq) from pol_insured i where e.pol_yr = i.pol_yr and e.pol_br = i.pol_br and e.app_pre = i.pol_pre and e.pol_no = i.pol_no  )
										else  1 end) as varchar(20) )+'|'
, PremiumAmt					= cast(e.total_premium as varchar(20))+'|'
, TransactionStatus				= 'N'--case isnull(ins.rec_status,'')  when 'A' then 'N'  when 'C' then 'U'  when 'D' then 'C' else 'N' end
, ReferenceNumber				= '' + '|'

FROM #tempEndorse e 
INNER JOIN centerdb.dbo.vat_control v 
	ON v.class_code + v.subclass_code = e.app_pre 
	and v.start_date in ( select max(centerdb.dbo.vat_control.start_date) 
							from centerdb.dbo.vat_control
							where class_code + subclass_code = e.app_pre 
							and centerdb.dbo.vat_control.start_date <= e.start_date
							)
INNER JOIN pol_insured ins  on
	e.pol_yr	= ins.pol_yr and
	e.app_br	= ins.pol_br and
	e.app_pre	= ins.pol_pre and
	e.pol_no	= ins.pol_no 
and
(
	( e.flag_group = 'G' and  ins.ins_seq in (
			SELECT ins_seq 
			FROM endos_insured 
			WHERE endos_insured.app_yr = e.app_yr 
			and endos_insured.app_br = e.app_br 
			and endos_insured.app_pre = e.app_pre 
			and endos_insured.app_no = e.app_no
			)
	)
	or
	( isnull(e.flag_group,'I') = 'I' )
	or
	( ins.ins_seq in (
			SELECT ins_seq 
			FROM pol_insured 
			WHERE pol_insured.pol_yr = e.pol_yr 
			and pol_insured.pol_br = e.app_br 
			and pol_insured.pol_pre = e.app_pre 
			and pol_insured.pol_no = e.pol_no 
			and e.endos_group in ('2','3','4') 
			)
	)
)
-- 233 -> 217
LEFT JOIN #tmpPrefix prf2 on ins.ins_prefix		= prf2.prefix_code
LEFT JOIN pol_beneficiary bnf 
ON bnf.pol_yr BETWEEN @YEARNO_13 AND @YEARNO_17
and e.pol_yr	= bnf.pol_yr 
and e.pol_br	= bnf.pol_br 
and e.app_pre	= bnf.pol_pre 
and e.pol_no	= bnf.pol_no 
and ins.ins_seq = bnf.ins_seq 
and bnf.bnf_seq in ( select min (bnf_seq) 
						from pol_beneficiary  
						where bnf.pol_yr	= pol_beneficiary.pol_yr 
							and bnf.pol_br	= pol_beneficiary.pol_br 
							and bnf.pol_pre = pol_beneficiary.pol_pre 
							and bnf.pol_no	= pol_beneficiary.pol_no 
							and bnf.ins_seq = pol_beneficiary.ins_seq  
						)
LEFT JOIN #tmpPrefix prf3 on prf3.prefix_code	= bnf.bnf_prefix

LEFT JOIN pol_holder  hld 
	on hld.pol_yr BETWEEN @YEARNO_13 AND @YEARNO_17
	and hld.pol_yr	= e.pol_yr
	and hld.pol_br	= e.pol_br
	and hld.pol_pre = e.app_pre
	and hld.pol_no	= e.pol_no

--LEFT JOIN pol_journey_ta  journeyTA 
--	where journeyTA.pol_yr	= e.pol_yr 
--	and journeyTA.pol_br	= e.pol_br 
--	and journeyTA.pol_pre	= e.app_pre 
--	and journeyTA.pol_no	= e.pol_no

--where --'000008' = ins.pol_no and 
--ins.pol_yr = '17' and ins.pol_br = 006 and ins.pol_pre = '520'

--===================================================
