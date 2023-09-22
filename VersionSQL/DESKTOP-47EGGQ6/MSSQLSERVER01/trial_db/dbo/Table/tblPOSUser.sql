/****** Object:  Table [dbo].[tblPOSUser]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPOSUser](
	[POSUser_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[POSUser_Code] [nvarchar](50) NULL,
	[POSUser_LoginID] [nvarchar](50) NULL,
	[POSUser_Password] [nvarchar](50) NULL,
	[POSUser_Status] [smallint] NULL,
	[POSUser_Name] [nvarchar](50) NULL,
	[POSUser_CreatedBy] [nvarchar](50) NULL,
	[POSUser_CreatedDate] [datetime] NULL,
	[POSUser_UserType] [smallint] NULL,
	[POSUser_CompanyCode] [nvarchar](50) NULL,
	[POSUser_Sync] [smallint] NOT NULL,
	[POSUser_SyncDate] [datetime] NULL,
	[POSUser_MinGiveOutDiscountRate] [money] NOT NULL,
	[POSUser_MinGiveOutDiscountAmt] [money] NOT NULL,
	[POSUser_UserGroupID] [bigint] NOT NULL,
 CONSTRAINT [PK_tblPOSUser] PRIMARY KEY CLUSTERED 
(
	[POSUser_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPOSUser] ADD  CONSTRAINT [DF_tblPOSUser_POSUser_Sync]  DEFAULT ((0)) FOR [POSUser_Sync]
ALTER TABLE [dbo].[tblPOSUser] ADD  CONSTRAINT [DF_tblPOSUser_POSUser_MinGiveOutDiscountRate_1]  DEFAULT ((-1)) FOR [POSUser_MinGiveOutDiscountRate]
ALTER TABLE [dbo].[tblPOSUser] ADD  CONSTRAINT [DF_tblPOSUser_POSUser_MinGiveOutDiscountAmt_1]  DEFAULT ((-1)) FOR [POSUser_MinGiveOutDiscountAmt]
ALTER TABLE [dbo].[tblPOSUser] ADD  CONSTRAINT [DF_tblPOSUser_POSUser_UserGroupID_1]  DEFAULT ((0)) FOR [POSUser_UserGroupID]
