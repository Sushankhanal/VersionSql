/****** Object:  Table [dbo].[tblCounterTrans]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCounterTrans](
	[CounterTrans_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CounterTrans_UserCode] [nvarchar](50) NULL,
	[CounterTrans_CounterCode] [nvarchar](50) NULL,
	[CounterTrans_OpenCash] [money] NULL,
	[CounterTrans_SettlementCash] [money] NULL,
	[CounterTrans_TransDate] [datetime] NULL,
	[CounterTrans_ModifiedBy] [nvarchar](50) NULL,
	[CounterTrans_ModifiedDate] [datetime] NULL,
	[CounterTrans_IsSettlement] [int] NOT NULL,
	[CounterTrans_SettleBy] [nvarchar](50) NULL,
	[CounterTrans_SettleDate] [datetime] NULL,
	[CounterTrans_SettleCode] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblCounterTrans] PRIMARY KEY CLUSTERED 
(
	[CounterTrans_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblCounterTrans] ADD  CONSTRAINT [DF_tblCounterTrans_CounterTrans_IsSettlement]  DEFAULT ((0)) FOR [CounterTrans_IsSettlement]
