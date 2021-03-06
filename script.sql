USE [vpp2]
GO
/****** Object:  StoredProcedure [dbo].[sp_deleteAllInfoProduct]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_deleteAllInfoProduct] @id int 
AS
BEGIN
	DELETE FROM Inventory WHERE IDProduct = @id
END


GO
/****** Object:  StoredProcedure [dbo].[sp_getAccount]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getAccount] @username varchar(50) , @password varchar(50) , @type int
AS
BEGIN
	SELECT * FROM Account WHERE Username = @username AND Password = @password AND Type_acc = @type 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getAllInfoInventory]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getAllInfoInventory]
AS
BEGIN 
	SELECT Product.ID , Name , NameCategory,  Quantity,PriceBuy, PriceBuy * Quantity as total
	FROM dbo.Product , dbo.Inventory , dbo.Category
	WHERE dbo.Product.ID = dbo.Inventory.IDProduct and Product.IDCategory = Category.ID and Status = 1
END
GO
/****** Object:  StoredProcedure [dbo].[sp_getAllInfoInventoryByText]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getAllInfoInventoryByText] @txt nvarchar(50)
AS
BEGIN 
	DECLARE @text NVarchar(50) = '%'+ @txt +'%'
	SELECT Product.ID , Name , NameCategory,  Quantity,PriceBuy, PriceBuy * Quantity as total
	FROM dbo.Product , dbo.Inventory , dbo.Category
	WHERE dbo.Product.ID = dbo.Inventory.IDProduct and Product.IDCategory = Category.ID AND ( CAST(dbo.Product.ID AS NVARCHAR(30)) LIKE @text OR dbo.Product.Name LIKE @text) and Status = 1
END
GO
/****** Object:  StoredProcedure [dbo].[sp_getAllInfoProduct]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getAllInfoProduct]
AS
BEGIN 
	SELECT Product.ID , Image , Name , Quantity , PriceBuy ,Price, NameCategory 
	FROM dbo.Product , dbo.Category , dbo.Inventory
	WHERE dbo.Product.IDCategory = dbo.Category.ID AND dbo.Product.ID = dbo.Inventory.IDProduct AND Status = 1
END
GO
/****** Object:  StoredProcedure [dbo].[sp_getAllInfoProductById]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getAllInfoProductById] @id int
AS
BEGIN 
	SELECT Product.ID , Image , Name , Quantity , PriceBuy ,Price, NameCategory 
	FROM dbo.Product , dbo.Category , dbo.Inventory
	WHERE dbo.Product.IDCategory = dbo.Category.ID AND dbo.Product.ID = dbo.Inventory.IDProduct AND dbo.Product.ID = @id AND Status =1
END
GO
/****** Object:  StoredProcedure [dbo].[sp_getAllInfoProductByIdOrName]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getAllInfoProductByIdOrName] @txt NVarchar(100)
AS
BEGIN 
	DECLARE @text NVarchar(100)= '%' + @txt + '%'
	SELECT Product.ID , Image , Name , Quantity , PriceBuy ,Price, NameCategory 
	FROM dbo.Product , dbo.Category , dbo.Inventory
	WHERE dbo.Product.IDCategory = dbo.Category.ID AND dbo.Product.ID = dbo.Inventory.IDProduct AND ( CAST(dbo.Product.ID AS NVARCHAR(30)) LIKE @text OR dbo.Product.Name LIKE @text) AND Status = 1
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getCategory]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getCategory]  
AS
BEGIN
	SELECT * FROM Category 
END


GO
/****** Object:  StoredProcedure [dbo].[sp_getProductInCategory]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getProductInCategory] @search nvarchar(50), @id int
AS
BEGIN 
	DECLARE @text NVarchar(100)= '%' + @search + '%'
	SELECT Product.ID , Image , Name , Quantity , PriceBuy ,Price, NameCategory 
	FROM dbo.Product , dbo.Category , dbo.Inventory
	WHERE dbo.Product.IDCategory = dbo.Category.ID AND dbo.Product.ID = dbo.Inventory.IDProduct AND ( CAST(dbo.Product.ID AS NVARCHAR(30)) LIKE @text OR dbo.Product.Name LIKE @text) AND Product.IDCategory = @id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getProfitByDate]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getProfitByDate] @datefrom datetime , @dateto datetime
AS
BEGIN 
	SELECT Bill.ID , Bill.CreatedDate , CONCAT(Account.FirstName , ' ' , Account.LastName) as name ,SUM(BillDetail.Amount) as total, - SUM(Inventory.PriceBuy * BillDetail.Quantity) + SUM(BillDetail.Amount) as profit
	FROM Bill , BillDetail , Account , Inventory
	WHERE Bill.ID = BillDetail.IDBill AND Account.ID = Bill.IDCashier AND Inventory.IDProduct = BillDetail.IDProduct AND Bill.CreatedDate >= @datefrom AND Bill.CreatedDate < @dateto
	GROUP BY Bill.ID , Bill.CreatedDate , Account.FirstName ,Account.LastName
END
GO
/****** Object:  StoredProcedure [dbo].[sp_getProfitByProduct]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getProfitByProduct] @datefrom datetime , @dateto datetime
AS
BEGIN 
	SELECT Product.ID , Product.Name , SUM(BillDetail.Quantity) as Quantity, Inventory.PriceBuy , Product.Price , SUM(BillDetail.Amount) as total , SUM(Price * BillDetail.Quantity) - SUM(BillDetail.Amount) as promotionPrice, SUM(BillDetail.Amount) - SUM(Inventory.PriceBuy*BillDetail.Quantity) as profit
	FROM Product, BillDetail , Inventory , Bill
	WHERE Product.ID = Inventory.IDProduct AND Inventory.IDProduct = BillDetail.IDProduct AND Bill.ID = BillDetail.IDBill AND Bill.CreatedDate >= @datefrom AND Bill.CreatedDate < @dateto
	GROUP BY Product.ID , Product.Name , Inventory.PriceBuy , Product.Price 
END
GO
/****** Object:  StoredProcedure [dbo].[sp_getRevenueByDate]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_getRevenueByDate] @datefrom DateTime , @dateto DateTime
AS
BEGIN
	SELECT Product.ID , Product.Name , Bill.CreatedDate , CONCAT(UserInfo.FirstName , ' ' ,UserInfo.LastName) as NameUser , BillDetail.Quantity ,Product.PromotionPrice , BillDetail.Amount FROM Account , Bill , BillDetail ,Product ,UserInfo WHERE Account.ID = Bill.IDCashier AND UserInfo.UserID = BillDetail.UserID AND Product.ID = BillDetail.IDProduct AND Bill.ID = BillDetail.IDBill AND Bill.Status = 1 AND (Bill.CreatedDate >= @datefrom AND Bill.CreatedDate <= @dateto)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertAllInfoProduct]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_InsertAllInfoProduct] @image image , @name nvarchar(100) , @quan int , @priceBuy int , @price int , @idCate int
AS
BEGIN
	INSERT INTO Product(IDCategory , Name , Image , Price , CreatedBy) VALUES(@idCate , @name , @image , @price , 'Tandz');
	DECLARE @id int = (SELECT MAX(ID) FROM Product);
	INSERT INTO Inventory(IDProduct , IDCategory , Quantity,PriceBuy) VALUES(@id ,@idCate,@quan,@priceBuy)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_updateProduct]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_updateProduct] @id int, @image image, @name nvarchar(100), @qua int, @prBuy int, @pr int, @idCa int 
AS
BEGIN 
	UPDATE Inventory SET IDCategory = @idCa , Quantity = @qua , PriceBuy = @prBuy WHERE IDProduct = @id;
	UPDATE Product SET IDCategory = @idCa , Image = @image , Name = @name , Price = @pr WHERE ID = @id;
END

GO
/****** Object:  UserDefinedFunction [dbo].[func_getMonthlyRevenue]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[func_getMonthlyRevenue] ( @datefrom DateTime , @dateto DateTime)
returns int
BEGIN
	DECLARE @sum int 
	SELECT @sum = SUM(BillDetail.Amount) FROM Bill , BillDetail WHERE Bill.ID = BillDetail.IDBill AND Bill.Status = 1 AND (Bill.CreatedDate >= @datefrom AND Bill.CreatedDate <= @dateto) 
	return @sum
END
GO
/****** Object:  Table [dbo].[Account]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Account](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[LastName] [nvarchar](255) NOT NULL,
	[Phone] [varchar](30) NOT NULL,
	[Image] [image] NULL,
	[Type_acc] [int] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Bill]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bill](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDCashier] [int] NULL,
	[Status] [bit] NULL DEFAULT ((1)),
	[CreatedDate] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BillDetail]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDBill] [int] NULL,
	[IDProduct] [int] NULL,
	[UserID] [int] NULL,
	[IDCashier] [int] NULL,
	[FirstNameCashier] [nvarchar](255) NOT NULL,
	[LastNameCashier] [nvarchar](255) NOT NULL,
	[Status] [bit] NULL DEFAULT ((0)),
	[Amount] [decimal](18, 0) NOT NULL,
	[Description] [ntext] NULL,
	[Quantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Category]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NameCategory] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Inventory]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Inventory](
	[IDProduct] [int] NOT NULL,
	[IDCategory] [int] NOT NULL,
	[Quantity] [int] NULL DEFAULT ((0)),
	[PriceBuy] [real] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IDProduct] ASC,
	[IDCategory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Product]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDCategory] [int] NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [ntext] NULL,
	[Image] [image] NULL,
	[Price] [decimal](18, 0) NOT NULL,
	[PromotionPrice] [decimal](18, 0) NULL DEFAULT ((0)),
	[CreatedDate] [datetime] NULL DEFAULT (getdate()),
	[CreatedBy] [nvarchar](255) NOT NULL DEFAULT (N'TanLe'),
	[Status] [bit] NULL DEFAULT ((1)),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserInfo]    Script Date: 06/12/2020 9:51:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserInfo](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[LastName] [nvarchar](255) NOT NULL,
	[Address] [nvarchar](255) NOT NULL,
	[Email] [nvarchar](255) NOT NULL,
	[Phone] [varchar](30) NOT NULL,
	[Image] [image] NULL,
	[Point] [int] NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[Account] ON 

INSERT [dbo].[Account] ([ID], [Username], [Password], [FirstName], [LastName], [Phone], [Image], [Type_acc]) VALUES (1, N'hai', N'123', N'HAI', N'THACH', N'12345', NULL, 1)
INSERT [dbo].[Account] ([ID], [Username], [Password], [FirstName], [LastName], [Phone], [Image], [Type_acc]) VALUES (2, N'thu', N'123', N'THU', N'NGUYEN', N'12345', NULL, 1)
INSERT [dbo].[Account] ([ID], [Username], [Password], [FirstName], [LastName], [Phone], [Image], [Type_acc]) VALUES (3, N'abc', N'123', N'TAN', N'NGUYEN', N'12345', NULL, 0)
INSERT [dbo].[Account] ([ID], [Username], [Password], [FirstName], [LastName], [Phone], [Image], [Type_acc]) VALUES (4, N'tan', N'123', N'TAN', N'LE', N'12345', NULL, 1)
INSERT [dbo].[Account] ([ID], [Username], [Password], [FirstName], [LastName], [Phone], [Image], [Type_acc]) VALUES (7, N'bde', N'123', N'abc', N'abc', N'12345', NULL, 0)
SET IDENTITY_INSERT [dbo].[Account] OFF
SET IDENTITY_INSERT [dbo].[Bill] ON 

INSERT [dbo].[Bill] ([ID], [IDCashier], [Status], [CreatedDate]) VALUES (1, 1, 1, CAST(N'2020-11-18 14:07:58.163' AS DateTime))
INSERT [dbo].[Bill] ([ID], [IDCashier], [Status], [CreatedDate]) VALUES (2, 2, 1, CAST(N'2020-11-18 14:08:12.410' AS DateTime))
INSERT [dbo].[Bill] ([ID], [IDCashier], [Status], [CreatedDate]) VALUES (3, 3, 0, CAST(N'2020-11-18 14:08:41.830' AS DateTime))
INSERT [dbo].[Bill] ([ID], [IDCashier], [Status], [CreatedDate]) VALUES (4, 4, 0, CAST(N'2020-11-18 14:09:15.380' AS DateTime))
SET IDENTITY_INSERT [dbo].[Bill] OFF
SET IDENTITY_INSERT [dbo].[BillDetail] ON 

INSERT [dbo].[BillDetail] ([ID], [IDBill], [IDProduct], [UserID], [IDCashier], [FirstNameCashier], [LastNameCashier], [Status], [Amount], [Description], [Quantity]) VALUES (1, 1, 4, 1, 1, N'hai', N'thach', 1, CAST(50000 AS Decimal(18, 0)), NULL, 2)
INSERT [dbo].[BillDetail] ([ID], [IDBill], [IDProduct], [UserID], [IDCashier], [FirstNameCashier], [LastNameCashier], [Status], [Amount], [Description], [Quantity]) VALUES (5, 2, 2, 3, 2, N'thu', N'nguyen', 1, CAST(80000 AS Decimal(18, 0)), NULL, 4)
SET IDENTITY_INSERT [dbo].[BillDetail] OFF
SET IDENTITY_INSERT [dbo].[Category] ON 

INSERT [dbo].[Category] ([ID], [NameCategory]) VALUES (1, N'Sách')
INSERT [dbo].[Category] ([ID], [NameCategory]) VALUES (2, N'Vở')
INSERT [dbo].[Category] ([ID], [NameCategory]) VALUES (3, N'Truyện')
INSERT [dbo].[Category] ([ID], [NameCategory]) VALUES (4, N'Thước')
INSERT [dbo].[Category] ([ID], [NameCategory]) VALUES (5, N'Bút')
INSERT [dbo].[Category] ([ID], [NameCategory]) VALUES (6, N'Khác')
SET IDENTITY_INSERT [dbo].[Category] OFF
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (2, 1, 75, 15000)
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (3, 1, 80, 17000)
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (4, 1, 75, 20000)
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (5, 2, 60, 3000)
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (6, 2, 65, 6000)
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (7, 2, 68, 7000)
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (8, 3, 58, 22000)
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (9, 3, 70, 20000)
INSERT [dbo].[Inventory] ([IDProduct], [IDCategory], [Quantity], [PriceBuy]) VALUES (11, 3, 78, 20000)
SET IDENTITY_INSERT [dbo].[Product] ON 

INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (2, 1, N'Sách Giáo Khoa Lớp 10', NULL, NULL, CAST(20000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 13:50:53.203' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (3, 1, N'Sách Giáo Khoa Lớp 11', NULL, NULL, CAST(22000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 13:52:17.817' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (4, 1, N'Sách Giáo Khoa Lớp 12', NULL, NULL, CAST(25000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 13:53:01.137' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (5, 2, N'Vở 99 Trang', NULL, NULL, CAST(4000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 13:53:38.203' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (6, 2, N'Vở 150 Trang', NULL, NULL, CAST(7000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 13:54:14.803' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (7, 2, N'Vở 200 Trang ', NULL, NULL, CAST(8000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 13:54:46.850' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (8, 3, N'Truyện Conan', NULL, NULL, CAST(28000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 13:55:56.623' AS DateTime), N'thu', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (9, 3, N'Truyện Doraemon', NULL, NULL, CAST(25000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 13:59:56.183' AS DateTime), N'thu', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (11, 3, N'Truyện 7 Viên Ngọc Rồng', NULL, NULL, CAST(25000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:00:34.843' AS DateTime), N'thu', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (13, 4, N'Thước E ke', NULL, NULL, CAST(5000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:32:29.130' AS DateTime), N'tan', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (14, 4, N'Thước Đo Độ', NULL, NULL, CAST(5000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:33:35.567' AS DateTime), N'tan', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (15, 4, N'Thước Kẻ', NULL, NULL, CAST(5000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:33:53.650' AS DateTime), N'tan', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (18, 5, N'Bút Bi Xanh', NULL, NULL, CAST(5000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:34:37.413' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (19, 5, N'Bút Bi Đỏ', NULL, NULL, CAST(5000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:34:55.813' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (20, 5, N'Bút Chì', NULL, NULL, CAST(5000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:35:11.663' AS DateTime), N'hai', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (21, 6, N'Nhãn Dán', NULL, NULL, CAST(3000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:35:33.850' AS DateTime), N'thu', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (22, 6, N'Cục Tẩy', NULL, NULL, CAST(3000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:35:59.973' AS DateTime), N'thu', 1)
INSERT [dbo].[Product] ([ID], [IDCategory], [Name], [Description], [Image], [Price], [PromotionPrice], [CreatedDate], [CreatedBy], [Status]) VALUES (23, 6, N'Bao Vở', NULL, NULL, CAST(2000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(N'2020-11-18 14:37:15.267' AS DateTime), N'thu', 1)
SET IDENTITY_INSERT [dbo].[Product] OFF
SET IDENTITY_INSERT [dbo].[UserInfo] ON 

INSERT [dbo].[UserInfo] ([UserID], [FirstName], [LastName], [Address], [Email], [Phone], [Image], [Point]) VALUES (1, N'user1', N'123', N'Thủ Đức', N'user1@gmail.com', N'123456', NULL, 0)
INSERT [dbo].[UserInfo] ([UserID], [FirstName], [LastName], [Address], [Email], [Phone], [Image], [Point]) VALUES (3, N'user2', N'123', N'Bình Thạnh', N'user2@gmail.com', N'123456', NULL, 0)
INSERT [dbo].[UserInfo] ([UserID], [FirstName], [LastName], [Address], [Email], [Phone], [Image], [Point]) VALUES (4, N'user3', N'123', N'Gò Vấp', N'user3@gmail.com', N'1234546', NULL, 0)
INSERT [dbo].[UserInfo] ([UserID], [FirstName], [LastName], [Address], [Email], [Phone], [Image], [Point]) VALUES (5, N'user4', N'123', N'Quận 9', N'user4@gmail.com', N'123456', NULL, 0)
SET IDENTITY_INSERT [dbo].[UserInfo] OFF
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__Account__536C85E49F9E0095]    Script Date: 06/12/2020 9:51:17 SA ******/
ALTER TABLE [dbo].[Account] ADD UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD FOREIGN KEY([IDCashier])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD FOREIGN KEY([IDBill])
REFERENCES [dbo].[Bill] ([ID])
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD FOREIGN KEY([IDCashier])
REFERENCES [dbo].[Account] ([ID])
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD FOREIGN KEY([IDProduct])
REFERENCES [dbo].[Product] ([ID])
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[UserInfo] ([UserID])
GO
ALTER TABLE [dbo].[Inventory]  WITH CHECK ADD FOREIGN KEY([IDCategory])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[Inventory]  WITH CHECK ADD FOREIGN KEY([IDProduct])
REFERENCES [dbo].[Product] ([ID])
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD FOREIGN KEY([IDCategory])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD CHECK  (([Type_acc]>=(0)))
GO
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD CHECK  (([ID]>(0)))
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD CHECK  (([Amount]>(0)))
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD CHECK  (([ID]>(0)))
GO
ALTER TABLE [dbo].[Category]  WITH CHECK ADD CHECK  (([ID]>(0)))
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD CHECK  (([ID]>(0)))
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD CHECK  (([Price]>(0)))
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD CHECK  (([PromotionPrice]>=(0)))
GO
ALTER TABLE [dbo].[UserInfo]  WITH CHECK ADD CHECK  (([UserID]>(0)))
GO
