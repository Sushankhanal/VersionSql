/****** Object:  Table [dbo].[tblCardCloud]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCardCloud](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Card_ID] [bigint] NULL,
	[Card_SerialNo] [nvarchar](50) NULL,
	[Card_Status] [smallint] NOT NULL,
	[Card_MobileUser] [nvarchar](50) NOT NULL,
	[Card_Balance] [money] NOT NULL,
	[Card_CreatedBy] [nvarchar](50) NULL,
	[Card_CreatedDate] [datetime] NULL,
	[Card_Point] [decimal](38, 10) NOT NULL,
	[Card_CompanyCode] [nvarchar](50) NULL,
	[Card_CardOwner_ID] [bigint] NULL,
	[Card_Sync] [smallint] NOT NULL,
	[Card_SyncDate] [datetime] NULL,
	[Card_Type] [smallint] NOT NULL,
	[tblCard_pin] [nvarchar](32) NOT NULL,
	[Card_Balance_Cashable_No] [money] NOT NULL,
	[Card_Balance_Cashable] [money] NOT NULL,
	[Card_PointAccumulate] [decimal](38, 10) NOT NULL,
	[Card_isPinReset] [smallint] NOT NULL,
	[Card_Point_Tier] [decimal](38, 10) NOT NULL,
	[Card_Point_Hidden] [decimal](38, 10) NOT NULL,
	[Card_isAbleToUpgrade] [smallint] NOT NULL,
	[Card_Level] [bigint] NOT NULL,
	[Card_last_up_gradetime] [datetime] NULL,
	[Card_tier_last_reset_time] [datetime] NULL,
	[Card_level_expired_time] [datetime] NULL,
	[Card_last_down_gradetime] [datetime] NULL,
	[Card_img] [nvarchar](max) NOT NULL,
	[Card_PrintDate] [datetime] NULL,
	[Card_Expiry_Cashable_No] [datetime] NULL,
	[Card_Expiry_Cashable] [datetime] NULL,
	[Card_balance_Edit_DateTime] [datetime] NULL,
	[Card_without_sync] [int] NOT NULL,
	[SiteId] [int] NULL,
 CONSTRAINT [PK_tblCardCloud] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_tblCardCloud] UNIQUE NONCLUSTERED 
(
	[Card_SerialNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
