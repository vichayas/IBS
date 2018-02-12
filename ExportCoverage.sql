
--try 1 branch 401
-- 2013-01-01  --> 2013-01-31 |    159 rows take 00:33 sec
--try 2 branch 401
-- 2013-01-01  --> 2013-03-31 |    374 rows take 01:01 sec
--try 3 all branch
-- 2013-01-01  --> 2013-01-31 | 21 294 rows take 01:38 sec

--try 4 all branch 000 - 709 ** check query again *** between
-- 2013-01-01  --> 2013-01-31 | 21 512 rows take 04:05 sec
--try 5 all branch 000 - 709 ** check query again *** where in
-- 2013-01-01  --> 2013-01-31 | 21 512 rows take 04:03 sec
--try 6 all branch 000 - 709 ** check query again *** where in
-- 2013-01-01  --> 2013-01-31 | 21 512 rows take 03:35 sec

--try 7 all branch 000 - 709 ** check query again *** where in
-- 2013-03-01  --> 2013-03-31 | 317 741  rows take 05:45 sec
--try 8 all branch 000 - 709 ** check query again *** where in
-- 2016-12-01  --> 2016-12-31 |  19 718  rows take 04:18 sec

--real
--try 9 all branch 000 - 709 ** check query again *** where between
-- 2013-02-01  --> 2013-02-28 |  96 411  rows take 10:08 sec
--try 10 all branch 000 - 709 ** check query again *** where between
-- 2013-02-01  --> 2013-02-28 |  97 515 rows take 05:26 sec

 --		drop table #TMP_HIS_COVER_PA
 --		drop table #TMP_POL_COVER_PA
 --		drop table #tempPolicyCO
 --		drop table #tempEndorseCO
 --		drop table #TempCoverTA
 --		drop table #TempResult
 --		drop table #TempCoverPA
 --		drop table #TempCoverPAX
 --		drop table #TempEndorsementPA
 --		drop table #TempEndorsementPAX
 --		drop table #TMP_FINAL_RESULT
 --		drop table #TMP_ENDORSE_BEFORE
 --		drop table #tmp_tab_cover_insurance_oic

--======================================================================================
--======================================================================================
--======================================================================================


DECLARE @BranchFrom char(3) ,@BranchTo char(3)  , @TrDateFrom  char(10)  , @TrDateTo char(10)
DECLARE @YEARNO_12 CHAR(2); set @YEARNO_12 = '12';
DECLARE @YEARNO_13 CHAR(2); set @YEARNO_13 = '13';
DECLARE @YEARNO_14 CHAR(2); set @YEARNO_14 = '14';
DECLARE @YEARNO_15 CHAR(2); set @YEARNO_15 = '15';
DECLARE @YEARNO_16 CHAR(2); set @YEARNO_16 = '16';
DECLARE @YEARNO_17 CHAR(2); set @YEARNO_17 = '17';
DECLARE @YEARNO_18 CHAR(2); set @YEARNO_18 = '18';
DECLARE @MonthNDayStart CHAR(6), @MonthNDayEnd CHAR(6)
Declare @StartDateFrom char(10),  @StartDateTo char(10)
DECLARE @YEARNO CHAR(2)
DECLARE @isMixAvailable CHAR(1)

set @BranchFrom = '000'
set @BranchTo = '709'
--set @BranchFrom = '502'
--set @BranchTo = '003'

set @TrDateFrom = null
set @TrDateTo = null

set @isMixAvailable = 'Y'
set @YEARNO =  @YEARNO_17 ----------------------------
set @MonthNDayStart = '/03/01'
--set @MonthNDayEnd = '/06/30'
set	@StartDateFrom ='20' + @YEARNO + @MonthNDayStart
--set @StartDateTo = '20' + @YEARNO + @MonthNDayEnd

DECLARE @pol_yr_start DATETIME;
SET @pol_yr_start = convert(datetime , '20' + @YEARNO + @MonthNDayStart ,121 )
DECLARE @pol_yr_end DATETIME;
set @pol_yr_end = convert(datetime , DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, @pol_yr_start )+1,0))  , 121 )

--select @pol_yr_start
--select @pol_yr_end

----- ===========================

--select * into #his_cover_pa  from his_cover_pa with (nolock) where start_date between convert(datetime ,@pol_yr_start ,121 ) and convert(datetime ,@pol_yr_end ,121 )
--select * into #pol_cover_pa  from pol_cover_pa with (nolock) where start_date between convert(datetime ,@pol_yr_start ,121 ) and convert(datetime ,@pol_yr_end ,121 )

BEGIN

CREATE TABLE #TMP_HIS_COVER_PA  (
	[pol_yr] [char](2) NOT NULL,	[pol_br] [char](3) NOT NULL,	[pol_pre] [char](3) NOT NULL,	
	[pol_no] [char](6) NOT NULL,	[endos_seq] [smallint] NOT NULL,	[ins_seq] [smallint] NOT NULL,	
	[start_date] [datetime] NULL,	[end_date] [datetime] NULL,	[itm1_pa1_sumins_amt] [float] NULL,	
	[itm1_pa1_deduct_amt] [float] NULL,	[itm1_pa1_net_premium] [float] NULL,	[itm1_pa2_sumins_amt] [float] NULL,	
	[itm1_pa2_deduct_amt] [float] NULL,	[itm1_pa2_net_premium] [float] NULL,	[itm2_mpw] [smallint] NULL,	
	[itm2_sumins_amt] [float] NULL,	[itm2_deduct_amt] [float] NULL,	[itm2_net_premium] [float] NULL,	
	[itm3_mpw] [smallint] NULL,	[itm3_sumins_amt] [float] NULL,	[itm3_deduct_amt] [float] NULL,	[itm3_net_premium] [float] NULL,	
	[itm4_sumins_amt] [float] NULL,	[itm4_deduct_amt] [float] NULL,	[itm4_net_premium] [float] NULL,	
	[itm1_war_sumins_amt] [float] NULL,	[itm1_war_net_premium] [float] NULL,	[itm1_strike_sumins_amt] [float] NULL,	
	[itm1_strike_net_premium] [float] NULL,	[itm1_play_sumins_amt] [float] NULL,	[itm1_play_net_premium] [float] NULL,	
	[itm1_drive_sumins_amt] [float] NULL,	[itm1_drive_net_premium] [float] NULL,	[itm1_travel_sumins_amt] [float] NULL,	
	[itm1_travel_net_premium] [float] NULL,	[itm2_war_sumins_amt] [float] NULL,	[itm2_war_net_premium] [float] NULL,	
	[itm2_strike_sumins_amt] [float] NULL,	[itm2_strike_net_premium] [float] NULL,	[itm2_play_sumins_amt] [float] NULL,	
	[itm2_play_net_premium] [float] NULL,	[itm2_drive_sumins_amt] [float] NULL,	[itm2_drive_net_premium] [float] NULL,	
	[itm2_travel_sumins_amt] [float] NULL,	[itm2_travel_net_premium] [float] NULL,	[itm3_war_sumins_amt] [float] NULL,	
	[itm3_war_net_premium] [float] NULL,	[itm3_strike_sumins_amt] [float] NULL,	[itm3_strike_net_premium] [float] NULL,	
	[itm3_play_sumins_amt] [float] NULL,	[itm3_play_net_premium] [float] NULL,	[itm3_drive_sumins_amt] [float] NULL,	
	[itm3_drive_net_premium] [float] NULL,	[itm3_travel_sumins_amt] [float] NULL,	[itm3_travel_net_premium] [float] NULL,	
	[itm4_war_sumins_amt] [float] NULL,	[itm4_war_net_premium] [float] NULL,	[itm4_strike_sumins_amt] [float] NULL,	
	[itm4_strike_net_premium] [float] NULL,	[itm4_play_sumins_amt] [float] NULL,	[itm4_play_net_premium] [float] NULL,	
	[itm4_drive_sumins_amt] [float] NULL,	[itm4_drive_net_premium] [float] NULL,	[itm4_travel_sumins_amt] [float] NULL,	
	[itm4_travel_net_premium] [float] NULL,	[murder_sumins_amt] [float] NULL,	[discnt_murder_amt] [float] NULL,	
	[income_amt_per_day] [float] NULL,	[die_amt_per_month] [float] NULL,	[income_amt_net_premium] [float] NULL,	
	[die_amt_net_premium] [float] NULL,	[cremate_sumins_amt] [float] NULL,	[cremate_net_premium] [float] NULL,	
	[itm1_pa1_add_sumins_amt] [float] NULL,	[itm1_pa1_add_deduct_amt] [float] NULL,	[itm1_pa1_add_net_premium] [float] NULL,	
	[itm1_pa2_add_sumins_amt] [float] NULL,	[itm1_pa2_add_deduct_amt] [float] NULL,	[itm1_pa2_add_net_premium] [float] NULL,	
	[income_time] [smallint] NULL,	[die_time] [smallint] NULL,	[net_premium] [float] NULL,
	UNIQUE CLUSTERED ([pol_yr], [pol_br], [pol_pre], [pol_no], [endos_seq], [ins_seq])
)

END
-- #endregion

CREATE TABLE #TMP_POL_COVER_PA(
	[pol_yr] [char](2) NOT NULL,	[pol_br] [char](3) NOT NULL,	[pol_pre] [char](3) NOT NULL,	[pol_no] [char](6) NOT NULL,	
	[ins_seq] [smallint] NOT NULL,	[start_date] [datetime] NULL,	[end_date] [datetime] NULL,	[itm1_pa1_sumins_amt] [float] NULL,	
	[itm1_pa1_deduct_amt] [float] NULL,	[itm1_pa1_net_premium] [float] NULL,	[itm1_pa2_sumins_amt] [float] NULL,	
	[itm1_pa2_deduct_amt] [float] NULL,	[itm1_pa2_net_premium] [float] NULL,	[itm2_mpw] [smallint] NULL,	[itm2_sumins_amt] [float] NULL,	
	[itm2_deduct_amt] [float] NULL,	[itm2_net_premium] [float] NULL,	[itm3_mpw] [smallint] NULL,	[itm3_sumins_amt] [float] NULL,	
	[itm3_deduct_amt] [float] NULL,	[itm3_net_premium] [float] NULL,	[itm4_sumins_amt] [float] NULL,	[itm4_deduct_amt] [float] NULL,	
	[itm4_net_premium] [float] NULL,	[itm1_war_sumins_amt] [float] NULL,	[itm1_war_net_premium] [float] NULL,	
	[itm1_strike_sumins_amt] [float] NULL,	[itm1_strike_net_premium] [float] NULL,	[itm1_play_sumins_amt] [float] NULL,	
	[itm1_play_net_premium] [float] NULL,	[itm1_drive_sumins_amt] [float] NULL,	[itm1_drive_net_premium] [float] NULL,	
	[itm1_travel_sumins_amt] [float] NULL,	[itm1_travel_net_premium] [float] NULL,	[itm2_war_sumins_amt] [float] NULL,	
	[itm2_war_net_premium] [float] NULL,	[itm2_strike_sumins_amt] [float] NULL,	[itm2_strike_net_premium] [float] NULL,	
	[itm2_play_sumins_amt] [float] NULL,	[itm2_play_net_premium] [float] NULL,	[itm2_drive_sumins_amt] [float] NULL,	
	[itm2_drive_net_premium] [float] NULL,	[itm2_travel_sumins_amt] [float] NULL,	[itm2_travel_net_premium] [float] NULL,	
	[itm3_war_sumins_amt] [float] NULL,	[itm3_war_net_premium] [float] NULL,	[itm3_strike_sumins_amt] [float] NULL,	
	[itm3_strike_net_premium] [float] NULL,	[itm3_play_sumins_amt] [float] NULL,	[itm3_play_net_premium] [float] NULL,	
	[itm3_drive_sumins_amt] [float] NULL,	[itm3_drive_net_premium] [float] NULL,	[itm3_travel_sumins_amt] [float] NULL,	
	[itm3_travel_net_premium] [float] NULL,	[itm4_war_sumins_amt] [float] NULL,	[itm4_war_net_premium] [float] NULL,	
	[itm4_strike_sumins_amt] [float] NULL,	[itm4_strike_net_premium] [float] NULL,	[itm4_play_sumins_amt] [float] NULL,	
	[itm4_play_net_premium] [float] NULL,	[itm4_drive_sumins_amt] [float] NULL,	[itm4_drive_net_premium] [float] NULL,	
	[itm4_travel_sumins_amt] [float] NULL,	[itm4_travel_net_premium] [float] NULL,	[murder_sumins_amt] [float] NULL,	
	[discnt_murder_amt] [float] NULL,	[income_amt_per_day] [float] NULL,	[die_amt_per_month] [float] NULL,	
	[income_amt_net_premium] [float] NULL,	[die_amt_net_premium] [float] NULL,	[cremate_sumins_amt] [float] NULL,	
	[cremate_net_premium] [float] NULL,	[itm1_pa1_add_sumins_amt] [float] NULL,	[itm1_pa1_add_deduct_amt] [float] NULL,	
	[itm1_pa1_add_net_premium] [float] NULL,	[itm1_pa2_add_sumins_amt] [float] NULL,	[itm1_pa2_add_deduct_amt] [float] NULL,	
	[itm1_pa2_add_net_premium] [float] NULL,	[income_time] [smallint] NULL,	[die_time] [smallint] NULL,	[net_premium] [float] NULL,
	UNIQUE CLUSTERED ([pol_yr], [pol_br], [pol_pre], [pol_no], [ins_seq])
)

--select   , h.start_date ,h.end_date ,h.sale_code , h.flag_language ,c.flag_group , h.tr_datetime  
--into #tempPolicyCO

CREATE TABLE #tempPolicyCO (
	[pol_yr] [char](2) NULL,	[pol_br] [char](3) NULL,	[pol_pre] [char](3) NULL,	[pol_no] [char](6) NULL,	
	[endos_seq] [int] NULL,	[net_premium] [float] NULL,	[stamp] [float] NULL,	[vat] [float] NULL,	[tax] [float] NULL,	
	[total_premium] [float] NULL,	[start_date] [varchar](20) NULL,	[end_date] [varchar](20) NULL,	[sale_code] [char](5) NULL,	
	[flag_language] [char](1) NULL,	[flag_group] [char](1) NULL,	[tr_datetime] [varchar](20) NULL,
	[class_oic] [char](2) NOT NULL,
	[subclass_oic] [char](2) NOT NULL,
	[SubClass] [char](2) NOT NULL
	UNIQUE CLUSTERED ([pol_yr], [pol_br], [pol_pre], [pol_no])
)

CREATE TABLE #tempEndorseCO (
	[pol_yr] [char](2) NULL,	[pol_br] [char](3) NULL,	[pol_pre] [char](3) NULL,	[pol_no] [char](6) NULL,
	[app_yr] [char](2) NULL,	[app_br] [char](3) NULL,	[app_pre] [char](3) NULL,	[app_no] [char](6) NULL,
	[endos_yr] [char](2) NULL,	[endos_no] [char](6) NULL,	--[endos_seq] [int] NULL,	
	[net_premium] [float] NULL,
	[stamp] [float] NULL,	[vat] [float] NULL,	[tax] [float] NULL,	[total_premium] [float] NULL,
	[start_date] [varchar](20) NULL,	[end_date] [varchar](20) NULL,	[sale_code] [char](5) NULL,	[flag_language] [char](1) NULL,
	[flag_group] [char](1) NULL,	[approve_datetime] [datetime] NULL,	[endos_group] [varchar](10) NULL,
	[class_oic] [char](2) NOT NULL,	[subclass_oic] [char](2) NOT NULL,  [SubClass] [char](2) NOT NULL
	--UNIQUE CLUSTERED ([pol_yr], [pol_br], [pol_no])
)

CREATE NONCLUSTERED INDEX [ix_index_tmpendose] ON #tempEndorseCO ([pol_yr], [pol_br], [app_pre], [pol_no]);

CREATE TABLE #TempCoverTA (
	[pol_yr] [char](2) NOT NULL,	[pol_br] [char](3) NOT NULL,	[pol_pre] [char](3) NOT NULL,	[pol_no] [char](6) NOT NULL,	[endos_seq] [smallint] NOT NULL,	
	[ins_seq] [smallint] NOT NULL,
	--[oic_main_code] [VARCHAR](100) NULL,	--[oic_code] [VARCHAR](100) NULL,	
	[itm1_sumins_amt] [float] NULL,	[itm1_net_premium] [float] NULL,	
	[itm2_sumins_amt] [float] NULL,	[itm2_net_premium] [float] NULL,	[murder_sumins_amt] [float] NULL,	[discnt_murder_amt] [float] NULL,	
	[person_qty] [int] NULL,	[itm1_play_sumins_amt] [float] NULL,	[itm1_play_net_premium] [float] NULL,	[itm2_play_sumins_amt] [float] NULL,	
	[itm2_play_net_premium] [float] NULL,	[itm1_drive_sumins_amt] [float] NULL,	[itm1_drive_net_premium] [float] NULL,	
	[itm2_drive_sumins_amt] [float] NULL,	[itm2_drive_net_premium] [float] NULL,	[itm1_travel_sumins_amt] [float] NULL,	
	[itm1_travel_net_premium] [float] NULL,	[itm2_travel_sumins_amt] [float] NULL,	[itm2_travel_net_premium] [float] NULL,	
	[discnt_guide_amt] [float] NULL,	
	--[net_premium] [float] NULL,	--[sumins_amt] [float] NULL,
	UNIQUE CLUSTERED ([pol_yr], [pol_br], [pol_pre], [pol_no], [endos_seq], [ins_seq])
)

CREATE TABLE #TempResult (
	[pol_yr] [char](2) NOT NULL, 
	[pol_br] [char](3) NOT NULL,
	[pol_pre] [char](3) NOT NULL,
	[pol_no] [char](6) NOT NULL,
	--[endos_seq] [smallint] NOT NULL,
	[ins_seq] [smallint] NOT NULL,

	[oic_main_code] [VARCHAR](100) NOT NULL,
	[oic_code] [VARCHAR](100) NOT NULL,

	[sumins_amt] [float] NULL,
	[net_premium] [float] NULL
	--INDEX  ([pol_yr]) --endos_seq
)

CREATE NONCLUSTERED INDEX [ix_index_tmp] ON #TempResult ([pol_yr], [pol_br], [pol_pre], [pol_no]);

--============================= SETUP [#tmp_tab_cover_insurance_oic] ================================================================
PRINT 'INSERT INTO #tmp_tab_cover_insurance_oic '
CREATE TABLE [#tmp_tab_cover_insurance_oic](
	[class_code] [char](1) NOT NULL,
	[subclass_code] [char](2) NOT NULL,
	[cover_seq] [int] NOT NULL,
	[oic_main_code] [varchar](10) NULL,
	[oic_code] [varchar](10) NULL,
	UNIQUE CLUSTERED ([class_code], [subclass_code], [cover_seq])
)

INSERT INTO [#tmp_tab_cover_insurance_oic]
select * from tab_cover_insurance_oic (NOLOCK)

--============================= SETUP  #TMP_HIS_COVER_PA ================================================================
PRINT 'INSERT INTO #TMP_HIS_COVER_PA '

IF @isMixAvailable = 'N'
BEGIN
	INSERT #TMP_HIS_COVER_PA --#his_cover_pa
	SELECT * FROM his_cover_pa (NOLOCK) 
	WHERE pol_Yr BETWEEN @YEARNO_12 AND @YEARNO_18
	and pol_pre IN ('506','509','510','516','536','537','540','551','552','553','555','560','567','577','580','592')
	and pol_br between @BranchFrom and @BranchTo
	--AND pol_br NOT IN ( @BranchFrom,  @BranchTo )
	AND start_date between @pol_yr_start and @pol_yr_end
END
ELSE BEGIN
	INSERT #TMP_HIS_COVER_PA --#his_cover_pa
	SELECT * FROM his_cover_pa (NOLOCK) 
	WHERE pol_Yr BETWEEN @YEARNO_12 AND @YEARNO_18
	and pol_pre IN ('502','503','513','514','518','521','530','531','532','533','534','538','542','558','570','590','591')
	and pol_br between @BranchFrom and @BranchTo
	--AND pol_br NOT IN ( @BranchFrom,  @BranchTo )
	AND start_date between @pol_yr_start and @pol_yr_end

END

--============================= SETUP  #TMP_POL_COVER_PA ================================================================
PRINT 'INSERT INTO #TMP_POL_COVER_PA '

IF @isMixAvailable = 'N'
BEGIN
	INSERT #TMP_POL_COVER_PA
	SELECT * FROM pol_cover_pa (NOLOCK) 
	WHERE pol_Yr BETWEEN @YEARNO_12 AND @YEARNO_18 
	and pol_pre IN ('506','509','510','516','536','537','540','551','552','553','555','560','567','577','580','592') -- for non-mix policy 
	and pol_br between @BranchFrom and @BranchTo
	AND start_date between @pol_yr_start and @pol_yr_end
END
ELSE BEGIN
	INSERT #TMP_POL_COVER_PA
	SELECT * FROM pol_cover_pa (NOLOCK) 
	WHERE pol_Yr BETWEEN @YEARNO_12 AND @YEARNO_18 
	and pol_pre IN ('502','503','513','514','518','521','530','531','532','533','534','538','542','558','570','590','591') -- for mix policy 
	and pol_br between @BranchFrom and @BranchTo
	AND start_date between @pol_yr_start and @pol_yr_end
END
 
--============================= SETUP  #tempPolicyCO ================================================================

PRINT 'INSERT INTO #tempPolicyCO '
IF @isMixAvailable = 'N'
BEGIN
	INSERT INTO #tempPolicyCO
	SELECT [pol_yr],[pol_br],[pol_pre],[pol_no],[endos_seq],[net_premium],[stamp],[vat],[tax],[total_premium],[start_date],[end_date],[sale_code],	
		[flag_language],[flag_group],[tr_datetime],[class_oic],[subclass_oic], tmpPo.subclass_oic AS [SubClass] 
	FROM [dbo].[GetPolicys](@StartDateFrom) AS tmpPo
	WHERE tmpPo.pol_pre NOT IN ('579','569','564','564','562','561','539')
END
ELSE BEGIN
	INSERT INTO #tempPolicyCO
	SELECT [pol_yr],[pol_br],[pol_pre],[pol_no],[endos_seq],[net_premium],[stamp],[vat],[tax],[total_premium],[start_date],[end_date],[sale_code],	
		[flag_language],[flag_group],[tr_datetime],[class_oic],[subclass_oic], tmpPo.subclass_oic AS [SubClass] 
	FROM [dbo].[GetPolicys](@StartDateFrom) AS tmpPo
END
--move to nuew func
--INSERT INTO #tempPolicyCO
--SELECT   h.pol_yr , h.pol_br, h.pol_pre ,h.pol_no , h.endos_seq  , h.net_premium , h.stamp , h.vat ,h.tax ,h.total_premium , 
--h.start_date ,h.end_date ,h.sale_code , h.flag_language ,c.flag_group , h.tr_datetime , c.class_oic, c.subclass_oic, c.subclass_oic
--from ibs_pol h  with (nolock)
--inner join centerdb.dbo.subclass c on h.pol_pre = c.class_code + c.subclass_code and isnull(c.flag_mixpolicy,'') <> 'Y'
--where c.class_oic in ('06','07','11')   and  h.endos_seq = 0  
--and ( @pol_yr_start is not null and  h.start_datetime between  @pol_yr_start  and @pol_yr_end)
--and h.pol_br  between @BranchFrom  and @BranchTo
----AND h.pol_br NOT IN ( @BranchFrom,  @BranchTo )
----and  ( (@TrDateFrom is null) or (@TrDateFrom is not null  and  convert(varchar(10) , h.tr_datetime ,111 ) between  @TrDateFrom  and @TrDateTo))
----and h.pol_Yr IN ( @YEARNO_12, @YEARNO_13, @YEARNO_14, @YEARNO_15, @YEARNO_16, @YEARNO_17 )
--and h.pol_Yr BETWEEN @YEARNO_12 AND @YEARNO_18
----and h.pol_pre not in ('511','515','520','533','534','535','536','539','561','562','563','564','569','573','574','578','579')
--and h.pol_pre IN ('506','509','510','516','536','537','540','551','552','553','555','560','567','577','580','592')
----and h.pol_pre in ('533')

UPDATE  #tempPolicyCO
SET SubClass = (
					CASE  #tempPolicyCO.pol_pre WHEN '506' THEN CASE  h.country_code_to 
														WHEN '764' THEN   '06' 
														ELSE '08' 
													END 
												WHEN '516' THEN CASE  h.country_code_to 
														WHEN '764' THEN   '06' 
														ELSE '08' 
													END 
					END
				)
				FROM  his_journey_ta h WITH(NOLOCK)
				WHERE (
				#tempPolicyCO.pol_yr	= h.pol_yr and 
				#tempPolicyCO.pol_br	= h.pol_br and 
				#tempPolicyCO.pol_pre	= h.pol_pre and 
				#tempPolicyCO.pol_no	= h.pol_no and 
				#tempPolicyCO.endos_seq = h.endos_seq 
) 

--============================= SETUP  #tempEndorseCO ================================================================
-- Endose inner join IBS_POL
--		To get total endorse which has start date in range of 5 year 
--		Table Endos has 4 primary columns and 5 additional columns
--		1. app_yr			Good for search
--		2. app_br			Good for search
--		3. app_pre			Good for search
--		4. app_no			Not Equal to endos_no
--		-- for additional
--		5. endos_group		number
--		6. endos_yr			Equal to app_yr but some is NULL
--		7. endos_no			Not Equal to app_no
--		8. pol_yr			Such data some are 36, 11, 12 can be more than app_yr
--		9. pol_no			Policy Number

PRINT 'INSERT INTO #tempEndorseCO '
IF @isMixAvailable = 'N'
BEGIN
	INSERT INTO #tempEndorseCO
	SELECT [pol_yr],[pol_br],[app_pre],[pol_no],[app_yr],[app_br],[app_pre],[app_no],[endos_yr],[endos_no],
		[net_premium],[stamp],[vat],[tax],[total_premium],[start_date],[end_date],[sale_code],[flag_language],
		[flag_group],[approve_datetime],[endos_group],[class_oic],[subclass_oic],tmpEn.subclass_oic AS [SubClass]
	FROM [dbo].[GetEndorsements](@StartDateFrom) AS tmpEn
	WHERE tmpEn.app_pre NOT IN ('579','569','564','564','562','561','539')
END
ELSE BEGIN
	INSERT INTO #tempEndorseCO
	SELECT [pol_yr],[pol_br],[app_pre],[pol_no],[app_yr],[app_br],[app_pre],[app_no],[endos_yr],[endos_no],
		[net_premium],[stamp],[vat],[tax],[total_premium],[start_date],[end_date],[sale_code],[flag_language],
		[flag_group],[approve_datetime],[endos_group],[class_oic],[subclass_oic],tmpEn.subclass_oic AS [SubClass]
	FROM [dbo].[GetEndorsements](@StartDateFrom) AS tmpEn
END
-- move to func
--select e.pol_yr, e.pol_br, h.pol_pre,  e.pol_no , e.app_yr , e.app_br, e.app_pre ,e.app_no , e.endos_yr, e.endos_no, e.net_premium , e.stamp , e.vat ,e.tax ,e.total_premium , h.start_date ,h.end_date ,h.sale_code , 
--e.flag_language , c.flag_group , e.approve_datetime ,e.endos_group, c.class_oic, c.subclass_oic, c.subclass_oic
--from endos e  
--INNER JOIN ibs_pol h WITH(NOLOCK) ON
--	e.pol_yr = h.pol_yr and e.pol_br = h.pol_br and e.app_pre = h.pol_pre and e.pol_no = h.pol_no
--INNER JOIN centerdb.dbo.subclass c WITH(NOLOCK) ON 
--	e.app_pre = c.class_code+ c.subclass_code
--WHERE c.class_oic in ('06','07','11')
--AND e.approve_datetime is not null 
--and ( (e.eff_date is null)  or ( e.eff_date between  @pol_yr_start  and @pol_yr_end))
--and e.pol_br  between @BranchFrom  and @BranchTo
--AND h.pol_pre in ('579','569','564','564','562','561','539','506','509','510','516','536','537','540','551','552','553','555','560','567','577','580','592')


UPDATE  #tempEndorseCO
SET SubClass = (
					CASE  #tempEndorseCO.app_pre  WHEN '506' THEN CASE  h.country_code_to 
														WHEN '764' THEN   '06' 
														ELSE '08' 
													END 
												WHEN '516' THEN CASE  h.country_code_to 
														WHEN '764' THEN   '06' 
														ELSE '08' 
													END 
					END
				)
FROM  his_journey_ta h WITH(NOLOCK)
WHERE (
	#tempEndorseCO.pol_yr	= h.pol_yr and 
	#tempEndorseCO.pol_br	= h.pol_br and 
	#tempEndorseCO.app_pre	= h.pol_pre and 
	#tempEndorseCO.pol_no	= h.pol_no 

)

--============================= SETUP  #TempCoverTA ================================================================

PRINT 'INSERT INTO #TempCoverTA '
INSERT INTO #TempCoverTA
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.endos_seq, t.ins_seq ,
	[itm1_sumins_amt], 	[itm1_net_premium],	[itm2_sumins_amt],	[itm2_net_premium],	[murder_sumins_amt],	[discnt_murder_amt],	
	[person_qty],	[itm1_play_sumins_amt],	[itm1_play_net_premium],	[itm2_play_sumins_amt],	[itm2_play_net_premium],	
	[itm1_drive_sumins_amt],	[itm1_drive_net_premium],	[itm2_drive_sumins_amt],	[itm2_drive_net_premium],	[itm1_travel_sumins_amt],	
	[itm1_travel_net_premium],	[itm2_travel_sumins_amt],	[itm2_travel_net_premium],	[discnt_guide_amt] [float]
FROM   his_cover_ta  t  INNER JOIN #tempPolicyCO h 
ON	t.pol_yr = h.pol_yr 
	and t.pol_br = h.pol_br 
	and t.pol_pre = h.pol_pre 
	and t.pol_no = h.pol_no 
	and t.endos_seq = h.endos_seq

--SET STATISTICS IO, TIME ON;

--delete #TempResult
--================================== Modify His TA =================================---
PRINT 'Modify His TA - start insert tmp data'

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA003',
oic_code		= 'T00043',
sumins_amt		= Itm1_sumins_amt,
net_premium		= Itm1_net_premium
FROM   #TempCoverTA t
WHERE ( t.Itm1_sumins_amt <> 0		and  t.endos_seq = 0  )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA002',
oic_code		= 'T00034',
sumins_amt		= Itm2_sumins_amt,
net_premium		= Itm2_net_premium
FROM   #TempCoverTA t
WHERE ( t.Itm2_sumins_amt <> 0		and  t.endos_seq = 0  )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA003',
oic_code		= 'T00049',
sumins_amt		= Itm1_Play_sumins_amt,
net_premium		= Itm1_Play_net_premium
FROM   #TempCoverTA t
WHERE ( Itm1_Play_sumins_amt <> 0    and  t.endos_seq = 0  ) 

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA002',
oic_code		= 'T00026',
sumins_amt		= Itm2_Play_sumins_amt,
net_premium		= Itm2_Play_net_premium
FROM   #TempCoverTA t
WHERE ( Itm2_Play_sumins_amt <> 0    and  t.endos_seq = 0  ) 

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA003',
oic_code		= 'T00047',
sumins_amt		= Itm1_Drive_sumins_amt,
net_premium		= Itm1_Drive_net_premium
FROM   #TempCoverTA t
WHERE ( Itm1_Drive_sumins_amt <> 0    and  t.endos_seq = 0 )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA002',
oic_code		= 'T00023',
sumins_amt		= Itm2_Drive_sumins_amt,
net_premium		= Itm2_Drive_net_premium
FROM   #TempCoverTA t
WHERE ( Itm2_Drive_sumins_amt <> 0    and  t.endos_seq = 0 )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA003',
oic_code		= 'T00050',
sumins_amt		= Itm1_Travel_sumins_amt,
net_premium		= Itm1_Travel_net_premium
FROM   #TempCoverTA t
WHERE ( Itm1_Travel_sumins_amt <> 0    and  t.endos_seq = 0  )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA002',
oic_code		= 'T00027',
sumins_amt		= Itm2_Travel_sumins_amt,
net_premium		= Itm2_Travel_net_premium
FROM   #TempCoverTA t
WHERE ( Itm2_Travel_sumins_amt <> 0    and  t.endos_seq = 0  )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'TA003',
oic_code		= 'T00046',
sumins_amt		= murder_sumins_amt,
net_premium		= discnt_murder_amt
FROM   #TempCoverTA t
WHERE ( murder_sumins_amt <> 0    and  t.endos_seq = 0   )


--================================== Modify His PA =================================---

SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.endos_seq, t.ins_seq ,
	[itm1_pa1_sumins_amt] ,
	[itm1_pa1_deduct_amt] ,
	[itm1_pa1_net_premium] ,
	[itm1_pa2_sumins_amt] ,
	[itm1_pa2_deduct_amt] ,
	[itm1_pa2_net_premium] ,
	[itm2_mpw] ,
	[itm2_sumins_amt] ,
	[itm2_deduct_amt] ,
	[itm2_net_premium] ,
	[itm3_mpw] [smallint] ,
	[itm3_sumins_amt] ,
	[itm3_deduct_amt] ,
	[itm3_net_premium] ,
	[itm4_sumins_amt] ,
	[itm4_deduct_amt] ,
	[itm4_net_premium] ,
	[itm1_war_sumins_amt] ,
	[itm1_war_net_premium] ,
	[itm1_strike_sumins_amt] ,
	[itm1_strike_net_premium] ,
	[itm1_play_sumins_amt] ,
	[itm1_play_net_premium] ,
	[itm1_drive_sumins_amt] ,
	[itm1_drive_net_premium] ,
	[itm1_travel_sumins_amt] ,
	[itm1_travel_net_premium] ,
	[itm2_war_sumins_amt] ,
	[itm2_war_net_premium] ,
	[itm2_strike_sumins_amt] ,
	[itm2_strike_net_premium] ,
	[itm2_play_sumins_amt] ,
	[itm2_play_net_premium] ,
	[itm2_drive_sumins_amt] ,
	[itm2_drive_net_premium] ,
	[itm2_travel_sumins_amt] ,
	[itm2_travel_net_premium] ,
	[itm3_war_sumins_amt] ,
	[itm3_war_net_premium] ,
	[itm3_strike_sumins_amt] ,
	[itm3_strike_net_premium] ,
	[itm3_play_sumins_amt] ,
	[itm3_play_net_premium] ,
	[itm3_drive_sumins_amt] ,
	[itm3_drive_net_premium] ,
	[itm3_travel_sumins_amt] ,
	[itm3_travel_net_premium] ,
	[itm4_war_sumins_amt] ,
	[itm4_war_net_premium] ,
	[itm4_strike_sumins_amt] ,
	[itm4_strike_net_premium] ,
	[itm4_play_sumins_amt] ,
	[itm4_play_net_premium] ,
	[itm4_drive_sumins_amt] ,
	[itm4_drive_net_premium] ,
	[itm4_travel_sumins_amt] ,
	[itm4_travel_net_premium] ,
	[murder_sumins_amt] ,
	[discnt_murder_amt] ,
	[income_amt_per_day] ,
	[die_amt_per_month] ,
	[income_amt_net_premium] ,
	[die_amt_net_premium] ,
	[cremate_sumins_amt] ,
	[cremate_net_premium] ,
	[itm1_pa1_add_sumins_amt] ,
	[itm1_pa1_add_deduct_amt] ,
	[itm1_pa1_add_net_premium] ,
	[itm1_pa2_add_sumins_amt] ,
	[itm1_pa2_add_deduct_amt] ,
	[itm1_pa2_add_net_premium] ,
	[income_time]
INTO #TempCoverPA
FROM #TMP_HIS_COVER_PA  t INNER JOIN #tempPolicyCO h 
ON t.pol_yr = h.pol_yr 
	and t.pol_br = h.pol_br 
	and t.pol_pre = h.pol_pre 
	and t.pol_no = h.pol_no  
	and t.endos_seq = h.endos_seq

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA001',
oic_code		= 'P00001',
sumins_amt		= itm1_pa1_sumins_amt,
net_premium		= itm1_pa1_net_premium
FROM   #TempCoverPA t
WHERE ( itm1_pa1_sumins_amt <> 0  )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA002',
oic_code		= 'P00001',
sumins_amt		= itm1_pa2_sumins_amt,
net_premium		= itm1_pa2_net_premium
FROM   #TempCoverPA t
WHERE ( itm1_pa2_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00026',
sumins_amt		= itm2_sumins_amt,
net_premium		= itm2_net_premium
FROM   #TempCoverPA t
WHERE ( itm2_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00027',
sumins_amt		= itm3_sumins_amt,
net_premium		= itm3_net_premium
FROM   #TempCoverPA t
WHERE ( itm3_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00038',
sumins_amt		= itm4_sumins_amt,
net_premium		= itm4_net_premium
FROM   #TempCoverPA t
WHERE ( itm4_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= (select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
							case  when isnull(itm1_pa1_sumins_amt ,0)  = 0  then  'PA999' else  'PA001'  end else 'PA002' end 
						from  #TMP_HIS_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq   and t.endos_seq = endos_seq 
					 ),
oic_code		= 'P00016',
sumins_amt		= itm1_war_sumins_amt,
net_premium		= itm1_war_net_premium
FROM   #TempCoverPA t
WHERE ( itm1_war_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= (select 	case  when isnull(itm1_pa2_sumins_amt ,0)	= 0  then  
							case  when isnull(itm1_pa1_sumins_amt ,0)	= 0  then  'PA999' else  'PA001'  end else 'PA002' end 
						from  #TMP_HIS_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  and t.endos_seq = endos_seq 
					),
oic_code		= 'P00006',
sumins_amt		= itm1_strike_net_premium,
net_premium		= itm1_strike_net_premium
FROM   #TempCoverPA t
WHERE ( itm1_strike_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= (select 	case  when isnull(itm1_pa2_sumins_amt ,0)	= 0  then  
							case  when isnull(itm1_pa1_sumins_amt ,0)	= 0  then  'PA999' else  'PA001'  end else 'PA002' end 
						from  #TMP_HIS_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  and t.endos_seq = endos_seq 
					 ) ,
oic_code		= 'P00007',
sumins_amt		= itm1_play_sumins_amt,
net_premium		= itm1_play_net_premium
FROM   #TempCoverPA t
WHERE ( itm1_play_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= (select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
							case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
						from  #TMP_HIS_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  and t.endos_seq = endos_seq 
					 ) , 
oic_code		= 'P00002',
sumins_amt		= itm1_drive_sumins_amt,
net_premium		= itm1_drive_net_premium
FROM   #TempCoverPA t
WHERE ( itm1_drive_sumins_amt <> 0   )
 
INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= (select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
							case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
						from  #TMP_HIS_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  and t.endos_seq = endos_seq 
					 ) , 
oic_code		= 'P00008',
sumins_amt		= itm1_travel_sumins_amt,
net_premium		= itm1_travel_net_premium
FROM   #TempCoverPA t
WHERE ( itm1_travel_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00036',
sumins_amt		= itm2_war_sumins_amt,
net_premium		= itm2_war_net_premium
FROM   #TempCoverPA t
WHERE ( itm2_war_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00028',
sumins_amt		= itm2_strike_sumins_amt,
net_premium		= itm2_strike_net_premium
FROM   #TempCoverPA t
WHERE ( itm2_strike_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00029',
sumins_amt		= itm2_play_sumins_amt,
net_premium		= itm2_play_net_premium
FROM   #TempCoverPA t
WHERE ( itm2_play_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00019',
sumins_amt		= itm2_drive_sumins_amt,
net_premium		= itm2_drive_net_premium
FROM   #TempCoverPA t
WHERE ( itm2_drive_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00030',
sumins_amt		= itm2_travel_sumins_amt,
net_premium		= itm2_travel_net_premium
FROM   #TempCoverPA t
WHERE ( itm2_travel_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00036',
sumins_amt		= itm3_war_sumins_amt,
net_premium		= itm3_war_net_premium
FROM   #TempCoverPA t
WHERE ( itm3_war_sumins_amt <> 0   )


INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00028',
sumins_amt		= itm3_strike_sumins_amt,
net_premium		= itm3_strike_net_premium
FROM   #TempCoverPA t
WHERE ( itm3_strike_sumins_amt <> 0   )


INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00029',
sumins_amt		= itm3_play_sumins_amt,
net_premium		= itm3_play_net_premium
FROM   #TempCoverPA t
WHERE ( itm3_play_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00019',
sumins_amt		= itm3_drive_sumins_amt,
net_premium		= itm3_drive_net_premium
FROM   #TempCoverPA t
WHERE ( itm3_drive_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'PA00030',
sumins_amt		= itm3_travel_sumins_amt,
net_premium		= itm3_travel_net_premium
FROM   #TempCoverPA t
WHERE ( itm3_travel_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00059',
sumins_amt		= itm4_war_sumins_amt,
net_premium		= itm4_war_net_premium
FROM   #TempCoverPA t
WHERE ( itm4_war_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00044',
sumins_amt		= itm4_strike_sumins_amt,
net_premium		= itm4_strike_net_premium
FROM   #TempCoverPA t
WHERE ( itm4_strike_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00045',
sumins_amt		= itm4_play_sumins_amt,
net_premium		= itm4_play_net_premium
FROM   #TempCoverPA t
WHERE ( itm4_play_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00039',
sumins_amt		= itm4_drive_sumins_amt,
net_premium		= itm4_drive_net_premium
FROM   #TempCoverPA t
WHERE ( itm4_drive_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999',
oic_code		= 'P00046',
sumins_amt		= itm4_travel_sumins_amt,
net_premium		= itm4_travel_net_premium
FROM   #TempCoverPA t
WHERE ( itm4_travel_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= (select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
							case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
						from  #TMP_HIS_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  and t.endos_seq = endos_seq 
					 ) , 
oic_code		= 'P00005',
sumins_amt		= murder_sumins_amt,
net_premium		= case when  isnull(discnt_murder_amt,0) > 0 then  (-1)* discnt_murder_amt  else  0 end
FROM   #TempCoverPA t
WHERE ( murder_sumins_amt <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999' , 
oic_code		= 'P00053',
sumins_amt		= income_amt_per_day,
net_premium		= income_amt_net_premium
FROM   #TempCoverPA t
WHERE ( income_amt_per_day <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= 'PA999' , 
oic_code		= 'P99999',
sumins_amt		= die_amt_per_month,
net_premium		= die_amt_net_premium
FROM   #TempCoverPA t
WHERE ( die_amt_per_month <> 0   )

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	= (select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
							case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
						from  #TMP_HIS_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  and t.endos_seq = endos_seq 
					 ) ,
oic_code		= 'P00011',
sumins_amt		= cremate_sumins_amt,
net_premium		= cremate_net_premium
FROM   #TempCoverPA t
WHERE ( cremate_sumins_amt <> 0   )


--================================== Modify His_UD =================================---
--================================== INNER JOIN his_cover_ud =======================---

INSERT INTO #TempResult
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , i.ins_seq ,
oic_main_code	= 'PA001' ,
oic_code		= 'P00001',
sumins_amt		= itm1_die_sumins_amt,
net_premium		= 0
FROM    #tempPolicyCO h 
INNER JOIN his_insured i 
ON h.pol_yr = i.pol_yr 
	and h.pol_br = i.pol_br 
	and h.pol_pre = i.pol_pre 
	and h.pol_no = i.pol_no  
	and h.endos_seq =  i.endos_seq
INNER JOIN  his_cover_ud t		-- JOIN HERE his_cover_ud
ON t.pol_yr = h.pol_yr 
	and t.pol_br = h.pol_br 
	and t.pol_pre = h.pol_pre 
	and t.pol_no = h.pol_no  
	and t.endos_seq =  h.endos_seq
--WHERE ( t.itm1_die_sumins_amt <> 0 )

--================================== Modify His_PAX =================================---
--================================== INNER JOIN his_cover_pax =======================---

--DROP table #TempCoverPAX
SELECT t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.endos_seq, i.ins_seq,
	t.[itm1_pa1_per] ,
	t.[itm1_pa1_sumins_amt] ,
	t.[itm1_pa1_net_premium] ,
	t.[itm1_drive_sumins_amt] ,
	t.[cremate_sumins_amt] ,
	t.[discnt_murder_amt] ,
	t.[murder_sumins_amt] ,
	t.[terrorize_sumins_amt] ,
	t.[increase_sumins_amt],
	t.[flag_pa1_pa2]
INTO #TempCoverPAX
FROM #tempPolicyCO h 
inner join his_insured i on 
h.pol_yr = i.pol_yr and h.pol_br = i.pol_br and h.pol_pre = i.pol_pre and h.pol_no = i.pol_no  and h.endos_seq =  i.endos_seq
inner join  his_cover_pax  t   on -- JOIN HERE his_cover_pax
t.pol_yr = h.pol_yr and t.pol_br = h.pol_br and t.pol_pre = h.pol_pre and t.pol_no = h.pol_no  and t.endos_seq =  h.endos_seq

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		=	'P00001', 
sumins_amt		=	itm1_pa1_sumins_amt, 
net_premium		=	itm1_pa1_net_premium 
from    #TempCoverPAX t
where t.itm1_pa1_sumins_amt <> 0

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		=	'P00019', 
sumins_amt		=	itm1_drive_sumins_amt, 
net_premium		=	0 
from    #TempCoverPAX t
where t.itm1_drive_sumins_amt <> 0

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		=	'P00005', 
sumins_amt		=	murder_sumins_amt, 
net_premium		=	discnt_murder_amt
from    #TempCoverPAX t
where t.murder_sumins_amt <> 0

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		=	'P00011', 
sumins_amt		=	cremate_sumins_amt, 
net_premium		=	0
from    #TempCoverPAX t
where t.cremate_sumins_amt <> 0

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		=	'P99999', 
sumins_amt		=	increase_sumins_amt, 
net_premium		=	0
from    #TempCoverPAX t
where t.increase_sumins_amt <> 0

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		=	'P00016', 
sumins_amt		=	terrorize_sumins_amt, 
net_premium		=	0
from    #TempCoverPAX t
where t.terrorize_sumins_amt <> 0
 
 --==========================================================================================---
 --================================== Modify Endorsement PA =================================---
 --==========================================================================================---
 --==========================================================================================---

SELECT t.* ,
	[app_yr],
	[app_br],
	[app_pre],
	[app_no],

	[endos_yr],
	[endos_no],

	[stamp],
	[vat],
	[tax],
	[total_premium],
	[sale_code] ,
	[flag_language],
	[flag_group] ,
	[approve_datetime] ,
	[endos_group]
INTO #TempEndorsementPA
FROM #TMP_POL_COVER_PA  t  inner join #tempEndorseCO h on
t.pol_yr = h.pol_yr and t.pol_br = h.pol_br and t.pol_pre = h.app_pre and t.pol_no = h.pol_no 

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA001',
oic_code		=	'P00001', 
sumins_amt		=	itm1_pa1_sumins_amt, 
net_premium		=	itm1_pa1_net_premium
from    #TempEndorsementPA t
where ( t.itm1_pa1_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA002',
oic_code		=	'P00001', 
sumins_amt		=	itm1_pa2_sumins_amt, 
net_premium		=	itm1_pa2_net_premium
from    #TempEndorsementPA t
where ( t.itm1_pa2_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999',
oic_code		=	'P00026', 
sumins_amt		=	itm2_sumins_amt, 
net_premium		=	itm2_net_premium
from    #TempEndorsementPA t
where ( t.itm2_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999',
oic_code		=	'P00027', 
sumins_amt		=	itm3_sumins_amt, 
net_premium		=	itm3_net_premium
from    #TempEndorsementPA t
where ( t.itm3_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999',
oic_code		=	'P00038', 
sumins_amt		=	itm4_sumins_amt, 
net_premium		=	itm4_net_premium
from    #TempEndorsementPA t
where ( t.itm4_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	(select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
								case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
							from  #TMP_POL_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  
						 ) , 
oic_code		=	'P00016', 
sumins_amt		=	itm1_war_sumins_amt, 
net_premium		=	itm1_war_net_premium
from    #TempEndorsementPA t
where ( t.itm1_war_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	(select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
								case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
							from  #TMP_POL_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  
						 ) , 
oic_code		=	'P00006', 
sumins_amt		=	itm1_strike_sumins_amt, 
net_premium		=	itm1_strike_net_premium
from    #TempEndorsementPA t
where ( t.itm1_strike_sumins_amt <> 0 )


INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	(select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
								case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
							from  #TMP_POL_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  
						 ) ,
oic_code		=	'P00007', 
sumins_amt		=	itm1_play_sumins_amt, 
net_premium		=	itm1_play_net_premium
from    #TempEndorsementPA t
where ( t.itm1_play_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	(select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
								case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
							from  #TMP_POL_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  
						 ) , 
oic_code		=	'P00002', 
sumins_amt		=	itm1_drive_sumins_amt, 
net_premium		=	itm1_drive_net_premium
from    #TempEndorsementPA t
where ( t.itm1_drive_sumins_amt <> 0 )


INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	(select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
								case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
							from  #TMP_POL_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  
						 ) , 
oic_code		=	'P00008', 
sumins_amt		=	itm1_travel_sumins_amt, 
net_premium		=	itm1_travel_net_premium
from    #TempEndorsementPA t
where ( t.itm1_travel_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00036', 
sumins_amt		=	itm2_war_sumins_amt, 
net_premium		=	itm2_war_net_premium
from    #TempEndorsementPA t
where ( t.itm2_war_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00028', 
sumins_amt		=	itm2_strike_sumins_amt, 
net_premium		=	itm2_strike_net_premium
from    #TempEndorsementPA t
where ( t.itm2_strike_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00029', 
sumins_amt		=	itm2_play_sumins_amt, 
net_premium		=	itm2_play_net_premium
from    #TempEndorsementPA t
where ( t.itm2_play_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00019', 
sumins_amt		=	itm2_drive_sumins_amt, 
net_premium		=	itm2_drive_net_premium
from    #TempEndorsementPA t
where ( t.itm2_drive_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00030', 
sumins_amt		=	itm2_travel_sumins_amt, 
net_premium		=	itm2_travel_net_premium
from    #TempEndorsementPA t
where ( t.itm2_travel_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00036', 
sumins_amt		=	itm3_war_sumins_amt, 
net_premium		=	itm3_war_net_premium
from    #TempEndorsementPA t
where ( t.itm3_war_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00028', 
sumins_amt		=	itm3_strike_sumins_amt, 
net_premium		=	itm3_strike_net_premium
from    #TempEndorsementPA t
where ( t.itm3_strike_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00029', 
sumins_amt		=	itm3_play_sumins_amt, 
net_premium		=	itm3_play_net_premium
from    #TempEndorsementPA t
where ( t.itm3_play_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00019', 
sumins_amt		=	itm3_drive_sumins_amt, 
net_premium		=	itm3_drive_net_premium
from    #TempEndorsementPA t
where ( t.itm3_drive_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00030', 
sumins_amt		=	itm3_travel_sumins_amt, 
net_premium		=	itm3_travel_net_premium
from    #TempEndorsementPA t
where ( t.itm3_travel_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00059', 
sumins_amt		=	itm4_war_sumins_amt, 
net_premium		=	itm4_war_net_premium
from    #TempEndorsementPA t
where ( t.itm4_war_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00044', 
sumins_amt		=	itm4_strike_sumins_amt, 
net_premium		=	itm4_strike_net_premium
from    #TempEndorsementPA t
where ( t.itm4_strike_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00045', 
sumins_amt		=	itm4_play_sumins_amt, 
net_premium		=	itm4_play_net_premium
from    #TempEndorsementPA t
where ( t.itm4_play_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00039', 
sumins_amt		=	itm4_drive_sumins_amt, 
net_premium		=	itm4_drive_net_premium
from    #TempEndorsementPA t
where ( t.itm4_drive_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00046', 
sumins_amt		=	itm4_travel_sumins_amt, 
net_premium		=	itm4_travel_net_premium
from    #TempEndorsementPA t
where ( t.itm4_travel_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	(select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
								case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
							from  #TMP_POL_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  
						 ) , 
oic_code		=	'P00005', 
sumins_amt		=	murder_sumins_amt,
net_premium		=	case when  isnull(discnt_murder_amt,0) > 0 then  (-1)* discnt_murder_amt  else  0 end
from    #TempEndorsementPA t
where ( t.murder_sumins_amt <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P00053', 
sumins_amt		=	income_amt_per_day,
net_premium		=	income_amt_net_premium
from    #TempEndorsementPA t
where ( t.income_amt_per_day <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	'PA999', 
oic_code		=	'P99999', 
sumins_amt		=	die_amt_per_month,
net_premium		=	die_amt_net_premium
from    #TempEndorsementPA t
where ( t.die_amt_per_month <> 0 )

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , t.ins_seq ,
oic_main_code	=	(select 	case  when isnull(itm1_pa2_sumins_amt ,0)  = 0  then  
								case  when isnull(itm1_pa1_sumins_amt ,0) = 0 then  'PA999' else  'PA001'  end else 'PA002' end 
							from  #TMP_POL_COVER_PA where  t.pol_yr = pol_yr and t.pol_br = pol_br and t.pol_pre = pol_pre and t.pol_no = pol_no and t.ins_seq = ins_seq  
						 ), 
oic_code		=	'P00011', 
sumins_amt		=	cremate_sumins_amt,
net_premium		=	cremate_net_premium
from    #TempEndorsementPA t
where ( t.cremate_sumins_amt <> 0 )

/******** endorse UD *********/

INSERT INTO #TempResult
select t.pol_yr ,t.pol_br ,t.pol_pre ,t.pol_no , i.ins_seq ,
oic_main_code	=	'PA001', 
oic_code		=	'P00001', 
sumins_amt		=	itm1_die_sumins_amt,
net_premium		=	0
from    #tempEndorseCO h 
inner join endos_insured i on -- comment pol_br == app_br
h.app_yr = i.app_yr and h.pol_br = i.app_br and h.app_pre = i.app_pre and h.app_no = i.app_no  
inner join  pol_cover_ud  t   on
t.pol_yr = h.pol_yr and t.pol_br = h.pol_br and t.pol_pre = h.app_pre and t.pol_no = h.pol_no  
--where t.itm1_die_sumins_amt <> 0   

--inner join pol_insured i on 
--h.pol_yr = i.pol_yr and h.pol_br = i.pol_br and h.app_pre = i.pol_pre and h.pol_no = i.pol_no  
-- inner join  pol_cover_ud  t   on
--t.pol_yr = h.pol_yr and t.pol_br = h.pol_br and t.pol_pre = h.app_pre and t.pol_no = h.pol_no  
--where t.itm1_die_sumins_amt <> 0   

/******** endorse_PAX*********/

SELECT t.* , i.ins_seq
INTO #TempEndorsementPAX
FROM #tempEndorseCO h 
inner join endos_insured i on
h.app_yr = i.app_yr and h.pol_br = i.app_br and h.app_pre = i.app_pre and h.app_no = i.app_no  
inner join  pol_cover_pax  t   on
t.pol_yr = h.pol_yr and t.pol_br = h.pol_br and t.pol_pre = h.app_pre and t.pol_no = h.pol_no  

--inner join pol_insured i on 
--h.pol_yr = i.pol_yr and h.pol_br = i.pol_br and h.app_pre = i.pol_pre and h.pol_no = i.pol_no  


INSERT INTO #TempResult
SELECT t.pol_yr, t.pol_br, t.pol_pre, t.pol_no, t.ins_seq,
oic_main_code	= case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		= 'P00001',
sumins_amt		= itm1_pa1_sumins_amt, 
net_premium		= itm1_pa1_net_premium
FROM	#TempEndorsementPAX t
WHERE ( t.itm1_pa1_sumins_amt <> 0 )

INSERT INTO #TempResult
SELECT t.pol_yr, t.pol_br, t.pol_pre, t.pol_no, t.ins_seq,
oic_main_code	= case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		= 'P00019',
sumins_amt		= itm1_drive_sumins_amt, 
net_premium		= 0
FROM	#TempEndorsementPAX t
WHERE ( t.itm1_drive_sumins_amt <> 0 )

INSERT INTO #TempResult
SELECT t.pol_yr, t.pol_br, t.pol_pre, t.pol_no, t.ins_seq,
oic_main_code	= case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		= 'P00005',
sumins_amt		= murder_sumins_amt, 
net_premium		= discnt_murder_amt
FROM	#TempEndorsementPAX t
WHERE ( t.murder_sumins_amt <> 0 )

INSERT INTO #TempResult
SELECT t.pol_yr, t.pol_br, t.pol_pre, t.pol_no, t.ins_seq,
oic_main_code	= case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		= 'P00011',
sumins_amt		= cremate_sumins_amt, 
net_premium		= 0
FROM	#TempEndorsementPAX t
WHERE ( t.cremate_sumins_amt <> 0 )
 
INSERT INTO #TempResult
SELECT t.pol_yr, t.pol_br, t.pol_pre, t.pol_no, t.ins_seq,
oic_main_code	= case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		= 'P99999',
sumins_amt		= increase_sumins_amt, 
net_premium		= 0
FROM	#TempEndorsementPAX t
WHERE ( t.increase_sumins_amt <> 0 )

INSERT INTO #TempResult
SELECT t.pol_yr, t.pol_br, t.pol_pre, t.pol_no, t.ins_seq,
oic_main_code	= case when isnull(flag_pa1_pa2,'Y') ='Y' then   'PA001' else 'PA002'  end,
oic_code		= 'P00016',
sumins_amt		= terrorize_sumins_amt, 
net_premium		= 0
FROM	#TempEndorsementPAX t
WHERE ( t.terrorize_sumins_amt <> 0 )




/****************** PREPARE SELECT DATA **********************/ --$$$

CREATE TABLE #TMP_FINAL_RESULT(
	CompanyCode VARCHAR(20),
	MainClass VARCHAR(10),
	SubClass VARCHAR(10),
	PolicyNumber VARCHAR(50),
	EndorsementNumber VARCHAR(50),
	InsuredSeq INT,
	CoverageCode VARCHAR(10),
	CoverageCode2 VARCHAR(10),
	SumInsuredAmt VARCHAR(20),
	SumInsuredPerDay VARCHAR(20),
	SumInsuredPerTimes VARCHAR(20),
	PremiumPerCover VARCHAR(20),
	DeductibleAmt VARCHAR(20),
	DeductibleText VARCHAR(20),
	CoPayment  VARCHAR(20),
	NumOfDays VARCHAR(20),
	TransactionStatus VARCHAR(20),
	ReferenceNumber VARCHAR(20)
)

--==================================== PREPARE ENDORSE =============================

--select top 1909 * from #TMP_ENDORSE_BEFORE
--where pol_no = '391963'

--select top 199 * from #tempEndorseCO
--where pol_yr = 14

SELECT h.*, datas.ins_seq
INTO #TMP_ENDORSE_BEFORE
FROM
(
	SELECT e.* FROM
	(
		SELECT e.* from 
		(
			SELECT e.*, EndorseSeq = (
					select cast(count(endos_no) as varchar(5)) 
					from #tempEndorseCO 
					where 
					pol_yr = e2.pol_yr and 
					pol_br = e2.pol_br and 
					app_pre = e2.app_pre and 
					pol_no = e2.pol_no and 
					endos_yr + endos_no <= e2.endos_yr + e2.endos_no and approve_datetime is not null
					)
			FROM 
			#tempEndorseCO e INNER JOIN #tempEndorseCO e2
			ON 
			e.app_yr = e2.app_yr and 
			e.app_br = e2.app_br and 
			e.app_pre = e2.app_pre and 
			e.app_no = e2.app_no
		) AS  e
		WHERE e.approve_datetime is not null 
	) AS e

	LEFT JOIN his_insured (nolock)
	ON his_insured.pol_yr = e.pol_yr
	and his_insured.pol_br = e.pol_br
	and his_insured.pol_pre = e.pol_pre
	and his_insured.pol_no = e.pol_no
	and his_insured.endos_seq = e.EndorseSeq
	--where e.pol_no = '391963'
) AS h

INNER JOIN 
--select * from 
(
	 SELECT h.* FROM
	 (
		select Customer_WhoIn_EndosInsured.pol_yr, Customer_WhoIn_EndosInsured.pol_br, Customer_WhoIn_EndosInsured.pol_pre, 
		Customer_WhoIn_EndosInsured.pol_no, Customer_WhoIn_EndosInsured.flag_group, Customer_WhoIn_EndosInsured.endos_group,
		endosInsureResult.app_yr, endosInsureResult.app_no, endosInsureResult.app_br, endosInsureResult.app_pre, endosInsureResult.ins_seq
		from  #tempEndorseCO Customer_WhoIn_EndosInsured
		LEFT JOIN 
		( 
			select h.app_yr, h.app_br, h.app_pre, h.app_no, endos_ins.ins_seq
			from #tempEndorseCO h
			inner join endos_insured endos_ins  on -- pol_insured
			h.app_yr = endos_ins.app_yr and
			h.app_br = endos_ins.app_br and
			h.app_pre = endos_ins.app_pre and
			h.app_no = endos_ins.app_no 
		) as endosInsureResult
		on  Customer_WhoIn_EndosInsured.app_yr	= endosInsureResult.app_yr and
			Customer_WhoIn_EndosInsured.app_br	= endosInsureResult.app_br and
			Customer_WhoIn_EndosInsured.app_pre = endosInsureResult.app_pre and
			Customer_WhoIn_EndosInsured.app_no	= endosInsureResult.app_no 
		where endosInsureResult.app_yr IS NOT NULL
		
		--and
		--(
		--	( Customer_WhoIn_EndosInsured.flag_group = 'G' and  endosInsureResult.ins_seq in (select ins_seq from endos_insured where endos_insured.app_yr = Customer_WhoIn_EndosInsured.app_yr and endos_insured.app_br = Customer_WhoIn_EndosInsured.app_br and endos_insured.app_pre = Customer_WhoIn_EndosInsured.app_pre and endos_insured.app_no = Customer_WhoIn_EndosInsured.app_no))
		--	or
		--	(isnull(Customer_WhoIn_EndosInsured.flag_group,'I') ='I' and endosInsureResult.ins_seq in (select ins_seq from pol_insured where pol_insured.pol_yr = Customer_WhoIn_EndosInsured.pol_yr and pol_insured.pol_br = Customer_WhoIn_EndosInsured.app_br and pol_insured.pol_pre = Customer_WhoIn_EndosInsured.app_pre and pol_insured.pol_no = Customer_WhoIn_EndosInsured.pol_no))
		--	or
		--	(endosInsureResult.ins_seq in (select ins_seq from pol_insured where pol_insured.pol_yr = Customer_WhoIn_EndosInsured.pol_yr and pol_insured.pol_br = Customer_WhoIn_EndosInsured.app_br and pol_insured.pol_pre = Customer_WhoIn_EndosInsured.app_pre and pol_insured.pol_no = Customer_WhoIn_EndosInsured.pol_no and Customer_WhoIn_EndosInsured.endos_group in ('3','4') ))
		--)
		
	 ) AS h

	UNION

	SELECT h.*, ins.ins_seq FROM
	(
		select Customer_WhoNotIn_EndosInsured.pol_yr, Customer_WhoNotIn_EndosInsured.pol_br, Customer_WhoNotIn_EndosInsured.pol_pre, 
		Customer_WhoNotIn_EndosInsured.pol_no, Customer_WhoNotIn_EndosInsured.flag_group, Customer_WhoNotIn_EndosInsured.endos_group,
		Customer_WhoNotIn_EndosInsured.app_yr, Customer_WhoNotIn_EndosInsured.app_no, Customer_WhoNotIn_EndosInsured.app_br, Customer_WhoNotIn_EndosInsured.app_pre
		from  #tempEndorseCO Customer_WhoNotIn_EndosInsured
		LEFT JOIN 
		( 
			select h.app_yr, h.app_br, h.app_pre, h.app_no
			from #tempEndorseCO h
			inner join endos_insured endos_ins  on
			h.app_yr = endos_ins.app_yr and
			h.app_br = endos_ins.app_br and
			h.app_pre = endos_ins.app_pre and
			h.app_no = endos_ins.app_no 
		) as endosInsureResult
		on  Customer_WhoNotIn_EndosInsured.app_yr	= endosInsureResult.app_yr and
			Customer_WhoNotIn_EndosInsured.app_br	= endosInsureResult.app_br and
			Customer_WhoNotIn_EndosInsured.app_pre = endosInsureResult.app_pre and
			Customer_WhoNotIn_EndosInsured.app_no	= endosInsureResult.app_no 
		where endosInsureResult.app_yr IS NULL
	) AS h
	inner join pol_insured ins  on
	h.pol_yr = ins.pol_yr and
	h.app_br = ins.pol_br and
	h.app_pre = ins.pol_pre and
	h.pol_no = ins.pol_no
	--where h.pol_no = '391963'
	-- where app_no = '000006'
	--and
	--(
	--	( h.flag_group = 'G' and  ins.ins_seq in (select ins_seq from endos_insured 
	--											where endos_insured.app_yr = h.app_yr 
	--											and endos_insured.app_br = h.app_br 
	--											and endos_insured.app_pre = h.app_pre 
	--											and endos_insured.app_no = h.app_no))
	--	or
	--	( isnull(h.flag_group,'I') = 'I' )
	--	or
	--	( h.endos_group in ('3','4') )
	--)

) AS datas
ON  h.pol_yr	= datas.pol_yr and
	h.app_br	= datas.pol_br and
	h.app_pre	= datas.pol_pre and
	h.pol_no	= datas.pol_no 

/******************SELECT DATA **********************/ --$$$
/******************SELECT DATA **********************/ --$$$
/******************SELECT DATA **********************/ --$$$
/******************SELECT DATA **********************/ --$$$
/******************SELECT DATA **********************/ --$$$
/******************SELECT DATA **********************/ --$$$
/******************SELECT DATA **********************/ --$$$

--select top 100 * from #TMP_ENDORSE_BEFORE 
--where endos_no = '000037'


delete #TMP_FINAL_RESULT

-- (@1)

INSERT INTO #TMP_FINAL_RESULT
SELECT GroupA.CompanyCode , GroupA.MainClass, GroupA.SubClass, GroupA.PolicyNumber, GroupA.EndorsementNumber, GroupA.InsuredSeq, GroupA.CoverageCode, GroupA.CoverageCode2
, SumInsuredAmt		= cast(convert(decimal(20,0), SUM(GroupA.SumInsuredAmt)	    ) as varchar(20)) +'|'
, SumInsuredPerDay	= cast(convert(decimal(20,0), SUM(GroupA.SumInsuredPerDay)  ) as varchar(20)) +'|' 
, SumInsuredPerTimes= cast(convert(decimal(20,0), SUM(GroupA.SumInsuredPerTimes)) as varchar(20)) +'|'
, PremiumPerCover	= cast(convert(decimal(15,2), SUM(GroupA.PremiumPerCover)   ) as varchar(20)) +'|'
, DeductibleAmt		= cast(convert(decimal(20,0), SUM(GroupA.DeductibleAmt)     ) as varchar(20)) +'|'
, DeductibleText	= '|'
, CoPayment			= '0|'
, NumOfDays			= LEFT(cast(convert(decimal(20,0), SUM(GroupA.NumOfDays) ) as varchar(20)), 3)  +'|'
, TransactionStatus	= 'N' +'|'
, ReferenceNumber	= '' 
 FROM 
(
	SELECT * FROM 
	(
		SELECT  '2037|' as CompanyCode , 
		MainClass  = tco.class_oic +'|', 
		SubClass   = tco.SubClass + '|',
		--SubClass =    case  h.pol_pre --				when '506' then --					(select top 1 case  country_code_to --						when '764' then   '06' else '08' end --						from his_journey_ta --						where pol_yr = h.pol_yr and --						pol_br = h.pol_br and --						pol_pre = h.pol_pre and --						pol_no = h.pol_no and --						endos_seq = h.endos_seq)--				when '516' then --					(select top 1 case  country_code_to --						when '764' then   '06' else '08' end --						from his_journey_ta --						where pol_yr = h.pol_yr and --						pol_br = h.pol_br and --						pol_pre = h.pol_pre and --						pol_no = h.pol_no and --						endos_seq = h.endos_seq ) --		else  tco.subclass_oic end  +'|', 
		PolicyNumber			= h.sale_code+ '-'+h.pol_yr+h.pol_br+'/POL/'+h.pol_no+'-'+h.pol_pre +'|' 
		, EndorsementNumber		= '' +'|' 
		, InsuredSeq			= ins.ins_seq
		, CoverageCode			=  '|' + case when cd.add_cover_seq IS NULL then tc.oic_main_code else  
										isnull( ( select top 1 o.oic_main_code
											from [#tmp_tab_cover_insurance_oic] o  where
											cd.pol_pre = o.class_code + o.subclass_code and
											cd.add_cover_seq = o.cover_seq and cd.add_cover_seq <> 0 ), 'PA999' )  end +'|'
		 ,CoverageCode2		= (case when tc.oic_code IS NULL then case when h.pol_pre IN (select distinct pol_pre from #TempCoverTA) then 'T99999' else 'P99999' end else tc.oic_code end) + '|'

		, SumInsuredAmt		= convert(decimal(20,0), cd.itm_sumins_amt)
		, SumInsuredPerDay	= case  when isnull(cd.itm_time,0)  = 0 and isnull(t.cover_limit_unit,'') = '0'  then '0' else convert(decimal(20,0),cd.itm_sumins_amt)  end 
		, SumInsuredPerTimes= case   when isnull(cd.itm_time,0) = 0 and isnull(t.cover_limit_unit,'') = '0'  then '0' else convert(decimal(20,0),cd.itm_sumins_amt)  end 
		, PremiumPerCover	= convert(decimal(15,2),cd.itm_net_premium) 
		, DeductibleAmt		= convert(decimal(20,0),cd.itm_deduct_amt)
		, DeductibleText	= ''
		, CoPayment			= '0'
		, NumOfDays			= case when cd.itm_time IS NULL and t.cover_limit_unit IS NULL  then '0' else  convert(decimal(20,0), cd.itm_sumins_amt)  end

		from #tempPolicyCO tco inner join  ibs_pol h  on -- ibs_pol  (5 )
		tco.pol_yr = h.pol_yr and tco.pol_br = h.pol_br and tco.pol_pre = h.pol_pre and tco.pol_no = h.pol_no and tco.endos_seq = h.endos_seq
		--inner join centerdb.dbo.subclass c on h.pol_pre = c.class_code+ c.subclass_code and isnull(c.flag_mixpolicy,'') <> 'Y'
		left join his_insured ins  on
		h.pol_yr = ins.pol_yr and
		h.pol_br = ins.pol_br and
		h.pol_pre = ins.pol_pre and
		h.pol_no = ins.pol_no and
		h.endos_seq = ins.endos_seq 

		left join  his_cover_insurance_detail  cd on
		ins.pol_yr = cd.pol_yr and
		ins.pol_br = cd.pol_br and
		ins.pol_pre = cd.pol_pre and
		ins.pol_no = cd.pol_no and
		ins.ins_seq = cd.ins_seq and
		ins.endos_seq = cd.endos_seq 

		left join  [#tmp_tab_cover_insurance_oic] tc on
		cd.pol_pre = tc.class_code + tc.subclass_code and
		cd.cover_seq = tc.cover_seq

		left join tab_cover_insurance t on
		cd.pol_pre = t.class_code+t.subclass_code and
		cd.cover_seq = t.cover_seq

		--where c.class_oic in ('06','07','11')
		where h.endos_seq = 0  
		and  
		(
			( cd.add_cover_seq = 0 ) or
			(	cd.add_cover_seq <> 0  and  cd.add_cover_seq in (select  cover_seq from his_cover_insurance_detail 
				where	his_cover_insurance_detail.pol_yr = cd.pol_yr and his_cover_insurance_detail.pol_br = cd.pol_br and 
				his_cover_insurance_detail.pol_pre = cd.pol_pre and his_cover_insurance_detail.pol_no = cd.pol_no and 
				his_cover_insurance_detail.flag_sumins_amt = 'Y'   and his_cover_insurance_detail.ins_seq =  cd.ins_seq and 
				his_cover_insurance_detail.endos_seq = 0 )
			)
		)

	) AS SectionA
	UNION ALL 
	SELECT * FROM 
	(
		SELECT   '2037|' as CompanyCode , 
		MainClass	=  t.class_oic +'|',
		SubClass	=  t.SubClass + '|',
		--SubClass	=  case  h.pol_pre when '506' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from his_journey_ta where pol_yr = h.pol_yr and pol_br = h.pol_br and pol_pre = h.pol_pre and pol_no = h.pol_no and endos_seq = h.endos_seq /*order by journey_seq asc*/) 
		--								when '516' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from his_journey_ta where pol_yr = h.pol_yr and pol_br = h.pol_br and pol_pre = h.pol_pre and pol_no = h.pol_no and endos_seq = h.endos_seq /*order by journey_seq  asc*/) 
		--				else  t.subclass_oic end  +'|',
		PolicyNumber		= h.sale_code + '-' + h.pol_yr + h.pol_br + '/POL/' + h.pol_no + '-' + h.pol_pre + '|'
		, EndorsementNumber	= '' +'|'
		, InsuredSeq		= ins.ins_seq
		, CoverageCode		= '|' + (case when cd.oic_main_code IS NULL then case when h.pol_pre IN (select distinct pol_pre from #TempCoverTA) then 'TA999' else 'PA999' end else cd.oic_main_code end) +'|'
		, CoverageCode2		= (case when cd.oic_code IS NULL then case when h.pol_pre IN (select distinct pol_pre from #TempCoverTA) then 'T99999' else 'P99999' end else cd.oic_code end) + '|'
		, SumInsuredAmt		= isnull(cd.sumins_amt, 0)
		, SumInsuredPerDay	= 0
		, SumInsuredPerTimes= case   when cd.oic_main_code  = 'TA002'  then  isnull(cd.sumins_amt, 0) else '0' end
		, PremiumPerCover	= isnull(cd.net_premium, 0)

		, DeductibleAmt		=  0
		, DeductibleText	=  ''
		, CoPayment			=  0
		, NumOfDays			=  0

		FROM #tempPolicyCO  t inner join ibs_pol h  on
		t.pol_yr = h.pol_yr and t.pol_br = h.pol_br and t.pol_pre = h.pol_pre and t.pol_no = h.pol_no and t.endos_seq =  h.endos_seq 
		--inner join centerdb.dbo.subclass c on h.pol_pre = c.class_code+ c.subclass_code and isnull(c.flag_mixpolicy,'') <> 'Y'

		left join his_insured ins  on
		h.pol_yr = ins.pol_yr and
		h.pol_br = ins.pol_br and
		h.pol_pre = ins.pol_pre and
		h.pol_no = ins.pol_no and
		h.endos_seq = ins.endos_seq 

		left join  #TempResult  cd on --$$
		ins.pol_yr = cd.pol_yr and
		ins.pol_br = cd.pol_br and
		ins.pol_pre = cd.pol_pre and
		ins.pol_no = cd.pol_no and
		ins.ins_seq = cd.ins_seq 
		where 1=1
		--c.class_oic in ('06','07','11')
		and h.endos_seq = 0 
	) AS SectionC

) AS GroupA
GROUP BY GroupA.CompanyCode , GroupA.MainClass, GroupA.SubClass, GroupA.PolicyNumber, GroupA.EndorsementNumber, GroupA.InsuredSeq, GroupA.CoverageCode, GroupA.CoverageCode2

--select * from #TMP_FINAL_RESULT
--where PolicyNumber = '01247-15181/POL/000001-552|'

-- (@2)

INSERT INTO #TMP_FINAL_RESULT
SELECT GroupB.CompanyCode , GroupB.MainClass, GroupB.SubClass, GroupB.PolicyNumber, GroupB.EndorsementNumber, GroupB.InsuredSeq, GroupB.CoverageCode, GroupB.CoverageCode2
, SumInsuredAmt		= cast(convert(decimal(20,0), SUM(GroupB.SumInsuredAmt)	    ) as varchar(20)) +'|'
, SumInsuredPerDay	= cast(convert(decimal(20,0), SUM(GroupB.SumInsuredPerDay)  ) as varchar(20)) +'|' 
, SumInsuredPerTimes= cast(convert(decimal(20,0), SUM(GroupB.SumInsuredPerTimes)) as varchar(20)) +'|'
, PremiumPerCover	= cast(convert(decimal(15,2), SUM(GroupB.PremiumPerCover)   ) as varchar(20)) +'|'
, DeductibleAmt		= cast(convert(decimal(20,0), SUM(GroupB.DeductibleAmt)     ) as varchar(20)) +'|'
, DeductibleText	= '|'
, CoPayment			= '0|'
, NumOfDays			= LEFT(cast(convert(decimal(20,0), SUM(GroupB.NumOfDays) ) as varchar(20)), 3)  +'|'
, TransactionStatus	= 'N|'
, ReferenceNumber	= '' 
 FROM 
(
	SELECT * FROM 
	(
		SELECT   '2037|' as CompanyCode , 
		MainClass	= h.class_oic +'|',  
		SubClass	=  h.SubClass + '|',
		--SubClass	=    case  h.app_pre when '506' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = h.pol_yr and pol_br = h.pol_br and pol_pre = h.app_pre and pol_no = h.pol_no  /*order by journey_seq asc*/ ) 
		--				when '516' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = h.pol_yr and pol_br = h.pol_br and pol_pre = h.app_pre and pol_no = h.pol_no  /*order by journey_seq asc*/ ) 
		--		else  h.subclass_oic end  +'|', 
		PolicyNumber		= h.sale_code + '-' + h.pol_yr+h.pol_br + '/POL/' + h.pol_no + '-' + h.app_pre + '|', 
		EndorsementNumber	=     h.endos_yr + h.app_br +'/END/' + h.endos_no + '-' + h.app_pre + '|'
		, InsuredSeq		= h.ins_seq 
		, CoverageCode		= '|' +  case when cd.add_cover_seq IS NULL then tc.oic_main_code else 
									 ISNULL(( select top 1  o.oic_main_code
										from [#tmp_tab_cover_insurance_oic] o  where
										cd.pol_pre = o.class_code+o.subclass_code and
										cd.add_cover_seq = o.cover_seq and cd.add_cover_seq <> 0), 'PA999' ) 
										 end +'|'
		, CoverageCode2		= (case when tc.oic_code IS NULL then case when h.pol_pre IN (select distinct pol_pre from #TempCoverTA) then 'T99999' else 'P99999' end else tc.oic_code end) + '|'

		, SumInsuredAmt		= convert(decimal(20,0),cd.itm_sumins_amt)
		, SumInsuredPerDay	= case  when cd.itm_time IS NULL and t.cover_limit_unit IS NULL  then '0' else convert(decimal(20,0), cd.itm_sumins_amt) end
		, SumInsuredPerTimes= case  when cd.itm_time IS NULL and t.cover_limit_unit IS NULL  then '0' else convert(decimal(20,0), cd.itm_sumins_amt) end
		, PremiumPerCover	= convert(decimal(15,2),cd.itm_net_premium)
		, DeductibleAmt		= convert(decimal(20,0),cd.itm_deduct_amt) 
		, DeductibleText	= ''
		, CoPayment			= '0'
		, NumOfDays			= case when cd.itm_time IS NULL and t.cover_limit_unit IS NULL  then '0' else convert(decimal(20,0), cd.itm_sumins_amt) end

		FROM #TMP_ENDORSE_BEFORE h

		left join pol_cover_insurance_detail  cd on
		h.pol_yr = cd.pol_yr and
		h.pol_br = cd.pol_br and
		h.app_pre = cd.pol_pre and
		h.pol_no = cd.pol_no and
		h.ins_seq = cd.ins_seq 

		left join  [#tmp_tab_cover_insurance_oic] tc on
		cd.pol_pre = tc.class_code+tc.subclass_code and
		cd.cover_seq = tc.cover_seq
		left join tab_cover_insurance t on
		cd.pol_pre = t.class_code+t.subclass_code and
		cd.cover_seq = t.cover_seq
		--where c.class_oic in ('06','07','11')  and 
		where h.approve_datetime is not null
		and 
		(
			( cd.add_cover_seq = 0 ) or
			(	cd.add_cover_seq <> 0  and  cd.add_cover_seq in (select  cover_seq from pol_cover_insurance_detail 
				where	pol_cover_insurance_detail.pol_yr = cd.pol_yr and pol_cover_insurance_detail.pol_br = cd.pol_br and 
				pol_cover_insurance_detail.pol_pre = cd.pol_pre and pol_cover_insurance_detail.pol_no = cd.pol_no and 
				pol_cover_insurance_detail.flag_sumins_amt = 'Y'   and pol_cover_insurance_detail.ins_seq =  cd.ins_seq) 
			)
		)
	) AS SectionB
	UNION ALL 
	SELECT * FROM 
	(
		SELECT   '2037|' as CompanyCode , 
		MainClass	=  t.class_oic +'|', 
		SubClass	=  t.SubClass + '|'
		--SubClass	=  case  h.pol_pre when '506' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = h.pol_yr and pol_br = h.pol_br and pol_pre = h.pol_pre and pol_no = h.pol_no /*order by journey_seq asc*/) 
		--								when '516' then (select top 1 case  country_code_to when '764' then   '06' else '08' end from pol_journey_ta where pol_yr = h.pol_yr and pol_br = h.pol_br and pol_pre = h.pol_pre and pol_no = h.pol_no  /*order by journey_seq  asc*/) 
		--		else  t.subclass_oic end  +'|'
		, PolicyNumber		= h.sale_code + '-' + h.pol_yr + h.pol_br + '/POL/' + h.pol_no + '-' + h.pol_pre + '|'
		, EndorsementNumber	= t.endos_yr+t.app_br +'/END/' + t.endos_no + '-' + t.app_pre  + '|'
		, InsuredSeq		= t.ins_seq 
		, CoverageCode		= '|' + (case when cd.oic_main_code IS NULL then case when h.pol_pre IN (select distinct pol_pre from #TempCoverTA) then 'TA999' else 'PA999' end else cd.oic_main_code end) +'|'
		, CoverageCode2		= (case when cd.oic_code IS NULL then case when h.pol_pre IN (select distinct pol_pre from #TempCoverTA) then 'T99999' else 'P99999' end else cd.oic_code end) + '|'

		, SumInsuredAmt		= convert(decimal(20,0), isnull(cd.sumins_amt, 0))
		, SumInsuredPerDay	= 0
		, SumInsuredPerTimes= case   when cd.oic_main_code  = 'TA002'  then  convert(decimal(20,0), isnull(cd.sumins_amt, 0) )  else 0 end
		, PremiumPerCover	= convert(decimal(15,2), isnull(cd.net_premium, 0))
		, DeductibleAmt		=  0
		, DeductibleText	=   ''
		, CoPayment			=  0
		, NumOfDays			=  0 

		FROM #TMP_ENDORSE_BEFORE  t  --  endose

		INNER JOIN policy h  on
		t.pol_yr = h.pol_yr and t.pol_br = h.pol_br and t.app_pre = h.pol_pre and t.pol_no = h.pol_no 

		left join  #TempResult  cd on
		t.pol_yr = cd.pol_yr and
		t.pol_br = cd.pol_br and
		t.pol_pre = cd.pol_pre and
		t.pol_no = cd.pol_no and
		t.ins_seq = cd.ins_seq 

	) AS SectionD

) AS GroupB
GROUP BY GroupB.CompanyCode , GroupB.MainClass, GroupB.SubClass, GroupB.PolicyNumber, GroupB.EndorsementNumber, GroupB.InsuredSeq, GroupB.CoverageCode, GroupB.CoverageCode2


--======

--inner join pol_insured ins  on
--h.pol_yr = ins.pol_yr and
--h.app_br = ins.pol_br and
--h.app_pre = ins.pol_pre and
--h.pol_no = ins.pol_no 
--and
--(
--	( h.flag_group = 'G' and  ins.ins_seq in (select ins_seq from endos_insured where endos_insured.app_yr = h.app_yr and endos_insured.app_br = h.app_br and endos_insured.app_pre = h.app_pre and endos_insured.app_no = h.app_no))
--	or
--	(isnull(h.flag_group,'I') ='I' and ins.ins_seq in (select ins_seq from pol_insured where pol_insured.pol_yr = h.pol_yr and pol_insured.pol_br = h.app_br and pol_insured.pol_pre = h.app_pre and pol_insured.pol_no = h.pol_no))
--	or
--	(ins.ins_seq in (select ins_seq from pol_insured where pol_insured.pol_yr = h.pol_yr and pol_insured.pol_br = h.app_br and pol_insured.pol_pre = h.app_pre and pol_insured.pol_no = h.pol_no and h.endos_group in ('3','4') ))
--)

--========

--MainClass	SubClass	PolicyNumber	EndorsementNumber	InsuredSeq	CoverageCode	CoverageCode2
--06|	01|	07150-17109/POL/000138-533|	17109/END/000008-533|	1	|PA999|	P00001|
--06|	01|	07150-17109/POL/000138-533|	17109/END/000008-533|	1	|PA999|	P00038|
--06|	01|	07150-17109/POL/000138-533|	17109/END/000008-533|	1	|PA001|	P00002|
--06|	01|	07150-17109/POL/000138-533|	17109/END/000008-533|	1	|PA001|	P00005|

--select top 100 * from #TMP_FINAL_RESULT

--select * from #TMP_FINAL_RESULT
--where PolicyNumber = '00584-17100/POL/000432-533|'

--================================== VALIDATION ==================================

--select PolicyNumber, CoverageCode , CoverageCode2 from #TMP_FINAL_RESULT
--group by PolicyNumber , CoverageCode , CoverageCode2
--having count(PolicyNumber) > 1

--================================================================================

--UNION

-- (@3)

--IF ( SELECT COUNT(1) FROM #TempResult ) > 0 
--BEGIN

/* bye bye Group C
INSERT INTO #TMP_FINAL_RESULT
SELECT GroupC.CompanyCode , GroupC.MainClass, GroupC.SubClass, GroupC.PolicyNumber, GroupC.EndorsementNumber, GroupC.InsuredSeq, GroupC.CoverageCode, GroupC.CoverageCode2
	, SumInsuredAmt		= cast(convert(decimal(20,0), SUM(SumInsuredAmt))		as varchar(20)) +'|'
	, SumInsuredPerDay	= '0|'
	, SumInsuredPerTimes= cast(convert(decimal(20,0), SUM(SumInsuredPerTimes))	as varchar(20)) +'|'
	, PremiumPerCover	= cast(convert(decimal(15,2), SUM(PremiumPerCover))		as varchar(15)) +'|'
	, DeductibleAmt		=  '0|'
	, DeductibleText	=   '|'
	, CoPayment			=  '0|'
	, NumOfDays			=  '0|'--case   when cd.oic_code  = 'PA00053'   then    cd.sumins_amt  else 0 end  
	, TransactionStatus	=  'N|'
	, ReferenceNumber	= '' 

FROM
(

	

) AS GroupC 
--where PolicyNumber = '00110-17100/POL/000065-506|'
GROUP BY GroupC.CompanyCode , GroupC.MainClass, GroupC.SubClass, GroupC.PolicyNumber, GroupC.EndorsementNumber, GroupC.InsuredSeq, GroupC.CoverageCode, GroupC.CoverageCode2
*/

--UNION

-- (@4)
/*
INSERT INTO #TMP_FINAL_RESULT
SELECT GroupD.CompanyCode , GroupD.MainClass, GroupD.SubClass, GroupD.PolicyNumber, GroupD.EndorsementNumber, GroupD.InsuredSeq, GroupD.CoverageCode, GroupD.CoverageCode2
	, SumInsuredAmt		= cast(convert(decimal(20,0), SUM(SumInsuredAmt) )		as varchar(20)) +'|'
	, SumInsuredPerDay	= '0|'
	, SumInsuredPerTimes= cast(convert(decimal(20,0), SUM(SumInsuredPerTimes))	as varchar(20)) +'|'
	, PremiumPerCover	= cast(convert(decimal(15,2), SUM(PremiumPerCover))		as varchar(20)) +'|'
	, DeductibleAmt		=  '0|'
	, DeductibleText	=   '|'
	, CoPayment			=  '0|'
	, NumOfDays			=  '0|' --  case   when cd.oic_code  = 'PA00053'   then    cd.sumins_amt  else 0 end 
	, TransactionStatus	=  'N|'
	, ReferenceNumber	=  '' 
FROM
(
	

) AS GroupD 
GROUP BY GroupD.CompanyCode , GroupD.MainClass, GroupD.SubClass, GroupD.PolicyNumber, GroupD.EndorsementNumber, GroupD.InsuredSeq, GroupD.CoverageCode, GroupD.CoverageCode2
*/


--END

--========================= For Export =================================== 

--========================= SELECT ALL =================================== 
--select *
--from #TMP_FINAL_RESULT
--order by  EndorsementNumber , PolicyNumber , InsuredSeq, CoverageCode

--========================= SELECT 1 COULMN =================================== 

--select 'CompanyCode|MainClass|SubClass|PolicyNumber|EndorsementNumber|InsuredSeq|CoverageCode|CoverageCode2|SumInsuredAmt|SumInsuredPerDay|SumInsuredPerTimes|PremiumPerCover|DeductibleAmt|DeductibleText|CoPayment|NumOfDays|TransactionStatus|ReferenceNumber' AS [rows]
--union all
--select res.[rows] from
--(select  CompanyCode + MainClass + SubClass + PolicyNumber + EndorsementNumber  + CAST(InsuredSeq AS VARCHAR(20)) + CoverageCode + CoverageCode2 + 
--	CAST(SumInsuredAmt AS VARCHAR(20))+ CAST(SumInsuredPerDay AS VARCHAR(20))+ CAST(SumInsuredPerTimes AS VARCHAR(20)) +
--	CAST(PremiumPerCover AS VARCHAR(20))+ CAST(DeductibleAmt AS VARCHAR(20))+ CAST(DeductibleText AS VARCHAR(20)) + CAST(CoPayment AS VARCHAR(20)) + CAST(NumOfDays AS VARCHAR(20)) + CAST(TransactionStatus AS VARCHAR(20)) + CAST(ReferenceNumber AS VARCHAR(20)) AS [rows]
--from #TMP_FINAL_RESULT
--order by  EndorsementNumber , PolicyNumber , InsuredSeq, CoverageCode) as res

    select
	*
	from
	(
	select --CompanyCode, MainClass, SubClass, PolicyNumber, EndorsementNumber, CoverageCode , InsuredSeq, CoverageCode2,
	(CompanyCode + MainClass + SubClass + PolicyNumber + EndorsementNumber  + CAST(InsuredSeq AS VARCHAR(20)) + CoverageCode + CoverageCode2 + 
		CAST(SumInsuredAmt AS VARCHAR(20))+ CAST(SumInsuredPerDay AS VARCHAR(20))+ CAST(SumInsuredPerTimes AS VARCHAR(20)) +
		CAST(PremiumPerCover AS VARCHAR(20))+ CAST(DeductibleAmt AS VARCHAR(20))+ CAST(DeductibleText AS VARCHAR(20)) + CAST(CoPayment AS VARCHAR(20)) + CAST(NumOfDays AS VARCHAR(20)) + CAST(TransactionStatus AS VARCHAR(20)) + CAST(ReferenceNumber AS VARCHAR(20))) AS [rows]
	from #TMP_FINAL_RESULT
	--where policynumber = '09844-15303/POL/313874-510|'
	--order by  EndorsementNumber , PolicyNumber , InsuredSeq, CoverageCode
	union
	select 'CompanyCode|MainClass|SubClass|PolicyNumber|EndorsementNumber|InsuredSeq|CoverageCode|CoverageCode2|SumInsuredAmt|SumInsuredPerDay|SumInsuredPerTimes|PremiumPerCover|DeductibleAmt|DeductibleText|CoPayment|NumOfDays|TransactionStatus|ReferenceNumber'
	) as a 
	order by a.[rows] DESC
	--where SubClass NOT IN ('579','569','564','564','562','561','539')
	--and PolicyNumber = '01247-15181/POL/000001-552|'
	

-- select * from #TMP_FINAL_RESULT
--=========================================================================
--select top 100 * from #tempEndorseCO
--select top 100 * from #TempResult

--select * from #TMP_FINAL_RESULT
--where PolicyNumber like '03654-17502%'

--========================= For Check : Duplicate =========================
		--select PolicyNumber, EndorsementNumber, CoverageCode, CoverageCode2 from #TMP_FINAL_RESULT
		--where PolicyNumber IN (select SubClass, PolicyNumber, EndorsementNumber, CoverageCode, CoverageCode2 from #TMP_FINAL_RESULT
		--						group by SubClass, PolicyNumber, EndorsementNumber, CoverageCode, CoverageCode2
		--						having COUNT(CoverageCode) > 1 and COUNT(CoverageCode2) > 1
		--						)
		--	--and PolicyNumber like '00570-18100%'
		--group by PolicyNumber, EndorsementNumber, CoverageCode, CoverageCode2
		--having  COUNT(PolicyNumber) > 1 and  COUNT(EndorsementNumber) > 1 and  COUNT(CoverageCode) > 1 and COUNT(CoverageCode2) > 1
--=========================================================================



--=====================================================================================
--SET STATISTICS IO, TIME OFF;
--=====================================================================================--

--SELECT * FROM #TMP_HIS_COVER_PA
--SELECT * FROM #TMP_POL_COVER_PA
--SELECT * FROM #tempPolicyCO
--Where pol_no = '000006'
--and pol_yr = 17
----and pol_br = '100'
--and pol_pre = '533'


--select * from #tempEndorseCO
--select * from #TempResult

 --		drop table #TMP_HIS_COVER_PA
 --		drop table #TMP_POL_COVER_PA
 --		drop table #tempPolicyCO
 --		drop table #tempEndorseCO
 --		drop table #TempCoverTA
 --		drop table #TempResult
 --		drop table #TempCoverPA
 --		drop table #TempCoverPAX
 --		drop table #TempEndorsementPA
 --		drop table #TempEndorsementPAX
 --		drop table #TMP_FINAL_RESULT
 --		drop table #TMP_ENDORSE_BEFORE
 --		drop table #tmp_tab_cover_insurance_oic
 -- January 2013 00:47 159 records




-- select top 10000 * from centerdb.dbo.subclass (nolock)

--where class_oic in ('06', '07', '11')
--and flag_group = 'G'
--and table_product <> 'product_mixpolicy'