﻿USE [miscwebdb]
GO
/****** Object:  StoredProcedure [dbo].[sp_OIC_AH_IS]    Script Date: 4/1/2561 9:09:35 ******/

 --drop table #tempPolicy
 --drop table #tempEndorse
 --drop table #tempPolInsured



Declare @StartDateFrom char(10) ,  @StartDateTo char(10),@BranchFrom char(3) ,@BranchTo char(3)  , @TrDateFrom  char(10)  , @TrDateTo char(10)
set	@StartDateFrom ='2013/01/01'
set @StartDateTo = '2013/01/31'
set @BranchFrom = '000'
set @BranchTo = '709'
set @TrDateFrom = null 
set @TrDateTo = NULL

--  DROP TABLE #Result
--  DROP TABLE #tempPolicy


CREATE TABLE #Result
	(
		CompanyCode VARCHAR(10),
		MainClass VARCHAR(50),
		Beneficiary1 VARCHAR (256),
		PolicyNumber VARCHAR(30),
		EndorsementNumber VARCHAR(2),
		SubClass varchar(5),
		ClassSub varchar(5),
		Seq varchar(25),
		InsuredName varchar(200),
		InsuredAddress varchar(500),
		InsuredProvinceDistrictSub  varchar(6),
		InsuredCitizenId varchar(20),
		OccupationCode varchar(10),
		OccupationLevel varchar(2),
		InsuredBirthday varchar(10),
		InsuredGender varchar(1),
		RelationHolderInsured varchar(2),
		InsuredFullName varchar(200),
		HolderFulName varchar(200),
		NumOfPerson INTEGER,
		PremiumAmt VARCHAR (10),
		TransactionStatus VARCHAR(3),
		ReferenceNumber VARCHAR(15),
		IsHisInsuredNull bit DEFAULT 0,
		IsInVatControl bit DEFAULT 0,

		PolEnd_Yr CHAR(2) NOT NULL,
		PolEnd_Br CHAR(3) NOT NULL,
		PolEnd_Pre CHAR(3)  NOT NULL,
		PolEnd_No CHAR(6)  NOT NULL,
  		endos_seq int NULL,
		IsPolicy bit  NOT NULL,
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

INSERT INTO #Result 
    (
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
      IsPolicy				        
		)
select p.class_oic,
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
       1
FROM #tempPolicy p
inner join 


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


-- Update Seq,RelationHolderInsured
UPDATE  #Result
SET Seq = ins.ins_seq,
InsuredCitizenId=ins.ins_idno,
OccupationCode=  (
					case when isnull(centerdb.dbo.cnudf_GetMasterOic('','position','',ins.ins_position ),'9999') =  '' then 
							  isnull(centerdb.dbo.cnudf_GetMasterOic('','position',ins.ins_position_name ,''),'9999')
						else  
							  isnull(centerdb.dbo.cnudf_GetMasterOic('','position','',ins.ins_position ),'9999')  
					end
				)
FROM
his_insured ins  WITH(NOLOCK) 
where
#Result.PolEnd_Yr= ins.pol_yr and
#Result.PolEnd_Br = ins.pol_br and
#Result.PolEnd_Pre = ins.pol_pre and
#Result.PolEnd_No = ins.pol_no and
#Result.endos_seq = ins.endos_seq

select * from #Result
select * 
from his_insured
where
pol_yr = '12' and
pol_br = '003' and
pol_pre = '533' and
pol_no = '000013' and
endos_seq = '0'

select isnull(centerdb.dbo.cnudf_GetMasterOic('','position','','30116' ),'9999')

--EXEC tempdb.dbo.sp_help N'#tempPolicy';

-- Update Address his_insured
UPDATE  #tempPolicy
SET InsuredAddress = Case  #tempPolicy.flag_language     ---- Eng ------------------------------------------
			  						When 'E' Then
									  		Ltrim(
													(CASE isnull(ins.ins_addno, '')    WHEN ''  THEN '' ElSE ins.ins_addno+' ' END) + 
													(CASE isnull(ins.ins_building, '') WHEN ''  THEN '' ELSE ins.ins_building+' Bld., ' END) + 
													(CASE isnull(ins.ins_village, '')  WHEN ''  THEN '' ELSE ins.ins_village+' village, ' END) + 
													(CASE isnull(ins.ins_street, '')   WHEN ''  THEN '' ELSE ins.ins_street+' Rd., ' END) + 
													(CASE isnull(ins.ins_trog, '')     WHEN ''  THEN '' ELSE ins.ins_trog+', ' END) + 
													(CASE isnull(ins.ins_soi, '')      WHEN ''  THEN '' ELSE ins.ins_soi+', ' END)
												)
					ELSE
				 		CASE ins.ins_country WHEN '764' THEN 
										Ltrim(
															(CASE isnull(ins.ins_addno, '') WHEN 	'-' THEN '' WHEN 	'' THEN ''  ELSE 'เลขที่ '  + ins.ins_addno END)
															+ (CASE isnull(ins.ins_building, '') WHEN '' THEN '' ELSE ' ' + ins.ins_building END) 
															+ (CASE isnull(ins.ins_village, '') WHEN '' THEN '' ELSE ' ' + ins.ins_village END) + 
															(CASE isnull(ins.ins_street, '') WHEN '' THEN '' ELSE ' ถ.' + ins.ins_street END) + 
															(CASE isnull(ins.ins_trog, '') WHEN '' THEN '' ELSE ' ตรอก' + ins.ins_trog END) 
															+ (CASE isnull(ins.ins_soi, '') WHEN '' THEN '' ELSE ' ซ.' + ins.ins_soi END)
														) 
						ELSE
							Ltrim(
									 (CASE isnull(ins.ins_addno, '') WHEN '' THEN '' ELSE ins.ins_addno END) 
									 + (CASE isnull(ins.ins_building, '') WHEN '' THEN '' ELSE '  ' + ins.ins_building END) 
									 + (CASE isnull(ins.ins_village, '')  WHEN '' THEN '' ELSE '  ' + ins.ins_village END) 
									 + (CASE isnull(ins.ins_street, '') WHEN '' THEN '' ELSE '  ' + ins.ins_street END) 
									 + (CASE isnull(ins.ins_trog, '') WHEN '' THEN '' ELSE '  ' + ins.ins_trog END) 
									 + (CASE isnull(ins.ins_soi, '')  WHEN '' THEN '' ELSE '  ' + ins.ins_soi END)
							 )
						End
					END	
					,
	IsHisInsuredNull = 0,
	InsuredProvinceDistrictSub 	= centerdb.dbo.cnudf_GetMasterOic('','district',ins.ins_tumbol ,'')+'|',
	InsuredZipCode = ins.ins_zipcode+'|',
	InsuredCountryCode = centerdb.dbo.cnudf_GetMasterOic('','country','' ,ins.ins_country)+'|',
	InsuredFullName =  ins.ins_fname + ins.ins_lname
FROM
his_insured ins  
where
#tempPolicy.pol_yr = ins.pol_yr and
#tempPolicy.pol_br = ins.pol_br and
#tempPolicy.pol_pre = ins.pol_pre and
#tempPolicy.pol_no = ins.pol_no and
#tempPolicy.endos_seq = ins.endos_seq 
 AND
(
	ins.ins_addno is not null AND
	ins.ins_amphur is not null AND
	ins.ins_province is not null 
)


-- Update Address his_holder
UPDATE  #tempPolicy
SET InsuredAddress = Case  #tempPolicy.flag_language     ---- Eng ------------------------------------------
			  						When 'E' Then
									  		Ltrim(
											(CASE isnull(hld.hld_addno, '')    WHEN ''  THEN '' ElSE hld.hld_addno+' ' END) + 
											(CASE isnull(hld.hld_building, '') WHEN ''  THEN '' ELSE hld.hld_building+' Bld., ' END) + 
											(CASE isnull(hld.hld_village, '')  WHEN ''  THEN '' ELSE hld.hld_village+' village, ' END) + 
											(CASE isnull(hld.hld_street, '')   WHEN ''  THEN '' ELSE hld.hld_street+' Rd., ' END) + 
											(CASE isnull(hld.hld_trog, '')     WHEN ''  THEN '' ELSE hld.hld_trog+', ' END) + 
											(CASE isnull(hld.hld_soi, '')      WHEN ''  THEN '' ELSE hld.hld_soi+', ' END)
										)
					ELSE
				 		CASE hld.hld_country WHEN '764' THEN 
										Ltrim(
										(CASE isnull(hld.hld_addno, '') WHEN 	'-' THEN '' WHEN 	'' THEN ''  ELSE 'เลขที่ '  + hld.hld_addno END)
									  +(CASE isnull(hld.hld_building, '') WHEN '' THEN '' ELSE ' ' + hld.hld_building END) 
									  +(CASE isnull(hld.hld_village, '') WHEN '' THEN '' ELSE ' ' + hld.hld_village END) 
									  +(CASE isnull(hld.hld_street, '') WHEN '' THEN '' ELSE ' ถ.' + hld.hld_street END) 
									  +(CASE isnull(hld.hld_trog, '') WHEN '' THEN '' ELSE ' ตรอก' + hld.hld_trog END) 
									  + (CASE isnull(hld.hld_soi, '') WHEN '' THEN '' ELSE ' ซ.' + hld.hld_soi END)
									) 
						ELSE
							Ltrim(
									 (CASE isnull(hld.hld_addno, '') WHEN '' THEN '' ELSE hld.hld_addno END) 
									 + (CASE isnull(hld.hld_building, '') WHEN '' THEN '' ELSE '  ' + hld.hld_building END) 
									 + (CASE isnull(hld.hld_village, '')  WHEN '' THEN '' ELSE '  ' + hld.hld_village END) 
									 + (CASE isnull(hld.hld_street, '') WHEN '' THEN '' ELSE '  ' + hld.hld_street END) 
									 + (CASE isnull(hld.hld_trog, '') WHEN '' THEN '' ELSE '  ' + hld.hld_trog END) 
									 + (CASE isnull(hld.hld_soi, '')  WHEN '' THEN '' ELSE '  ' + hld.hld_soi END)
								)  
						End
					END		
					,
	InsuredProvinceDistrictSub 	= centerdb.dbo.cnudf_GetMasterOic('','district',hld.hld_tumbol ,'')+'|',
	InsuredZipCode = hld.hld_zipcode+'|',
	InsuredCountryCode = centerdb.dbo.cnudf_GetMasterOic('','country','' ,hld.hld_country) +'|',
	RelationHolderInsured = (
							case  when #tempPolicy.InsuredFullName = hld.hld_fname+hld.hld_lname then '00'  
								 else  centerdb.dbo.cnudf_GetMasterOic('AH03','relationship','ผู้เอาประกัน','') 
							end 
						)+'|'		 				
FROM
his_holder  hld 
where
#tempPolicy.pol_yr = hld.pol_yr and
#tempPolicy.pol_br = hld.pol_br and
#tempPolicy.pol_pre = hld.pol_pre and
#tempPolicy.pol_no = hld.pol_no and
#tempPolicy.endos_seq = hld.endos_seq AND
#tempPolicy.IsHisInsuredNull = 1
--===== End Update Address

--===== Update when OccupationLevel h.ClassSub '0601','0602','0603','0604'
UPDATE  #tempPolicy
SET OccupationLevel = (
						case when isnull( ins.ins_position_level,'0') = '0' or  ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' else  '0'+ isnull( ins.ins_position_level,'')   end
					  )+'|'
FROM
his_insured ins  
where
#tempPolicy.pol_yr = ins.pol_yr and
#tempPolicy.pol_br = ins.pol_br and
#tempPolicy.pol_pre = ins.pol_pre and
#tempPolicy.pol_no = ins.pol_no and
#tempPolicy.endos_seq = ins.endos_seq AND
(
	#tempPolicy.ClassSub in ('0601','0602','0603','0604')
)
--===== End Update OccupationLevel
--===== Update when InsuredBirthday &  InsuredGender
UPDATE  #tempPolicy
SET InsuredBirthday = (
						convert(varchar(10),ins.ins_birthdate,112)
					  )+'|',
	InsuredGender = (
					  case when isnull(ins.ins_sex,'') ='' then 
					  			case  when isnull(prf2.flag_sex,'N')='N' then 
								  	'M'  
								  else 
								  	prf2.flag_sex  
								end 
					   else case  when isnull( ins.ins_sex ,'N')='N' then 
					   				'M' 
								  else 
								  	ins.ins_sex  
							end 
					  end
					)+'|'
FROM
his_insured ins  
left join centerdb.dbo.prefix prf2 on 
								ins.ins_prefix = prf2.prefix_code
where
#tempPolicy.pol_yr = ins.pol_yr and
#tempPolicy.pol_br = ins.pol_br and
#tempPolicy.pol_pre = ins.pol_pre and
#tempPolicy.pol_no = ins.pol_no and
#tempPolicy.endos_seq = ins.endos_seq AND
(
	#tempPolicy.ClassSub in ('0601','0602','0604')
)


select e.pol_yr, e.pol_br, e.pol_no , e.app_yr , e.app_br, e.app_pre ,e.app_no , e.endos_yr, e.endos_no, e.net_premium , e.stamp , e.vat ,e.tax ,e.total_premium , h.start_date ,h.end_date ,h.sale_code , 
e.flag_language , c.flag_group , e.approve_datetime ,e.endos_group
into #tempEndorse
from ibs_end e  
inner join ibs_pol h  on e.pol_yr = h.pol_yr and e.pol_br = h.pol_br and e.app_pre = h.pol_pre and e.pol_no = h.pol_no
inner join centerdb.dbo.subclass c on e.app_pre = c.class_code+ c.subclass_code --and isnull(c.flag_mixpolicy,'') <> 'Y'
where c.class_oic in ('06','07','11')  and e.approve_datetime is not null 
and e.app_Yr  in  ('12' ,  '13' ,  '14' ,  '15' ,  '16' ,  '17')
and ( (e.eff_date is null)  or ( convert(varchar(10) , e.eff_date	 ,111 ) between  @StartDateFrom  and @StartDateTo))
and e.app_br >= @BranchFrom  
and e.app_br <= @BranchTo
and  ( (e.approve_datetime is null) or (convert(varchar(10) ,e.approve_datetime ,111 ) between  @TrDateFrom  and @TrDateTo))
--and h.pol_pre='574' and h.pol_br='181' and h.pol_yr='17' and h.pol_no = '000013' 
--and h.pol_pre='574' 
CREATE UNIQUE CLUSTERED INDEX i_tempEndorse
ON #tempEndorse (app_yr,app_br,app_pre,app_no);

--select * from #tempPolicy


select  
(select comp_code_oic+'|' from centerdb.dbo.sys_control) as CompanyCode ,
MainClass = h.MainClass , 
SubClass =   h.SubClass,
PolicyNumber =h.PolicyNumber ,
EndorsementNumber  = h.EndorsementNumber,
Seq=h.Seq, 
InsuredName= isnull(prf2.prefix_name,'') + case when isnull(prf2.flag_space,'')  ='Y' then ' ' else '' end  +ins.ins_fname +' ' +ins.ins_lname +'|' ,
InsuredAddress= h.InsuredAddress+'|', 
InsuredProvinceDistrictSub=  h.InsuredProvinceDistrictSub, 
InsuredZipCode= h.InsuredZipCode, 
InsuredCountryCode= h.InsuredCountryCode, 
InsuredCitizenId=h.InsuredCitizenId, 
OccupationLevel= h.OccupationLevel, 
OccupationCode=  h.OccupationCode,
InsuredBirthday =h.InsuredBirthday, 
InsuredGender = h.InsuredGender, 
RelationHolderInsured= h.RelationHolderInsured, 
Beneficiary1= (
				case when isnull(bnf.bnf_fname,'') ='' or charindex( 'ทายาทโดยธรรม',bnf.bnf_fname  ,1 )> 0  or  charindex( 'ทายาทตามกฏหมาย' ,bnf.bnf_fname ,1 )> 0  then 'ทายาทโดยธรรม'  
					else  isnull(prf3.prefix_name,'') + case when isnull(prf3.flag_space,11) = 'Y' then ' ' else '' end + bnf.bnf_fname +' ' + bnf.bnf_lname 
				end
				)+'|', 
RelationInsuredBeneficiary1= (
								case when  isnull(bnf.bnf_fname,'') ='' or charindex('ทายาทโดยธรรม' , bnf.bnf_fname ,1 )> 0  or  charindex('ทายาทตามกฏหมาย' , bnf.bnf_fname ,1 )> 0  then '99' 
									else centerdb.dbo.cnudf_GetMasterOic('AH03','relationship','', bnf.bnf_relationship) 
								end
							)+'|', 
NumOfPerson= cast(
					(
						case  when isnull(h.flag_group,'') ='G' and charindex('ตามรายการแนบ',ins.ins_fname ,1) > 0 
								then (
										select count(ins_seq) 
										from his_insured i 
										where h.pol_yr = i.pol_yr and h.pol_br = i.pol_br and h.pol_pre = i.pol_pre and h.pol_no = i.pol_no  and h.endos_seq = i.endos_seq
									)
							else  1 
						end
					) as varchar(20) 
				)+'|',
PremiumAmt= cast(convert(decimal(15,2),h.total_premium) as varchar(20))+'|', 
TransactionStatus='N'+'|', 
ReferenceNumber=''
into #tempPolInsured

from #tempPolicy h 
left join centerdb.dbo.prefix prf2 on 
								ins.ins_prefix = prf2.prefix_code
left join his_beneficiary bnf on 
								ins.pol_yr = bnf.pol_yr and
								ins.pol_br = bnf.pol_br and
								ins.pol_pre = bnf.pol_pre and
								ins.pol_no = bnf.pol_no and
								ins.endos_seq = bnf.endos_seq  and
								ins.ins_seq = bnf.ins_seq  and
								bnf.bnf_seq in (
												select min (bnf_seq) from his_beneficiary  where 
												ins.pol_yr = pol_yr and
												ins.pol_br = pol_br and
												ins.pol_pre = pol_pre and
												ins.pol_no = pol_no and
												ins.endos_seq = endos_seq  and
												ins.ins_seq = ins_seq  
											)
left join centerdb.dbo.prefix prf3 on 
							prf3.prefix_code = bnf.bnf_prefix

union

select   (
			select comp_code_oic+'|' from centerdb.dbo.sys_control) as CompanyCode ,
			MainClass = c.class_oic +'|', 
			SubClass =  (case e.app_pre	 when '506' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = e.pol_yr and pol_br = e.pol_br and pol_pre = e.app_pre and pol_no = e.pol_no  /*order by journey_seq asc*/ ) 
			    when '516' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = e.pol_yr and pol_br = e.pol_br and pol_pre = e.app_pre and pol_no = e.pol_no  /*order by journey_seq asc*/ ) 
		else  c.subclass_oic end)+'|'  ,
PolicyNumber = e.sale_code+'-'+ e.pol_yr+e.pol_br+'/POL/'+e.pol_no+'-'+e.app_pre+'|' ,
EndorsementNumber  =     e.endos_yr+e.app_br +'/END/' +e.endos_no +'-'+e.app_pre +'|'
, Seq=cast(ins.ins_seq as varchar(20))+'|'
, InsuredName= isnull(prf2.prefix_name,'') + case when isnull(prf2.flag_space,'')  ='Y' then ' ' else '' end  +ins.ins_fname +' ' +ins.ins_lname  +'|'
, InsuredAddress=
(
Case  e.flag_language     ---- Eng ------------------------------------------
			  When 'E' Then
					case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
						when '' then
					Ltrim((CASE isnull(hld.hld_addno, '')    WHEN ''  THEN '' ElSE hld.hld_addno+' ' END) + 
			       	     (CASE isnull(hld.hld_building, '') WHEN ''  THEN '' ELSE hld.hld_building+' Bld., ' END) + 
						 (CASE isnull(hld.hld_village, '')  WHEN ''  THEN '' ELSE hld.hld_village+' village, ' END) + 
						 (CASE isnull(hld.hld_street, '')   WHEN ''  THEN '' ELSE hld.hld_street+' Rd., ' END) + 
						 (CASE isnull(hld.hld_trog, '')     WHEN ''  THEN '' ELSE hld.hld_trog+', ' END) + 
						(CASE isnull(hld.hld_soi, '')      WHEN ''  THEN '' ELSE hld.hld_soi+', ' END))
					else
						Ltrim((CASE isnull(ins.ins_addno, '')    WHEN ''  THEN '' ElSE ins.ins_addno+' ' END) + 
			       	     (CASE isnull(ins.ins_building, '') WHEN ''  THEN '' ELSE ins.ins_building+' Bld., ' END) + 
						 (CASE isnull(ins.ins_village, '')  WHEN ''  THEN '' ELSE ins.ins_village+' village, ' END) + 
						 (CASE isnull(ins.ins_street, '')   WHEN ''  THEN '' ELSE ins.ins_street+' Rd., ' END) + 
						 (CASE isnull(ins.ins_trog, '')     WHEN ''  THEN '' ELSE ins.ins_trog+', ' END) + 
							(CASE isnull(ins.ins_soi, '')      WHEN ''  THEN '' ELSE ins.ins_soi+', ' END))
					end
			ELSE

				 CASE ins.ins_country WHEN '764' THEN 
					case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
						when '' then
						        Ltrim((CASE isnull(hld.hld_addno, '') WHEN 	'-' THEN '' WHEN 	'' THEN ''  ELSE 'เลขที่ '  + hld.hld_addno END)
			                  +(CASE isnull(hld.hld_building, '') WHEN '' THEN '' ELSE ' ' + hld.hld_building END) 
			                  +(CASE isnull(hld.hld_village, '') WHEN '' THEN '' ELSE ' ' + hld.hld_village END) 
							  +(CASE isnull(hld.hld_street, '') WHEN '' THEN '' ELSE ' ถ.' + hld.hld_street END) 
							  +(CASE isnull(hld.hld_trog, '') WHEN '' THEN '' ELSE ' ตรอก' + hld.hld_trog END) 
			                  + (CASE isnull(hld.hld_soi, '') WHEN '' THEN '' ELSE ' ซ.' + hld.hld_soi END)) 
						else
			                        Ltrim((CASE isnull(ins.ins_addno, '') WHEN 	'-' THEN '' WHEN 	'' THEN ''  ELSE 'เลขที่ '  + ins.ins_addno END)
			                                 + (CASE isnull(ins.ins_building, '') WHEN '' THEN '' ELSE ' ' + ins.ins_building END) 
			                                 + (CASE isnull(ins.ins_village, '') WHEN '' THEN '' ELSE ' ' + ins.ins_village END) + 
			                                   (CASE isnull(ins.ins_street, '') WHEN '' THEN '' ELSE ' ถ.' + ins.ins_street END) + 
			                                   (CASE isnull(ins.ins_trog, '') WHEN '' THEN '' ELSE ' ตรอก' + ins.ins_trog END) 
			                                 + (CASE isnull(ins.ins_soi, '') WHEN '' THEN '' ELSE ' ซ.' + ins.ins_soi END)) 
						End
		           ELSE
						case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
						when '' then
						     Ltrim((CASE isnull(hld.hld_addno, '') WHEN '' THEN '' ELSE hld.hld_addno END) 
			                 + (CASE isnull(hld.hld_building, '') WHEN '' THEN '' ELSE '  ' + hld.hld_building END) 
							 + (CASE isnull(hld.hld_village, '')  WHEN '' THEN '' ELSE '  ' + hld.hld_village END) 
							 + (CASE isnull(hld.hld_street, '') WHEN '' THEN '' ELSE '  ' + hld.hld_street END) 
		                     + (CASE isnull(hld.hld_trog, '') WHEN '' THEN '' ELSE '  ' + hld.hld_trog END) 
							 + (CASE isnull(hld.hld_soi, '')  WHEN '' THEN '' ELSE '  ' + hld.hld_soi END))  
						else
				             Ltrim((CASE isnull(ins.ins_addno, '') WHEN '' THEN '' ELSE ins.ins_addno END) 
			                 + (CASE isnull(ins.ins_building, '') WHEN '' THEN '' ELSE '  ' + ins.ins_building END) 
							 + (CASE isnull(ins.ins_village, '')  WHEN '' THEN '' ELSE '  ' + ins.ins_village END) 
							 + (CASE isnull(ins.ins_street, '') WHEN '' THEN '' ELSE '  ' + ins.ins_street END) 
		                     + (CASE isnull(ins.ins_trog, '') WHEN '' THEN '' ELSE '  ' + ins.ins_trog END) 
							 + (CASE isnull(ins.ins_soi, '')  WHEN '' THEN '' ELSE '  ' + ins.ins_soi END))  
						end
				    END  
			END  
			)+'|'
, InsuredProvinceDistrictSub=  (case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
							when '' then centerdb.dbo.cnudf_GetMasterOic('','district',hld.hld_tumbol ,'')  else centerdb.dbo.cnudf_GetMasterOic('','district',ins.ins_tumbol ,'') end )+'|'
, InsuredZipCode= (case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
							when '' then hld.hld_zipcode else ins.ins_zipcode end)+'|'
, InsuredCountryCode= ( case  isnull(ins.ins_addno, '') +isnull(ins.ins_amphur, '') + isnull(ins.ins_province, '') 
							when '' then centerdb.dbo.cnudf_GetMasterOic('','country','' ,hld.hld_country)  else centerdb.dbo.cnudf_GetMasterOic('','country','' ,ins.ins_country)  end)+'|'
, InsuredCitizenId=ins.ins_idno+'|'
, OccupationLevel=(
					case  c.class_oic+c.subclass_oic	when '0601' then 
											case when isnull( ins.ins_position_level,'0') = '0' or  ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' else  '0'+ isnull( ins.ins_position_level,'')   end /**01  Defatult**/
									when '0602'  then  
											case when isnull( ins.ins_position_level,'0') = '0' or  ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' else  '0'+ isnull( ins.ins_position_level,'')   end /**01  Defatult**/
									when '0603'  then  
											case when isnull( ins.ins_position_level,'0') = '0' or  ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' else  '0'+ isnull( ins.ins_position_level,'')   end /**01  Defatult**/
									when '0604'  then  
											case when isnull( ins.ins_position_level,'0') = '0' or  ltrim(rtrim(isnull( ins.ins_position_level,'')))= '' then '01' else  '0'+ isnull( ins.ins_position_level,'')   end /**01  Defatult**/
									else '' end			)+'|'					
, OccupationCode=  (case when isnull(centerdb.dbo.cnudf_GetMasterOic('','position','',ins.ins_position ),'9999') =  '' then 
			 isnull(centerdb.dbo.cnudf_GetMasterOic('','position',ins.ins_position_name ,''),'9999')
			else  isnull(centerdb.dbo.cnudf_GetMasterOic('','position','',ins.ins_position ),'9999')  end)+'|'
, InsuredBirthday= (case  c.class_oic+c.subclass_oic	when '0601' then 
											convert(varchar(10),ins.ins_birthdate,112) 
									when '0602'  then  
											convert(varchar(10),ins.ins_birthdate,112) 
									when '0604'  then  
											convert(varchar(10),ins.ins_birthdate,112) 
									else '' end)+'|'

, InsuredGender= 	(case  c.class_oic+c.subclass_oic								
									when '0601' then 
												case when isnull(ins.ins_sex,'') ='' then case  when isnull(prf2.flag_sex,'N')='N' then 'M'  else prf2.flag_sex  end else case  when isnull( ins.ins_sex ,'N')='N' then 'M' else ins.ins_sex  end end 
									when '0602'  then  
												case when isnull(ins.ins_sex,'') ='' then case  when isnull(prf2.flag_sex,'N')='N' then 'M'  else prf2.flag_sex  end else case  when isnull( ins.ins_sex ,'N')='N' then 'M' else ins.ins_sex  end end 
									when '0604'  then  
												case when isnull(ins.ins_sex,'') ='' then case  when isnull(prf2.flag_sex,'N')='N' then 'M'  else prf2.flag_sex  end else case  when isnull( ins.ins_sex ,'N')='N' then 'M' else ins.ins_sex  end end 
									else '' end)+'|'
, RelationHolderInsured= (case  when ins.ins_fname + ins.ins_lname = hld.hld_fname+hld.hld_lname then ''  else  centerdb.dbo.cnudf_GetMasterOic('AH03','relationship','ผู้เอาประกัน','') end )+'|'
, Beneficiary1= (case when isnull(bnf.bnf_fname,'') ='' or  charindex( 'ทายาทโดยธรรม' ,bnf.bnf_fname ,1 )> 0  or  charindex('ทายาทตามกฏหมาย' , bnf.bnf_fname ,1 )> 0  then 'ทายาทโดยธรรม'  else  isnull(prf3.prefix_name,'') + case when isnull(prf3.flag_space,11) = 'Y' then ' ' else '' end + bnf.bnf_fname +' ' + bnf.bnf_lname end)+'|'
, RelationInsuredBeneficiary1= (case when isnull(bnf.bnf_fname,'') ='' or  charindex( 'ทายาทโดยธรรม' ,bnf.bnf_fname ,1 )> 0  or  charindex( 'ทายาทตามกฏหมาย' ,bnf.bnf_fname ,1 )> 0  then '99' else centerdb.dbo.cnudf_GetMasterOic('AH03','relationship','', bnf.bnf_relationship)  end )+'|'
, NumOfPerson= cast((case  when isnull(c.flag_group,'') ='G' and charindex(ins.ins_fname ,'ตามรายการแนบ',1) > 0 then (select count(ins_seq) from pol_insured i where e.pol_yr = i.pol_yr and e.pol_br = i.pol_br and e.app_pre = i.pol_pre and e.pol_no = i.pol_no  )
	else  1 end) as varchar(20) )+'|'
, PremiumAmt= cast(e.total_premium as varchar(20))+'|'
, TransactionStatus= 'N'--case isnull(ins.rec_status,'')  when 'A' then 'N'  when 'C' then 'U'  when 'D' then 'C' else 'N' end
, ReferenceNumber=''+'|'



from #tempEndorse e 
inner join endos_detail  ed on
e.app_yr = ed.app_yr and e.app_br = ed.app_br and e.app_pre = ed.app_pre and e.app_no = ed.app_no and 
ed.seq_no in (select min(seq_no) from endos_detail where e.app_yr = app_yr and e.app_br = app_br and  e.app_pre = app_pre and e.app_no = app_no)
inner join centerdb.dbo.subclass c on e.app_pre = c.class_code+ c.subclass_code --and isnull(c.flag_mixpolicy,'') <> 'Y' 
inner join pol_insured ins  on
e.pol_yr = ins.pol_yr and
e.app_br = ins.pol_br and
e.app_pre = ins.pol_pre and
e.pol_no = ins.pol_no 
and
(
	( e.flag_group = 'G' and  ins.ins_seq in (select ins_seq from endos_insured where endos_insured.app_yr = e.app_yr and endos_insured.app_br = e.app_br and endos_insured.app_pre = e.app_pre and endos_insured.app_no = e.app_no))
	or
	(isnull(e.flag_group,'I') ='I' and ins.ins_seq in (select ins_seq from pol_insured where pol_insured.pol_yr = e.pol_yr and pol_insured.pol_br = e.app_br and pol_insured.pol_pre = e.app_pre and pol_insured.pol_no = e.pol_no))
	or
	(ins.ins_seq in (select ins_seq from pol_insured where pol_insured.pol_yr = e.pol_yr and pol_insured.pol_br = e.app_br and pol_insured.pol_pre = e.app_pre and pol_insured.pol_no = e.pol_no and e.endos_group in ('2','3','4') ))
)
left join centerdb.dbo.prefix prf2 on ins.ins_prefix = prf2.prefix_code
left join pol_beneficiary bnf on 
e.pol_yr = bnf.pol_yr and
e.pol_br = bnf.pol_br and
e.app_pre = bnf.pol_pre and
e.pol_no = bnf.pol_no and
ins.ins_seq = bnf.ins_seq  and
bnf.bnf_seq in (select min (bnf_seq) from pol_beneficiary  where 
bnf.pol_yr = pol_beneficiary.pol_yr and
bnf.pol_br = pol_beneficiary.pol_br and
bnf.pol_pre = pol_beneficiary.pol_pre and
bnf.pol_no = pol_beneficiary.pol_no and
bnf.ins_seq = pol_beneficiary.ins_seq  
)

left join centerdb.dbo.prefix prf3 on prf3.prefix_code = bnf.bnf_prefix
left join pol_holder  hld on
e.pol_yr = hld.pol_yr and e.pol_br = hld.pol_br and
e.app_pre = hld.pol_pre and e.pol_no = hld.pol_no 
inner join centerdb.dbo.vat_control v on v.class_code+v.subclass_code = e.app_pre and v.start_date in (select max(centerdb.dbo.vat_control.start_date) from centerdb.dbo.vat_control
 where class_code+subclass_code = e.app_pre and centerdb.dbo.vat_control.start_date <= e.start_date)
--and bnf.pol_pre='563' and bnf.pol_br='181' and bnf.pol_yr='16' 


 select * from #tempPolInsured
 order by  EndorsementNumber , PolicyNumber , Seq

 



 drop table #tempPolicy
 drop table #tempEndorse
 drop table #tempPolInsured
