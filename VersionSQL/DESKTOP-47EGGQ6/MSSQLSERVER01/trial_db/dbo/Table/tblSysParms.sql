/****** Object:  Table [dbo].[tblSysParms]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblSysParms](
	[SysParam_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SysParam_Scope] [varchar](30) NOT NULL,
	[SysParam_Category] [varchar](30) NOT NULL,
	[SysParam_LogicalName] [varchar](50) NOT NULL,
	[SysParam_PhysicalName] [nvarchar](100) NULL,
	[SysParam_Desc] [nvarchar](500) NULL,
	[SysParam_Editable] [char](1) NULL,
	[SysParam_DataType] [varchar](20) NULL,
	[SysParam_RangeFrom] [varchar](50) NULL,
	[SysParam_RangeTo] [varchar](50) NULL,
 CONSTRAINT [PK_tblSysParms] PRIMARY KEY CLUSTERED 
(
	[SysParam_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
