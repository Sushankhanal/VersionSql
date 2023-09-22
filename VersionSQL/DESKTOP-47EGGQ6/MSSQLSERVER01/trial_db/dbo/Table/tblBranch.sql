/****** Object:  Table [dbo].[tblBranch]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblBranch](
	[Branch_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Branch_Code] [nvarchar](50) NULL,
	[Branch_CompanyCode] [nvarchar](50) NULL,
	[Branch_Name] [nvarchar](50) NULL,
	[Branch_RegNo] [nvarchar](50) NULL,
	[Branch_Address1] [nvarchar](50) NULL,
	[Branch_Address2] [nvarchar](50) NULL,
	[Branch_City] [nvarchar](50) NULL,
	[Branch_Postcode] [nvarchar](50) NULL,
	[Branch_State] [int] NULL,
	[Branch_Status] [smallint] NULL,
	[Branch_CreatedBy] [nvarchar](50) NULL,
	[Branch_CreatedDate] [datetime] NULL,
	[Branch_ModifiedBy] [nvarchar](50) NULL,
	[Branch_ModifiedDate] [datetime] NULL,
	[Branch_Sync] [smallint] NOT NULL,
	[Branch_SyncDate] [datetime] NULL,
 CONSTRAINT [PK_tblBranch] PRIMARY KEY CLUSTERED 
(
	[Branch_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblBranch] ADD  CONSTRAINT [DF_tblBranch_Branch_Sync]  DEFAULT ((0)) FOR [Branch_Sync]
